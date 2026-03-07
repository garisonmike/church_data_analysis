# Church Analytics – Development Tracker (Aligned With GitHub Issues)

This file is the single source of truth for day-to-day development tracking.  
Every task is checkbox-based so Copilot (or any developer) can mark progress directly here.

## How to use this file

- Mark task checkboxes as work is completed.
- Mark acceptance checkboxes only after verification/testing.
- Mark the issue-level checkbox only when all acceptance items are complete.

---

## Issue Alignment (from `scripts/issues.sh`)

- [x] Issue 1: Android export system broken (Downloads folder + file access)
- [x] Issue 2: Auto update system failing (update.json / GitHub release integration)
- [x] Issue 3: Refactor storage and export system (cross-platform reliability)
- [x] Issue 4: Improve export success feedback and file accessibility
- [x] Issue 5: Improve release workflow (develop -> main -> tagged releases)

---

## 1) Android export system broken (Downloads folder + file access)

### Problem
Exporting files on Android fails in the default Downloads flow, and exported files are hard to access.

### Tasks
- [x] Fix exporting to `Downloads/ChurchAnalytics`
- [x] Auto-create `Downloads/ChurchAnalytics` if missing
- [x] Handle Android storage permissions correctly
- [x] Replace **Open Folder** with **Open File**
- [x] Add **Share** action
- [x] Add **Copy Path** action
- [x] Display the export path clearly in the UI
- [x] Ensure exported files are visible in standard file managers

### Acceptance
- [x] Files export successfully to `Downloads/ChurchAnalytics`
- [x] Export folder is created automatically when missing
- [x] Export path is displayed after export
- [x] **Open File** opens exported files
- [x] **Copy Path** copies the export path
- [x] **Share** shares exported files
- [x] Tested successfully on Android 10+

### Issue Complete
- [x] Mark this section complete

---

## 2) Auto update system failing (update.json / GitHub release integration)

### Problem
The app fails to detect/process updates from GitHub reliably.

### Tasks
- [x] Verify `update.json` is publicly accessible
- [x] Verify update URLs are valid and reachable
- [x] Verify GitHub release asset URLs are correct
- [x] Validate version comparison logic
- [x] Ensure release notes display correctly
- [x] Test update checks across supported platforms

### Acceptance
- [x] App retrieves `update.json` successfully
- [x] App detects newer versions correctly
- [x] Release notes are displayed
- [x] Update notification appears for newer versions
- [x] Update check works across supported platforms

### Issue Complete
- [x] Mark this section complete

---

## 3) Refactor storage and export system (cross-platform reliability)

### Problem
File/export logic is duplicated and inconsistent across platforms.

### Tasks
- [x] Implement centralized `FileService`
- [x] Standardize export folder structure
- [x] Add filename sanitization
- [x] Handle duplicate filenames automatically
- [x] Improve export/import error handling
- [x] Log export/import actions

### Acceptance
- [x] Export logic is centralized
- [x] Duplicate filenames are handled automatically
- [x] Errors are clearly reported to users
- [x] Export works on Android, Windows, and Linux
- [x] Activity logs track file operations

### Issue Complete
- [x] Mark this section complete

---

## 4) Improve export success feedback and file accessibility

### Problem
Users cannot easily locate or act on exported files from success messages.

### Tasks
- [x] Improve export success UI messaging
- [x] Display full export path
- [x] Add **Open File** button
- [x] Add **Share** button
- [x] Add **Copy Path** button
- [x] Make export path selectable

### Acceptance
- [x] Success screen clearly shows file location
- [x] Export path is selectable and copyable
- [x] Action buttons work correctly
- [x] Users can open exported files directly

### Issue Complete
- [x] Mark this section complete

---

## 5) Improve release workflow (develop -> main -> tagged releases)

### Problem
Release and versioning process is unclear and inconsistently applied.

### Tasks
- [x] Define release process from `develop` to `main`
- [x] Define version increment strategy
- [x] Ensure tags trigger release builds
- [x] Verify releases include correct assets
- [x] Document release steps for the team

### Acceptance
- [x] Release workflow is documented
- [x] Versioning strategy is documented and followed
- [x] Releases are created via tags
- [x] Expected assets are attached to releases

### Issue Complete
- [x] Mark this section complete

---

## Future Improvements

- [ ] Background update checks
- [ ] Update download progress UI
- [ ] Automatic installer verification
- [ ] Improved activity logging
- [ ] Web build deployment improvements