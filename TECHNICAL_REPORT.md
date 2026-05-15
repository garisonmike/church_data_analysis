# Technical Report — Church Analytics: Feature Work & Bug Fixes

**Date:** May 2026  
**Scope:** Navigation bug, log export bug, update system improvements, tutorial opt-in, data management (view full imported data list, delete data), analytics graphs, PDF export, app icon & name documentation, Excel import & template download  
**Codebase Version:** As at commit `HEAD` on 2026-05-12  
**Author:** garisonmike  
**Report Version:** 3.1 (supersedes v3.0 — FEAT-008 architecture revised)

---

## How to Use This Report

Each item is self-contained. It documents: what the current code does, what specific files are involved, what the proposed change is, whether there are risks, and what needs to be tested. No item here deletes an existing file or restructures an existing feature. Everything is additive or a surgical single-point fix.

Items are classified as **BUG** (something broken) or **FEAT** (new behaviour requested). They are ordered from lowest to highest implementation complexity within each class.

---

## Table of Contents

- [BUG-001 — Back button from Dashboard leads to stuck loading screen](#bug-001)
- [BUG-002 — Log export fails on Android ("Could not determine save location")](#bug-002)
- [FEAT-001 — Tutorial: ask user before showing onboarding](#feat-001)
- [FEAT-002 — Update: request install-unknown-apps permission proactively](#feat-002)
- [FEAT-003 — Update: prompt user to back up before updating](#feat-003)
- [FEAT-004 — Update: auto-delete installer file after successful update](#feat-004)
- [FEAT-005 — Update: handle already-downloaded package on retry](#feat-005)
- [FEAT-006 — Update: pause and resume download](#feat-006)
- [FEAT-007 — Update: resume download after unexpected app closure](#feat-007)
- [FEAT-008 — Update: continue downloading while app is in background (Android)](#feat-008)
- [FEAT-009 — Platform feature parity audit](#feat-009)
- [FEAT-010 — Baptism & Holy Communion graphs](#feat-010)
- [FEAT-011 — PDF export completeness](#feat-011)
- [FEAT-012 — App icon customisation documentation](#feat-012)
- [FEAT-013 — App name documentation for forks](#feat-013)
- [FEAT-014 — Home screen: view full list of imported data](#feat-014)
- [FEAT-015 — Data management: delete imported records](#feat-015)
- [FEAT-016 — Excel (.xlsx) import support](#feat-016)
- [FEAT-017 — Downloadable import template](#feat-017)
- [Testing Checklist](#testing-checklist)
- [Risk Summary](#risk-summary)

---

<a name="bug-001"></a>
## BUG-001 — Back button from Dashboard leads to stuck loading screen

**Status:** Complete (2026-05-12)

### Severity
Medium. Reproducible when specific timing conditions are met. Confusing but non-destructive.

### Observed Behaviour
From the `DashboardScreen`, pressing the AppBar back arrow navigates to a screen showing only a spinning progress indicator that never resolves. The user is stuck and must kill and reopen the app.

### Root Cause Analysis

**Two independent problems compound to produce this bug.**

**Problem A — Race condition in `StartupGateScreen.initState()`.**

`lib/ui/screens/startup_gate_screen.dart`, `initState()` schedules two concurrent async operations at startup:

```dart
@override
void initState() {
  super.initState();
  _routeFromState();                              // (1) async, starts immediately
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!mounted) return;
    await showCrashRecoveryDialogIfNeeded(context); // (2) async, fires after first frame
    if (!mounted) return;
    final done = await isOnboardingComplete();
    if (!done && mounted) {
      await Navigator.of(context).push(           // (3) pushes OnboardingOverlay
        MaterialPageRoute(builder: (_) => const OnboardingOverlay()),
      );
    }
  });
}
```

`_routeFromState()` awaits `SharedPreferences.getInstance()` and multiple database calls before it calls `pushReplacementNamed('/dashboard')`. `addPostFrameCallback` fires after the first frame — which is drawn immediately, while `_routeFromState()` is still awaiting. Both are running "at the same time" from Dart's cooperative scheduler perspective.

In the normal path (onboarding already done), `isOnboardingComplete()` returns true quickly and the callback finishes without pushing anything. `_routeFromState()` then does its `pushReplacementNamed('/dashboard')` and the stack is clean: `[DashboardScreen]`. No back button is shown because `Navigator.canPop()` is false.

**The problem path**: On slow devices or cold starts, the postFrameCallback reaches `showCrashRecoveryDialogIfNeeded()` and `isOnboardingComplete()` and finds that a crash occurred last session OR onboarding is not complete. It `await`s a dialog or pushes the `OnboardingOverlay`. During this await, `_routeFromState()` finishes and calls `pushReplacementNamed('/dashboard')` from the `StartupGateScreen` context. 

`pushReplacementNamed` replaces `StartupGateScreen` in the stack. If `OnboardingOverlay` was already pushed above it, the stack becomes `[DashboardScreen, OnboardingOverlay]` — the overlay sits *on top* of the dashboard. When the user dismisses the overlay, they see the dashboard with `canPop() == true` because... wait, actually in this case there's nothing below Dashboard, so `canPop()` would still be false.

The more dangerous race is: `_routeFromState()` calls `pushReplacementNamed` *while the `mounted` guard in the postFrameCallback has already passed but before the overlay push completes*. Flutter's navigation is not synchronised between these two code paths, so the navigator can end up in an inconsistent intermediate state that, in some builds/devices, leaves a ghost `StartupGateScreen` entry below `DashboardScreen` in the internal route history. When the dashboard's implied back button triggers a pop, this ghost route is revealed — and because it was "replaced" its `_routeFromState()` never runs again, leaving the user staring at the spinner.

**Problem B — DashboardScreen does not protect against back-navigation.**

`lib/ui/screens/dashboard_screen.dart`, the `Scaffold`'s `AppBar` has no `automaticallyImplyLeading: false` and there is no `PopScope` wrapping the `Scaffold`. This means Flutter will automatically render a back arrow any time `Navigator.canPop()` returns true on the dashboard's route, whether that is expected or not. On a phone with Android's gesture navigation, a swipe-from-left also triggers a pop.

### Affected Files

| File | What the problem is |
|---|---|
| `lib/ui/screens/startup_gate_screen.dart` | Two async tasks in `initState()` with no coordination guard, can both attempt navigation |
| `lib/ui/screens/dashboard_screen.dart` | No `PopScope` guard; shows a back arrow whenever `canPop()` is true |

### Proposed Fix

**Step 1 — Coordinate the two async tasks in `StartupGateScreen`.**

Add a `bool _navigationInProgress = false` flag. `_routeFromState()` sets it to `true` before its first `await`. The `addPostFrameCallback` checks this flag before calling `showCrashRecoveryDialogIfNeeded` or pushing the overlay. If the flag is true the callback returns early. This ensures only one of the two paths pushes a navigation event.

```dart
// lib/ui/screens/startup_gate_screen.dart

bool _navigationInProgress = false;   // ADD THIS

@override
void initState() {
  super.initState();
  _routeFromState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!mounted || _navigationInProgress) return;  // GUARD ADDED
    await showCrashRecoveryDialogIfNeeded(context);
    if (!mounted || _navigationInProgress) return;  // GUARD ADDED
    final done = await isOnboardingComplete();
    if (!done && mounted && !_navigationInProgress) { // GUARD ADDED
      await Navigator.of(context).push(...);
    }
  });
}

Future<void> _routeFromState() async {
  _navigationInProgress = true;  // SET FLAG AT ENTRY
  try {
    // ... existing logic unchanged ...
  } catch (e) {
    _navigationInProgress = false;  // Release on error so the callback can run
    if (!mounted) return;
    setState(() => _error = e);
  }
}
```

**Why this is safe:** `_routeFromState()` sets the flag synchronously at entry, before any `await`. Dart's event loop runs synchronously until the first `await`, so by the time the postFrameCallback can run (it's scheduled for the next microtask after the first frame), the flag is already set. No real concurrency — just Dart cooperative scheduling — so this guard is sufficient.

**Step 2 — Protect `DashboardScreen` with `PopScope`.**

Wrap the `DashboardScreen` `Scaffold` in a `PopScope` with `canPop: false` and an `onPopInvokedWithResult` that uses `SystemNavigator.pop()` to exit the app cleanly when the user presses back from the root dashboard:

```dart
// lib/ui/screens/dashboard_screen.dart
import 'package:flutter/services.dart'; // already imported elsewhere in the project

@override
Widget build(BuildContext context) {
  return PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) SystemNavigator.pop(); // clean app exit on back
    },
    child: Scaffold(
      appBar: AppBar( ... ), // unchanged
      ...
    ),
  );
}
```

**Why `PopScope` and not `WillPopScope`?** `WillPopScope` is deprecated as of Flutter 3.22 and will be removed. The codebase targets a version that has `PopScope`; `SystemNavigator` is already imported elsewhere (see `platform_installer_launch_service.dart`). Using `PopScope(canPop: false)` means the back arrow also disappears from the AppBar automatically, which is the correct UX for a root screen.

**Compatibility:** `PopScope` with `onPopInvokedWithResult` (two parameters) requires Flutter 3.22+. Check `flutter --version` before merging. If the project is on an older Flutter, use `onPopInvoked` (one parameter, deprecated signature) instead. Do NOT use `WillPopScope`.

### What Does NOT Change
The navigation logic inside `_routeFromState()` is untouched. All routes (`/select-church`, `/select-profile`, `/dashboard`) remain identical. The rest of the `DashboardScreen` build is untouched.

### Risk
Low. The flag guard is purely additive. `PopScope` is a standard Flutter widget replacing a deprecated one. The only meaningful change is that pressing the system back button from the dashboard now exits the app instead of navigating backward — which is the expected behaviour for any root screen.

---

<a name="bug-002"></a>
## BUG-002 — Log export fails on Android ("Could not determine save location")

**Status:** Complete (2026-05-12)

### Severity
Low-medium. App logs export is a diagnostic feature; the failure is not data-threatening, but the error message is confusing.

### Observed Behaviour
As seen in the screenshot (Image 2): after tapping the Export button in the App Logs screen, the red snackbar "Could not determine save location." appears at the bottom. The log file is never written.

### Root Cause

`lib/ui/screens/log_viewer_screen.dart`, the `_exportLogs()` method:

```dart
String? destPath;
if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
  final dir = await _getExportsDir();
  destPath = '${dir.path}/$suggestedName';
}

if (destPath == null) {
  _showSnack('Could not determine save location.');
  return;
}
```

Android is not handled. `destPath` is never assigned on Android, so the null check fires and the error is shown. The `_getExportsDir()` helper itself also only handles Linux/macOS (using the `HOME` env variable for Documents folder) and falls back to `Directory.systemTemp` on other platforms — but this whole helper is not even called on Android because of the `Platform.isLinux || Platform.isMacOS || Platform.isWindows` guard.

### Affected Files

| File | Line range | What to change |
|---|---|---|
| `lib/ui/screens/log_viewer_screen.dart` | ~78–97 (`_exportLogs`) | Add Android branch |
| `lib/ui/screens/log_viewer_screen.dart` | ~116–127 (`_getExportsDir`) | Add Android path resolution |

### Proposed Fix

The project already uses `path_provider: ^2.1.5` (confirmed in `pubspec.yaml`). `path_provider` exposes `getExternalStorageDirectory()` on Android, which returns the app's external files directory (e.g. `/sdcard/Android/data/com.church.church_analytics/files`). This does not require any storage permission on Android 10+.

**Change `_exportLogs()`:**

```dart
String? destPath;
if (!kIsWeb) {
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    final dir = await _getExportsDir();
    destPath = '${dir.path}/$suggestedName';
  } else if (Platform.isAndroid) {             // ADD THIS BRANCH
    final dir = await _getAndroidExportsDir(); // ADD THIS CALL
    if (dir != null) destPath = '${dir.path}/$suggestedName';
  }
}
```

**Add `_getAndroidExportsDir()`:**

```dart
Future<Directory?> _getAndroidExportsDir() async {
  try {
    final external = await getExternalStorageDirectory();
    if (external != null) {
      final dir = Directory('${external.path}/church_analytics_exports');
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    }
  } catch (e) {
    LogService.warning('LogViewer', 'External storage unavailable: $e');
  }
  // Fallback: app-internal documents directory (always accessible, no permission needed)
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}/church_analytics_exports');
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}
```

**Why this is safe:**
- `getExternalStorageDirectory()` is app-scoped on Android 10+ (no manifest permission needed).
- The `getApplicationDocumentsDirectory()` fallback is always available on all Android versions.
- No new dependencies required.
- The existing desktop path is completely untouched.

**One additional improvement:** After a successful export on Android, show the destination path in the snackbar so the user knows where to find the file. This is already done for desktop by the success snackbar: `'Exported $lines lines → $destPath'`.

### Risk
None. The Android branch is new code that did not exist before. The existing Linux/macOS/Windows branch is untouched. The fallback chain ensures a valid path is always produced on Android.

---

<a name="feat-001"></a>
## FEAT-001 — Tutorial: ask user before showing onboarding on first launch

### Current State
`lib/ui/widgets/onboarding_overlay.dart` already contains a complete 5-slide onboarding flow. `lib/ui/screens/startup_gate_screen.dart` checks `isOnboardingComplete()` on startup and, if the flag is not set, immediately pushes the overlay without asking the user.

`lib/ui/screens/app_settings_screen.dart` already exposes a "Help & Tutorial" tile that reopens the overlay at any time (with `fromSettings: true` to avoid re-setting the completion flag).

### What Is Requested
On first launch, instead of pushing the overlay immediately, show a dialog asking: "Would you like a quick tour of Church Analytics?" with two options: **Show me around** and **Skip for now**. If the user taps Skip, mark onboarding complete anyway (so it never auto-shows again) and proceed. If the user taps Show me around, push the overlay as before.

The user should always be able to access the tutorial from Settings (already working).

### Proposed Change

**Move onboarding logic to `DashboardScreen`.** Remove the onboarding check and dialog from `StartupGateScreen` entirely. Keep `showCrashRecoveryDialogIfNeeded()` in `StartupGateScreen` since it is unrelated to onboarding.

**In `StartupGateScreen`** keep only the crash recovery call in `addPostFrameCallback` and delete the onboarding block.

**In `DashboardScreen.initState()`** add a post-frame onboarding gate:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) async {
  if (!mounted) return;
  final done = await isOnboardingComplete();
  if (!done && mounted) {
    final wantsTour = await _askIfUserWantsTour(context);
    if (wantsTour == true && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => const OnboardingOverlay(),
        ),
      );
    } else {
      // User skipped -- still mark complete so this dialog never re-appears.
      await markOnboardingComplete();
    }
  }
});
```

**Add `_askIfUserWantsTour()` as a private helper in `dashboard_screen.dart`** (same dialog copy as before).

### Files Changed

| File | Change |
|---|---|
| `lib/ui/screens/startup_gate_screen.dart` | Remove onboarding block; keep crash recovery only |
| `lib/ui/screens/dashboard_screen.dart` | Add onboarding gate + dialog helper |

**No changes to:** `onboarding_overlay.dart`, `app_settings_screen.dart`, `markOnboardingComplete()`.

### Risk
Low. Onboarding is moved to the dashboard lifecycle to avoid the navigation guard in `StartupGateScreen`. The overlay itself is unchanged and Settings entry remains intact.

---

<a name="feat-002"></a>
## FEAT-002 — Update: request install-unknown-apps permission proactively on Android

### Current State
`lib/platform/platform_installer_launch_service.dart`, `_launchAndroid()` calls `OpenFile.open(installerPath)`. If the `REQUEST_INSTALL_PACKAGES` permission has not been granted, `OpenFile` returns `ResultType.permissionDenied` and the service returns a failure with a multi-step manual instructions string. The user sees the `UpdateInstallFailureDialog` with those instructions.

This is reactive. The user has already waited for the download to finish before discovering the permission is missing.

### What Is Requested
Before the download begins, check whether the install-unknown-apps permission is granted on Android. If not, inform the user and direct them to grant it in Settings. The download should not start until permission is confirmed.

### Proposed Change

**New dependency required:** `permission_handler: ^11.3.1` (latest stable as of May 2026). This adds ~200KB to the Android APK. It is the standard Flutter package for runtime permission management.

Add to `pubspec.yaml` under `dependencies`:
```yaml
permission_handler: ^11.3.1
```

Add to `android/app/src/main/AndroidManifest.xml` (already required but confirm it's present):
```xml
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>
```

**New helper in `lib/platform/platform_installer_launch_service.dart`** (or a new `lib/platform/install_permission_service.dart` if separation is preferred):

```dart
/// Checks whether the app has permission to install unknown APKs on Android 8+.
/// Returns true if permission is already granted or if the platform is not Android.
/// Returns false and optionally opens the settings screen if permission is denied.
Future<bool> ensureInstallPermissionGranted(BuildContext context) async {
  if (!Platform.isAndroid) return true;
  
  final status = await Permission.requestInstallPackages.status;
  if (status.isGranted) return true;

  // Show a dialog before redirecting to system settings.
  final agreed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Permission Required'),
      content: const Text(
        'To install updates directly, Church Analytics needs permission to '
        'install apps. You will be taken to the system settings to enable this.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Open Settings'),
        ),
      ],
    ),
  );

  if (agreed != true) return false;

  await openAppSettings(); // from permission_handler
  // After returning from settings, re-check.
  return (await Permission.requestInstallPackages.status).isGranted;
}
```

**Call site in `lib/ui/widgets/about_updates_card.dart`**, in the `_onDownloadUpdate()` or `_doInstall()` method, before the download call:

```dart
// At the point where user confirms download (before UpdateDownloadService.download() is called)
if (Platform.isAndroid) {
  final hasPermission = await ensureInstallPermissionGranted(context);
  if (!hasPermission) return; // User cancelled or still denied — do not proceed
}
// ... existing download logic continues ...
```

**Compatibility consideration:** `Permission.requestInstallPackages` is Android-only. The `if (!Platform.isAndroid)` guard means this code path is never reached on Windows or Linux. The import must be guarded: `import 'dart:io' show Platform;` is already present in this file.

**Risk assessment:** Adding `permission_handler` is a well-maintained package used across thousands of Flutter apps. The AndroidManifest permission `REQUEST_INSTALL_PACKAGES` is already documented in the codebase (see `platform_installer_launch_service.dart` line 50) as required — this item just makes the runtime check explicit instead of leaving it to `open_file` to discover at install time. The change does not affect Windows or Linux paths.

---

<a name="feat-003"></a>
## FEAT-003 — Update: prompt user to back up before updating

### Current State
`lib/ui/widgets/installer_confirmation_dialog.dart` shows a confirmation dialog before the download begins. It tells the user the app will close and install the update. It does not mention backup.

`lib/services/backup_service.dart` has a full `BackupService` with `createBackup(churchId, db)` returning a `BackupResult`. The reports screen and settings already use this service.

### What Is Requested
Before the update download starts (or at the confirmation step), show a prompt advising the user to back up their data. Offer a shortcut to back up immediately, a "skip and continue" option, and a cancel option.

### Proposed Change

**Option 1 (preferred, lowest risk):** Add a new dialog shown *before* `InstallerConfirmationDialog`. This keeps the existing confirmation dialog untouched.

**New file: `lib/ui/widgets/pre_update_backup_dialog.dart`**

```dart
/// Dialog shown before an update download starts.
/// Returns true if the user wants to proceed (with or without backup).
/// Returns false if the user cancelled.
class PreUpdateBackupDialog extends StatefulWidget {
  final int churchId;
  final AppDatabase db;

  const PreUpdateBackupDialog({required this.churchId, required this.db, super.key});

  static Future<bool?> show(BuildContext context, {
    required int churchId,
    required AppDatabase db,
  }) => showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PreUpdateBackupDialog(churchId: churchId, db: db),
  );
  
  // ... build: shows "Back Up Now" / "Skip & Update" / "Cancel"
  // "Back Up Now" calls BackupService.createBackup(), shows a progress indicator,
  // then on success shows a checkmark + file path, then returns true.
  // "Skip & Update" returns true immediately.
  // "Cancel" returns false.
}
```

**Call site in `lib/ui/widgets/about_updates_card.dart`:**

Replace the existing `confirmInstall` call site:
```dart
// BEFORE (existing):
final confirmed = await (widget.confirmInstall ?? InstallerConfirmationDialog.show)(context);
if (confirmed != true) return;

// AFTER:
// Step 1: backup prompt
final proceedAfterBackup = await PreUpdateBackupDialog.show(
  context, churchId: currentChurchId, db: ref.read(databaseProvider),
);
if (proceedAfterBackup != true) return;

// Step 2: existing install confirmation (unchanged)
final confirmed = await (widget.confirmInstall ?? InstallerConfirmationDialog.show)(context);
if (confirmed != true) return;
```

**About getting `churchId` in `about_updates_card.dart`:** The card is shown in `app_settings_screen.dart`. `AppSettingsScreen` receives `churchId` as a constructor argument. Pass `churchId` down as a constructor parameter to `AboutUpdatesCard`. This is a one-line change in `AboutUpdatesCard`'s constructor and the call site.

**Risk assessment:** The new dialog is a new file and a new flow step. It does not touch the download logic, the installer, or the manifest system. The `BackupService` is already production-tested. The only risk is that `BackupService.createBackup()` fails inside the dialog — which is handled by showing an error message while still allowing the user to skip and continue the update. The existing `confirmInstall` injection point for tests is preserved (the backup step can be separately skipped in tests by overriding `PreUpdateBackupDialog.show`).

---

<a name="feat-004"></a>
## FEAT-004 — Update: auto-delete installer file after successful update (Android)

### Current State
`lib/platform/platform_installer_launch_service.dart`, `_launchAndroid()`:

```dart
case ResultType.done:
  _popFn(); // exits the app (SystemNavigator.pop)
  return const InstallerLaunchResult.success();
```

After `_popFn()` is called, the app exits. The downloaded APK file (in `getTemporaryDirectory()`) remains on disk until Android's OS temp-cleanup runs. This can be anywhere from minutes to days.

### What Is Requested
After a successful install handoff, the installer file should be removed automatically.

### Proposed Change

Do **not** delete the APK immediately after `OpenFile.open()` returns `done`. This can race the Android installer if it has not opened the file yet.

**Rely solely on next-startup cleanup (belt-and-suspenders):**

In `startup_gate_screen.dart`, after routing is resolved (in `_routeFromState()`, after the successful route is identified), add a one-liner fire-and-forget cleanup:

```dart
unawaited(_cleanUpStaleApks());

Future<void> _cleanUpStaleApks() async {
  try {
    final tempDir = await getTemporaryDirectory();
    final files = tempDir.listSync();
    for (final f in files) {
      if (f is File && f.path.endsWith('.apk')) {
        await f.delete();
      }
    }
  } catch (_) { /* best-effort */ }
}
```

This cleanup is lightweight, async, and does not block startup. It catches any APK that survived a previous install due to crashes or interrupted flows.

**For Windows/Linux:** The ZIP/tar.gz installer is extracted to a staging folder. The staging folder is also not cleaned up today. A similar cleanup approach applies — but the staging folder path is known only to `PlatformInstallerLaunchService`. Add a `hint` in the `InstallerLaunchResult.success()` for Windows/Linux that includes the staging folder path, and add a cleanup pass in `startup_gate_screen.dart` if a "last staging path" key exists in SharedPreferences. This is lower priority than Android.

### Risk
Low. Startup cleanup is best-effort and restricted to `.apk` files in system temp; no install-time deletion avoids races with the Android installer.

---

<a name="feat-005"></a>
## FEAT-005 — Update: handle already-downloaded package on retry

### Current State
`lib/services/update_download_service.dart`, `download()` builds the destination file path as `'${destDir.path}/$filename'` and starts a fresh download every time. If a previous download completed successfully but installation failed (e.g. permission denied), and the user taps Download Update again, the app re-downloads the full file from scratch.

`UpdateDownloadService._deletePartial()` is called on error, but it is NOT called after a successful download + failed install. So the complete APK file may still be sitting in the temp directory.

### What Is Requested
If the APK was already fully downloaded and its SHA-256 matches the manifest, skip the network download entirely and proceed directly to installation.

### Proposed Change

**Modify the `download()` method in `update_download_service.dart`** — add a pre-download file check at the very top, before any network call:

```dart
Future<UpdateDownloadResult> download({
  required UpdateManifest manifest,
  required Directory destDir,
  void Function(double progress)? onProgress,
  CancelToken? cancelToken,
}) async {
  final asset = _resolvePlatformAsset(manifest);
  if (asset == null) { /* existing */ }

  final filename = asset.downloadUrl.split('/').last;
  final file = File('${destDir.path}/$filename');

  // --- NEW: check if a valid complete download already exists ---
  if (await file.exists()) {
    try {
      final existingBytes = await file.readAsBytes();
      final existingHash = _sha256Hex(existingBytes);
      if (existingHash == asset.sha256.toLowerCase()) {
        // File is already downloaded and verified. Skip network.
        debugPrint('[UpdateDownloadService] Using cached file: ${file.path}');
        onProgress?.call(1.0); // signal 100% immediately
        return UpdateDownloadResult.success(file.path);
      } else {
        // File exists but is corrupt or partial — delete and re-download.
        debugPrint('[UpdateDownloadService] Stale/corrupt file found, deleting.');
        await _deletePartial(file);
      }
    } catch (_) {
      await _deletePartial(file); // unreadable — start fresh
    }
  }
  // --- END NEW ---

  // ... existing download logic continues unchanged ...
```

**Risk assessment:** The hash check reads the file from disk synchronously inside a try/catch. On a large APK (e.g. 30–50 MB), this may take 100–300ms on a slow device. This is acceptable — it happens only once on the retry attempt, not on every launch. The existing 13 download error paths are untouched. This is purely additive code before the existing network call.

**Note:** This check is best-effort on top of the existing SHA-256 verification. It does not introduce a new security surface because the verified hash comes from the same remote manifest that was already cryptographically validated.

---

<a name="feat-006"></a>
## FEAT-006 — Update: pause and resume download

### Current State
`lib/services/update_download_service.dart` downloads the installer as an HTTP stream and accumulates all bytes in a `BytesBuilder` in memory. Cancellation is supported via `CancelToken` (cooperative, checked at each chunk). There is no pause concept.

### What Is Requested
User should be able to pause the download (stop network transfer), resume it later without restarting from zero, and continue if the app is brought back to the foreground.

### Technical Analysis Before Proposing

**Can the server support this?** HTTP range requests (`Range: bytes=X-`) allow resuming a download from a specific byte offset. GitHub Releases CDN (objects.githubusercontent.com) supports range requests. Verify before implementing by issuing a `HEAD` request to the APK URL and checking for `Accept-Ranges: bytes` in the response headers. If this header is absent, resumable download cannot be implemented reliably.

**In-memory vs on-disk accumulation:** The current `BytesBuilder` keeps the entire file in RAM during download. For a 30–50 MB APK this is acceptable but not ideal. Pause/resume requires writing chunks to disk incrementally (so the partial file survives across pause/resume cycles and app restarts). This changes the fundamental download strategy.

**Proposed Change (requires the Accept-Ranges header to be confirmed)**

1. **New download strategy — stream to file, not to `BytesBuilder`:**
   
   Change `update_download_service.dart` so that each chunk is appended to the destination file immediately:
   ```dart
   final sink = file.openWrite(mode: FileMode.append); // append, not overwrite
   int received = 0;
   await for (final chunk in streamedResponse.stream) {
     if (cancelToken?.isCancelled == true) { ... }
     if (pauseToken?.isPaused == true) {
       await sink.flush();
       await sink.close();
       return UpdateDownloadResult.paused(file.path, bytesReceived: received);
     }
     await sink.addStream(Stream.value(chunk));
     received += chunk.length;
     onProgress?.call(received / responseContentLength!);
   }
   await sink.flush();
   await sink.close();
   ```

2. **New `PauseToken` class (sibling of `CancelToken`):**
   ```dart
   class PauseToken {
     bool _isPaused = false;
     void pause() => _isPaused = true;
     void resume() => _isPaused = false;
     bool get isPaused => _isPaused;
   }
   ```

3. **Resume method on `UpdateDownloadService`:** Accepts the existing partial file path and the manifest, issues a `Range: bytes=<file_size>-` HTTP request, and appends the response to the existing file.

4. **New result type `UpdateDownloadResult.paused(String filePath, {required int bytesReceived})`** so the caller can present a "Paused — Resume" button.

5. **`UpdateDownloadProgressDialog`:** Add a Pause/Resume button alongside the existing Cancel button.

**Risk assessment:** This is the most invasive item in the update section. The switch from `BytesBuilder` to on-disk streaming touches the core of `update_download_service.dart`. All existing error paths (checksum mismatch, HTTP error, cancellation) must be re-verified after the change. The SHA-256 computation also needs to change — instead of computing over the in-memory bytes, read the completed file from disk after all chunks are received.

**Recommendation:** Implement this after all other simpler update items are merged and tested. Write a unit test covering: normal full download, pause mid-stream, resume, final checksum pass. Before implementing, add an integration test that issues a HEAD to the production APK URL and asserts `Accept-Ranges: bytes`.

---

<a name="feat-007"></a>
## FEAT-007 — Update: resume download after unexpected app closure

### Current State
If the app closes unexpectedly during a download (killed by Android, crash, phone restart), `_deletePartial()` is never called (it only runs on gracefully caught exceptions). The partial file remains in `getTemporaryDirectory()`. On next launch, nothing checks for it. The user must re-download from scratch.

### What Is Requested
If the download was interrupted by a crash or unexpected closure, the app should detect the partial file on next launch and either offer to resume or clean it up.

### Technical Dependencies
This item depends on FEAT-006 (on-disk streaming). If chunks are accumulated in `BytesBuilder` in memory, a crashed download leaves nothing useful on disk. Once FEAT-006 switches to on-disk streaming, there IS a partial file to resume from.

### Proposed Change (after FEAT-006 is implemented)

**Persist download state before streaming begins.** In `update_download_service.dart`, write a small JSON record to `SharedPreferences` at the moment a download starts:

```json
{
  "url": "https://github.com/.../app-release.apk",
  "dest_path": "/data/user/0/.../app-release.apk",
  "sha256": "abc123...",
  "started_at": "2026-05-12T13:00:00Z"
}
```

Clear this record when the download completes (success or clean failure/cancel).

**On startup, in `StartupGateScreen._routeFromState()`**, after routing is determined, check `SharedPreferences` for this key. If found:

- Verify the partial file still exists on disk.
- If it does: show a `SnackBar` or dialog: "An update download was interrupted. Resume or discard?" with Resume and Discard buttons.
- If the file does not exist (was cleaned up by the OS): silently clear the key.
- "Discard" deletes the file and clears the key.
- "Resume" hands off to the `UpdateDownloadService.resume()` method from FEAT-006.

**Risk assessment:** The SharedPreferences write/clear is trivial. The partial file detection is non-destructive (it never auto-deletes without user confirmation). The resume path is gated on FEAT-006. Implementing FEAT-007 before FEAT-006 would not crash anything, but the "Resume" path would have no functional effect — so implement FEAT-006 first.

---

<a name="feat-008"></a>
## FEAT-008 — Update: continue downloading while app is in background (Android)

> **Report version 3.1 — This section replaces the FEAT-008 content in v3.0.** The v3.0 plan described a background-isolate architecture that contained several fundamental errors. This version corrects them and defines the implementation clearly enough to code from.

### Current State
The download runs in the Flutter main isolate. On Android, when the user sends the app to the background, Android may throttle or kill the process after several minutes (depending on device OEM, battery optimisation settings, Android version). The download would be interrupted.

### What Is Requested
The download should continue even if the user minimises the app.

---

### Why the v3.0 Plan Was Wrong

The previous plan described the download running "in an isolate managed by the service" with progress communicated via `FlutterForegroundTask.sendDataToMain`. That description contains three critical errors that would have caused real failures during implementation:

**Error 1 — `http.Client` cannot cross an isolate boundary.**  
`UpdateDownloadService` takes an injected `http.Client` (constructor field). Dart isolates have separate heaps. You cannot pass a live `http.Client` instance to a true background isolate via `SendPort` — the attempt throws a runtime error. If the download had been moved to a real separate isolate, the entire injectable-for-testing constructor pattern would have broken silently.

**Error 2 — `CancelToken` and `PauseToken` mutation is invisible across isolate boundaries.**  
FEAT-006 and FEAT-007 use `CancelToken` and `PauseToken` as plain Dart objects mutated from UI callbacks (`cancelToken.cancel()`, `pauseToken.pause()`). If the download loop runs in a different isolate, mutating these objects in the UI isolate has zero effect on the copies in the service isolate — the Pause and Cancel buttons would silently do nothing. The v3.0 plan did not address this.

**Error 3 — SharedPreferences writes from a background isolate are not visible to the main isolate.**  
FEAT-007's `DownloadStateService.persist()` writes a crash-recovery record to SharedPreferences during download. If this write happens inside a background isolate, the main isolate's cached SharedPreferences instance will not see it until a cold restart. The FEAT-007 crash-recovery dialog would fail to appear on the next launch.

---

### Chosen Architecture: Main Isolate + Foreground Service as a Process Anchor

The simplest correct architecture is:

- The download continues to run in the **main Dart isolate**, exactly as it does today.
- A **Foreground Service** is started for the duration of the download. Its sole jobs are to (a) post the mandatory persistent notification (required by Android OS) and (b) prevent Android from killing the process when the app is backgrounded.
- The existing `CancelToken`, `PauseToken`, `DownloadStateService`, and `UpdateDownloadService` are **unchanged**. No isolate boundary is crossed. No new communication channel is needed.

This eliminates all three errors above. It is also what most production Flutter apps do for background downloads — the Foreground Service is a process-lifecycle anchor, not a compute unit.

---

### Technical Requirements

**Android Foreground Service is the only reliable mechanism.** Android's battery optimisation policies restrict background work on API 26+. Without a Foreground Service, background downloads will be silently throttled or killed. There is no alternative.

**`flutter_foreground_task` package (pin to `^8.0.0`).** This package wraps the Android Foreground Service API for Flutter. Pin the version — the package has had breaking API changes between v4, v5, and v8 (notification config and `TaskHandler` interface differ substantially between them). As of May 2026 v8.x is current and stable. Do not use an unpinned constraint.

**Desktop platforms (Windows, Linux) require no changes.** The OS does not throttle Flutter desktop processes the same way. The download already continues naturally in the background on desktop.

---

### Pre-Implementation Checklist

Before writing any code, confirm:

- [ ] `flutter pub add flutter_foreground_task:^8.0.0` resolves without conflicts.
- [ ] `flutter --version` is ≥ 3.22 (required for `PopScope`, also needed here for compatibility with the package's Kotlin plugin).
- [ ] The `minSdk` value in `android/app/build.gradle.kts` resolves to at least **21** (Android 5). Foreground Services are available from API 21+. The current build config uses `flutter.minSdkVersion` which defaults to 16 — this must be raised. If your device target is Android 8+ only, raise to 26 to simplify testing.
- [ ] Confirm the production APK download URL returns `Accept-Ranges: bytes` in a `HEAD` response (needed for FEAT-006 pause/resume; also confirms the CDN allows sustained connections).

---

### AndroidManifest.xml Changes

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Required for Foreground Service on all Android versions -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />

<!-- Required on Android 14+ (API 34+) for network I/O in a foreground service.
     Without this attribute on the <service> element AND this permission,
     Android 14 crashes the service at start. -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />

<!-- Required on Android 13+ (API 33+) to post the mandatory download notification -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

Inside the `<application>` element, add the service declaration:

```xml
<service
    android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
    android:foregroundServiceType="dataSync"
    android:exported="false" />
```

> **Critical:** both the `<uses-permission android:name="...FOREGROUND_SERVICE_DATA_SYNC"/>` entry **and** the `android:foregroundServiceType="dataSync"` attribute on the `<service>` element are required on Android 14+. Either alone is insufficient and causes a runtime crash on API 34+ devices.

---

### pubspec.yaml Change

```yaml
dependencies:
  flutter_foreground_task: ^8.0.0   # ADD — process anchor for background download
```

No other new dependencies. `http`, `shared_preferences`, and `path_provider` are already present.

---

### minSdk Change

In `android/app/build.gradle.kts`, replace:

```kotlin
minSdk = flutter.minSdkVersion
```

with:

```kotlin
minSdk = 21  // Raised from flutter default (16) to support ForegroundService
```

If the project has explicitly confirmed it targets Android 8+ only, you may raise this to 26 and simplify the API-level gating below.

---

### Implementation — Step by Step

#### Step 1 — Foreground service wrapper

Create `lib/services/download_foreground_service.dart`:

```dart
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Manages the Android Foreground Service lifecycle for the duration of
/// an update download.  On non-Android platforms this class is a no-op.
///
/// The service acts purely as a process anchor: it posts the mandatory
/// persistent notification and prevents Android from killing the process
/// when the app is backgrounded.  The download itself continues to run
/// in the main Dart isolate — no isolate boundary is crossed.
class DownloadForegroundService {
  static bool _initialised = false;

  /// Call once before [start], typically in [AboutUpdatesCard.initState] or
  /// at app startup.  Safe to call multiple times.
  static void init() {
    if (_initialised || !Platform.isAndroid) return;
    _initialised = true;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'church_analytics_update_download',
        channelName: 'Update Download',
        channelDescription: 'Shown while a Church Analytics update is downloading.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        // LOW importance: no sound, no heads-up — unobtrusive during download.
      ),
      iosNotificationOptions: const IOSNotificationOptions(), // no-op on iOS
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        // We drive progress updates ourselves via [updateNotification];
        // the package's built-in event loop is not needed.
        autoRunOnBoot: false,
      ),
    );
  }

  /// Start the foreground service with an initial notification.
  /// Must be called from the main isolate with a valid [BuildContext] if
  /// POST_NOTIFICATIONS permission has not been granted yet on Android 13+.
  static Future<void> start({CancelToken? cancelToken}) async {
    if (!Platform.isAndroid) return;
    _activeCancelToken = cancelToken;
    // Reset throttle state so the first update always fires immediately.
    _lastNotificationTime = null;
    _lastNotifiedPct = 0;
    await FlutterForegroundTask.startService(
      serviceId: 1001,
      notificationTitle: 'Downloading update…',
      notificationText: 'Church Analytics update is downloading',
    );
  }

  /// Update the notification text to reflect current progress.
  ///
  /// Throttled: the notification is only updated when at least 2 seconds have
  /// elapsed since the last update **or** the displayed percentage has moved
  /// by ≥ 5 points — whichever comes first.  Both gates must be checked
  /// because on a fast connection 5% ticks can arrive in under a second, and
  /// on a slow connection the 2-second timer fires before 5% accumulates.
  ///
  /// Calling [FlutterForegroundTask.updateService] on every downloaded chunk
  /// (which can be hundreds of times per second on a fast link) floods the
  /// Android notification manager, causes visible notification flicker, and
  /// generates unnecessary binder IPC traffic.  Throttling keeps the shade
  /// feeling live without any of those side-effects.
  static Future<void> updateProgress(double fraction) async {
    if (!Platform.isAndroid) return;

    final now = DateTime.now();
    final pct = (fraction * 100).round();

    final elapsedEnough = _lastNotificationTime == null ||
        now.difference(_lastNotificationTime!).inMilliseconds >= 2000;
    final deltaEnough = (pct - _lastNotifiedPct).abs() >= 5;

    if (!elapsedEnough && !deltaEnough) return; // skip this tick

    _lastNotificationTime = now;
    _lastNotifiedPct = pct;

    await FlutterForegroundTask.updateService(
      notificationTitle: 'Downloading update… $pct%',
      notificationText: 'Church Analytics update is downloading',
    );
  }

  // Throttle state — reset by [start] so each download begins clean.
  static DateTime? _lastNotificationTime;
  static int _lastNotifiedPct = 0;

  /// Stop the foreground service.  Call this when the download completes,
  /// is cancelled, is paused, or errors out.
  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    await FlutterForegroundTask.stopService();
  }
}
```

#### Step 2 — Wire into the download flow in `about_updates_card.dart`

`_onDownloadUpdate()` already calls `UpdateDownloadService.download()` with an `onProgress` callback. Wrap it:

```dart
Future<void> _onDownloadUpdate() async {
  // ... existing permission check, dialog setup, cancelToken/pauseToken creation ...

  // START: anchor the process against Android backgrounding
  await DownloadForegroundService.start();

  UpdateDownloadResult result;
  try {
    result = await _downloadService.download(
      manifest: _manifest!,
      destDir: await getTemporaryDirectory(),
      cancelToken: cancelToken,
      pauseToken: pauseToken,
      onProgress: (p) {
        progressNotifier.value = p;
        // Update the notification — DownloadForegroundService.updateProgress
        // throttles internally (2 s or 5% delta) so this is safe to call on
        // every chunk without flooding the Android notification manager.
        DownloadForegroundService.updateProgress(p);
      },
    );
  } finally {
    // STOP: always tear down the service, whatever the outcome.
    await DownloadForegroundService.stop();
  }

  popDialog();
  WidgetsBinding.instance.addPostFrameCallback((_) => progressNotifier.dispose());

  // ... existing result handling (success → _doInstall, paused → setState, etc.) ...
}
```

Apply the same `start()`/`stop()` wrapping to `_onResumeDownload()`.

#### Step 3 — Handle notification permission on Android 13+

`POST_NOTIFICATIONS` is a runtime permission on Android 13+ (API 33+). The Foreground Service notification will be silently suppressed if it is not granted. Request it before calling `DownloadForegroundService.start()`:

```dart
// In _onDownloadUpdate(), before DownloadForegroundService.start():
if (Platform.isAndroid) {
  // permission_handler is already added for FEAT-002.
  // POST_NOTIFICATIONS is a separate permission from REQUEST_INSTALL_PACKAGES.
  final notifStatus = await Permission.notification.status;
  if (!notifStatus.isGranted) {
    await Permission.notification.request();
    // If the user denies, the download still proceeds — the notification is
    // just suppressed.  Do not block the download on notification permission.
  }
}
```

#### Step 4 — Handle system notification cancel

When the user swipes away the foreground service notification or taps a system-level cancel action, Android stops the service. `flutter_foreground_task` surfaces this as a `FlutterForegroundTask.addTaskDataCallback` event or via the `onDestroy` lifecycle on the `TaskHandler`. In the main-isolate model, this means `FlutterForegroundTask.stopService()` is called by the OS. The download in the main isolate keeps running — the service stopping does not kill the isolate.

However, if the user intended to cancel by dismissing the notification, the download continues invisibly. To handle this correctly:

```dart
// In DownloadForegroundService.init(), after FlutterForegroundTask.init():
// Register a callback for when the service is stopped externally.
FlutterForegroundTask.addTaskDataCallback((data) {
  // The package sends a task-stopped event when the service is killed by the OS
  // or by the user swiping the notification.
  if (data == 'stop') {
    // Notify the active cancelToken if one exists.
    _activeCancelToken?.cancel();
  }
});
```

`_activeCancelToken` is a static nullable field on `DownloadForegroundService`, set when `start()` is called and cleared when `stop()` is called. Pass the `CancelToken` to `DownloadForegroundService.start(cancelToken: cancelToken)` so the service can cancel the download if the notification is dismissed.

The `start()` signature shown in Step 1 already includes the `cancelToken` parameter and the throttle-state reset — no separate update is needed here. For reference, the fields involved:

```dart
static CancelToken? _activeCancelToken;
static DateTime? _lastNotificationTime; // throttle
static int _lastNotifiedPct = 0;        // throttle
```

`stop()` clears `_activeCancelToken`; the throttle fields are reset at the top of `start()` so each new download begins with a clean slate.

---

### What Does NOT Change

- `UpdateDownloadService` — no changes. The download loop, `CancelToken`, `PauseToken`, `DownloadStateService`, SHA-256 verification, and error paths are all untouched.
- `UpdateDownloadProgressDialog` — no changes. The in-app progress bar and Cancel/Pause buttons work exactly as before.
- `startup_gate_screen.dart` crash-recovery flow — no changes. SharedPreferences writes happen in the main isolate as before.
- Windows and Linux download paths — no changes.

---

### Stopgap: `wakelock_plus` (implement while FEAT-008 is in development)

Use `wakelock_plus: ^1.3.4` to prevent the screen from sleeping during a download, combined with a clear "keep the app open until the download finishes" message in `UpdateDownloadProgressDialog`. This does not prevent Android from killing the background process but does reduce the most common interruption (screen turning off → system deciding to throttle). Implement this as a one-liner in `_onDownloadUpdate` and remove it once FEAT-008 ships.

```dart
// _onDownloadUpdate, before the download call:
await WakelockPlus.enable();
try {
  result = await _downloadService.download(...);
} finally {
  await WakelockPlus.disable();
  await DownloadForegroundService.stop();
}
```

---

### Risk Assessment

| Sub-task | Risk | Notes |
|---|---|---|
| `flutter_foreground_task` package add | Low | Stable, widely used; pinned to `^8.0.0` |
| AndroidManifest `<service>` + permissions | Low | Additive; wrong `foregroundServiceType` causes API 34+ crash — test on API 34 device |
| `minSdk` raise to 21 | Low | Drops devices on Android 4.x (< 0.1% of active Android install base) |
| Main-isolate download (no architecture change) | None | `UpdateDownloadService` is untouched |
| `CancelToken` / notification cancel wiring | Low | Single static field; straightforward |
| `POST_NOTIFICATIONS` runtime request | None | Download proceeds even if denied; notification just suppressed |
| Desktop paths | None | Entire feature is gated by `Platform.isAndroid` |

Overall: **Medium** (down from High in v3.0). The complexity is now in Android configuration, not in isolate communication or threading.

**Estimated implementation effort:** 1 day with thorough testing on Android 8, 10, and 14 devices. The v3.0 estimate of 2–3 days assumed the background-isolate architecture.

---

### Testing Checklist for FEAT-008

- [ ] `flutter analyze` passes with zero warnings on all changed files
- [ ] `minSdk` resolves to 21 in `build.gradle.kts` (check `flutter build apk --analyze-size` output)
- [ ] Android 8 (API 26): start download → minimise app → confirm download continues → notification visible in shade
- [ ] Android 10 (API 29): same as above
- [ ] Android 14 (API 34): same as above — this is the most important target; missing `foregroundServiceType` crashes here
- [ ] Android 13+ (API 33+): confirm `POST_NOTIFICATIONS` dialog appears before first download; deny it → download still starts, notification absent (not a crash)
- [ ] Swipe away notification mid-download → download cancels (via `_activeCancelToken.cancel()`) → in-app dialog dismisses → `DownloadForegroundService.stop()` called cleanly
- [ ] Complete download while backgrounded → bring app to foreground → install flow proceeds as normal
- [ ] Pause download → minimise app → foreground service notification updates to "Paused" or disappears (stop service on pause) → resume from in-app UI on return
- [ ] Cancel from in-app Cancel button while backgrounded → service stops, partial file handled per FEAT-006/FEAT-007 rules
- [ ] Windows: download unaffected; no foreground service code runs
- [ ] Linux: same as Windows

---

<a name="feat-009"></a>
## FEAT-009 — Platform feature parity audit

### Current State
The app targets Android and Windows (primary), with Linux support in the build config. Several features have platform-specific branches. A formal parity audit has not been documented.

### Findings from Code Review

| Feature | Android | Windows | Linux |
|---|---|---|---|
| Update download | ✅ Full | ✅ Full (ZIP extract) | ✅ Full (tar extract) |
| Update install | ✅ APK open intent | ⚠️ Manual copy required | ⚠️ Manual copy required |
| Log export | ❌ Broken (BUG-002) | ✅ Works | ✅ Works |
| Backup / restore | ✅ | ✅ | ✅ |
| PDF export | ✅ | ✅ | ✅ |
| CSV export | ✅ | ✅ | ✅ |
| CSV import | ✅ | ✅ | ✅ |
| Onboarding tutorial | ✅ | ✅ | ✅ |
| Crash recovery dialog | ✅ | ✅ | ✅ |
| Permission request (install) | ⚠️ Reactive only (FEAT-002) | N/A | N/A |
| Background download | ❌ Backgrounding kills it | ✅ OS allows it | ✅ OS allows it |
| File picker (save location) | ✅ via `file_picker` | ✅ via `file_picker` | ✅ via `file_picker` |

**Key gaps:**
- Android log export is broken (BUG-002 above).
- Windows/Linux update install requires the user to manually copy files. This is a known limitation documented in the code (`PlatformInstallerLaunchService._launchWindows()`). Future work could automate the swap via a small helper launcher, but this is out of scope for the current report.
- Android background download requires a Foreground Service (FEAT-008 above).

### Proposed Change

No code changes in this item beyond what is described in BUG-002 and FEAT-008. This item exists to document the current parity state so any developer picking up this project has a clear baseline and does not accidentally introduce a feature that exists only on one platform.

**Action:** Add a `docs/PLATFORM_PARITY.md` file summarising the table above and noting which items are known limitations vs. bugs. Update it whenever a platform-specific code path is added.

---

<a name="feat-010"></a>
## FEAT-010 — Baptism & Holy Communion graphs

**Status:** Complete (2026-05-12)

*This section is carried forward from v1.0 of this report with minor additions.*

### Current State (Confirmed by Code Review)

**Baptisms:** Stored on `WeeklyRecord.baptisms` (nullable int). `AnalyticsService.baptismsTrend()` exists but is connected to nothing — no graph, no PDF widget, no UI card renders it anywhere.

**Holy Communion:** Two data sources:
- `WeeklyRecord.holyCommunion` (nullable int, simple weekly flag)
- `HolyCommunionEvent` — rich model with quarterly event data, per-home-church actual vs expected attendance, `overallRate`, `quarterLabel`

Three methods in `AnalyticsService` operate on `HolyCommunionEvent`:
- `holyCommunionRateTrend(events)`
- `holyCommunionActualVsExpected(events)`
- `holyCommunionByHomeChurch(event)`

**Zero of these three are connected to any graph, screen, or PDF export.** `holyCommunionEventsProvider` exists in `lib/services/weekly_records_provider.dart` and is ready to consume.

### Proposed Graph Set

#### Baptisms → `PdfGraphCategory.attendance`

| Graph ID | Chart Type | Analytics Method |
|---|---|---|
| `baptismsTrend` | Line | `baptismsTrend(records)` |
| `baptismsMonthly` | Bar | aggregate by month from `baptismsTrend` |
| `baptismsCumulative` | Line | running sum from `baptismsTrend` |

Monthly aggregation matters because individual weekly baptism counts are often 0 or 1 — a monthly bar gives better visual signal for leadership. Cumulative is the number pastoral leadership cares about at year-end.

#### Holy Communion → new `PdfGraphCategory.holyCommunion`

| Graph ID | Chart Type | Analytics Method |
|---|---|---|
| `communionAttendanceRateTrend` | Line | `holyCommunionRateTrend(events)` |
| `communionActualVsExpected` | Grouped bar | `holyCommunionActualVsExpected(events)` |
| `communionByHomeChurch` | Grouped bar | `holyCommunionByHomeChurch(event)` |
| `communionQuarterlyComparison` | Bar | `totalActual` per `quarterLabel` |

### File-by-File Changes (All Additive)

**`lib/services/pdf_graph_catalogue.dart`**
- Add 3 enum values to `PdfGraphId`: `baptismsTrend`, `baptismsMonthly`, `baptismsCumulative`
- Add 4 enum values to `PdfGraphId`: `communionAttendanceRateTrend`, `communionActualVsExpected`, `communionByHomeChurch`, `communionQuarterlyComparison`
- Add `PdfGraphCategory.holyCommunion`
- Add `'Holy Communion'` entry to `kPdfGraphCategoryLabels`
- Add 7 new `PdfGraphOption` entries to `kPdfGraphCatalogue`

**`lib/services/pdf_chart_builder.dart`**
- Add 3 static methods for baptism charts (all take `List<WeeklyRecord>`)
- Add 4 static methods for communion charts (all take `List<HolyCommunionEvent>`)

**`lib/services/pdf_report_service.dart`**
- `buildGraph()` receives a new optional parameter: `List<HolyCommunionEvent> communionEvents = const []`
- Add 7 new `case` branches in `buildGraph()` switch
- Pass the same optional parameter through `buildMultiChartReport()`

**`lib/ui/screens/reports_screen.dart`**
- `_exportPdf()` watches `holyCommunionEventsProvider` (provider already exists)
- Passes the resolved list to `buildMultiChartReport(communionEvents: events)`
- No UI changes needed — `_buildReportBuilderCard` already iterates `kPdfGraphCatalogue` dynamically

**Risk:** None. Adding enum values is backwards-compatible. The 13 existing graphs and their IDs are entirely untouched. Dart enforces exhaustive switch at compile time — any unhandled new case will be a compile-time warning, not a silent runtime failure.

---

<a name="feat-011"></a>
## FEAT-011 — PDF export completeness

After FEAT-010 is implemented, the PDF export will cover 20 graphs across 4 categories:

- **Attendance (8):** Total Attendance Trend, Demographic Breakdown, Attendance Growth Rate, Home Church Trend, Adult vs Young Distribution, Baptisms Trend, Baptisms Monthly, Baptisms Cumulative
- **Financial (5):** Total Income Trend, Income Composition, Tithe vs Offerings Trend, Income Per Attendee, Regular vs Special Income
- **Ratios & Correlations (3):** Per-Capita Giving Trend, Men:Women Ratio Trend, Adult:Young Ratio Trend
- **Holy Communion (4):** Attendance Rate Trend, Actual vs Expected, By Home Church, Quarterly Comparison

That covers every meaningful metric the app currently tracks. No gap will remain after FEAT-010.

The catalogue-driven architecture (`kPdfGraphCatalogue` → `buildGraph()` switch) means adding another graph in the future requires only: one new enum value, one new `PdfGraphOption`, and one new `case`. The UI, pipeline, and layout update automatically. No changes to this section beyond what FEAT-010 specifies.

---

<a name="feat-012"></a>
## FEAT-012 — App icon customisation documentation

### Current State
`flutter_launcher_icons: ^0.14.1` is in `pubspec.yaml` (confirmed). The icon source is `assets/images/app_icon.png`. The tooling is already fully configured for all platforms.

### What Is Missing
Clear documentation for church developers who fork the project.

### Proposed Change

Create `docs/CUSTOMISATION.md`:

```markdown
# Customising Church Analytics

## App Icon

Replace `assets/images/app_icon.png` with your own 1024×1024 PNG.

Rules:
- Square dimensions required (1024×1024 recommended)
- Transparent background is supported (Android adaptive icon will apply a background colour)
- Do not rename the file — the pubspec.yaml config references it by path

Then run:
```
dart run flutter_launcher_icons
```

Then rebuild:
```
flutter build apk --release         # Android
flutter build windows --release     # Windows
```

The config in pubspec.yaml already handles Android adaptive icons, Windows .ico, web favicon, and Linux icons from this single source file. No further configuration is needed.

**Tip:** Add an `assets/images/app_icon_template.png` — a 1024×1024 blank white square with a centred placeholder cross or church icon — as a starting point for forking churches.
```

No code changes. Documentation only.

---

<a name="feat-013"></a>
## FEAT-013 — App name documentation for forks

### Current State — Where the App Name Lives

| File | Value | Controls |
|---|---|---|
| `android/app/src/main/AndroidManifest.xml` | `android:label="church_analytics"` | Android launcher name |
| `android/app/build.gradle.kts` | `applicationId = "com.church.church_analytics"` | Android package ID |
| `pubspec.yaml` | `name: church_analytics` | Dart package name (internal only, not user-visible) |
| `lib/` (multiple screens) | Hardcoded string `"Church Analytics"` | App bar titles, About screen |
| `windows/runner/Runner.rc` | `ProductName`, `FileDescription` | Windows taskbar/title |

### Proposed Change

Create `docs/FORKING.md`:

```markdown
# Forking Church Analytics for Your Church

## Step 1 — Android launcher name (what users see on their home screen)
Edit `android/app/src/main/AndroidManifest.xml`:
Change `android:label="church_analytics"` to your church name.
Example: `android:label="Nairobi Central SDA"`

## Step 2 — Android application ID (required if publishing to Play Store)
Edit `android/app/build.gradle.kts`:
Change both `namespace` and `applicationId` from `com.church.church_analytics`
to a unique reverse-domain ID for your church.
Example: `com.nairobicentralsda.analytics`

Two apps on the Play Store cannot share the same applicationId.

## Step 3 — Windows app name
Edit `windows/runner/Runner.rc`:
Change the `VALUE "ProductName"` and `VALUE "FileDescription"` strings.

## Step 4 — In-app display name
Search the `lib/` directory for the string `"Church Analytics"` and replace
with your church name. These appear in app bar titles and the About screen.
(Approximately 8–12 occurrences across screens.)

## Step 5 — App icon
Follow the instructions in `docs/CUSTOMISATION.md`.

## Step 6 — Signing (critical for Play Store)
Generate a new signing keystore for your fork.
Do not reuse the original church's keystore.
Follow the Android keytool documentation or Android Studio's signing wizard.

## Step 7 — `pubspec.yaml` name field
The `name: church_analytics` field is the Dart package name.
It is referenced internally by imports (`package:church_analytics/...`).
If you change it, you must run a find-and-replace across all `lib/` imports.
This step is optional if you are not publishing to pub.dev.
```

No code changes. Documentation only.

---

<a name="feat-014"></a>
## FEAT-014 — Home screen: view full list of imported data

**Status:** Complete (2026-05-12)

### Current State
The home screen surfaces summary cards and charts, but there is no way to open a complete list of the data that has already been imported. Users must navigate into individual modules (or cannot find the records at all) to confirm what was imported.

### What Is Requested
From the home screen, provide a "View all imported data" entry that opens a full list of imported records for the current church, with basic filters (type and date) and a read-only view of each record.

### Proposed Change

**Add a simple entry point on the home screen.**
In `lib/ui/screens/dashboard_screen.dart`, add a "View all data" button or list tile in the data summary area.

**Create a new list screen.**
Add `lib/ui/screens/imported_data_screen.dart` that:
- loads imported records via existing repositories/providers
- groups by data type (tabs or filter chips)
- provides date range filtering and search
- navigates to existing detail/edit screens when an item is tapped

**Keep it read-only.** Deletion or editing remains in the existing screens; this screen only exposes the full list.

### Risk
Low. This is a new, read-only screen plus a single navigation entry on the home screen.

---

<a name="feat-015"></a>
## FEAT-015 — Data management: delete imported records

**Status:** Complete (2026-05-12)

### Current State
Imported records can be edited/updated, but there is no delete action in the UI. Mistakes in imported data cannot be removed without manual database edits.

### What Is Requested
Allow users to delete imported records from the app UI, with a confirmation step to prevent accidental loss.

### Proposed Change

**Add delete actions to record views.**
- Add a "Delete" button or menu action in existing record detail/edit screens.
- Confirm with a destructive dialog ("Delete" / "Cancel").

**Wire delete through repositories/DAOs.**
- Add `delete` methods where missing in `lib/repositories/` and `lib/database/` so the UI can remove records safely.
- After deletion, refresh providers so dashboards and charts update.

**Guard against accidental loss.**
- Show a success snackbar and remove the item from lists immediately.
- If a record is referenced elsewhere, block deletion with a clear message (or cascade-delete if appropriate).

### Risk
Medium. This introduces destructive operations and requires careful confirmation and state refresh to avoid orphaned references.

---

<a name="feat-016"></a>
## FEAT-016 — Excel (.xlsx) import support

### Current State

`lib/ui/screens/import_screen.dart` drives data import exclusively through `CsvImportService`, which calls `_fileService.pickFile(allowedExtensions: ['csv'])` and parses the result with the `csv` package. Users who maintain their records in Excel must export their workbook to CSV first — an extra manual step that introduces friction and opportunities for encoding errors (BOM characters, line-ending mismatches).

A second, more capable service already exists: `lib/services/import_service.dart` (`ImportService`) was written to handle both `.csv` and `.xlsx`. It accepts both extensions in `pickFile()`, routes by file extension, and parses XLSX files using the `excel` package (already declared in `pubspec.yaml` at `^2.1.0`). It also shares the same `validateAndConvertRow` / `suggestColumnMapping` logic as `CsvImportService`.

`ImportService` is **not currently wired to `ImportScreen`**. The screen instantiates `CsvImportService` directly:

```dart
// lib/ui/screens/import_screen.dart
final _importService = ImportService();   // ← this is actually CsvImportService
```

*(The variable is named `_importService` but the type is `CsvImportService`; this is a naming inconsistency in the existing code.)*

### What Is Requested

Allow users to upload a `.xlsx` file directly from the Import screen, without converting to CSV first. The column-mapping and validation flow should be identical to the existing CSV path.

### Affected Files

| File | Change |
|---|---|
| `lib/ui/screens/import_screen.dart` | Replace `CsvImportService` with `ImportService`; no other logic changes needed |
| `lib/services/csv_import_service.dart` | No change — kept for any callers outside `ImportScreen` |
| `lib/services/import_service.dart` | No change — already handles both file types |

### Proposed Change

**Step 1 — Swap the service in `ImportScreen`.**

```dart
// lib/ui/screens/import_screen.dart  — BEFORE
import 'package:church_analytics/services/csv_import_service.dart';
...
final _importService = CsvImportService();
```

```dart
// lib/ui/screens/import_screen.dart  — AFTER
import 'package:church_analytics/services/import_service.dart';
...
final _importService = ImportService();
```

Both services expose the same `pickFile()` and `parseFile()` / `parseCsvFile()` signatures (the file-parse method is called `parseFile` on `ImportService` vs `parseCsvFile` on `CsvImportService`). Any call sites that use the parse method will need the rename: `_importService.parseCsvFile(file)` → `_importService.parseFile(file)`.

**Step 2 — Update any user-facing strings** that currently say "CSV file" in `ImportScreen` to say "CSV or Excel file" where appropriate (file-picker dialog hint, error messages, help text).

**Step 3 — No changes to column mapping.** `ImportService.suggestColumnMapping()` is identical to `CsvImportService.suggestColumnMapping()`. The mapping UI, validation, and row-conversion logic are shared and require no modifications.

### Risk

Low. `ImportService` is already written and tested at the service layer. The only code change in `ImportScreen` is the import statement, the constructor call, and the parse-method rename. The entire validation and mapping flow is unchanged. XLSX files with multiple sheets will use the first sheet; this is documented behaviour in `ImportService._parseXlsxFile()`.

---

<a name="feat-017"></a>
## FEAT-017 — Downloadable import template

### Current State

There is no in-app guide to the expected column structure for imported data. Users discover the required columns by trial and error or by reading the source code. The `suggestColumnMapping()` method in `ImportService` (and `CsvImportService`) accepts a set of fuzzy header aliases, but the canonical field names are not surfaced anywhere in the UI.

The correct canonical column names for a weekly record import are:

| Column | Type | Required | Notes |
|---|---|---|---|
| `week_start_date` | Date (YYYY-MM-DD) | ✅ | e.g. `2025-01-05` |
| `men` | Integer | ✅ | |
| `women` | Integer | ✅ | |
| `youth` | Integer | ✅ | |
| `children` | Integer | ✅ | |
| `sunday_home_church` | Integer | ✅ | Home church attendance count |
| `tithe` | Decimal | ✅ | |
| `offerings` | Decimal | Optional | Defaults to 0 if omitted |
| `emergency_collection` | Decimal | Optional | Defaults to 0 if omitted |
| `planned_collection` | Decimal | Optional | Defaults to 0 if omitted |
| `baptisms` | Integer | Optional | Defaults to 0 if omitted |
| `holy_communion` | Integer | Optional | Defaults to 0 if omitted |

These names come directly from `CsvExportService.weeklyRecordHeaders` and are the same headers produced when a user exports their data. The template should therefore be derivable from the export service with no separate maintenance.

### What Is Requested

From the Import screen, provide a "Download Template" button that produces a ready-to-fill spreadsheet with the correct column headers and one example row. Users can open it in Excel or Google Sheets, delete the example row, fill in their data, and re-import without guesswork.

The template should be available in both `.xlsx` format (for Excel users, which is the primary use case driving this feature) and `.csv` format (for users without Excel).

### Affected Files

| File | Change |
|---|---|
| `lib/services/import_template_service.dart` | **New file.** Generates the template bytes in XLSX and CSV formats |
| `lib/ui/screens/import_screen.dart` | Add "Download Template" button; call `ImportTemplateService` |
| `pubspec.yaml` | No change — `excel ^2.1.0` already declared |

### Proposed Change

**Step 1 — Create `lib/services/import_template_service.dart`.**

The service builds the template in memory using the `excel` package for XLSX and the `csv` package for CSV, then writes the result via `FileService.exportFile()`.

```dart
// lib/services/import_template_service.dart

import 'package:church_analytics/services/csv_export_service.dart';
import 'package:church_analytics/services/file_service.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

class ImportTemplateService {
  final FileService _fileService;

  ImportTemplateService({FileService? fileService})
      : _fileService = fileService ?? FileService();

  // Columns that a user needs to fill in (system columns like id, church_id
  // are excluded — the app assigns those on import).
  static const List<String> _templateColumns = [
    'week_start_date',
    'men',
    'women',
    'youth',
    'children',
    'sunday_home_church',
    'tithe',
    'offerings',
    'emergency_collection',
    'planned_collection',
    'baptisms',
    'holy_communion',
  ];

  static const List<dynamic> _exampleRow = [
    '2025-01-05', // week_start_date  — ISO 8601, Sunday of the week
    120,          // men
    95,           // women
    40,           // youth
    30,           // children
    25,           // sunday_home_church
    15000.00,     // tithe
    3200.50,      // offerings
    0,            // emergency_collection
    500.00,       // planned_collection
    2,            // baptisms
    0,            // holy_communion (1 = yes, 0 = no for a weekly flag)
  ];

  Future<String?> downloadXlsx() async {
    final excel = Excel.createExcel();
    final sheet = excel['Weekly Records'];
    excel.setDefaultSheet('Weekly Records');

    // Header row
    sheet.appendRow(_templateColumns.map((h) => TextCellValue(h)).toList());

    // Example row
    sheet.appendRow(_exampleRow.map((v) => _cellValue(v)).toList());

    final bytes = excel.save();
    if (bytes == null) return null;

    return _fileService.exportFile(
      bytes: bytes,
      filename: 'church_analytics_import_template.xlsx',
      mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  Future<String?> downloadCsv() async {
    final rows = [_templateColumns, _exampleRow];
    final csvString = const ListToCsvConverter().convert(rows);
    final bytes = csvString.codeUnits;

    return _fileService.exportFile(
      bytes: bytes,
      filename: 'church_analytics_import_template.csv',
      mimeType: 'text/csv',
    );
  }

  CellValue _cellValue(dynamic v) {
    if (v is int) return IntCellValue(v);
    if (v is double) return DoubleCellValue(v);
    return TextCellValue(v.toString());
  }
}
```

**Step 2 — Add a "Download Template" button to `ImportScreen`.**

Place it near the file-picker button, clearly labelled so users see it before they attempt an import:

```dart
// lib/ui/screens/import_screen.dart — in the pre-import state UI

OutlinedButton.icon(
  onPressed: _downloadTemplate,
  icon: const Icon(Icons.download_outlined),
  label: const Text('Download Template'),
),
```

```dart
Future<void> _downloadTemplate() async {
  final service = ImportTemplateService();
  // Offer both formats via a simple bottom sheet or two separate buttons
  final path = await service.downloadXlsx();
  if (!mounted) return;
  if (path != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Template saved to $path')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not save template')),
    );
  }
}
```

**Column notes to include in the template (as a second sheet or comment row):**

The XLSX template should include a second sheet named `Notes` with one row per column, explaining the expected format. This eliminates the need for any out-of-app documentation:

| Column | Description | Example |
|---|---|---|
| `week_start_date` | Start of the week in ISO format (YYYY-MM-DD). Use the Sunday of the week. | `2025-01-05` |
| `men` / `women` / `youth` / `children` | Attendance count for each group. Integer, no decimals. | `120` |
| `sunday_home_church` | Attendance at the Sunday Home Church service. Integer. | `25` |
| `tithe` | Tithe income for the week. Decimal, no currency symbol. | `15000.00` |
| `offerings` / `emergency_collection` / `planned_collection` | Other income categories. Optional; defaults to 0. | `3200.50` |
| `baptisms` | Number of baptisms that week. Optional; defaults to 0. | `2` |
| `holy_communion` | Whether Holy Communion was held (1 = yes, 0 = no). Optional; defaults to 0. | `1` |

### Risk

Low. Template generation is entirely additive — a new service and a new button. It does not touch any existing import, export, or data path. The only dependency is the `excel` package, already present. Failure in template generation (disk full, permissions) is surfaced as a snackbar and does not affect any other screen state.

---

<a name="testing-checklist"></a>
## Testing Checklist

### BUG-001 — Back button fix

- [ ] `flutter analyze` passes with zero warnings on changed files
- [ ] On Android: launch app fresh → navigate to Dashboard → press system back button → app exits cleanly (does not show loading screen)
- [ ] On Android: launch app fresh → navigate to Dashboard → press AppBar back arrow → no arrow is visible (since `PopScope(canPop: false)` removes it)
- [ ] On Android: first launch, onboarding not complete → crash dialog (simulate a crash) → confirm startup proceeds normally without double navigation
- [ ] On Android: first launch, race condition simulation → add 500ms artificial delay to `_routeFromState()` → confirm onboarding is shown, completing it resolves to dashboard correctly

### BUG-002 — Log export

- [ ] On Android: App Logs screen → Export → file is written to external storage directory → snackbar shows file path
- [ ] On Android: External storage unavailable (rooted device, secondary storage absent) → fallback to internal documents directory → export succeeds
- [ ] On Linux/macOS/Windows: existing log export paths still work unchanged

### FEAT-001 — Tutorial opt-in

- [ ] First launch (onboarding flag not set): after Dashboard loads, dialog appears asking about tour
- [ ] User taps "Skip for now": dialog dismissed, onboarding flag is set to true, no overlay shown, app proceeds normally
- [ ] User taps "Show me around": OnboardingOverlay is pushed and works through all 5 slides as before
- [ ] Second launch: dialog does NOT appear (flag is set)
- [ ] Settings → Help & Tutorial: overlay opens as before, flag NOT changed (fromSettings: true)

### FEAT-002 — Permission request

- [ ] Android 8+ with `REQUEST_INSTALL_PACKAGES` denied: tapping Download Update shows permission dialog
- [ ] User taps Cancel: download does not start
- [ ] User taps Open Settings: system settings screen opens; after returning, if permission still denied, download does not start
- [ ] Android 7 and below: permission check skipped (API not available), existing flow unchanged
- [ ] Windows: permission check skipped entirely, download proceeds as before

### FEAT-003 — Backup before update

- [ ] Pre-update backup dialog appears before install confirmation dialog
- [ ] "Cancel" in backup dialog: entire update flow aborted
- [ ] "Skip & Update": backup dialog dismissed, install confirmation appears as before
- [ ] "Back Up Now": `BackupService.createBackup()` is called, progress shown, on success a checkmark + file path shown, then install confirmation appears
- [ ] "Back Up Now" with backup failure: error message shown in dialog, user can still skip and proceed

### FEAT-004 — Auto-delete installer

- [ ] Android: after successful APK open intent, APK may remain until the next app start
- [ ] Next cold start: `_cleanUpStaleApks()` runs silently, any leftover `.apk` files in system temp are deleted, no error surfaced to user

### FEAT-005 — Already-downloaded package

- [ ] Download APK fully → simulate install failure (deny permission) → tap Download Update again → download is skipped (100% progress shown immediately) → install proceeds
- [ ] Download APK fully → corrupt the file (modify a byte) → tap Download Update again → corrupt file is deleted, fresh download starts

### FEAT-006 — Pause/resume (requires FEAT-006 to be implemented first)

- [ ] Verify production APK URL returns `Accept-Ranges: bytes` in HEAD response before implementing
- [ ] Start download → pause → bytes on disk match progress percentage
- [ ] Resume → download continues from byte offset, not from zero
- [ ] Cancel after pause → partial file deleted
- [ ] Full checksum verification passes after a pause-resume cycle

### FEAT-007 — Resume after closure

- [ ] Start download → kill app mid-download → relaunch → "Resume interrupted download?" dialog appears
- [ ] Choose Discard → partial file deleted, SharedPreferences key cleared
- [ ] Choose Resume → download continues from saved offset (requires FEAT-006)
- [ ] Partial file missing on disk → dialog does NOT appear, SharedPreferences key is silently cleared

### FEAT-008 — Background download

See the dedicated testing checklist in the [FEAT-008 section](#feat-008) above.

### FEAT-010 — Baptism & Holy Communion graphs

- [ ] `flutter analyze` → zero warnings
- [ ] `kPdfGraphCatalogue.length == 20`
- [ ] Every `PdfGraphId` appears exactly once in `kPdfGraphCatalogue`
- [ ] All 3 baptism chart builder methods handle empty dataset without throwing
- [ ] All 4 communion chart builder methods handle empty dataset without throwing
- [ ] Reports screen: all 20 graphs appear, grouped by category, "Holy Communion" section header visible
- [ ] Select all 20 → export PDF → PDF opens without crash
- [ ] Select only communion graphs with zero events in DB → PDF renders empty-chart placeholders, no crash
- [ ] All 13 original graphs render identically to pre-change baseline
- [ ] Existing `flutter test` suite passes

### FEAT-014 — Home screen full data list

- [ ] Home screen shows a "View all data" entry when a church is selected
- [ ] Tapping opens the Imported Data screen with the full list for the current church
- [ ] Type/date filters update the list correctly
- [ ] Empty state is shown when no data has been imported

### FEAT-015 — Delete imported records

- [ ] Delete action is visible in record detail/edit screens
- [ ] Cancel leaves the record unchanged
- [ ] Confirm delete removes the record and it stays deleted after app restart
- [ ] Dashboards and charts refresh to reflect the deletion

### FEAT-016 — Excel import

- [ ] `flutter analyze` passes with zero warnings on changed files
- [ ] Import screen file picker accepts both `.csv` and `.xlsx` extensions
- [ ] Upload a valid `.xlsx` file → column mapping screen appears with headers pre-populated
- [ ] Upload a `.xlsx` file with multiple sheets → first sheet is used, no crash
- [ ] Upload a `.xlsx` file with an empty first sheet → error message shown, no crash
- [ ] Upload a `.xlsx` file with missing required columns → validation errors shown per row
- [ ] Upload a `.xlsx` file with all optional columns absent → records imported with defaults (0)
- [ ] Existing CSV import path still works unchanged after the service swap
- [ ] Error messages in the UI say "CSV or Excel file" where previously they said "CSV file"

### FEAT-017 — Downloadable import template

- [ ] "Download Template" button is visible on the Import screen before a file is selected
- [ ] Tapping the button saves a `.xlsx` file and shows a snackbar with the saved path
- [ ] Saved `.xlsx` opens in Excel / Google Sheets without errors
- [ ] Template `.xlsx` has a `Weekly Records` sheet with the 12 correct column headers in row 1
- [ ] Template `.xlsx` has a populated example row in row 2 with plausible values
- [ ] Template `.xlsx` has a `Notes` sheet with one explanatory row per column
- [ ] A CSV variant of the template (if exposed) produces equivalent headers and example row
- [ ] On Android: file is saved to the expected external storage path; snackbar path is correct
- [ ] On Windows/Linux: file is saved to the expected documents path; snackbar path is correct
- [ ] Failure to write (e.g. no storage permission) shows an error snackbar; no crash

---

<a name="risk-summary"></a>
## Risk Summary

| Item | Risk | Reason |
|---|---|---|
| BUG-001 flag guard in `StartupGateScreen` | Low | Additive guard, does not change routing logic |
| BUG-001 `PopScope` on `DashboardScreen` | Low | Standard Flutter API replacing deprecated pattern; changes back-press to app-exit |
| BUG-002 Android log export path | None | New branch only; existing desktop branches untouched |
| FEAT-001 Tutorial opt-in dialog | Low | Move onboarding gate to Dashboard; remove StartupGate guard issue |
| FEAT-002 Permission request (Android) | Low | New package (`permission_handler`); guarded by `Platform.isAndroid` |
| FEAT-003 Backup before update | Low | New dialog + new file; existing install flow unchanged |
| FEAT-004 Auto-delete installer | Low | Startup-only cleanup; avoids install-time race |
| FEAT-005 Already-downloaded package check | None | Additive file-exists check before network call |
| FEAT-006 Pause/resume download | Medium | Core change to download streaming strategy; requires thorough testing |
| FEAT-007 Resume after closure | Low | Depends on FEAT-006; persistence is SharedPreferences only |
| FEAT-008 Background download (Android) | Medium ↓ from High | Foreground Service as process anchor only; download stays in main isolate; no isolate communication, no token redesign |
| FEAT-009 Platform parity doc | None | Documentation only |
| FEAT-010 Baptism & Communion graphs | None | Entirely additive; 13 existing graphs untouched |
| FEAT-011 PDF completeness | None | Consequence of FEAT-010 |
| FEAT-012 Icon doc | None | Documentation only |
| FEAT-013 Fork name doc | None | Documentation only |
| FEAT-014 Home screen full data list | Low | New read-only screen plus navigation entry |
| FEAT-015 Delete imported records | Medium | Destructive actions; data integrity and refresh required |
| FEAT-016 Excel import support | Low | Service swap + parse-method rename; XLSX parsing already implemented |
| FEAT-017 Downloadable import template | Low | Additive template generation + export; no impact on import flow |

**Recommended implementation order:**
1. BUG-001, BUG-002 (fixes first)
2. FEAT-001, FEAT-004, FEAT-005 (low-risk features)
3. FEAT-014, FEAT-015 (data management)
4. FEAT-016, FEAT-017 (import UX)
5. FEAT-010, FEAT-011, FEAT-012, FEAT-013 (analytics and docs)
6. FEAT-002, FEAT-003, FEAT-009 (update system, lower complexity)
7. FEAT-006, FEAT-007 (update system, medium complexity — implement together)
8. FEAT-008 (implement last; complete the pre-implementation checklist before starting)
