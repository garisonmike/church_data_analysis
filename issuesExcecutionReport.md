# Issues Execution Report

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
