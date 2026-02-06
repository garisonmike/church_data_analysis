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

* [x] Create reports_screen.dart
* [x] Add PDF export button
* [x] Add CSV export button
* [x] Add backup export button
* [x] Add restore backup button
* [x] Add dashboard navigation button to Reports

---

# Repair R5 — Fix CSV Import for Web

* [x] Use file_picker bytes mode
* [x] Parse CSV from memory bytes
* [x] Remove file path assumptions
* [x] Remove dart:io dependency
* [x] Verify CSV import works on web

---

# Repair R6 — Chart Export Web Support

* [x] Implement web PNG download method
* [x] Implement mobile file save method
* [x] Route via platform storage interface
* [x] Verify export works on web
* [x] Verify export works on mobile

---

# Repair R7 — Church/Admin Bootstrap Flow

* [x] Add startup admin check
* [x] Add startup church check
* [x] Create profile selection screen
* [x] Create church selection screen
* [x] Add guarded navigation flow
* [x] Prevent dashboard load without context


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
# Phase S — Stability, Architecture & Safety

> This phase stabilizes the app before further UX or feature expansion. No new features. No visual refactors. Goal is correctness, safety, and future-proofing.

---

# S1 — App-Scoped Database Lifecycle

* [x] Create a single AppDatabase provider (Riverpod)
* [x] Ensure only one AppDatabase instance exists app-wide
* [x] Remove all ad-hoc `AppDatabase()` instantiations
* [x] Fix dashboard DB lifecycle leak
* [x] Properly dispose database on app exit

Acceptance Criteria:

* Only one AppDatabase instance exists at runtime
* No screen or service directly instantiates AppDatabase
* Dashboard no longer creates or leaks DB instances
* App runs without DB warnings or locks
* flutter analyze shows no DB lifecycle issues

---

# S2 — Safe Provider Defaults (No Crash Footguns)

* [x] Remove `throw UnimplementedError` from providers
* [x] Provide safe default implementations
* [x] Allow ProviderScope overrides but do not require them  
* [x] App must not crash when overrides are missing

Acceptance Criteria:

* App boots without ProviderScope overrides
* Tests no longer crash due to missing providers
* Overrides still work when explicitly provided
* No runtime crashes caused by provider initialization

---

# S3 — Fix & Stabilize Test Suite

* [x] Fix ProviderScope overrides in all tests
* [x] Remove duplicate attendance test
* [x] Ensure tests use real-safe providers
* [x] Run full test suite

Acceptance Criteria:

* `flutter test` passes with zero failures ✅
* No test-only hacks or conditional code ✅
* Tests reflect real app behavior ✅
* CI-ready test stability ✅

---

# S4 — Centralized Formatting & Currency Application

* [x] Create centralized formatting service
* [x] Remove hardcoded currency symbols
* [x] Apply formatter to dashboard values
* [x] Apply formatter to all graphs
* [x] Ensure currency updates propagate globally

Acceptance Criteria:

* No `$` symbols hardcoded anywhere ✅
* Currency change updates dashboard and graphs ✅
* KES formatting is consistent everywhere ✅
* Restart preserves correct formatting ✅

---

# S5 — Demo Mode vs Real Mode Boundary

* [x] Introduce explicit demo mode flag
* [x] Restrict auto-seeding to demo mode only
* [x] Ensure real installs start with empty data
* [x] Prevent admin/demo auto-creation in real mode

Acceptance Criteria:

* Fresh real install has no demo data ✅
* Demo mode loads sample data predictably ✅
* User can clearly distinguish demo vs real mode ✅
* No unintended reseeding occurs ✅

---

# S6 — Navigation Safety Hardening

* [x] Add safe fallback route for unknown paths
* [x] Prevent null route returns
* [x] Guard `/entry` route consistently
* [x] Ensure navigation failures do not crash app

Acceptance Criteria:

* [x] Unknown routes show fallback screen
* [x] `/entry` route behavior matches other guarded routes
* [x] No navigation-related runtime exceptions
* [x] App navigation is resilient

---
# Phase U — UX, Configurability & Production Safety.
---

# UX1 — App Settings (Currency, Location Defaults, Kenyan Presets)

* [x] Create AppSettings model
* [x] Create Riverpod settings provider
* [x] Add currency enum + dropdown
* [x] Set default currency = KES
* [x] Set default locale = Nairobi, Kenya
* [x] Persist settings locally
* [x] Build settings screen UI
* [x] Apply currency formatting globally

Acceptance Criteria:

* Settings screen exists and loads
* Default currency shows as KES
* Currency symbol updates across dashboard + graphs
* Restart preserves settings
* No existing screens break

---

# UX2 — Theme System + Dark Mode Toggle

* [x] Create theme provider
* [x] Define light theme
* [x] Define dark theme
* [x] Add dark mode toggle
* [x] Persist theme choice
* [x] Update chart contrast for dark mode

Acceptance Criteria:

* Toggle switches theme instantly
* Preference persists after restart
* Charts remain readable
* No layout regressions

---

# UX3 — Responsive & Live Graph Rendering

* [x] Replace fixed graph sizes
* [x] Use LayoutBuilder responsiveness
* [x] Bind graphs to provider watchers
* [x] Enable auto-refresh on data change
* [x] Add time range selector

Acceptance Criteria:

* Graph resizes with window/device
* Graph updates when data changes
* No overflow errors
* Works on web + desktop

---

# UX4 — Custom Graph Builder (Metric vs Metric)

* [x] Create graph builder screen
* [x] Add metric A selector
* [x] Add metric B selector
* [x] Add chart type selector
* [x] Add time range selector
* [x] Generate dynamic graph

Acceptance Criteria:

* User can pick any two metrics
* Graph renders correctly
* Changing selector updates graph
* Navigation works without crash

---

# UX5 — Dashboard Widget Customization

* [x] Create dashboard config model
* [x] Add widget toggles
* [x] Build layout editor UI
* [x] Persist layout config
* [x] Apply layout dynamically

Acceptance Criteria:

* User can hide/show widgets
* Layout persists after restart
* Dashboard loads without errors

---

# UX6 — CSV Schema Mapping UI

* [x] Build column mapping screen
* [x] Add field-to-column selectors
* [x] Add optional column flags
* [x] Add preview table
* [x] Add validation checks
* [x] Support missing columns

Acceptance Criteria:

* User can map CSV columns manually
* Missing optional fields allowed
* Import succeeds with mapped schema
* Invalid schema shows errors

---

# UX7 — Export Location Picker

* [x] Add export location picker UI
* [x] Integrate platform storage layer
* [x] Update PDF export path logic
* [x] Update CSV export path logic
* [x] Update backup export path logic

Acceptance Criteria:

* User chooses save location
* Files save to selected path
* Works on web + desktop
* No hardcoded paths remain

---

# UX8 — PDF Report Builder Customization

* [x] Create report builder UI
* [x] Add include-graphs toggle
* [x] Add include-KPI toggle
* [x] Add include-table toggle
* [x] Add include-trends toggle
* [x] Update PDF builder logic

Acceptance Criteria:

* User selects report contents
* PDF reflects selections
* PDF builds without error
* Existing export still works

---

# UX9 — Production Database Storage Path

* [x] Implement app data path resolver
* [x] Move DB to app data directory
* [x] Remove Documents path usage
* [x] Add DB migration logic
* [x] Verify Linux path

Acceptance Criteria:

* DB no longer appears in Documents
* App reads old DB if present
* New DB stored in app directory
* No data loss

---

# UX10 — Kenyan Sample Data & Templates

* [x] Create sample church seed
* [x] Create Kenyan weekly dataset
* [x] Create CSV template file
* [x] Add demo dashboard seed
* [x] Auto-load demo data when empty

Acceptance Criteria:

* Fresh install shows Kenyan sample data
* CSV template downloadable
* Demo graphs render correctly
* Sample data removable by user

---

## Phase R — Release Readiness (Interactive Analytics & UX Finalization)

> Goal: Make the app genuinely usable and trustworthy for real users before any public/beta release.
> Scope: UX + analytics behavior only. No architectural refactors (Phase S already completed).

### R1 — Interactive Graph Engine (Pan / Zoom / Resize)

* [x] Replace static chart widgets with interactive chart widgets (pan, zoom, scale)
* [x] Support time-range control (e.g. week range slider or selector)
* [x] Graphs must resize correctly with window/screen size

**Acceptance Criteria**

* [x] User can pan and zoom graphs smoothly (desktop + mobile)
* [x] Resizing the window resizes graphs without overflow or clipping
* [x] No loss of existing graph types
* [x] App compiles on all targets

---

### R2 — Global Currency Application (UI + Graphs)

* [x] Ensure selected currency applies everywhere (dashboard, tables, exports, graphs)
* [x] Update all graph Y-axes to display selected currency (e.g. KES, not $)
* [x] Remove any remaining hardcoded currency symbols

**Acceptance Criteria**

* Changing currency updates:

  * [x] Dashboard values (uses _formatCurrency)
  * [x] All graph Y-axis labels (all chart screens updated)
  * [x] Tooltips / legends (uses _formatCurrency and _getCurrencySymbol)
  * [x] Exported PDF/CSV headers (PDF uses formatCurrency, CSV exports raw values)
* [x] Default currency is KES
* [x] No "$" remains in UI unless USD is selected

---

### R3 — User-Selectable Graph Builder (X vs Y)

* [x] Add UI to let user choose what metric is plotted against what
* [x] Support Attendance vs Attendance, Attendance vs Funds, Funds vs Funds
* [x] Persist last selection locally

**Acceptance Criteria**

* [x] User can select X-axis and Y-axis metrics
* [x] Graph updates live without restart
* [x] Invalid combinations are prevented gracefully
* [x] Existing predefined graphs still work

---

### R4 — Customizable Dashboard Layout

* [x] Allow users to choose which widgets appear on the dashboard
* [x] Persist dashboard layout locally
* [x] Provide sensible Kenyan-default dashboard on first run

**Acceptance Criteria**

* [x] Users can add/remove dashboard widgets
* [x] Layout persists after app restart
* [x] No empty or broken dashboard state

---

### R5 — Safe CSV Import Configuration

* [x] Before import, allow user to map CSV columns to expected fields
* [x] Allow missing optional columns (e.g. Youth, Emergency Collection)
* [x] Show preview before committing import

**Acceptance Criteria**

* [x] User explicitly confirms column mapping
* [x] Import never crashes on missing columns
* [x] No data written before confirmation

---

### R6 — Export Customization (PDF / CSV)

* [ ] Let user choose export location
* [ ] Let user choose what to include (graphs, tables, summaries)
* [ ] Respect currency and locale in exports

**Acceptance Criteria**

* User controls export destination
* Export reflects selected currency
* Export content matches user selection

---

### R7 — Dark Mode & Visual Polish

* [ ] Add dark mode toggle
* [ ] Ensure charts and dashboard render correctly in dark mode

**Acceptance Criteria**

* Dark mode applies globally
* Charts remain readable
* User preference persists

---

### Phase R Exit Gate

* [ ] All R-tasks completed
* [ ] flutter test passes
* [ ] Manual sanity check on desktop
* [ ] No regression from Phase S

> Only after this phase may a beta or release build be cut.
