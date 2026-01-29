# ✅ Church Analytics Flutter App — Build Tasks

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

* [ ] Forecast projection chart
* [ ] Moving average overlay chart
* [ ] Attendance vs funds heatmap
* [ ] Outlier markers on charts

---

# Issue 14 — Graph Center Screen

* [ ] Build graph selector grid
* [ ] Add category filters
* [ ] Add navigation buttons
* [ ] Implement graph routing
* [ ] Verify navigation stability

---

# Issue 15 — Graph Export System

* [ ] Implement RepaintBoundary capture
* [ ] Save chart as PNG
* [ ] Add export button UI
* [ ] Implement file naming scheme
* [ ] Verify exports open correctly

---

# Issue 16 — PDF Report Builder

* [ ] Create PDF layout template
* [ ] Insert graphs into PDF
* [ ] Insert KPI stats
* [ ] Build multi-graph report
* [ ] Implement save & share
* [ ] Verify PDF output

---

# Issue 17 — Multi-Admin Local Profiles

* [ ] Implement Admin profile model
* [ ] Build profile switcher UI
* [ ] Separate data per admin
* [ ] Build profile creation flow
* [ ] Verify profile isolation

---

# Issue 18 — Church Entity Support

* [ ] Integrate Church model
* [ ] Build church selector UI
* [ ] Link records to church
* [ ] Build church settings page
* [ ] Verify church data scoping

---

# Issue 19 — Validation & Integrity Layer

* [ ] Enforce numeric >= 0 rule
* [ ] Add missing field checks
* [ ] Add outlier warnings
* [ ] Add CSV schema validation
* [ ] Verify validation messages

---

# Issue 20 — Testing Suite

* [ ] Add analytics unit tests
* [ ] Add model tests
* [ ] Add widget tests
* [ ] Add CSV import tests
* [ ] Verify test runs pass

---

# Issue 21 — Performance Optimization

* [ ] Cache derived metrics
* [ ] Lazy load graphs
* [ ] Optimize DB queries
* [ ] Add pagination for records
* [ ] Measure dashboard load time

---

# Issue 22 — Backup & Local Export

* [ ] Implement full CSV export
* [ ] Implement JSON backup export
* [ ] Implement restore from backup
* [ ] Verify restore correctness

---

# ✅ Usage

Copy this file directly into your repository as `tasks.md`. Copilot should only tick checkboxes — not re
