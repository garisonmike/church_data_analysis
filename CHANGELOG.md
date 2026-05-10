# Changelog

All notable changes to Church Analytics are documented here.
Format: [BUG-XX] or [FEATURE] — Description — Files changed

---

## [Unreleased] — May 2026

### Bug Fixes

- **[BUG-01]** Syncfusion license key injection point prepared in `lib/main.dart`.
  - Replace the empty `kSyncfusionLicenseKey` string with your license key.
  - Files: `lib/main.dart`

- **[BUG-02]** Added optional PIN authentication to admin profiles.
  - Files: `lib/database/app_database.dart`, `lib/models/admin_user.dart`,
    `lib/repositories/admin_user_repository.dart`,
    `lib/services/admin_profile_service.dart`,
    `lib/ui/screens/profile_selection_screen.dart`
  - Schema: v4 → v5 (added `pinHash` nullable text column to `AdminUsers`)

- **[BUG-03]** WeeklyEntryScreen now receives `churchId` as a route argument,
  eliminating the SharedPreferences race condition that could silently save
  records with a null church.
  - Files: `lib/main.dart`, `lib/ui/screens/weekly_entry_screen.dart`

- **[BUG-04]** Added `baptisms` column to `WeeklyRecords` table to match
  the BAPTISMS field in data.py Dataset 2.
  - Files: `lib/database/app_database.dart`, `lib/models/weekly_record.dart`,
    `lib/repositories/weekly_record_repository.dart`,
    `lib/services/validation_service.dart`, `lib/services/csv_import_service.dart`,
    `lib/services/csv_export_service.dart`, `lib/services/analytics_service.dart`,
    `lib/ui/screens/weekly_entry_screen.dart`,
    `lib/ui/screens/target_analysis_screen.dart`
  - Schema: v2 → v3 (added `baptisms` nullable int column to `WeeklyRecords`)

- **[BUG-05]** Dashboard now shows all church records by default regardless of
  which admin profile is active, so new admin profiles no longer appear empty.
  - Files: `lib/ui/screens/dashboard_screen.dart`

- **[BUG-06]** Update manifest URL is now guarded by an environment constant.
  Debug builds can be switched to a local mock server without touching production
  traffic.
  - Files: `lib/services/update_service.dart`

- **[BUG-07]** Date validation now allows entries up to 2 days in the future,
  covering the Saturday → Sunday entry window.
  - Files: `lib/models/weekly_record.dart`

- **[BUG-08]** Registered named routes for 6 previously anonymous-push-only screens.
  - Files: `lib/main.dart`, `lib/ui/screens/graph_center_screen.dart`,
    `lib/ui/screens/dashboard_screen.dart`
  - New routes: `/charts/detail`, `/charts/distribution`, `/charts/targets`,
    `/charts/cross`, `/reports`, `/dashboard/layout`

- **[BUG-09]** Consolidated widget directories: `lib/widgets/charts/` merged into
  `lib/ui/widgets/charts/`. All import paths updated across all screen files.
  Old `lib/widgets/` directory removed.
  - Files moved: `area_chart_widget.dart`, `bar_chart_widget.dart`,
    `box_plot_widget.dart`, `dual_axis_chart_widget.dart`,
    `full_screen_chart_page.dart`, `heatmap_chart_widget.dart`,
    `histogram_chart_widget.dart`, `line_chart_widget.dart`,
    `pie_chart_widget.dart`, `scatter_chart_widget.dart`,
    `stacked_area_chart_widget.dart`, `charts.dart`
  - Import paths updated in: `lib/ui/screens/advanced_charts_screen.dart`,
    `lib/ui/screens/analytics_dashboard.dart`,
    `lib/ui/screens/attendance_charts_screen.dart`,
    `lib/ui/screens/correlation_charts_screen.dart`,
    `lib/ui/screens/cross_dataset_screen.dart`,
    `lib/ui/screens/detailed_metrics_screen.dart`,
    `lib/ui/screens/distribution_screen.dart`,
    `lib/ui/screens/financial_charts_screen.dart`,
    `lib/ui/screens/target_analysis_screen.dart`

- **[BUG-10]** PerformanceMonitor now caps stored measurements at 100 per
  operation key and exposes `clearAll()` to release memory on major navigation
  events (e.g., switching churches).
  - Files: `lib/services/performance_monitor.dart`

- **[BUG-13]** Updated pubspec.yaml description from Flutter placeholder to
  real product description.
  - Files: `pubspec.yaml`

### New Features

- **[FEATURE]** Added `holyCommunion` field — track weekly Holy Communion
  participant counts per week (nullable int; blank weeks record null, not 0).
  - Files: `lib/database/app_database.dart`, `lib/models/weekly_record.dart`,
    `lib/repositories/weekly_record_repository.dart`,
    `lib/services/validation_service.dart`, `lib/services/csv_import_service.dart`,
    `lib/services/csv_export_service.dart`, `lib/services/analytics_service.dart`,
    `lib/ui/screens/weekly_entry_screen.dart`
  - Schema: v3 → v4 (added `holyCommunion` nullable int column to `WeeklyRecords`)

---

## [1.2.4+5] — Previous Release

- Base version at time of audit.
