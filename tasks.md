# ✅ Church Analytics Flutter App — Build Tasks

⚠️ PLAN STATE CHANGE — FOUNDATION CORRECTION PHASE ACTIVE
>
> The following repair tasks MUST be completed first before continuing normal build tasks. These align the codebase with plan.md and fix web, bootstrap, and architecture violations.

---

# Repair R1 — Fix App Bootstrap

* [x] Replace counter demo main.dart
* [x] Wrap app with ProviderScope
* [x] Wire MaterialApp routes
* [x] Set DashboardScreen as home
* [x] Remove demo counter widgets
* [x] Verify Riverpod providers resolve

---

# Repair R2 — Enforce Web Compatibility Layer

* [x] Create platform/file_storage_interface.dart
* [x] Create platform/file_storage_mobile.dart
* [x] Create platform/file_storage_web.dart
* [x] Remove direct dart:io File usage in services
* [x] Refactor CSV import to use interface
* [x] Refactor export services to use interface
* [x] Verify flutter build web succeeds

---

# Repair R3 — Create Graph Module Structure

* [x] Create graph_modules folder
* [x] Create attendance subfolder
* [x] Create finance subfolder
* [x] Create correlation subfolder
* [x] Create forecast subfolder
* [x] Add placeholder files in each

---

# Repair R4 — Add Reports Screen + Navigation

* [ ] Create reports_screen.dart
* [ ] Add PDF export button
* [ ] Add CSV export button
* [ ] Add backup export button
* [ ] Add restore backup button
* [ ] Add dashboard navigation button to Reports

---

# Repair R5 — Fix CSV Import for Web

* [ ] Use file_picker bytes mode
* [ ] Parse CSV from memory bytes
* [ ] Remove file path assumptions
* [ ] Remove dart:io dependency
* [ ] Verify CSV import works on web

---

# Repair R6 — Chart Export Web Support

* [ ] Implement web PNG download method
* [ ] Implement mobile file save method
* [ ] Route via platform storage interface
* [ ] Verify export works on web
* [ ] Verify export works on mobile

---

# Repair R7 — Church/Admin Bootstrap Flow

* [ ] Add startup admin check
* [ ] Add startup church check
* [ ] Create profile selection screen
* [ ] Create church selection screen
* [ ] Add guarded navigation flow
* [ ] Prevent dashboard load without context


---
> Follow tasks strictly in order. Only check items when fully completed and verified. Do not change task wording unless a PLAN CHANGE is declared.

---

# Issue 1 — Initialize Flutter Multiplatform Project

* [x] Create Flutter project
* [x] Enable web, android, ios, windows, macos, linux targets
* [x] Verify build runs on web
* [x] Verify build runs on at least one mobile platform
* [x] Set project name and package IDs
* [x] Create initial README
* [x] Commit base scaffold

---

# Issue 2 — Add Core Dependencies

* [x] Add Riverpod
* [x] Add Drift or sqflite
* [x] Add fl_chart (or Syncfusion charts)
* [x] Add csv package
* [x] Add pdf package
* [x] Add printing package
* [x] Add path_provider
* [x] Add file_picker
* [x] Run pub get
* [x] Verify project builds
* [x] Commit lockfile

---

# Issue 3 — Define Data Models

* [x] Create Church model
* [x] Create AdminUser model
* [x] Create WeeklyRecord model
* [x] Create DerivedMetrics model
* [x] Create ExportHistory model
* [x] Add JSON serialization
* [x] Add validation methods
* [x] Add model unit tests

---

# Issue 4 — Setup Local Database Layer

* [x] Configure SQLite package
* [x] Create tables per model
* [x] Create DB migrations
* [x] Create repository classes
* [x] Implement CRUD operations
* [x] Add indexes for weekly records
* [x] Add optional seed data
* [x] Verify persistence across restarts

---

# Issue 5 — Build Analytics Engine (Core Metrics)

* [x] Implement total attendance calculator
* [x] Implement total income calculator
* [x] Implement growth % calculator
* [x] Implement averages calculator
* [x] Implement category percentage calculator
* [x] Implement attendance-to-income ratio
* [x] Implement per-capita giving
* [x] Write unit tests for metrics

---

# Issue 6 — Advanced Analytics Engine

* [x] Implement moving averages
* [x] Implement linear trend line calculator
* [x] Implement correlation coefficient calculator
* [x] Implement forecast projection (linear)
* [x] Implement outlier detection
* [x] Implement rolling 4-week metrics
* [x] Add unit tests

---

# Issue 7 — Weekly Data Entry Form UI

* [x] Build weekly entry form layout
* [x] Add numeric validation
* [x] Enforce required fields
* [x] Save records to database
* [x] Support edit existing week
* [x] Prevent duplicate week entries
* [x] Add error messaging UI

---

# Issue 8 — CSV Import System

* [x] Integrate file picker
* [x] Implement CSV parser
* [x] Build column mapping UI
* [x] Add preview screen
* [x] Add validation checks
* [x] Add import confirmation step
* [x] Add error reporting

---

# Issue 9 — Dashboard Screen UI

* [x] Create KPI cards
* [x] Show summary metrics
* [x] Show recent weeks list
* [x] Add quick graph buttons
* [x] Add growth indicators
* [x] Make responsive layout

---

# Issue 10 — Graph Module: Attendance Charts

* [x] Attendance by category bar chart
* [x] Total attendance trend line
* [x] Attendance distribution pie chart
* [x] Growth rate chart
* [x] Verify tooltips and labels

---

# Issue 11 — Graph Module: Financial Charts

* [x] Tithe vs offerings chart
* [x] Income breakdown stacked chart
* [x] Income distribution pie chart
* [x] Funds vs attendance charts
* [x] Verify scales and labels

---

# Issue 12 — Graph Module: Correlation & Combined Charts

* [x] Attendance vs income dual-axis chart
* [x] Demographics vs funds charts
* [x] Scatter correlation charts
* [x] Groups vs funds correlation charts
* [x] Verify legends and axes

---

# Issue 13 — Advanced Graphs (Forecast & Heatmaps)

* [x] Forecast projection chart
* [x] Moving average overlay chart
* [x] Attendance vs funds heatmap
* [x] Outlier markers on charts

---

# Issue 14 — Graph Center Screen

* [x] Build graph selector grid
* [x] Add category filters
* [x] Add navigation buttons
* [x] Implement graph routing
* [x] Verify navigation stability

---

# Issue 15 — Graph Export System

* [x] Implement RepaintBoundary capture
* [x] Save chart as PNG
* [x] Add export button UI
* [x] Implement file naming scheme
* [x] Verify exports open correctly

---

# Issue 16 — PDF Report Builder

* [x] Create PDF layout template
* [x] Insert graphs into PDF
* [x] Insert KPI stats
* [x] Build multi-graph report
* [x] Implement save & share
* [x] Verify PDF output

---

# Issue 17 — Multi-Admin Local Profiles

* [x] Implement Admin profile model
* [x] Build profile switcher UI
* [x] Separate data per admin
* [x] Build profile creation flow
* [x] Verify profile isolation

---

# Issue 18 — Church Entity Support

* [x] Integrate Church model
* [x] Build church selector UI
* [x] Link records to church
* [x] Build church settings page
* [x] Verify church data scoping

---

# Issue 19 — Validation & Integrity Layer

* [x] Enforce numeric >= 0 rule
* [x] Add missing field checks
* [x] Add outlier warnings
* [x] Add CSV schema validation
* [x] Verify validation messages

---

# Issue 20 — Testing Suite

* [x] Add analytics unit tests
* [x] Add model tests
* [x] Add widget tests
* [x] Add CSV import tests
* [x] Verify test runs pass

---

# Issue 21 — Performance Optimization

* [x] Cache derived metrics
* [x] Lazy load graphs
* [x] Optimize DB queries
* [x] Add pagination for records
* [x] Measure dashboard load time

---

# Issue 22 — Backup & Local Export

* [x] Implement full CSV export
* [x] Implement JSON backup export
* [x] Implement restore from backup
* [x] Verify restore correctness

---

# ✅ Usage

Copy this file directly into your repository as `tasks.md`. Copilot should only tick checkboxes — not re
