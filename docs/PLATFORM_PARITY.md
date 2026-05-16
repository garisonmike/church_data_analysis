# Platform Feature Parity — Church Analytics

This document records which features work on which platforms, identifies known
gaps, and distinguishes bugs (unintended breakage) from limitations (deliberate
trade-offs or deferred work).

**Update this file whenever a platform-specific code path is added or changed.**
The goal is that any developer picking up this project has a clear baseline and
does not accidentally ship a feature that works on one platform and silently
fails on another.

---

## Supported platforms

| Platform | Status | Primary distribution |
|---|---|---|
| Android | ✅ Primary | Side-loaded APK (self-update system) |
| Windows | ✅ Primary | ZIP release (self-update system) |
| Linux | ✅ Supported | tar.gz release (self-update system) |
| Web | ⚠️ Partial | Static hosting; no installer pipeline |
| macOS | 🔲 Build config present, untested | — |
| iOS | 🔲 Build config present, untested | — |

---

## Feature parity matrix

| Feature | Android | Windows | Linux | Web | Notes |
|---|---|---|---|---|---|
| Update check | ✅ | ✅ | ✅ | ✅ | HTTP fetch of `update_manifest.json` from GitHub |
| Update download | ✅ | ✅ | ✅ | ✅ (browser) | Web opens GitHub Releases in browser tab |
| Update install | ✅ APK intent | ⚠️ Manual copy | ⚠️ Manual copy | N/A | See [Update install](#update-install) |
| Install permission (proactive) | ✅ FEAT-002 | N/A | N/A | N/A | `permission_handler` → `REQUEST_INSTALL_PACKAGES` |
| Background download | ✅ FEAT-008 | ✅ | ✅ | N/A | See [Background download](#background-download) |
| Log export | ✅ BUG-002 fixed | ✅ | ✅ | ❌ | Android uses `getExternalStorageDirectory()` |
| Backup (create) | ✅ | ✅ | ✅ | ✅ | JSON export via `file_picker` |
| Restore (import) | ✅ | ✅ | ✅ | ✅ | JSON import via `file_picker` |
| PDF export | ✅ | ✅ | ✅ | ✅ | `pdf` package; 20 graphs across 4 categories |
| CSV export | ✅ | ✅ | ✅ | ✅ | |
| CSV import | ✅ | ✅ | ✅ | ✅ | |
| File picker (save location) | ✅ | ✅ | ✅ | ✅ | `file_picker ^8.1.6` |
| Onboarding tutorial | ✅ | ✅ | ✅ | ✅ | |
| Crash recovery dialog | ✅ | ✅ | ✅ | ✅ | |

---

## Platform-specific detail

### Update install

**Code location:** `lib/platform/platform_installer_launch_service.dart`

The three platforms diverge significantly here:

**Android** — `_launchAndroid()`: calls `OpenFile.open(apkPath)`, which fires an
APK install intent. The OS handles the rest. The app exits via
`SystemNavigator.pop()` so the installer can run in the foreground (required
by Android). `REQUEST_INSTALL_PACKAGES` must be granted; the permission is
declared in `AndroidManifest.xml` and is now checked proactively before the
download begins (FEAT-002).

**Windows** — `_launchWindows()`: the release is a ZIP archive. PowerShell's
`Expand-Archive` cmdlet extracts it to a staging folder next to the download.
The user then manually copies the extracted files over their existing
installation. **This is a known limitation**, not a bug. Automating the
in-place swap would require a separate helper launcher process (because Windows
locks the running `.exe`). This is noted as future work in the code; no issue
is filed for it yet.

**Linux** — `_launchLinux()`: `tar -xzf` extracts the archive to the system
temp directory. Same manual-copy limitation as Windows.

**Web** — no-op. The download step already opened GitHub Releases in the
browser; there is nothing to install programmatically.

---

### Background download

**Code location:** `lib/services/update_download_service.dart`,
`lib/services/download_foreground_service.dart` (FEAT-008),
called from `lib/ui/widgets/about_updates_card.dart`

The download runs in the Flutter main isolate. On **Windows and Linux** this is
fine — desktop OSes do not throttle background work.

On **Android**, a **Foreground Service** (via `flutter_foreground_task ^8.0.0`)
is started for the duration of the download.  The service acts as a process
anchor: it posts the mandatory persistent notification and prevents Android from
killing the process when the app is backgrounded.  The download itself remains
in the main Dart isolate — no isolate boundary is crossed.

**Architecture decision (FEAT-008 v3.1):** An earlier draft of FEAT-008
(v3.0) proposed moving the download into a `TaskHandler` isolate.  That
approach was discarded because `http.Client` cannot cross an isolate boundary,
and `CancelToken`/`PauseToken` mutations from the UI would be invisible to a
separate isolate heap.  The main-isolate + Foreground Service anchor model
eliminates all three architectural errors from v3.0.  **This section
supersedes the TaskHandler-isolate model previously referenced in §100.**

**Package:** `flutter_foreground_task: ^8.0.0` (pinned — breaking API changes
between v4, v5, and v8).

**Manifest additions (Android):**
- `FOREGROUND_SERVICE` permission
- `FOREGROUND_SERVICE_DATA_SYNC` permission (Android 14+)
- `POST_NOTIFICATIONS` permission (Android 13+, requested at runtime)
- `<service android:name="com.pravera.flutter_foreground_task.service.ForegroundService" android:foregroundServiceType="dataSync" />`

**minSdk:** raised to 21 in `android/app/build.gradle.kts` (Foreground
Services require API 21+; the previous `flutter.minSdkVersion` resolved to 16).

---

### Log export

**Code location:** `lib/ui/screens/log_viewer_screen.dart` — `_exportLogs()`
and `_getExportsDir()` / `_getAndroidExportsDir()`

Fixed by BUG-002 (2026-05-12). Android now uses `getExternalStorageDirectory()`
from `path_provider` to write the log file to the app's external files
directory (e.g. `/sdcard/Android/data/com.church.church_analytics/files`).
No storage permission is required on Android 10+.

The original bug: `_exportLogs()` set `destPath` only inside
`if (Platform.isLinux || Platform.isMacOS || Platform.isWindows)`, so on
Android `destPath` was always `null` and the error snackbar always fired.

---

### Install permission (Android)

**Code location:** `lib/platform/install_permission_service.dart`

Implemented by FEAT-002. Before the APK download starts,
`ensureInstallPermissionGranted(context)` checks
`Permission.requestInstallPackages.status` via `permission_handler ^11.3.1`.
If the permission is not yet granted, an explanation dialog is shown and the
user is taken to the system Settings page. The download proceeds only if the
permission is confirmed on return.

`REQUEST_INSTALL_PACKAGES` was already declared in
`android/app/src/main/AndroidManifest.xml` before FEAT-002; no manifest change
was needed for this feature.

`PlatformInstallerLaunchService._launchAndroid()` also has a reactive fallback:
if `OpenFile.open()` returns `ResultType.permissionDenied`, it returns a
`InstallerLaunchResult.failure` with step-by-step instructions for the user to
grant the permission manually. This fallback remains as a safety net even after
FEAT-002.

---

## Known limitations (by design, not bugs)

| Limitation | Platforms | Tracking |
|---|---|---|
| Update install requires manual file copy | Windows, Linux | Future work (helper launcher) — no issue filed |
| Web: no installer pipeline | Web | By design — browser handles downloads |

---

## How to keep this document current

When you add or modify platform-specific behaviour, update the matrix table
and add or amend the corresponding detail section. The key questions to answer:

1. **Which platforms does the change affect?**
2. **Do any platforms intentionally not get the change?** If so, is this a
   known limitation (document it) or an oversight (file a bug)?
3. **Is there a platform guard in the code?** Record its location here so the
   next developer can find it without grepping.

Useful grep to find all existing platform guards:

```bash
grep -rn "Platform\.isAndroid\|Platform\.isWindows\|Platform\.isLinux\|kIsWeb" lib/ \
  | grep -v "_test\.dart" | grep -v "\.dart_tool"
```
