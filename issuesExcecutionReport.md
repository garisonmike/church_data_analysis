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
