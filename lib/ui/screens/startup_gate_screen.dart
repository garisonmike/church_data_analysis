import 'dart:async';
import 'dart:io';

import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:church_analytics/platform/platform_installer_launch_service.dart';
import 'package:church_analytics/services/download_foreground_service.dart'; // FEAT-008
import 'package:church_analytics/services/download_state_service.dart'; // FEAT-007
import 'package:church_analytics/models/update_error_type.dart'; // FEAT-007
import 'package:church_analytics/ui/screens/log_viewer_screen.dart';
import 'package:church_analytics/ui/widgets/installer_confirmation_dialog.dart'; // FEAT-007
import 'package:church_analytics/ui/widgets/update_download_progress_dialog.dart'; // FEAT-007
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Startup gate that enforces required context (church + admin profile)
/// before allowing the user into the dashboard.
class StartupGateScreen extends ConsumerStatefulWidget {
  const StartupGateScreen({super.key});

  @override
  ConsumerState<StartupGateScreen> createState() => _StartupGateScreenState();
}

class _StartupGateScreenState extends ConsumerState<StartupGateScreen> {
  Object? _error;

  // BUG-001 fix: _navigationInProgress has been removed.
  //
  // The old flag was set to true inside _routeFromState() on every navigation
  // path but never reset. The postFrameCallback for crash recovery checked it
  // and returned early, so crash recovery was permanently suppressed after the
  // very first call — even on hot-restart, OS resume, or a retry from the
  // error UI.
  //
  // Fix: addPostFrameCallback is registered once in initState and runs a
  // single sequential async chain (_startup). Crash recovery always runs
  // before _routeFromState, with a mounted check between them. The flag is no
  // longer needed because the callback is only ever registered once.

  @override
  void initState() {
    super.initState();
    // Registered exactly once — no re-entrancy is possible, so no flag needed.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startup());
  }

  /// Single sequential startup chain.
  ///
  /// Step 1 — crash recovery dialog (must run before routing so the user sees
  /// it on a blank screen rather than over the dashboard).
  /// Step 2 — route to the correct initial screen.
  ///
  /// Each await boundary is followed by a mounted check so that widget
  /// disposal mid-flight is handled safely.
  Future<void> _startup() async {
    if (!mounted) return;
    await showCrashRecoveryDialogIfNeeded(context);
    if (!mounted) return;
    await _routeFromState();
  }

  Future<void> _routeFromState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final db = ref.read(databaseProvider);
      final churchRepo = ChurchRepository(db);
      final adminRepo = AdminUserRepository(db);

      final churchService = ChurchService(churchRepo, prefs);
      final profileService = AdminProfileService(adminRepo, prefs);

      final churches = await churchRepo.getAllChurches();
      if (churches.isEmpty) {
        await churchService.clearCurrentChurch();
        await profileService.clearCurrentProfile();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/select-church');
        return;
      }

      final currentChurchId = churchService.getCurrentChurchId();
      if (currentChurchId == null) {
        await churchService.clearCurrentChurch();
        await profileService.clearCurrentProfile();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/select-church');
        return;
      }

      final currentChurchExists = churches.any((c) => c.id == currentChurchId);
      if (!currentChurchExists) {
        await churchService.clearCurrentChurch();
        await profileService.clearCurrentProfile();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/select-church');
        return;
      }

      final churchId = currentChurchId;

      // Admin profile must exist, be active, and belong to the selected church.
      final currentProfileId = profileService.getCurrentProfileId();
      if (currentProfileId == null) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacementNamed('/select-profile', arguments: churchId);
        return;
      }

      final currentProfile = await adminRepo.getUserById(currentProfileId);
      final validProfile =
          currentProfile != null &&
          currentProfile.isActive &&
          currentProfile.churchId == churchId;

      if (!validProfile) {
        await profileService.clearCurrentProfile();
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacementNamed('/select-profile', arguments: churchId);
        return;
      }

      // FEAT-007: Check for a download interrupted by a crash or unexpected
      // app closure.  Must run BEFORE _cleanUpStaleApks so that the partial
      // file is not deleted before the user has a chance to resume it.
      await _checkInterruptedDownload();

      // FEAT-004: belt-and-suspenders APK cleanup on every successful startup.
      // Runs fire-and-forget so it never delays routing.
      // FEAT-007: _cleanUpStaleApks skips the tracked partial file if any.
      unawaited(_cleanUpStaleApks());

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacementNamed('/dashboard', arguments: churchId);

      // FEAT-018: Fire a background update check on cold launch.
      //
      // Runs fire-and-forget immediately after the dashboard route is pushed.
      // The provider handles both the 24-hour cooldown gate and the
      // connectivity pre-check internally, so this call is always safe to
      // make unconditionally here.
      //
      // The provider is invalidated before reading so that it re-evaluates
      // on every cold launch rather than returning a cached value from a
      // previous session.  Without invalidation, a FutureProvider that
      // completed in a prior session would return its cached result
      // immediately and skip the cooldown/connectivity logic entirely.
      ref.invalidate(backgroundUpdateCheckProvider);
      unawaited(ref.read(backgroundUpdateCheckProvider.future));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
      });
    }
  }

  // -------------------------------------------------------------------------
  // FEAT-007: Interrupted download recovery
  // -------------------------------------------------------------------------

  /// Checks [SharedPreferences] for a download that was interrupted by a
  /// crash, OS kill, or unexpected power loss and offers the user a choice to
  /// resume or discard it.
  ///
  /// ## Flow
  /// 1. Read the [DownloadStateRecord] via [DownloadStateService.read].
  /// 2. If no record → return immediately (common case, no delay).
  /// 3. Verify the partial file still exists on disk.
  ///    - Missing → clear the stale record silently and return.
  /// 4. Show an [AlertDialog] with **Resume** and **Discard** options.
  /// 5. Discard → delete the partial file, clear the record, return.
  /// 6. Resume → show [UpdateDownloadProgressDialog], call
  ///    [UpdateDownloadService.resumeFile], handle the result:
  ///    - **success** → show [InstallerConfirmationDialog]; if confirmed,
  ///      launch the installer via [PlatformInstallerLaunchService].
  ///    - **paused** → record is kept; the user will be asked again on the
  ///      next launch.
  ///    - **cancelled** → record is kept; the user chose to stop mid-resume.
  ///    - **error** → show a SnackBar, clear the record and partial file so
  ///      the user can start fresh from Settings → Updates.
  ///
  /// This method is always awaited in [_routeFromState] so that navigation to
  /// the dashboard does not begin until the user has made a choice.  In the
  /// common case (no interrupted download) it returns immediately after one
  /// [SharedPreferences] read.
  Future<void> _checkInterruptedDownload() async {
    final record = await DownloadStateService.read();
    if (record == null) return; // common path — no interrupted download

    final partialFile = File(record.destPath);

    // Partial file was cleaned up by the OS (e.g. temp directory flush).
    // Silently discard the stale record and continue.
    if (!await partialFile.exists()) {
      await DownloadStateService.clear();
      return;
    }

    if (!mounted) return;

    // -----------------------------------------------------------------------
    // Ask the user: Resume or Discard?
    // -----------------------------------------------------------------------
    final shouldResume = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        key: const ValueKey('interrupted_download_dialog'),
        title: const Text('Download Interrupted'),
        content: const Text(
          'An update download was interrupted before it could complete. '
          'Would you like to resume it, or discard the partial file?',
        ),
        actions: [
          TextButton(
            key: const ValueKey('interrupted_download_discard'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Discard'),
          ),
          FilledButton(
            key: const ValueKey('interrupted_download_resume'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Resume'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (shouldResume != true) {
      // User chose Discard — delete the partial file and clear the record.
      await DownloadStateService.clear();
      try {
        await partialFile.delete();
      } catch (_) {}
      return;
    }

    // -----------------------------------------------------------------------
    // Resume: stream the remaining bytes with a progress dialog.
    // -----------------------------------------------------------------------
    final cancelToken = CancelToken();
    final pauseToken = PauseToken();
    // Seed the progress bar with the already-downloaded fraction so it does not
    // jump from 0% to the current offset on the first chunk.  Since we don't
    // have the total size here without a HEAD request, start with a small
    // non-zero value (5%) to show the bar isn't empty.  The download service
    // will report accurate fractions once the 206 Content-Length is known.
    double seedValue = 0.0;
    try {
      final existingBytes = await partialFile.length();
      if (existingBytes > 0) seedValue = 0.05; // approximate non-zero seed
    } catch (_) {}
    // Guard: partialFile.length() is async — widget may have been disposed.
    if (!mounted) return;

    final progressNotifier = ValueNotifier<double>(seedValue);
    var dialogShown = false;
    var dialogPopped = false;

    void popDialog() {
      if (dialogShown && !dialogPopped && mounted) {
        dialogPopped = true;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    // FEAT-008: initialise and start the foreground service BEFORE showing the
    // progress dialog so that any start failure is caught by the try/finally
    // below — which stops the service and disposes the notifier — rather than
    // leaving the modal stuck open or leaking resources.
    // init() is idempotent — safe to call here even if AboutUpdatesCard has
    // already called it in a prior session.
    DownloadForegroundService.init();

    late UpdateDownloadResult result;
    try {
      await DownloadForegroundService.start(cancelToken: cancelToken);
      // start() is async — re-check mounted before touching context.
      if (!mounted) return;

      // Show the progress dialog only after the service has started
      // successfully.  Fire-and-forget: dismissed imperatively via popDialog().
      dialogShown = true;
      // ignore: unawaited_futures
      UpdateDownloadProgressDialog.show(
        context,
        progress: progressNotifier,
        filename: record.destPath.split('/').last,
        onCancel: () {
          cancelToken.cancel();
          popDialog();
        },
        onPause: () => pauseToken.pause(),
      );

      final service = UpdateDownloadService();
      result = await service.resumeFile(
        downloadUrl: record.url,
        partialFilePath: record.destPath,
        expectedSha256: record.sha256,
        onProgress: (p) {
          progressNotifier.value = p;
          // Mirror progress to the foreground service notification (throttled
          // internally by DownloadForegroundService).
          DownloadForegroundService.updateProgress(p);
        },
        cancelToken: cancelToken,
        pauseToken: pauseToken,
      );
    } on ForegroundServiceStartException {
      // The foreground service failed to start (e.g. not initialised, Android
      // timeout).  This is not a fatal startup error — the user can still use
      // the app normally.
      //
      // Clear the interrupted-download record so this prompt does not recur on
      // future launches.  AboutUpdatesCard does not read DownloadStateService,
      // so the record cannot be resumed from Settings → Updates; leaving it
      // would re-prompt the user on every launch until it was manually cleared.
      // The partial file is left on disk — the OS will eventually reclaim it.
      await DownloadStateService.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not resume the interrupted download. '
              'Start a fresh download from Settings → Updates.',
            ),
            duration: Duration(seconds: 6),
          ),
        );
      }
      return;
    } finally {
      // FEAT-008: always stop the foreground service, whatever the outcome
      // (success, cancel, error, start failure, or unexpected exception).
      await DownloadForegroundService.stop();
      popDialog();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => progressNotifier.dispose(),
      );
    }

    if (!mounted) return;

    // -----------------------------------------------------------------------
    // Handle the result.
    // -----------------------------------------------------------------------
    if (result.isSuccess) {
      // Download is now complete — ask the user to confirm before installing.
      final confirmed = await InstallerConfirmationDialog.show(context);
      if (!mounted || confirmed != true) return;

      final launchResult =
          await PlatformInstallerLaunchService().launch(result.filePath!);

      // On Android the app exits via SystemNavigator.pop() inside launch().
      // On other platforms, surface any install error as a SnackBar.
      if (mounted && !launchResult.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(launchResult.error ?? 'Install failed.')),
        );
      }
    } else if (result.isPaused || result.isCancelledResumable) {
      // User paused or cancelled mid-resume — DownloadStateService record was
      // kept.  They will be prompted again on the next launch.
    } else if (result.errorType != UpdateErrorType.downloadCancelled) {
      // Error (record and file already cleaned up inside resumeFile).
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not resume the download. '
            'You can download the update again from Settings → Updates.',
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    }
    // Cancelled: record and partial file kept — user can resume on next launch.
  }

  /// FEAT-004: Deletes any leftover `.apk` files from the directories where
  /// the download service may have saved them.
  ///
  /// On Android the download can land in either the app's external-storage
  /// directory (preferred) or the system temp directory (fallback), so both
  /// are scanned.  On all other platforms only the temp directory is scanned.
  ///
  /// Catches all errors silently — this is purely best-effort hygiene and
  /// must never surface to the user or block startup.
  Future<void> _cleanUpStaleApks() async {
    final dirsToScan = <Directory>[];

    try {
      // External storage (Android only) — matches _resolveDownloadDirectory
      // in about_updates_card.dart.
      if (!kIsWeb && Platform.isAndroid) {
        try {
          final external = await getExternalStorageDirectory();
          if (external != null) dirsToScan.add(external);
        } catch (_) {
          // External storage unavailable — fall through to temp-only scan.
        }
      }
      // System temp directory (all platforms / Android fallback).
      dirsToScan.add(await getTemporaryDirectory());
    } catch (_) {
      // If we can't resolve any directory, do nothing.
      return;
    }

    // FEAT-007: read the tracked partial file path (if any) and skip it
    // during cleanup — the user may want to resume it on this launch.
    final trackedRecord = await DownloadStateService.read();
    final trackedPath = trackedRecord?.destPath;

    for (final dir in dirsToScan) {
      try {
        for (final entity in dir.listSync()) {
          if (entity is File && entity.path.endsWith('.apk')) {
            // FEAT-007: never delete the partial file we intend to resume.
            if (trackedPath != null && entity.path == trackedPath) continue;
            try {
              await entity.delete();
            } catch (_) {
              // Individual file deletion failure — skip and continue.
            }
          }
        }
      } catch (_) {
        // If we can't read a directory, skip it silently.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Startup')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Unable to start the app.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(_error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _error = null);
                    _startup();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}
