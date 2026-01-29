# ✅ Church Analytics Flutter App — Build Tasks

> Follow tasks strictly in order. Only check items when fully completed and verified. Do not change task wording unless a PLAN CHANGE is declared.

---

# Issue 1 — Initialize Flutter Multiplatform Project

* [ ] Create Flutter project
* [ ] Enable web, android, ios, windows, macos, linux targets
* [ ] Verify build runs on web
* [ ] Verify build runs on at least one mobile platform
* [ ] Set project name and package IDs
* [ ] Create initial README
* [ ] Commit base scaffold

---

# Issue 2 — Add Core Dependencies

* [ ] Add Riverpod
* [ ] Add Drift or sqflite
* [ ] Add fl_chart (or Syncfusion charts)
* [ ] Add csv package
* [ ] Add pdf package
* [ ] Add printing package
* [ ] Add path_provider
* [ ] Add file_picker
* [ ] Run pub get
* [ ] Verify project builds
* [ ] Commit lockfile

---

# Issue 3 — Define Data Models

* [ ] Create Church model
* [ ] Create AdminUser model
* [ ] Create WeeklyRecord model
* [ ] Create DerivedMetrics model
* [ ] Create ExportHistory model
* [ ] Add JSON serialization
* [ ] Add validation methods
* [ ] Add model unit tests

---

# Issue 4 — Setup Local Database Layer

* [ ] Configure SQLite package
* [ ] Create tables per model
* [ ] Create DB migrations
* [ ] Create repository classes
* [ ] Implement CRUD operations
* [ ] Add indexes for weekly records
* [ ] Add optional seed data
* [ ] Verify persistence across restarts

---

# Issue 5 — Build Analytics Engine (Core Metrics)

* [ ] Implement total attendance calculator
* [ ] Implement total income calculator
* [ ] Implement growth % calculator
* [ ] Implement averages calculator
* [ ] Implement category percentage calculator
* [ ] Implement attendance-to-income ratio
* [ ] Implement per-capita giving
* [ ] Write unit tests for metrics

---

# Issue 6 — Advanced Analytics Engine

* [ ] Implement moving averages
* [ ] Implement linear trend line calculator
* [ ] Implement correlation coefficient calculator
* [ ] Implement forecast projection (linear)
* [ ] Implement outlier detection
* [ ] Implement rolling 4-week metrics
* [ ] Add unit tests

---

# Issue 7 — Weekly Data Entry Form UI

* [ ] Build weekly entry form layout
* [ ] Add numeric validation
* [ ] Enforce required fields
* [ ] Save records to database
* [ ] Support edit existing week
* [ ] Prevent duplicate week entries
* [ ] Add error messaging UI

---

# Issue 8 — CSV Import System

* [ ] Integrate file picker
* [ ] Implement CSV parser
* [ ] Build column mapping UI
* [ ] Add preview screen
* [ ] Add validation checks
* [ ] Add import confirmation step
* [ ] Add error reporting

---

# Issue 9 — Dashboard Screen UI

* [ ] Create KPI cards
* [ ] Show summary metrics
* [ ] Show recent weeks list
* [ ] Add quick graph buttons
* [ ] Add growth indicators
* [ ] Make responsive layout

---

# Issue 10 — Graph Module: Attendance Charts

* [ ] Attendance by category bar chart
* [ ] Total attendance trend line
* [ ] Attendance distribution pie chart
* [ ] Growth rate chart
* [ ] Verify tooltips and labels

---

# Issue 11 — Graph Module: Financial Charts

* [ ] Tithe vs offerings chart
* [ ] Income breakdown stacked chart
* [ ] Income distribution pie chart
* [ ] Funds vs attendance charts
* [ ] Verify scales and labels

---

# Issue 12 — Graph Module: Correlation & Combined Charts

* [ ] Attendance vs income dual-axis chart
* [ ] Demographics vs funds charts
* [ ] Scatter correlation charts
* [ ] Groups vs funds correlation charts
* [ ] Verify legends and axes

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
