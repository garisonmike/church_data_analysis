# Issues Execution Report

---

## STORAGE-007 – Never silently save to hidden directories

**Date:** 2026-03-06
**Priority:** P1
**Status:** READY FOR REVIEW

### Problem Addressed
File exports could silently succeed to hidden or app-internal directories (e.g. `/data/data/<pkg>/`, `/.config/`, `/cache/`, `/tmp/`) that are inaccessible to regular users. There was no pre-write guard to detect and reject such paths, causing effective silent data loss.

### Implementation Summary

**`lib/platform/path_safety_guard.dart`** *(new file)*

- `PathSafetyGuard` — static utility class providing:
  - `isUserAccessible(String path) → bool` — matches the normalised path against three platform-specific pattern sets:
    - `commonHiddenPatterns` (`/cache/`, `/.`) — applies on all native platforms
    - `androidHiddenPatterns` (`/data/data/`, `/data/user/`, `/code_cache/`, `/shared_prefs/`, etc.) — applied when `Platform.isAndroid`
    - `desktopHiddenPatterns` (`/tmp/`, `/proc/`, `/sys/`, `/run/`) — applied on Linux/Windows/macOS
  - `guard(String path) → PathGuardResult` — wraps `isUserAccessible`; returns `PathGuardResult.safe` or `PathGuardResult.overridden`
  - Pattern normalisation: Windows backslashes are converted to forward-slashes and the path is lower-cased before matching (case-insensitive on all platforms)
  - Debug-mode logging via `[PathSafetyGuard]` prefix
- `PathGuardResult` — immutable value class with:
  - `PathGuardResult.safe(String path)` — path passed the guard
  - `PathGuardResult.overridden(String original)` — path rejected; `wasOverridden = true`, `resolvedPath = null`
- All pattern lists are `@visibleForTesting` to enable direct unit testing independent of the runtime platform
- Designed as integration-ready for `DefaultExportPathResolver` (STORAGE-002)

**`lib/ui/screens/reports_screen.dart`** *(modified)*

- Added import for `path_safety_guard.dart`
- In `_pickExportPath`: after `normalizeExportPath`, calls `PathSafetyGuard.guard(trimmed)`. If `wasOverridden`, shows a non-blocking orange `SnackBar` ("Selected folder is not user-accessible. Using the default export folder instead.") and returns `null` so the caller falls back to `FileStorageImpl._getExportDirectory()` (the platform-appropriate downloads folder).

**`test/platform/path_safety_guard_test.dart`** *(new file)*

- 21 tests covering:
  - Common hidden patterns: `/cache/`, `/.` (dot-folders), case-insensitivity
  - Platform-specific patterns for the host OS (Linux: `/tmp/`, `/proc/`, `/sys/`)
  - Android `androidHiddenPatterns` list membership (platform-independent assertions on the constant list)
  - Valid user-accessible paths: `~/Downloads/`, `~/Documents/`, Windows-style paths, paths containing "cache" as a substring but not `/cache/`
  - `PathSafetyGuard.guard` returning `.safe` and `.overridden` results correctly
  - `PathGuardResult` constructor field values

### Test Results
```
All 30 tests passed. (21 PathSafetyGuard + 9 STORAGE-001 regression)
```

### Files Modified / Created
| File | Change Type |
|------|-------------|
| `lib/platform/path_safety_guard.dart` | Created — `PathSafetyGuard`, `PathGuardResult` |
| `lib/ui/screens/reports_screen.dart` | Modified — guard integrated in `_pickExportPath` + import added |
| `test/platform/path_safety_guard_test.dart` | Created — 21 unit tests |

### Acceptance Criteria Verification
- [x] Paths containing `/data/data/`, `/.`, `/cache/` are rejected — all three patterns confirmed in tests and present in pattern sets.
- [x] Fallback to `Downloads/ChurchAnalytics/` is automatic — `_pickExportPath` returns `null` when guard rejects; `FileStorageImpl._getExportDirectory()` (which already creates `ChurchAnalytics/` under Downloads) is used as the natural fallback. Full resolver integration deferred to STORAGE-002 (`DefaultExportPathResolver`).
- [x] A non-blocking warning banner informs the user — orange `SnackBar` shown via `ScaffoldMessenger` when guard overrides the path.
- [x] Valid user-accessible paths pass the guard without impact — confirmed in tests.
- [x] Unit tests cover known hidden path patterns — 21 tests covering common, Linux/desktop, and Android pattern sets.

### Dependency Note
"Integration confirmed in `DefaultExportPathResolver`" (Definition of Done) depends on STORAGE-002. `PathSafetyGuard.guard` is already designed with a stable API for `DefaultExportPathResolver.resolve()` to call. The current integration point is `_pickExportPath` in `reports_screen.dart`.

### Regression Risk
**Low** — guard is a new pre-write check. The only behavioral change is: paths matching hidden patterns now return `null` from `_pickExportPath` and use the platform default folder instead of the user-selected one. All existing export flows and naming logic are unaffected.

### Static Analysis
No errors or warnings in any of the three files.

### Manual Verification Required
- [ ] Android: pick a save location pointing to `/data/data/` (via a custom picker stub or device test) — confirm orange SnackBar shown and export lands in `Downloads/ChurchAnalytics/`.
- [ ] Linux: pick `/tmp/` as save location — confirm override SnackBar and correct fallback.
- [ ] Valid path: confirm the guard does not interfere with normal `~/Downloads/` selection.

---

## STORAGE-001 – Trimmed export path must be returned and stored

**Date:** 2026-03-06
**Priority:** P1
**Status:** READY FOR REVIEW

### Problem Addressed
`_pickExportPath` in `reports_screen.dart` was trimming the path only for the empty-check but returning the **untrimmed** raw string. Additionally, `_lastExportPath` was being set to the untrimmed value. A path with leading or trailing whitespace could silently fail file-save operations on some platforms.

### Implementation Summary

**`lib/ui/screens/reports_screen.dart`**

1. Extracted a new library-level function `normalizeExportPath(String? rawPath) → String?`:
   - Trims the raw picker return value.
   - Returns `null` for `null` or whitespace-only input (preventing empty strings from reaching `FileService`).
   - Contains a defensive `assert` that the returned value equals its own `.trim()` — documents the contract and catches future regressions in debug builds.
   - Annotated `@visibleForTesting` to allow direct unit testing while indicating it is an implementation detail.

2. Updated `_pickExportPath` to:
   - Delegate to `normalizeExportPath(rawPath)` for all trimming logic.
   - Store the **trimmed** value in `_lastExportPath` (was previously storing the raw, untrimmed value).
   - Return the **trimmed** value (was previously returning the raw value when trim was non-empty).
   - Retain the same `assert` guard before the return statement.

**`test/ui/reports_screen_export_path_test.dart`** *(new file)*

9 unit tests covering:
- `null` input → `null` output
- Empty string → `null`
- Whitespace-only strings → `null`
- Trailing whitespace trimmed
- Leading whitespace trimmed
- Both ends trimmed
- Clean path unchanged
- Result always equals its own `.trim()` (regression guard)
- Windows-style path trimmed correctly

### Test Results
```
All 9 tests passed.
```

### Files Modified
| File | Change Type |
|------|-------------|
| `lib/ui/screens/reports_screen.dart` | Modified – extracted `normalizeExportPath`, fixed `_pickExportPath` |
| `test/ui/reports_screen_export_path_test.dart` | Created – 9 unit tests for trim behavior |

### Acceptance Criteria Verification
- [x] Returned path is always trimmed — `normalizeExportPath` always returns `.trim()`'d value or `null`.
- [x] Stored export path (`_lastExportPath`) is trimmed — set to `trimmed` (output of `normalizeExportPath`).
- [x] No trailing whitespace can cause a save failure — whitespace-only paths return `null`, blocking the downstream call.
- [x] No regression in file selection behavior — logic is equivalent for valid clean paths; only whitespace handling changed.

### Regression Risk
**Low** — isolated logic change. The only behavioral difference is:
- Paths that were previously returned with surrounding whitespace are now returned trimmed.
- Whitespace-only paths that previously returned as non-null are now `null` (same as empty-string guard previously applied).

No structural changes; SnackBar messages, file-service calls, and cancellation paths are unaffected.

### Static Analysis
No new lint warnings or errors introduced. `@visibleForTesting` annotation used correctly (Flutter SDK annotation from `foundation.dart`, already imported).

### Manual Verification Required
- [ ] Android: pick a save location and confirm path stored/used is trimmed.
- [ ] Web: confirm no regression in export flow (path is unused on Web).
- [ ] Linux/Windows: confirm file saves succeed to expected locations.

---

## STORAGE-008 — Centralise all file I/O through FileService

**Priority:** P1  
**Status:** Implementation complete; all automated tests passing (202/202)

---

### Files Modified / Created

| File | Action |
|------|--------|
| `lib/services/file_service.dart` | **CREATED** — `FileService`, `ExportResult`, `ImportResult` value classes, `fileServiceProvider` |
| `lib/services/activity_log_service.dart` | **CREATED** — abstract `ActivityLogService` + `NoOpActivityLogService` stub |
| `lib/services/services.dart` | **UPDATED** — added exports for new files |
| `lib/services/backup_service.dart` | **MIGRATED** — `FileStorage` → `FileService` |
| `lib/services/csv_export_service.dart` | **MIGRATED** — `FileStorage` → `FileService`; all three export methods updated |
| `lib/services/pdf_report_service.dart` | **MIGRATED** — `getFileStorage()` removed; `FileService?` injected into `savePdf` |
| `lib/services/chart_export_service.dart` | **MIGRATED** — `FileStorage?` → `FileService?` in `saveAsPng` and `exportChart` |
| `lib/services/import_service.dart` | **MIGRATED** — uses `FileService`; retains `FileStorage?` param for test backwards-compat |
| `lib/services/csv_import_service.dart` | **MIGRATED** — same backwards-compat pattern as `ImportService` |
| `lib/ui/screens/reports_screen.dart` | **UPDATED** — removed direct `_fileStorage` field; uses `fileServiceProvider` via Riverpod |
| `test/services/chart_export_service_test.dart` | **UPDATED** — `fileStorage:` → `fileService: FileService(fileStorage:)` |

---

### Implementation Summary

**Goal:** No service or screen instantiates `FileStorage` directly. All file I/O flows through `FileService`, which applies `PathSafetyGuard` audit and calls `ActivityLogService` before delegating to the underlying `FileStorage`.

**Key decisions:**
- `_auditPath()` calls `PathSafetyGuard.guard()` and emits a `debugPrint` warning on flagged paths. **Does not block** in `FileService` — blocking enforcement remains at the UI layer (`_pickExportPath`) so integration tests using `/tmp/` paths are unaffected.
- `ActivityLogService` is an abstract interface; `NoOpActivityLogService` is the injected default — forward-compatible stub for STORAGE-004.
- `ExportResult` / `ImportResult` are value classes with named factories (`.success`, `.failure`, `.cancelled`) replacing raw `String?` returns.
- Backwards-compatible constructors on `ImportService` and `CsvImportService`: `FileStorage? fileStorage` wraps into `FileService(fileStorage: fileStorage)` so existing tests need no changes.

---

### Acceptance Criteria Verification

| AC | Result |
|----|--------|
| Single `FileService` used by all services | ✅ All 6 services migrated |
| `getFileStorage()` not called directly in services/screens | ✅ Removed from all migrated files |
| `ExportResult` / `ImportResult` value types returned | ✅ Used throughout |
| `ActivityLogService` stub in place (STORAGE-004 forward compat) | ✅ `activity_log_service.dart` created |
| `PathSafetyGuard` audit runs on all export paths | ✅ `_auditPath()` called in `exportFile` and `exportFileBytes` |
| Activity logging fires for every operation (export AND import) | ✅ `pickFile()` pass-through now logs on success (audit correction) |
| Riverpod singleton used at all screen call-sites | ✅ `PdfReportService.savePdf` + `ChartExportService.exportChart` pass `ref.read(fileServiceProvider)` (audit correction) |
| All existing tests pass | ✅ 202/202 tests passed |
| Static analysis: 0 issues | ✅ 1 pre-existing info (drift web deprecation, unrelated) |

---

### Test Results

```
flutter test test/services/ test/platform/ test/ui/
+202: All tests passed!
```

### Audit Corrections Applied (post-implementation re-audit)

| # | File | Fix |
|---|------|-----|
| 1 | `lib/services/file_service.dart` | `pickFile()` expanded to async body; calls `_activityLog.logImport()` on success — ensures import activity is logged for all callers, not just those using `importFile()` |
| 2 | `lib/ui/screens/reports_screen.dart` | `PdfReportService.savePdf(...)` now receives `fileService: ref.read(fileServiceProvider)` — avoids silent anonymous `FileService()` instantiation |
| 3 | `lib/ui/screens/attendance_charts_screen.dart` | `ChartExportService.exportChart(...)` now receives `fileService: ref.read(fileServiceProvider)` — same fix; ensures the singleton `ActivityLogService` is used |

---

### Manual QA Checklist

- [ ] CSV export on mobile: confirm file saves to expected path.
- [ ] PDF report: confirm file saves successfully.
- [ ] Chart PNG export: confirm file saves.
- [ ] Backup: confirm JSON file written.
- [ ] Restore from backup: confirm data loads correctly.
- [ ] CSV import: confirm data parsed and inserted.
- [ ] Confirm no `getFileStorage()` calls remain in production code.

---

## STORAGE-009 — Filename sanitization & normalization

**Priority:** P1  
**Status:** Implementation complete; all automated tests passing (260/260)

---

### Files Modified / Created

| File | Action |
|------|--------|
| `lib/platform/filename_sanitizer.dart` | **CREATED** — `FilenameSanitizer` static utility with `sanitize()` and `splitExtension()` |
| `lib/services/file_service.dart` | **UPDATED** — added `filename_sanitizer.dart` import; both `exportFile` and `exportFileBytes` now call `_sanitizeFilename()` before passing the name to the platform layer; added private `_sanitizeFilename()` helper with debug-mode change notification |
| `test/platform/filename_sanitizer_test.dart` | **CREATED** — 36 unit tests covering all 4 AC groups plus edge cases |

---

### Implementation Summary

`FilenameSanitizer.sanitize()` applies the following transforms in order:

1. Normalise whitespace (`\s+` → single space) so that tabs and newlines become underscores rather than disappearing.
2. Strip non-whitespace control characters (`\x00–\x08`, `\x0E–\x1F`, `\x7F`) from the stem.
3. Strip Windows-invalid characters (`< > : " / \ | ? *`) from the stem.
4. Collapse remaining space runs, trim leading/trailing whitespace.
5. Replace spaces with underscores.
6. Prefix with `_` when the stem matches a Windows reserved name (CON, PRN, AUX, NUL, COM1–COM9, LPT1–LPT9).
7. Cap stem to 200 characters (configurable via `maxStemLen` parameter).
8. Fall back to `'export'` if the stem is empty after all transforms.

The extension (everything from the last dot) is sanitized separately (invalid chars stripped) and reattached.

Integration: `FileService._sanitizeFilename()` wraps `FilenameSanitizer.sanitize()` and emits a `debugPrint` when the name is modified, enabling detection of malformed inputs during development.

---

### Acceptance Criteria Verification

| AC | Result |
|----|--------|
| Invalid characters removed | ✅ `< > : " / \ | ? *`, control chars, and NUL stripped |
| Reserved names blocked or auto-modified | ✅ Prefixed with `_` (e.g. `CON.csv` → `_CON.csv`) |
| Whitespace normalized | ✅ Tabs/newlines → underscore; multiple spaces collapsed |
| Filename length capped safely | ✅ Stem capped at 200 chars; extension preserved |

---

### Test Results

```
flutter test test/services/ test/platform/ test/ui/
260 tests passed (success: true)
```

---

### Manual QA Checklist

- [ ] Export a CSV with a filename containing spaces: confirm spaces become underscores.
- [ ] Attempt to export with a reserved filename (e.g. `CON.csv`) on Windows: confirm `_CON.csv` is used.
- [ ] Export a file with a very long name (>200 chars): confirm it is truncated correctly.
- [ ] Export PDF, CSV, chart PNG: confirm extensions are preserved after sanitization.

---
