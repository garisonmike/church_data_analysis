# Church Analytics – Development Tracker (Aligned With GitHub Issues)

This file is the single source of truth for day-to-day development tracking.  
Every task is checkbox-based so Copilot (or any developer) can mark progress directly here.

## How to use this file

- Mark task checkboxes as work is completed.
- Mark acceptance checkboxes only after verification/testing.
- Mark the issue-level checkbox only when all acceptance items are complete.

---

## Issue Alignment (from `scripts/issues.sh`)

- [ ] Issue 1: Android export system broken (Downloads folder + file access)
- [ ] Issue 2: Auto update system failing (update.json / GitHub release integration)
- [ ] Issue 3: Refactor storage and export system (cross-platform reliability)
- [ ] Issue 4: Improve export success feedback and file accessibility
- [ ] Issue 5: Improve release workflow (develop -> main -> tagged releases)

---

## 1) Android export system broken (Downloads folder + file access)

### Problem
Exporting files on Android fails in the default Downloads flow, and exported files are hard to access.

### Tasks
- [ ] Fix exporting to `Downloads/ChurchAnalytics`
- [ ] Auto-create `Downloads/ChurchAnalytics` if missing
- [ ] Handle Android storage permissions correctly
- [ ] Replace **Open Folder** with **Open File**
- [ ] Add **Share** action
- [ ] Add **Copy Path** action
- [ ] Display the export path clearly in the UI
- [ ] Ensure exported files are visible in standard file managers

### Acceptance
- [ ] Files export successfully to `Downloads/ChurchAnalytics`
- [ ] Export folder is created automatically when missing
- [ ] Export path is displayed after export
- [ ] **Open File** opens exported files
- [ ] **Copy Path** copies the export path
- [ ] **Share** shares exported files
- [ ] Tested successfully on Android 10+

### Issue Complete
- [ ] Mark this section complete

---

## 2) Auto update system failing (update.json / GitHub release integration)

### Problem
The app fails to detect/process updates from GitHub reliably.

### Tasks
- [ ] Verify `update.json` is publicly accessible
- [ ] Verify update URLs are valid and reachable
- [ ] Verify GitHub release asset URLs are correct
- [ ] Validate version comparison logic
- [ ] Ensure release notes display correctly
- [ ] Test update checks across supported platforms

### Acceptance
- [ ] App retrieves `update.json` successfully
- [ ] App detects newer versions correctly
- [ ] Release notes are displayed
- [ ] Update notification appears for newer versions
- [ ] Update check works across supported platforms

### Issue Complete
- [ ] Mark this section complete

---

## 3) Refactor storage and export system (cross-platform reliability)

### Problem
File/export logic is duplicated and inconsistent across platforms.

### Tasks
- [ ] Implement centralized `FileService`
- [ ] Standardize export folder structure
- [ ] Add filename sanitization
- [ ] Handle duplicate filenames automatically
- [ ] Improve export/import error handling
- [ ] Log export/import actions

### Acceptance
- [ ] Export logic is centralized
- [ ] Duplicate filenames are handled automatically
- [ ] Errors are clearly reported to users
- [ ] Export works on Android, Windows, and Linux
- [ ] Activity logs track file operations

### Issue Complete
- [ ] Mark this section complete

---

## 4) Improve export success feedback and file accessibility

### Problem
Users cannot easily locate or act on exported files from success messages.

### Tasks
- [ ] Improve export success UI messaging
- [ ] Display full export path
- [ ] Add **Open File** button
- [ ] Add **Share** button
- [ ] Add **Copy Path** button
- [ ] Make export path selectable

### Acceptance
- [ ] Success screen clearly shows file location
- [ ] Export path is selectable and copyable
- [ ] Action buttons work correctly
- [ ] Users can open exported files directly

### Issue Complete
- [ ] Mark this section complete

---

## 5) Improve release workflow (develop -> main -> tagged releases)

### Problem
Release and versioning process is unclear and inconsistently applied.

### Tasks
- [ ] Define release process from `develop` to `main`
- [ ] Define version increment strategy
- [ ] Ensure tags trigger release builds
- [ ] Verify releases include correct assets
- [ ] Document release steps for the team

### Acceptance
- [ ] Release workflow is documented
- [ ] Versioning strategy is documented and followed
- [ ] Releases are created via tags
- [ ] Expected assets are attached to releases

### Issue Complete
- [ ] Mark this section complete

---

## Future Improvements

- [ ] Background update checks
- [ ] Update download progress UI
- [ ] Automatic installer verification
- [ ] Improved activity logging
- [ ] Web build deployment improvements