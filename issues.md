# Storage & Update System Hardening – Issue Set

---

## [STORAGE-001] Trimmed export path must be returned and stored

### Summary
Copilot PR review flagged that `_pickExportPath` trims the path only for validation but returns the untrimmed string, which can break downstream file operations.

### Problem
If the picker returns a path with trailing whitespace, saving may fail silently or inconsistently across platforms.

### Scope
- Ensure `_pickExportPath` returns the trimmed value.
- Persist the trimmed value to `_lastExportPath`.
- Add unit-level validation if applicable.
- Ensure no untrimmed path flows into `FileService`.

### Technical Direction
- In `_pickExportPath`, assign `final trimmed = rawPath.trim()` and return `trimmed`.
- Replace all downstream references to the raw return value with `trimmed`.
- Add assertion or guard: `assert(path == path.trim(), 'Export path must not contain leading/trailing whitespace')`.

### Acceptance Criteria
- [x] Returned path is always trimmed.
- [x] Stored export path (`_lastExportPath`) is trimmed.
- [x] No trailing whitespace can cause a save failure.
- [x] No regression in file selection behavior across platforms.

### Regression Risk
Low — isolated logic change with no structural impact.

### Definition of Done
- Code updated
- Manual export test passes on Android, Web, and Linux/Windows
- No file write failures caused by whitespace paths
- Unit test added for trim behavior

### Suggested Labels
`bug`, `storage`, `priority:P1`

**Status: COMPLETE**

---

## [STORAGE-002] Default Downloads/AppName folder strategy

### Summary
The app currently has no consistent default export folder. On platforms where a save dialog is unavailable or dismissed, the export destination is undefined.

### Problem
- File saves fall back to the app sandbox or throw silently on Web and Linux.
- Users have no predictable place to find exported files.
- The current strategy differs per platform without documentation.

### Scope
- Define a `DefaultExportPathResolver` that returns a platform-appropriate default path:
  - Android: `Downloads/ChurchAnalytics/`
  - Linux/Windows: `~/Downloads/ChurchAnalytics/`
  - Web: in-memory blob with forced download (no path concept)
- Create the directory if it does not exist before writing.
- Use this resolver as the fallback when no picker path is available.

### Technical Direction
- Implement `DefaultExportPathResolver` as a platform-conditional class under `lib/platform/`.
- Use `path_provider` (`getDownloadsDirectory`, `getExternalStorageDirectory`) where applicable.
- Inject into `FileService` via constructor or provider.

### Acceptance Criteria
- [x] All platforms have a defined default export path.
- [x] Directory is created automatically if absent.
- [x] Web download is not affected by path logic.
- [x] Default path is exposed to the UI (see STORAGE-005).
- [x] No `null` path reaches `FileService.saveFile`.

### Regression Risk
Low — new fallback path; existing picker flow unchanged.

### Definition of Done
- `DefaultExportPathResolver` implemented and tested per platform
- Integration with `FileService` confirmed
- Manual export without picker confirmed on Android and Linux

**Status: COMPLETE**

### Suggested Labels
`enhancement`, `storage`, `cross-platform`, `priority:P2`

---

## [STORAGE-003] Allow custom save location override

### Summary
Users cannot persistently override the default export folder. Every session resets the save location to the platform default.

### Problem
- Power users working with a specific folder (e.g., shared network drive) must re-select it every session.
- No settings field exists to persist a user-chosen base export directory.

### Scope
- Add a "Default Export Folder" field in App Settings.
- Persist the chosen path to `SharedPreferences` under key `default_export_path`.
- Load and apply this preference in `DefaultExportPathResolver` before falling back to the platform default.
- Add a "Reset to Default" action to clear the override.

### Technical Direction
- Add `SettingsRepository.getDefaultExportPath()` / `setDefaultExportPath(String path)`.
- In Settings UI, add a `ListTile` with trailing `IconButton` to trigger the folder picker.
- Feed the persisted path into `DefaultExportPathResolver.resolve()` as the highest-priority source.

### Acceptance Criteria
- [x] User can select and persist a custom export folder from Settings.
- [x] Custom path is used in all subsequent export operations.
- [x] "Reset to Default" clears the override and falls back to platform default.
- [x] Setting survives app restart.
- [x] Picker validates the path is writable before saving.

### Regression Risk
Low — additive feature; default path logic unchanged when no override is set.

### Definition of Done
- Settings UI field implemented
- Persistence via `SharedPreferences` confirmed
- Export uses custom path when set
- Reset behavior tested

**Status: COMPLETE**

### Suggested Labels
`enhancement`, `storage`, `priority:P2`

---

## [STORAGE-004] Export/Import activity log in Settings

### Summary
There is no record of past export or import operations. Users cannot verify when a backup was last saved or whether an import succeeded.

### Problem
- Silent failures leave users unaware that an operation did not complete.
- No audit trail exists for data operations.
- Support requests cannot be diagnosed without operation history.

### Scope
- Implement an `ActivityLogService` that appends timestamped entries on each export/import operation.
- Log: operation type, filename, path, status (success/failure), error message if applicable.
- Persist log to `SharedPreferences` or a local SQLite table (max 50 entries, FIFO).
- Add a "Recent Activity" section in App Settings displaying the last 10 entries.

### Technical Direction
- `ActivityLogEntry` model: `{ id, type, filename, path, status, message, timestamp }`.
- `ActivityLogService.log(ActivityLogEntry)` appends and trims to max size.
- UI: `ListView` in Settings, each entry as a `ListTile` with icon (success=green, failure=red), filename, and relative timestamp.

### Acceptance Criteria
- [ ] Every export operation produces a log entry (success or failure).
- [ ] Every import operation produces a log entry (success or failure).
- [ ] Log is visible in Settings under "Recent Activity".
- [ ] Log persists across app restarts.
- [ ] Log is capped at 50 entries; oldest are removed automatically.
- [ ] Error message is shown for failed operations.

### Regression Risk
Low — purely additive; no changes to existing export/import logic paths.

### Definition of Done
- `ActivityLogService` implemented and wired to export and import call sites
- Settings UI section added and verified
- Persistence confirmed across app restart

### Suggested Labels
`enhancement`, `storage`, `priority:P3`

---

## [STORAGE-005] Persist and display current default export folder

### Summary
Users have no visibility into where their exported files will be saved. The current export destination is opaque.

### Problem
- After a successful export, users do not know which folder was used.
- There is no indicator in the UI of the active export path before or after saving.
- This leads to confusion when files are not found in the expected location.

### Scope
- Display the resolved default export folder in App Settings under "Storage".
- Update the displayed path live when the user changes the override (see STORAGE-003).
- After a successful export, show the full file path in the confirmation message (see STORAGE-006).

### Technical Direction
- Add a read-only `ListTile` in the Settings "Storage" section: label = "Current Export Folder", subtitle = resolved path.
- Subscribe to `SettingsRepository.watchDefaultExportPath()` stream so the tile updates reactively.
- On platforms where path is not applicable (Web), display "Browser Downloads".

### Acceptance Criteria
- [ ] Settings screen shows the active export directory.
- [ ] Path updates immediately when the user sets a custom override.
- [ ] Resets to platform default text when override is cleared.
- [ ] Web displays "Browser Downloads" in place of a path.
- [ ] Path text is selectable/copyable on desktop.

### Regression Risk
Low — display-only addition to Settings.

### Definition of Done
- Settings tile implemented and reactive
- Web fallback label confirmed
- Path updates correctly after STORAGE-003 override change

### Suggested Labels
`enhancement`, `storage`, `ui`, `priority:P3`

---

## [STORAGE-006] Extended success/failure message with full file path

### Summary
Current export/import success and failure messages are generic and do not include the file path or actionable detail.

### Problem
- "Export successful" gives no indication of where the file was saved.
- "Export failed" gives no reason, making debugging impossible for end users.
- Failure messages do not distinguish between permission errors, path errors, and I/O errors.

### Scope
- Extend `SnackBar` messages on export/import completion to include:
  - **Success:** filename, full path (truncated with ellipsis if > 60 chars), "Open folder" action button (desktop/Android).
  - **Failure:** human-readable error classification (permission denied, invalid path, storage full, unknown), and suggested remediation.
- Add `copyToClipboard` icon on path text (desktop only).

### Technical Direction
- Create `ExportResultMessage` value class: `{ success, filename, path, errorType, errorDetail }`.
- `FileService` returns `ExportResultMessage` instead of `bool`.
- SnackBar builder consumes `ExportResultMessage` to render the correct widget.
- "Open folder" uses `url_launcher` to open the directory in the OS file manager.

### Acceptance Criteria
- [ ] Success message shows filename and path.
- [ ] Path is truncated gracefully if too long.
- [ ] "Open folder" button is shown on Android and desktop; hidden on Web.
- [ ] Failure message classifies the error type.
- [ ] Failure message includes a suggested action (e.g., "Check storage permissions").
- [ ] No regression in existing SnackBar dismiss behavior.

### Regression Risk
Low-Medium — `FileService` return type changes; all call sites must be updated.

### Definition of Done
- `ExportResultMessage` model implemented
- `FileService` updated and all call sites migrated
- SnackBar builder implemented and manually tested on all platforms
- [ ] All call sites updated to handle `ExportResultMessage`
- [ ] No legacy boolean return logic remains in any call site

### Suggested Labels
`enhancement`, `storage`, `ui`, `priority:P2`

---

## [STORAGE-007] Never silently save to hidden directories

### Summary
On some platforms, file operations may fall back to hidden or app-internal directories (e.g., `/data/data/...`) that users cannot access, causing a silent "successful" export that is irrecoverable without root access.

### Problem
- If `getExternalStorageDirectory` returns a non-user-accessible path on Android, exported files are effectively lost.
- There is no guard to reject internal/hidden paths before write.
- Users believe their data is backed up when it is not accessible.

### Scope
- Add a `PathSafetyGuard.isUserAccessible(String path)` function.
- Reject paths that match known hidden or internal patterns (e.g., contain `/data/data/`, `/.`, `/cache/`, `/code_cache/`).
- If the resolved path fails the guard, fall back to `Downloads/ChurchAnalytics/` and emit a warning log entry (see STORAGE-004).
- Surface a non-blocking warning in the UI if the fallback was used.

### Technical Direction
- Implement `PathSafetyGuard` in `lib/platform/`.
- Apply guard check in `DefaultExportPathResolver.resolve()` after path is determined.
- Guard patterns should be platform-specific (Android patterns differ from Linux).

### Acceptance Criteria
- [x] Paths containing `/data/data/`, `/.`, `/cache/` are rejected.
- [x] Fallback to `Downloads/ChurchAnalytics/` is automatic and logged.
- [x] A non-blocking warning banner informs the user that the path was overridden.
- [x] Valid user-accessible paths pass the guard without impact.
- [x] Unit tests cover known hidden path patterns.

### Regression Risk
Low — guard is a new pre-write check; write logic unchanged.

### Definition of Done
- `PathSafetyGuard` implemented and tested
- Integration confirmed in `DefaultExportPathResolver`
- Warning UI confirmed on Android emulator

### Suggested Labels
`bug`, `storage`, `cross-platform`, `priority:P1`

**Status: COMPLETE**

---

## [STORAGE-008] Centralized FileService abstraction

### Summary
File save and read operations are scattered across multiple screens and services with no single point of control, making consistent error handling, logging, and path validation impossible.

### Problem
- Export logic is duplicated in `reports_screen.dart`, `import_screen.dart`, and others.
- Path validation, safety guards, and activity logging must be applied in each location independently.
- Any change to file handling policy requires multiple touch points.

### Scope
- Create `FileService` as the single entry point for all file I/O operations.
- `FileService` provides:
  - `Future<ExportResult> exportFile({ required String filename, required String content, String? forcedPath })`
  - `Future<ExportResult> exportFileBytes({ required String filename, required Uint8List bytes, String? forcedPath })`
  - `Future<ImportResult> importFile({ required List<String> allowedExtensions })`
- Internally applies: path resolution, safety guard, activity logging, and error classification.
- All screens delegate file operations to `FileService` exclusively.

### Technical Direction
- Implement `FileService` under `lib/services/file_service.dart`.
- Inject `DefaultExportPathResolver`, `PathSafetyGuard`, `ActivityLogService`, and `FileStorageImpl` via constructor.
- Register as Riverpod provider.
- Migrate all existing direct file operation call sites to use `FileService`.

### Acceptance Criteria
- [x] `FileService` is the only class that calls `FileStorageImpl` directly.
- [x] All export call sites in screens are migrated to `FileService`.
- [x] All import call sites in screens are migrated to `FileService`.
- [x] Activity logging fires automatically for every operation.
- [x] Path safety guard fires automatically for every export.
- [x] No duplicated file I/O logic remains in screen or repository classes.

### Regression Risk
High — broad refactor touching all file I/O paths. Full regression test required.

### Definition of Done
- `FileService` implemented and fully injected
- All call sites migrated
- Existing import and export workflows tested end-to-end on all platforms
- Activity log entries confirmed for each operation
- [x] All export formats (PDF, CSV, image) tested
- [x] Import workflow tested end-to-end
- [x] No regression in error handling

**Status: COMPLETE**

### Suggested Labels
`refactor`, `storage`, `cross-platform`, `priority:P1`

---

## [STORAGE-009] Filename sanitization & normalization

### Summary
Export filenames are not sanitized against invalid characters or reserved names.

### Problem
Invalid filenames can cause failures on Windows or inconsistent behavior across platforms.

### Scope
- Strip invalid filesystem characters per platform.
- Prevent Windows reserved names (CON, PRN, AUX, etc.).
- Normalize whitespace.
- Enforce safe max filename length.

### Acceptance Criteria
- [x] Invalid characters removed.
- [x] Reserved names blocked or auto-modified.
- [x] Whitespace normalized.
- [x] Filename length capped safely.

### Regression Risk
Medium

### Definition of Done
- Cross-platform filename sanitizer implemented
- PDF, CSV, image exports tested
- No regression in export naming

**Status: COMPLETE**

### Suggested Labels
`storage`, `filesystem`, `priority:P1`

---

## [STORAGE-010] Duplicate filename conflict resolution

### Summary
Duplicate export filenames currently have undefined behavior.

### Problem
Files may overwrite silently or fail inconsistently.

### Scope
- Define default behavior.
- Auto-append (1), (2), etc. OR timestamp.
- Never silently overwrite without confirmation.

### Acceptance Criteria
- [x] Duplicate detection implemented.
- [x] Auto-rename logic applied.
- [x] No silent overwrites.
- [x] Behavior documented.

### Regression Risk
Medium

### Definition of Done
- Duplicate handling tested
- Confirmed no data loss risk

**Status: COMPLETE**

### Suggested Labels
`storage`, `data-integrity`, `priority:P1`

---

## [UPDATE-001] Introduce update.json contract

### Summary
The app has no mechanism to check for available updates. A machine-readable `update.json` contract must be defined and hosted on GitHub Releases to enable the update system.

### Problem
- Users have no way to discover new versions from within the app.
- There is no agreed schema for version metadata that `UpdateService` can consume.

### Scope
- Define the `update.json` schema:
  ```json
  {
    "version": "1.2.0",
    "release_date": "2026-03-01",
    "min_supported_version": "1.0.0",
    "release_notes": "- Fixed overflow bug\n- Improved import speed",
    "platforms": {
      "android": {
        "download_url": "https://github.com/.../app-release.apk",
        "sha256": "abc123..."
      },
      "windows": {
        "download_url": "https://github.com/.../ChurchAnalytics-Setup.exe",
        "sha256": "def456..."
      },
      "linux": {
        "download_url": "https://github.com/.../church-analytics-linux.tar.gz",
        "sha256": "ghi789..."
      }
    }
  }
  ```
- Host `update.json` at a stable URL under the GitHub Releases latest tag.
- Document the schema in `docs/update-contract.md`.
- Document the stable URL format.
- Document versioned vs latest URL strategy.
- Test and document CORS compatibility for Web clients.

### Technical Direction
- Add `UpdateManifest` Dart model with `fromJson` factory.
- Add `PlatformAsset` sub-model: `{ downloadUrl, sha256 }`.
- Schema version field to allow future non-breaking evolution.

### Acceptance Criteria
- [ ] `update.json` schema is fully documented.
- [ ] `UpdateManifest` Dart model parses the schema without error.
- [ ] Unknown fields are ignored gracefully (forward compatibility).
- [ ] Missing required fields throw a typed `UpdateManifestParseException`.
- [ ] Unit tests cover valid, partial, and malformed JSON inputs.

### Regression Risk
None — new contract and model only.

### Definition of Done
- Schema documented in `docs/update-contract.md`
- `UpdateManifest` model implemented with unit tests
- Example `update.json` committed to `docs/`

### Suggested Labels
`enhancement`, `update-system`, `priority:P2`

---

## [UPDATE-002] Implement UpdateService

### Summary
A dedicated `UpdateService` must be implemented to fetch, parse, and cache the remote `update.json` manifest for consumption by the UI.

### Problem
- No service exists to perform the HTTP fetch and version comparison lifecycle.
- Update checks must be debounced and cached to avoid excessive network calls.

### Scope
- Implement `UpdateService` under `lib/services/update_service.dart`:
  - `Future<UpdateCheckResult> checkForUpdate()`
  - `UpdateCheckResult` contains: `{ isUpdateAvailable, latestVersion, currentVersion, manifest, error }`
- Fetch from the stable `update.json` URL defined in `UPDATE-001`.
- Cache result in memory for the session; re-fetch only on explicit user action or app foreground.
- Handle network errors, timeouts (10s), and JSON parse failures gracefully.

### Technical Direction
- Use `http` package for the fetch.
- Parse response with `UpdateManifest.fromJson`.
- Compare versions using `package_info_plus` to obtain current version.
- Register as Riverpod `AsyncNotifierProvider`.

### Acceptance Criteria
- [ ] `checkForUpdate()` returns correct `isUpdateAvailable` flag.
- [ ] Network timeout of 10 seconds is enforced.
- [ ] Malformed JSON returns a typed error, not an unhandled exception.
- [ ] Result is cached for the session; repeated calls do not re-fetch.
- [ ] Unit tests mock HTTP responses for: update available, up-to-date, network error, parse error.

### Regression Risk
Low — new service with no changes to existing code.

### Definition of Done
- `UpdateService` implemented
- Riverpod provider registered
- Unit tests pass for all response scenarios

### Suggested Labels
`enhancement`, `update-system`, `priority:P2`

---

## [UPDATE-003] Version comparison logic

### Summary
Semantic version comparison must be implemented correctly to determine whether the remote version is newer than the installed version.

### Problem
- String comparison of version numbers (e.g., `"1.10.0" > "1.9.0"`) fails with lexicographic ordering.
- Pre-release suffixes (e.g., `1.2.0-beta`) must be handled or explicitly excluded.

### Scope
- Implement `VersionComparator.isNewer(String current, String remote)` returning `bool`.
- Parse major, minor, patch segments as integers.
- Treat pre-release versions as lower than the corresponding release.
- Expose `VersionComparator.parse(String version)` returning a comparable `Version` object.

### Technical Direction
- Either implement a lightweight `Version` value class or adopt `pub_semver` package.
- `isNewer` returns `true` only when `remote > current` by semver rules.
- Handle malformed version strings by returning `false` and logging a warning (never crash).

### Acceptance Criteria
- [ ] `1.10.0` is correctly identified as newer than `1.9.0`.
- [ ] `1.2.0` is not identified as newer than `1.2.0`.
- [ ] `1.2.1` is identified as newer than `1.2.0`.
- [ ] `1.2.0-beta` is identified as older than `1.2.0`.
- [ ] Malformed version returns `false` without crashing.
- [ ] Unit tests cover all cases above plus edge cases.

### Regression Risk
None — new utility only.

### Definition of Done
- `VersionComparator` implemented with full unit test coverage
- Integrated into `UpdateService.checkForUpdate()`

### Suggested Labels
`enhancement`, `update-system`, `priority:P2`

---

## [UPDATE-004] Settings → Check for Updates UI

### Summary
Users must be able to manually trigger an update check from within App Settings and see the result inline.

### Problem
- There is no surface in the app where users can check for or learn about available updates.
- The current app version is not displayed to users.

### Scope
- Add an "About & Updates" section in App Settings:
  - Display current app version (from `package_info_plus`).
  - "Check for Updates" button that triggers `UpdateService.checkForUpdate()`.
  - Inline result states: loading spinner, "Up to date", "Update available (v1.x.x)", error message.
- When an update is available, show a "View Release Notes" link (see UPDATE-005) and a "Download Update" button (see UPDATE-006).

### Technical Direction
- Consume `UpdateService` via Riverpod provider.
- Button is disabled while check is in progress.
- State machine: `idle → checking → upToDate | updateAvailable | error`.
- Display `last checked: <relative time>` below the button.

### Acceptance Criteria
- [ ] Current version is displayed accurately.
- [ ] "Check for Updates" triggers a fresh fetch.
- [ ] Loading state disables button and shows spinner.
- [ ] "Up to date" state is shown when no update is available.
- [ ] "Update available" state shows the new version number.
- [ ] Error state shows a human-readable message and retry option.
- [ ] Last-checked timestamp displayed after each check.

### Regression Risk
Low — additive UI section in Settings.

### Definition of Done
- Settings section implemented
- All state transitions confirmed manually
- Works on all platforms

### Suggested Labels
`enhancement`, `update-system`, `ui`, `priority:P2`

---

## [UPDATE-005] Release notes rendering dialog

### Summary
When an update is available, users should be able to read the release notes before deciding to download.

### Problem
- Without release notes, users cannot assess whether an update is relevant or safe to install.
- Raw markdown from `update.json` cannot be rendered directly.

### Scope
- Implement `ReleaseNotesDialog` that opens when the user taps "View Release Notes".
- Render the `release_notes` field from `UpdateManifest` as formatted text.
- Support basic markdown: headings, bullet lists, bold, inline code.
- Dialog has a "Download Update" action and a "Dismiss" action.

### Technical Direction
- Use `flutter_markdown` package for rendering.
- Dialog is a `showDialog` call with a `ConstrainedBox(maxHeight: 0.75 * screenHeight)` and internal `SingleChildScrollView`.
- "Download Update" button calls into UPDATE-006.

### Acceptance Criteria
- [ ] Release notes are rendered with bullet list and bold formatting.
- [ ] Dialog scrolls for long release notes.
- [ ] "Download Update" button is present and functional.
- [ ] "Dismiss" closes dialog with no action.
- [ ] Dialog height is capped at 75% of screen height.
- [ ] Works correctly at all breakpoints.

### Regression Risk
None — new dialog only.

### Definition of Done
- `ReleaseNotesDialog` implemented and connected to UPDATE-004 UI
- Markdown rendering confirmed for common note formats
- Tested at narrow and wide breakpoints

### Suggested Labels
`enhancement`, `update-system`, `ui`, `priority:P3`

---

## [UPDATE-006] Download installer from GitHub Releases

### Summary
Once an update is confirmed, the correct platform-specific installer binary must be downloaded to the device.

### Problem
- No download mechanism exists within the app.
- Platform detection must select the correct asset URL from `UpdateManifest`.
- Download progress must be visible to the user.

### Scope
- Implement `UpdateDownloadService.downloadInstaller()`:
  - Detect current platform.
  - Select the appropriate `PlatformAsset.downloadUrl` from the manifest.
  - Stream download progress to the UI.
  - Verify SHA-256 checksum after download.
  - Save to a temporary directory.
- Show a progress dialog during download with percentage indicator and cancel option.

### Technical Direction
- Use `http` package with `StreamedResponse` for progress tracking.
- Use `crypto` package for SHA-256 verification.
- Save to `getTemporaryDirectory()` result.
- On Web, open the download URL in a new tab instead of streaming.

### Acceptance Criteria
- [ ] Correct asset URL is selected per platform.
- [ ] Download progress is shown as a percentage.
- [ ] User can cancel the download.
- [ ] SHA-256 checksum is verified after completion.
- [ ] Checksum mismatch shows an error and deletes the partial file.
- [ ] On Web, the download URL is opened in a new browser tab.
- [ ] Temporary file path is returned for use by UPDATE-007.

### Regression Risk
Low — new service; no changes to existing code.

### Definition of Done
- `UpdateDownloadService` implemented
- Progress dialog confirmed
- Checksum verification tested with correct and incorrect hashes
- Web behavior confirmed

### Suggested Labels
`enhancement`, `update-system`, `cross-platform`, `priority:P3`

---

## [UPDATE-007] Platform-specific installer execution

### Summary
After the installer is downloaded (UPDATE-006), the app must hand off to the OS to execute the installer and gracefully exit.

### Problem
- Each platform requires a different mechanism to launch an installer:
  - Android: `ACTION_VIEW` intent with APK MIME type (requires `REQUEST_INSTALL_PACKAGES` permission).
  - Windows: `Process.run` with the `.exe` installer path.
  - Linux: `xdg-open` or `chmod +x && ./installer.tar.gz` extraction flow.
  - Web: no-op (download handled by browser in UPDATE-006).
- No unified abstraction exists for installer launch.

### Scope
- Implement `InstallerLaunchService` with platform-conditional implementations under `lib/platform/`.
- `InstallerLaunchService.launch(String installerPath)` performs the correct OS action per platform.
- After launch, call `SystemNavigator.pop()` or equivalent to exit the app gracefully.
- Show a final confirmation dialog before launching: "The app will close to complete the update."

### Technical Direction
- Android: use `open_file` or `android_intent_plus` to trigger APK install intent.
- Windows: `Process.start(installerPath, [])` then `exit(0)`.
- Linux: extract tarball to target directory then prompt user to restart manually.
- Confirmation dialog must be non-dismissable (barrierDismissible: false).

### Acceptance Criteria
- [ ] Android launches the APK install flow correctly.
- [ ] Windows launches the setup `.exe` and exits the app.
- [ ] Linux extracts the tarball and shows manual restart instructions.
- [ ] Web is a no-op — no installer launch attempted.
- [ ] Confirmation dialog appears before any platform action is taken.
- [ ] App exits cleanly after handoff on Android and Windows.
- [ ] If install permission not granted (Android 8+), show instruction dialog.
- [ ] Detect and handle permission denial gracefully.

### Regression Risk
Low — new service; existing app lifecycle is only affected during explicit update flow.

### Definition of Done
- `InstallerLaunchService` implemented per platform
- Confirmation dialog implemented
- Manually tested on Android emulator and Linux desktop
- Windows behavior documented if untestable in current environment

### Suggested Labels
`enhancement`, `update-system`, `cross-platform`, `priority:P3`

---

## [UPDATE-008] Update error handling & fallback messaging

### Summary
All stages of the update flow (check, download, verify, install) must have consistent, user-friendly error handling with clear fallback actions.

### Problem
- A failed update check currently has no user-facing error.
- A failed download leaves a partial file with no cleanup.
- A checksum mismatch has no guidance for the user.
- There is no fallback that directs users to the GitHub Releases page manually.

### Scope
- Define `UpdateErrorType` enum: `networkError`, `parseError`, `downloadError`, `checksumMismatch`, `installError`, `unsupportedPlatform`.
- Map each error type to:
  - A human-readable message string.
  - A suggested action (retry, open browser, contact support).
- In all update UI surfaces, display error with `UpdateErrorType`-appropriate messaging.
- Always offer "Open GitHub Releases" as an ultimate fallback action using `url_launcher`.

### Technical Direction
- Centralize error message strings in `UpdateErrorMessages` class.
- `UpdateCheckResult` and `UpdateDownloadResult` carry `UpdateErrorType?`.
- Error state in Settings (UPDATE-004) shows the error message and the fallback link.
- Partial downloaded files are deleted in the `catch` block of `UpdateDownloadService`.

### Acceptance Criteria
- [ ] Each `UpdateErrorType` has a distinct, actionable user-facing message.
- [ ] "Open GitHub Releases" fallback is shown for all error types.
- [ ] Partial files are cleaned up on download failure.
- [ ] Checksum mismatch shows a security-specific warning message.
- [ ] Network error shows a connectivity-specific message with retry button.
- [ ] No unhandled exceptions propagate from the update flow to the top-level error handler.

### Regression Risk
Low — error handling additions only; no changes to happy path.

### Definition of Done
- `UpdateErrorType` and `UpdateErrorMessages` implemented
- All error paths in UPDATE-002, UPDATE-006, UPDATE-007 wired to typed errors
- Error messages reviewed for clarity
- Fallback URL action confirmed functional

### Suggested Labels
`enhancement`, `update-system`, `stability`, `priority:P2`

---

## [UPDATE-009] Manifest authenticity & trust model

### Summary
Currently we verify SHA-256 integrity of downloaded installers using `update.json`. However, `update.json` itself is not authenticated. If the GitHub repo or DNS is compromised, a malicious `update.json` could redirect to a different installer and provide a matching hash.

### Problem
We verify file integrity but not source authenticity. This leaves a supply-chain trust gap.

### Scope
- Require HTTPS-only update URLs.
- Document trust model explicitly.
- Optionally support GitHub host pinning (future-ready structure).
- Document future detached-signature strategy for `update.json`.
- Add `docs/update-contract.md` explaining:
  - Integrity vs authenticity
  - Trust assumptions
  - Threat model

### Technical Direction
- Enforce HTTPS scheme validation.
- Reject non-HTTPS URLs.
- Add documentation describing current trust boundary.
- Design extension point for signature verification (do not implement signature yet).

### Acceptance Criteria
- [ ] `UpdateService` rejects non-HTTPS URLs.
- [ ] `update.json` trust model documented.
- [ ] `docs/update-contract.md` created.
- [ ] Architecture allows future signature validation.

### Regression Risk
Low

### Definition of Done
- Documentation committed
- URL scheme enforcement implemented
- No breaking change to existing update flow

### Suggested Labels
`security`, `update-system`, `priority:P1`

---

## [UPDATE-010] Pre-download disk space validation

### Summary
Installer downloads do not verify available disk space before starting.

### Problem
Users may experience partial downloads or unexplained failures if storage is insufficient.

### Scope
- Retrieve installer `Content-Length`.
- Compare against available disk space.
- Abort early if insufficient space.
- Provide actionable error message.

### Acceptance Criteria
- [ ] Installer size retrieved before download.
- [ ] Free disk space calculated.
- [ ] Download aborted if insufficient space.
- [ ] User receives clear error message.

### Regression Risk
Low

### Definition of Done
- Disk space check implemented
- Tested on Windows, Linux, Android
- No silent download failure

### Suggested Labels
`update-system`, `reliability`, `priority:P2`

---

## [UPDATE-011] Failed install recovery guidance

### Summary
If installer launch fails, user receives insufficient guidance.

### Scope
- Detect installer launch failure.
- Provide fallback GitHub Releases link.
- Log failure in `ActivityLogService`.

### Acceptance Criteria
- [ ] Failure detected.
- [ ] Manual install instructions shown.
- [ ] GitHub link displayed.
- [ ] Failure logged.

### Regression Risk
Low

### Definition of Done
- Failure detection implemented
- Fallback UI confirmed
- Log entry confirmed

### Suggested Labels
`update-system`, `resilience`, `priority:P2`

---

## [UPDATE-012] Web update cache invalidation strategy

### Summary
Flutter Web deployments may cache `update.json`, preventing update detection.

### Scope
- Add version query parameter strategy OR document required cache headers.
- Ensure CORS compatibility.

### Acceptance Criteria
- [ ] Cache invalidation strategy documented.
- [ ] Web update check tested.
- [ ] No stale `update.json` behavior.

### Regression Risk
Low

### Definition of Done
- Strategy documented
- Web update check confirmed working after deployment

### Suggested Labels
`update-system`, `web`, `priority:P2`

---

## [UPDATE-013] Optional background update check

### Summary
Currently updates are only checked manually. Users who do not visit Settings will never be notified of available updates.

### Scope
- Optional silent check on app start (at most once per 24 hours).
- Non-blocking notification banner if update is available.

### Acceptance Criteria
- [ ] Background check runs at most once per 24 hours.
- [ ] No blocking UI during background check.
- [ ] Banner appears if update is available.

### Regression Risk
Low

### Definition of Done
- Background check implemented with 24h cooldown
- Banner UI confirmed
- No impact on app startup performance

### Suggested Labels
`update-system`, `enhancement`, `priority:P3`

---

## [DOCKER-001] Dockerize the Flutter Web build for CI/CD and local preview

### Summary
The project has no Docker-based build or preview setup. Containerizing the Flutter Web build enables reproducible CI builds, simplified local preview, and deployment-ready image production without requiring a local Flutter installation.

### Problem
- Developers without a local Flutter SDK cannot build or test the web output.
- CI pipelines depend on the runner's Flutter version, making builds non-reproducible.
- There is no standardized way to serve and preview the compiled web app locally.
- Web deployment requires manual `flutter build web` and manual copy to a server.

### Scope
- Create a multi-stage `Dockerfile` for the web build:
  - **Stage 1 (`builder`):** Use `ghcr.io/cirruslabs/flutter:stable`, install dependencies, run `flutter build web --release`.
  - **Stage 2 (`server`):** Use `nginx:alpine`, copy `build/web/` output, serve with a production-optimized `nginx.conf`.
- Add `docker-compose.yml` for local preview (`docker compose up --build`).
- Add `.dockerignore` to exclude `build/`, `.dart_tool/`, `android/`, `ios/`, etc.
- Document usage in `README.md` under a new "Docker" section.

### Technical Direction
```dockerfile
# Stage 1 – Build
FROM ghcr.io/cirruslabs/flutter:stable AS builder
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

# Stage 2 – Serve
FROM nginx:alpine AS server
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```
- `nginx.conf` must set `try_files $uri $uri/ /index.html` for SPA routing.
- `docker-compose.yml` exposes port `8080:80` for local preview.
- Add a `build-web-docker` job to `.github/workflows/build-release.yml` that builds and pushes the image to `ghcr.io`.

### Acceptance Criteria
- [ ] `docker build -t church-analytics-web .` completes without error.
- [ ] `docker compose up --build` serves the app at `http://localhost:8080`.
- [ ] SPA routing works (deep links reload correctly without 404).
- [ ] `.dockerignore` excludes all non-essential files; image size is minimal.
- [ ] CI workflow builds the Docker image on push to `main` and on version tags.
- [ ] Image is pushed to `ghcr.io/garisonmike/church-analytics-web` on tagged releases.
- [ ] `README.md` documents the Docker build and preview commands.

### Regression Risk
Low — Docker build is isolated; no changes to Flutter source or existing CI jobs.

### Definition of Done
- `Dockerfile`, `docker-compose.yml`, `docker/nginx.conf`, `.dockerignore` committed
- Local preview confirmed at `http://localhost:8080`
- SPA routing confirmed (navigate to a deep route, refresh, no 404)
- CI job added to `build-release.yml` and confirmed passing
- `README.md` updated

### Suggested Labels
`enhancement`, `cross-platform`, `ci-cd`, `docker`, `priority:P2`
