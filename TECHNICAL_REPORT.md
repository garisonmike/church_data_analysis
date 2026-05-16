# Technical Report — Church Analytics: Feature Work & Bug Fixes

**Date:** May 2026  
**Scope:** Missing screen crash bugs, target analysis card copy, update system improvements, tutorial opt-in, Excel import & template download, background update checker connectivity, onboarding copy  
**Codebase Version:** As at commit `HEAD` on 2026-05-12  
**Author:** garisonmike  
**Report Version:** 3.4 (supersedes v3.3 — adds BUG-001 navigation guard fix; aligns FEAT-006 streaming correctness; adds FEAT-008 architecture alignment note, `flutter_foreground_task` v8 init requirements, and resolved minSdk decision)

---

## How to Use This Report

Each item is self-contained. It documents: what the current code does, what specific files are involved, what the proposed change is, whether there are risks, and what needs to be tested. No item here deletes an existing file or restructures an existing feature. Everything is additive or a surgical single-point fix.

Items are classified as **BUG** (something broken) or **FEAT** (new behaviour requested). They are ordered from lowest to highest implementation complexity within each class.

---

## Table of Contents

- [BUG-001 — `_navigationInProgress` guard suppresses crash recovery and onboarding indefinitely](#bug-001)
- [BUG-003 — Tapping SpecialEvents / HomeChurchAnalytics / BoardMeeting / FinancialGlossary crashes (missing screen classes)](#bug-003)
- [BUG-004 — Target Analysis card description misleads users into thinking the screen is empty](#bug-004)
- [FEAT-001 — Tutorial: ask user before showing onboarding](#feat-001)
- [FEAT-002 — Update: request install-unknown-apps permission proactively](#feat-002)
- [FEAT-003 — Update: prompt user to back up before updating](#feat-003)
- [FEAT-004 — Update: auto-delete installer file after successful update](#feat-004)
- [FEAT-005 — Update: handle already-downloaded package on retry](#feat-005)
- [FEAT-006 — Update: pause and resume download](#feat-006)
- [FEAT-007 — Update: resume download after unexpected app closure](#feat-007)
- [FEAT-008 — Update: continue downloading while app is in background (Android)](#feat-008)
- [FEAT-016 — Excel (.xlsx) import support](#feat-016)
- [FEAT-017 — Downloadable import template](#feat-017)
- [FEAT-018 — Background update checker: connectivity check + trigger on launch and connectivity restore](#feat-018)
- [FEAT-019 — Onboarding slide 4: add Chart Center hint](#feat-019)
- [Testing Checklist](#testing-checklist)
- [Risk Summary](#risk-summary)

---

<a name="bug-001"></a>
## BUG-001 — `_navigationInProgress` guard suppresses crash recovery and onboarding indefinitely

> **Added in Review — High severity. Fix before any FEAT work is merged.**

### Severity
High. As written, the `_navigationInProgress` flag in `startup_gate_screen.dart` is set to `true` before the first `await` in the post-frame callback. Because the flag is **never reset to `false` on the success path**, any subsequent post-frame callback (re-entry from the OS, a hot-restart in debug, or a deferred route trigger) hits the early-return guard and does nothing. The practical effect is that crash recovery and onboarding are silently suppressed after the first call — the user sees a blank or frozen startup screen with no forward route being pushed.

### Root Cause

```dart
// startup_gate_screen.dart — current (broken)
WidgetsBinding.instance.addPostFrameCallback((_) async {
  if (_navigationInProgress) return;   // <— guard checked here
  _navigationInProgress = true;        // <— set before await, never cleared on success
  await _routeFromState();
  // _navigationInProgress remains true forever — next callback always returns early
});
```

The guard was written to prevent concurrent re-entrant calls, but it conflates "in progress right now" with "ever attempted". A flag that is set and never cleared behaves like a one-shot latch rather than a mutex.

### Fix — Two options (choose one)

**Option A — Reset the flag after `_routeFromState()` completes (minimal change):**

```dart
WidgetsBinding.instance.addPostFrameCallback((_) async {
  if (_navigationInProgress) return;
  _navigationInProgress = true;
  try {
    await _routeFromState();
  } finally {
    _navigationInProgress = false;  // always reset, even on exception
  }
});
```

This is the lowest-risk fix. The `finally` block ensures the flag is always cleared — even if `_routeFromState()` throws — so a subsequent callback can retry.

**Option B — Serialize the entire startup flow in a single async chain (preferred for new code):**

Remove the `_navigationInProgress` flag entirely. Instead, ensure `addPostFrameCallback` is only registered once (e.g. in `initState`), and make `_routeFromState()` itself idempotent using a `Completer` or `mounted` checks at each `await` boundary:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) => _startup());
  // Only one registration — no flag needed.
}

Future<void> _startup() async {
  await showCrashRecoveryDialogIfNeeded();
  if (!mounted) return;
  await _routeFromState();
}
```

If `_routeFromState()` is only ever called from this single chain, there is no re-entrancy to guard against.

### Affected Files

| File | Change |
|---|---|
| `lib/ui/screens/startup_gate_screen.dart` | Apply Option A or Option B above |

### Risk
Low. The fix is surgical — it changes flag lifecycle only. The routing logic inside `_routeFromState()` and all downstream navigation calls are untouched. Test by simulating a crash-recovery path on first launch to confirm the dialog appears.

---

<a name="bug-003"></a>
## BUG-003 — Tapping SpecialEvents / HomeChurchAnalytics / BoardMeeting / FinancialGlossary crashes (missing screen classes)

### Severity
High. Any user who taps one of these four navigation entries in `graph_center_screen.dart` receives an immediate crash (either a compile-time `Undefined class` error if the project fails to build, or — if stub imports were accidentally omitted — a runtime `NoSuchMethodError` / `Null check operator used on a null value` when the route builder executes). The affected entries are visible in the UI, so all users are exposed.

### Observed Behaviour
In `lib/ui/screens/graph_center_screen.dart`, four navigation destinations reference the following classes:

```
SpecialEventsScreen
HomeChurchAnalyticsScreen
BoardMeetingAnalyticsScreen
FinancialGlossaryScreen
```

None of these classes exist anywhere in the codebase. The file has import statements (or inline route builders) for each, meaning:
- If the imports are present, the project **fails to compile** entirely.
- If they are missing (the imports were stripped during a prior cleanup), the navigator route builder throws at runtime the moment the user taps the tile.

Either way the app crashes.

### Root Cause
The four screens were planned and wired into the Chart Center navigation before their Dart files were created. The navigation references were committed; the implementations were not.

### Affected Files

| File | What the problem is |
|---|---|
| `lib/ui/screens/graph_center_screen.dart` | References four undefined screen classes |
| *(missing)* `lib/ui/screens/special_events_screen.dart` | Does not exist |
| *(missing)* `lib/ui/screens/home_church_analytics_screen.dart` | Does not exist |
| *(missing)* `lib/ui/screens/board_meeting_analytics_screen.dart` | Does not exist |
| *(missing)* `lib/ui/screens/financial_glossary_screen.dart` | Does not exist |

### Proposed Fix

**Phase 1 — Create placeholder screens (fixes the crash immediately, zero functional regression).**

Create each missing file as a minimal `StatelessWidget` that displays the screen's title and a "Coming soon" body. This unblocks compilation and stops the crash on tap:

```dart
// lib/ui/screens/special_events_screen.dart
import 'package:flutter/material.dart';

class SpecialEventsScreen extends StatelessWidget {
  const SpecialEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Special Events')),
      body: const Center(child: Text('Coming soon')),
    );
  }
}
```

Apply the identical pattern for `HomeChurchAnalyticsScreen`, `BoardMeetingAnalyticsScreen`, and `FinancialGlossaryScreen`, substituting the appropriate title string.

**Phase 2 — Replace placeholders with real screens** as separate follow-on tasks. Each screen gets its own work item and testing. Phase 1 and Phase 2 are deliberately decoupled so the crash is resolved immediately without waiting for full feature implementation.

### Why This Is Safe
Phase 1 creates four new files and changes nothing else. `graph_center_screen.dart` is not modified — the class names it already references will simply become resolvable. No existing navigation routes, providers, or data layers are touched.

### Risk
None (Phase 1). Phase 2 risk depends on the complexity of each individual screen; those are separate assessments.

---

<a name="bug-004"></a>
## BUG-004 — Target Analysis card description misleads users into thinking the screen is empty

### Severity
Low. The screen is fully functional (graphs G-49 through G-74 exist and render), but users abandon it before entering any data because the card description implies there is nothing to see. This is a UX confusion bug, not a code defect.

### Observed Behaviour
On the Chart Center (or wherever the Target Analysis entry card is shown), the card's description text is vague — it does not indicate that the screen contains charts (G-49 to G-74) or that the user needs to enter target data for those charts to populate. Users interpret the empty initial state as a broken or unfinished screen and navigate away.

### Root Cause
The card description copy was written before the screen was fully built and was never updated to reflect the final content. The screen itself works correctly; only the text is wrong.

### Affected Files

| File | Change |
|---|---|
| The file containing the Target Analysis card widget or its string constants | Update description text |

> **Note for implementer:** Locate the card description string in the codebase (likely in `graph_center_screen.dart`, a constants file, or the card widget itself) and confirm the exact current wording before editing.

### Proposed Fix

Replace the current vague description with copy that tells the user two things: what the screen contains, and what action is needed.

**Suggested new description:**

> "Set attendance and financial targets for your church, then view 26 charts (G-49 – G-74) that compare actuals against those targets. Tap to enter your targets and unlock the analysis."

Adjust the exact wording to match the app's existing tone, but the description must communicate: (a) charts exist, (b) data entry is required to activate them.

### What Does NOT Change
The screen, the charts (G-49–G-74), the data model, and any navigation logic are entirely untouched.

### Risk
None. This is a string change only.

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
   
   Change `update_download_service.dart` so that each chunk is appended to the destination file immediately. Two important corrections versus the naïve approach:

   - **Use `sink.add(chunk)` directly, not `await sink.addStream(Stream.value(chunk))`.**  
     Wrapping each chunk in `Stream.value()` and calling `addStream` creates a new single-element stream object per iteration and internally awaits the stream's `done` future before returning. This unnecessary overhead can stall throughput on fast connections. `sink.add()` is synchronous and buffers the write immediately — use it instead.

   - **Track resume progress correctly using `existingLength + received`.**  
     If the download is resumed after a pause or crash (FEAT-007), the partial file already contains `existingLength` bytes on disk. Progress must be `(existingLength + received) / totalContentLength`. Using `received / totalContentLength` alone restarts the progress bar from 0% regardless of how much was already downloaded.

   - **Use `Content-Range` / 206 handling for resume.**  
     When resuming via `Range: bytes=<existingLength>-`, the server responds with HTTP 206. The `Content-Length` header in a 206 response is the *remaining* bytes, not the full file size. Store the total file size from the manifest (or the initial 200 `Content-Length`) and use it as the denominator for all progress calculations.

   ```dart
   final sink = file.openWrite(mode: FileMode.append); // append, not overwrite
   int received = 0;
   final existingLength = await file.length(); // 0 for fresh download, >0 on resume

   try {
     await for (final chunk in streamedResponse.stream) {
       if (cancelToken?.isCancelled == true) { ... }
       if (pauseToken?.isPaused == true) {
         await sink.flush();
         await sink.close();
         return UpdateDownloadResult.paused(file.path, bytesReceived: existingLength + received);
       }
       sink.add(chunk);                                          // NOT addStream(Stream.value(chunk))
       received += chunk.length;
       onProgress?.call((existingLength + received) / totalContentLength); // full-file denominator
     }
     await sink.flush();
     await sink.close();
   } catch (e) {
     await sink.close();
     rethrow;
   }
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

> **Review note — Medium (architectural alignment required before implementation):**  
> The architecture described in this section (download stays in the main isolate; Foreground Service is a process anchor only) **conflicts with `PLATFORM_PARITY.md` §100**, which specifies moving the download into a `TaskHandler` isolate. These two documents must be reconciled before any FEAT-008 code is written. Building from either spec in isolation will produce the wrong architecture and require a rework.  
>  
> **Recommended resolution:** Hold a brief alignment review. The main-isolate approach described here is technically sounder (eliminates the three isolate-boundary errors documented above), but if the parity doc's TaskHandler model has already been agreed with stakeholders, that decision takes precedence and the error analysis above must be addressed first. Update whichever document loses so both specs agree before implementation starts.

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
- [ ] **Confirm the exact v8 API for service startup.** Earlier versions of `flutter_foreground_task` (v4–v7) required a `startCallback` top-level function annotated with `@pragma('vm:entry-point')` and a `setTaskHandler(MyHandler())` call before `startService()` could succeed. If v8 retains this requirement, `DownloadForegroundService.start()` as written in Step 1 will **fail silently at runtime** — `startService()` returns without starting the service and no notification appears. Check the v8 migration guide and the package's own example app to verify whether `@pragma('vm:entry-point')` + `setTaskHandler` are still mandatory. If they are, add the minimal no-op handler:
  ```dart
  @pragma('vm:entry-point')
  void startCallback() {
    FlutterForegroundTask.setTaskHandler(_DownloadAnchorHandler());
  }
  
  class _DownloadAnchorHandler extends TaskHandler {
    @override Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {}
    @override Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {}
    @override Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {}
  }
  ```
  Pass `startCallback` to `FlutterForegroundTask.init()` if required. **Confirm or rule this out before coding Step 1.**
- [ ] The `minSdk` is resolved to **21** in `android/app/build.gradle.kts` per the minSdk Decision section below — confirm the explicit value is committed before building.
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

### minSdk Decision — Resolved

> **Review note:** The pre-implementation checklist originally said "confirm the resolved value before locking this approach." Here is that decision.

`flutter.minSdkVersion` is a Gradle property injected by the Flutter toolchain. Its value is **not fixed** — it is the minimum SDK floor for the Flutter version currently in use. As of Flutter 3.22 (the version required by `flutter_foreground_task ^8.0.0`), `flutter.minSdkVersion` resolves to **16** (Android 4.1). Foreground Services require API 21+. At minSdk 16, any device running Android 4.1–4.4 would receive an APK that references a service class the OS cannot start — resulting in a runtime crash on those devices.

**Decision: set minSdk explicitly to 21.**

The global Android 4.x install base is below 0.1% and dropping. Church Analytics already depends on packages that implicitly require API 21+ (Kotlin coroutines, `flutter_local_notifications`, and the Material 3 theme engine all have practical API 21 floors). Keeping minSdk at 16 provides no real-world benefit and risks confusing the build system.

In `android/app/build.gradle.kts`, replace:

```kotlin
minSdk = flutter.minSdkVersion
```

with:

```kotlin
minSdk = 21  // Raised: ForegroundService requires API 21+; flutter default (16) is insufficient
```

**If your confirmed device targets are Android 8+ only:** raise to **26** instead of 21. This lets you drop the API-level runtime guards in `DownloadForegroundService` (the `if (Build.VERSION.SDK_INT >= 26)` branches) and simplifies testing. Only do this if you have confirmed that no supported device runs Android 5 or 6.

No other Gradle changes are needed. This does not affect Windows or Linux builds.

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

<a name="feat-018"></a>
## FEAT-018 — Background update checker: connectivity check + trigger on launch and connectivity restore

### Current State

The background update checker already runs with a 24-hour cooldown (confirmed in the codebase). However it has two gaps:

1. **No connectivity check.** The checker fires regardless of whether the device has an active network connection. On Android, an HTTP request to the update manifest while offline produces either a `SocketException` or a timeout. Depending on how the error is caught, this can surface a misleading "Update check failed" message to the user, consume battery/CPU on a retry loop, or silently swallow the error — none of which is correct behaviour.

2. **Only triggered by the cooldown timer, not on launch or connectivity restore.** If a user launches the app for the first time that day (within the 24-hour window from the last check), no check fires. If a user was offline all morning and regains connectivity, no check fires unless the timer also happens to expire. The net effect is that users see stale "up to date" status even when a new version has been published.

### What Is Requested

- Wrap every update check HTTP call in a connectivity pre-check. If offline, skip silently and do not count the attempt against the 24-hour cooldown.
- Also trigger a check on cold app launch (subject to the 24-hour cooldown).
- Also trigger a check when connectivity is restored from offline to online (subject to the cooldown, so a device that reconnects 10 minutes after the last check does not immediately re-check).

### Technical Analysis

**Connectivity check approach.**  
The `connectivity_plus` package (pub.dev, well-maintained, MIT licence) provides both a one-shot `Connectivity().checkConnectivity()` call and a `Connectivity().onConnectivityChanged` stream. Check whether `connectivity_plus` is already in `pubspec.yaml`. If not, add it — it has no native permissions requirements and adds negligible APK size (~50 KB).

**Why a one-shot check is sufficient before each HTTP call.**  
A race condition where the device goes offline between the connectivity check and the HTTP call is benign: the HTTP call will throw a `SocketException`, which the existing error handler already catches. The connectivity check is purely an optimisation to avoid unnecessary network attempts and misleading UI states.

**Connectivity-restore trigger.**  
Subscribe to `Connectivity().onConnectivityChanged` in the service or in the app's root widget lifecycle. When the stream emits a status that is not `ConnectivityResult.none`, re-run the update check (if the 24-hour cooldown has elapsed). The stream subscription must be cancelled in `dispose()` to avoid leaks.

**Launch trigger.**  
In the update checker's initialisation path (wherever the first-run or periodic timer is set up), add a call to `_checkForUpdates()` unconditionally on startup, gated only by the existing 24-hour cooldown logic. This is a one-liner.

### Proposed Change

**Step 1 — Add `connectivity_plus` if not already present.**

```yaml
# pubspec.yaml
dependencies:
  connectivity_plus: ^6.0.5   # ADD if not already present — check existing pubspec first
```

No Android manifest changes are needed; `connectivity_plus` does not require the `ACCESS_NETWORK_STATE` permission declaration on modern Flutter (the plugin handles it internally).

**Step 2 — Add a connectivity pre-check helper.**

In the update checker service (locate the file that calls the update manifest HTTP endpoint):

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

/// Returns true if the device has any active network connection.
Future<bool> _hasConnectivity() async {
  final result = await Connectivity().checkConnectivity();
  return result != ConnectivityResult.none;
}
```

**Step 3 — Guard the HTTP call.**

At the entry point of the method that performs the update check:

```dart
Future<void> _checkForUpdates() async {
  if (!await _hasConnectivity()) {
    debugPrint('[UpdateChecker] Skipping — no connectivity');
    return; // Do NOT update the lastChecked timestamp
  }
  // ... existing HTTP + cooldown logic unchanged ...
}
```

The critical invariant: **only update the `lastChecked` timestamp when the HTTP call actually fires.** If the check is skipped due to no connectivity, the timestamp must not be updated, so the cooldown does not consume the user's daily window while offline.

**Step 4 — Trigger on launch.**

Where the update checker is initialised (likely `StartupGateScreen._routeFromState()` or a dedicated `UpdateCheckerService.init()`), add a fire-and-forget launch check after routing is resolved:

```dart
unawaited(UpdateCheckerService.instance.checkIfDue());
// checkIfDue() internally respects the 24-hour cooldown and the connectivity guard
```

**Step 5 — Trigger on connectivity restore.**

In the same initialisation location (or in the root `App` widget's `initState()`), subscribe to the connectivity stream:

```dart
_connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
  if (result != ConnectivityResult.none) {
    unawaited(UpdateCheckerService.instance.checkIfDue());
  }
});
```

Cancel in `dispose()`:

```dart
@override
void dispose() {
  _connectivitySubscription?.cancel();
  super.dispose();
}
```

### Files Changed

| File | Change |
|---|---|
| `pubspec.yaml` | Add `connectivity_plus` if absent |
| Update checker service file | Add `_hasConnectivity()` helper; guard HTTP call; add launch trigger |
| `lib/ui/screens/startup_gate_screen.dart` or root `App` widget | Subscribe to connectivity stream; fire launch check |

### What Does NOT Change
The 24-hour cooldown logic, the manifest parsing, the update notification UI, and all existing update download/install flows are entirely untouched.

### Risk
Low. The connectivity check is purely additive — it adds an early-return guard before existing code. The connectivity stream subscription follows standard Flutter lifecycle patterns and is cancelled on dispose. The only new dependency is `connectivity_plus`, which is one of the most widely used Flutter packages and has no breaking surface on the platforms this app targets (Android, Windows, Linux).

---

<a name="feat-019"></a>
## FEAT-019 — Onboarding slide 4: add Chart Center hint

### Current State
`lib/ui/widgets/onboarding_overlay.dart` contains a 5-slide onboarding flow. Slide 4's current content does not mention the Chart Center or direct users to it for additional analytics graphs.

### What Is Requested
Add a line to slide 4's body text telling users they can find more charts in the Chart Center. The exact placement and phrasing should match the existing slide copy style.

### Proposed Change

Locate slide 4 in `onboarding_overlay.dart` (the slides are likely defined as a list of widget or data objects — find the one at index 3). Add the following sentence to the body copy, appended after the existing text:

> "You can find more detailed charts and category breakdowns in the **Chart Center**."

Adjust phrasing to match the app's existing slide tone. If slide 4 uses a subtitle/body two-field layout, add this as a second body line or as a sub-bullet.

**No structural changes:** do not add new slides, change slide count, or modify slide navigation logic. This is a text addition inside an existing slide only.

### Files Changed

| File | Change |
|---|---|
| `lib/ui/widgets/onboarding_overlay.dart` | Add one sentence to slide 4 body copy |

### What Does NOT Change
All other slides, the slide navigation, the `fromSettings` flag behaviour, and the `markOnboardingComplete()` logic are entirely untouched. FEAT-001's onboarding gate logic is unaffected — it pushes the overlay as a whole; it does not inspect individual slide content.

### Risk
None. Single string addition in a widget data definition.

---

<a name="testing-checklist"></a>
## Testing Checklist

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

### BUG-001 — Navigation guard fix

- [ ] Cold launch with no crash-recovery state: startup routes normally to Dashboard, no freeze or blank screen
- [ ] Cold launch with crash-recovery SharedPreferences key set: crash-recovery dialog appears (confirms the post-frame callback runs past the guard)
- [ ] First launch (onboarding incomplete): onboarding dialog (FEAT-001) appears after Dashboard loads
- [ ] Hot-restart in debug mode: startup flow re-runs cleanly without hanging on the guard
- [ ] `_navigationInProgress` is `false` after `_routeFromState()` completes (add a debug assertion to confirm during development)

### BUG-003 — Missing screen classes

- [ ] `flutter analyze` passes with zero warnings after all four placeholder files are created
- [ ] `flutter build apk --debug` succeeds (no compile-time `Undefined class` errors)
- [ ] Chart Center → tap "Special Events" → `SpecialEventsScreen` opens with correct AppBar title, no crash
- [ ] Chart Center → tap "Home Church Analytics" → `HomeChurchAnalyticsScreen` opens with correct AppBar title, no crash
- [ ] Chart Center → tap "Board Meeting Analytics" → `BoardMeetingAnalyticsScreen` opens with correct AppBar title, no crash
- [ ] Chart Center → tap "Financial Glossary" → `FinancialGlossaryScreen` opens with correct AppBar title, no crash
- [ ] Back navigation from each placeholder returns to Chart Center correctly
- [ ] All existing Chart Center destinations (not among the four new screens) continue to work as before

### BUG-004 — Target Analysis card description

- [ ] Locate the card description string and confirm the new text is deployed
- [ ] Target Analysis card shows a description that mentions charts and data entry requirement
- [ ] Tapping the card still navigates to the Target Analysis screen (navigation unchanged)
- [ ] Charts G-49 through G-74 still render once target data is entered (screen unchanged)

### FEAT-018 — Update checker connectivity + launch/restore triggers

- [ ] `flutter analyze` passes with zero warnings on changed files
- [ ] Device offline at launch → update checker does not fire, no error shown to user, `lastChecked` timestamp unchanged
- [ ] Device online at launch, cooldown expired → update checker fires on startup
- [ ] Device online at launch, cooldown NOT expired → update checker does not fire on startup
- [ ] Device starts offline → regains connectivity → update checker fires (if cooldown elapsed), does not fire (if cooldown has not elapsed)
- [ ] Device online throughout → cooldown behaviour unchanged from current implementation
- [ ] Connectivity stream subscription is cancelled when the subscribing widget/service is disposed (no leaked listeners — verify with Flutter DevTools)
- [ ] Windows: `connectivity_plus` behaves correctly (returns connected status); update checker fires on launch as expected

### FEAT-019 — Onboarding slide 4 Chart Center hint

- [ ] First launch (onboarding not complete) → proceed through to slide 4 → Chart Center hint text is visible
- [ ] Slide 4 layout is not broken (text does not overflow, wraps cleanly on small screens)
- [ ] All 5 slides still render; slide count unchanged
- [ ] Settings → Help & Tutorial → slide 4 shows the updated text
- [ ] Slide 5 (final slide) and its completion behaviour are unchanged

---

<a name="risk-summary"></a>
## Risk Summary

| Item | Risk | Reason |
|---|---|---|
| BUG-001 `_navigationInProgress` flag never cleared | High | Fix immediately — suppresses all startup routing after first call; Option A is one `finally` block |
| BUG-003 Missing screen class placeholders | None | Four new files only; `graph_center_screen.dart` unchanged |
| BUG-004 Target Analysis card description | None | String change only |
| FEAT-001 Tutorial opt-in dialog | Low | Move onboarding gate to Dashboard; remove StartupGate guard issue |
| FEAT-002 Permission request (Android) | Low | New package (`permission_handler`); guarded by `Platform.isAndroid` |
| FEAT-003 Backup before update | Low | New dialog + new file; existing install flow unchanged |
| FEAT-004 Auto-delete installer | Low | Startup-only cleanup; avoids install-time race |
| FEAT-005 Already-downloaded package check | None | Additive file-exists check before network call |
| FEAT-006 Pause/resume download | Medium | Core change to download streaming strategy; `sink.add()` replaces `addStream`; resume progress uses `existingLength + received`; requires thorough testing |
| FEAT-007 Resume after closure | Low | Depends on FEAT-006; persistence is SharedPreferences only |
| FEAT-008 Background download (Android) | Medium | Foreground Service as process anchor only; confirm `flutter_foreground_task` v8 `TaskHandler` requirements and architecture alignment with PLATFORM_PARITY.md before starting |
| FEAT-016 Excel import support | Low | Service swap + parse-method rename; XLSX parsing already implemented |
| FEAT-017 Downloadable import template | Low | Additive template generation + export; no impact on import flow |
| FEAT-018 Update checker connectivity + launch/restore | Low | Additive guard + stream subscription; cooldown logic untouched |
| FEAT-019 Onboarding slide 4 Chart Center hint | None | Single string addition in widget data |

**Recommended implementation order:**
1. BUG-001 (navigation guard fix — fix this before anything else; active startup regression)
2. BUG-003 (placeholder screens — fixes live crash, fastest win)
3. BUG-004 (Target Analysis card copy — quick UX win)
4. FEAT-019 (onboarding copy — trivial)
5. FEAT-001 (tutorial opt-in flow)
6. FEAT-016 (Excel import support)
7. FEAT-017 (downloadable import template)
8. FEAT-002 (install permission prompt)
9. FEAT-003 (backup before update)
10. FEAT-005 (already-downloaded package check)
11. FEAT-004 (auto-delete installer cleanup)
12. FEAT-018 (update checker connectivity + launch/restore)
13. FEAT-006 + FEAT-007 (pause/resume + resume after closure)
14. FEAT-008 (background download — complete pre-implementation checklist first)
