import 'dart:async';
import 'dart:io';

import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:church_analytics/ui/screens/log_viewer_screen.dart';
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
  bool _navigationInProgress = false;

  @override
  void initState() {
    super.initState();
    _routeFromState();
    // After first frame: check for crash recovery.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (_navigationInProgress) return;
      await showCrashRecoveryDialogIfNeeded(context);
    });
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
        _navigationInProgress = true;
        Navigator.of(context).pushReplacementNamed('/select-church');
        return;
      }

      final currentChurchId = churchService.getCurrentChurchId();
      if (currentChurchId == null) {
        await churchService.clearCurrentChurch();
        await profileService.clearCurrentProfile();
        if (!mounted) return;
        _navigationInProgress = true;
        Navigator.of(context).pushReplacementNamed('/select-church');
        return;
      }

      final currentChurchExists = churches.any((c) => c.id == currentChurchId);
      if (!currentChurchExists) {
        await churchService.clearCurrentChurch();
        await profileService.clearCurrentProfile();
        if (!mounted) return;
        _navigationInProgress = true;
        Navigator.of(context).pushReplacementNamed('/select-church');
        return;
      }

      final churchId = currentChurchId;

      // Admin profile must exist, be active, and belong to the selected church.
      final currentProfileId = profileService.getCurrentProfileId();
      if (currentProfileId == null) {
        if (!mounted) return;
        _navigationInProgress = true;
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
        _navigationInProgress = true;
        Navigator.of(
          context,
        ).pushReplacementNamed('/select-profile', arguments: churchId);
        return;
      }

      // FEAT-004: belt-and-suspenders APK cleanup on every successful startup.
      // Runs fire-and-forget so it never delays routing.
      unawaited(_cleanUpStaleApks());

      if (!mounted) return;
      _navigationInProgress = true;
      Navigator.of(
        context,
      ).pushReplacementNamed('/dashboard', arguments: churchId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
      });
    }
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

    for (final dir in dirsToScan) {
      try {
        for (final entity in dir.listSync()) {
          if (entity is File && entity.path.endsWith('.apk')) {
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
                    _routeFromState();
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
