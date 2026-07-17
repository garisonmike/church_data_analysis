# Changelog

All notable changes to Church Analytics are documented here.
Format: [BUG-XX] or [FEATURE] — Description — Files changed

---

## [Unreleased]

- _No changes yet._

---

## [1.6.0] — 2026-07-17

### Bug Fixes (on-device testing round)

Found and fixed during live testing on a physical Android device; several
shared a root cause and had shipped hidden behind the pre-release code
audit.

- **[BUG-22]** Reports & Backup "Restore" reported success but wrote
  nothing to the database (a parse-only stub); restoring then landed the
  user on "no church exists". Restore is now real, atomic, and shared with
  the first-launch importer. The matching export stub shipped an empty
  admin list and only the current church — every backup it produced was
  born with orphaned admin references; export now captures all churches and
  admins, and the serializer round-trips the previously-dropped optional
  fields (baptisms, communion, sabbath school, visitors, mission offering,
  local budget).
  - Files: `lib/services/backup_service.dart`,
    `lib/ui/screens/reports_screen.dart`,
    `lib/ui/screens/first_launch_backup_import_screen.dart`,
    `lib/repositories/admin_user_repository.dart`

- **[BUG-23]** Imported and restored records never appeared in any chart,
  and older records never appeared on the dashboard. The chart pipeline
  silently filtered to records created by the current admin (restored
  records have no creator, so they matched nothing), and the dashboard used
  a hardcoded 12-week window. Removed the per-admin filter (analytics are
  church-wide); the dashboard now honors a visible time-range selector
  defaulting to All Time, so dashboard, charts, imported-data, and PDF
  reports finally agree on scope.
  - Files: `lib/services/weekly_records_provider.dart`,
    `lib/repositories/weekly_record_repository.dart`,
    `lib/ui/screens/dashboard_screen.dart`

- **[BUG-24]** The dashboard's church selector updated the stored current
  church but every screen kept the church id frozen at construction, so
  "switching" relabeled the screen while still showing the old church's
  data (which read as cross-church leakage). The chip now routes through
  the real selector/gate so all screens rebuild for the new church.
  - Files: `lib/ui/widgets/church_selector_widget.dart`,
    `lib/ui/screens/dashboard_screen.dart`

- **[BUG-25]** CSV/XLSX import invalidated no providers, so imported
  records were invisible until an app restart. Import now refreshes the
  record providers and dashboard.
  - Files: `lib/ui/screens/import_screen.dart`

- **[BUG-26]** Profile Edit/Deactivate/Delete were unreachable: the
  dashboard's profile chip opened a bare switch/create dialog while the
  real management screen was only reachable from the startup gate. The chip
  now opens the real screen.
  - Files: `lib/ui/widgets/profile_switcher_widget.dart`,
    `lib/ui/screens/profile_selection_screen.dart`

- **[BUG-27]** Five dialogs (profile create/edit, church create, and three
  CSV-import dialogs) used LayoutBuilder as AlertDialog content, which
  asserts under the dialog's intrinsic measurement — a dimmed, hung screen
  in debug. All switched to a plain constrained box.
  - Files: `lib/ui/screens/profile_selection_screen.dart`,
    `lib/ui/screens/church_selection_screen.dart`,
    `lib/ui/screens/import_screen.dart`

- **[BUG-28]** App Settings currency/theme dropdowns and every chart
  screen's app bar overflowed on phone widths. Fixed with isExpanded on the
  dropdowns and by moving the chart time-range selector to a full-width
  app-bar bottom bar.
  - Files: `lib/ui/screens/app_settings_screen.dart`, chart screens

- **[BUG-29]** Three entry forms exposed an internal congregation
  abbreviation ("Expected at KCC") in field labels; relabeled to "Expected"
  with helper text.
  - Files: `lib/ui/screens/home_church_screen.dart`,
    `lib/ui/screens/business_meeting_entry_screen.dart`,
    `lib/ui/screens/holy_communion_entry_screen.dart`

### Bug Fixes

- **[BUG-16]** Backup restore no longer fails with a FOREIGN KEY error when
  the backup's records reference admins that weren't restored, and the whole
  restore is now atomic — a failure rolls back everything, so "No data was
  changed" is true and retries can't create duplicate churches.
  - Files: `lib/ui/screens/first_launch_backup_import_screen.dart`

- **[BUG-17]** Target Analysis no longer crashes to a blank white page: the
  missing 'Total Income' target was added and all target lookups now degrade
  to "no target line" instead of a null-check crash when a metric has no
  configured target.
  - Files: `lib/ui/screens/target_analysis_screen.dart`

- **[BUG-18]** Feedback that used to render off-screen is now brought into
  view: weekly-entry validation errors scroll back to the banner, the
  outlier check explains itself when there is too little history (or a clean
  result), and CSV import auto-scrolls to the validation results and Import
  button.
  - Files: `lib/ui/screens/weekly_entry_screen.dart`,
    `lib/ui/screens/import_screen.dart`

- **[BUG-19]** Switching or creating a church now resets the navigation
  stack — no more restart after switching, and the back button can't land on
  the previous church's stale screens.
  - Files: `lib/ui/screens/church_selection_screen.dart`

- **[BUG-20]** Home Churches, Board Meeting, Holy Communion, and Business
  Meeting entry now resolve the current church correctly. They previously
  read a settings field that nothing ever wrote (always null), so Home
  Churches was stuck on "No church selected"; all four now read the real
  church selection, and the dead field was removed from the settings model.
  - Files: `lib/services/weekly_records_provider.dart`,
    `lib/ui/screens/home_church_screen.dart`,
    `lib/ui/screens/board_meeting_entry_screen.dart`,
    `lib/ui/screens/holy_communion_entry_screen.dart`,
    `lib/ui/screens/business_meeting_entry_screen.dart`,
    `lib/models/app_settings.dart`

- **[BUG-21]** Backup metadata now records the app version that actually
  created the backup (previously hardcoded to 1.0.0).
  - Files: `lib/services/backup_service.dart`

### New Features

- **[FEATURE]** Multi-church management: a "Switch Church" entry in Church
  Settings reaches the church selector at any time, and churches can be
  deleted from there (full cascade in one transaction, confirmation with
  record/admin counts; the church in use is protected).
  - Files: `lib/ui/screens/church_settings_screen.dart`,
    `lib/ui/screens/church_selection_screen.dart`,
    `lib/repositories/church_repository.dart`,
    `lib/services/church_service.dart`

- **[FEATURE]** Admin profile management: profiles can be edited,
  deactivated (retired admins keep their record attribution), and deleted —
  deletion is blocked while an admin has entered records, preserving the
  accountability trail. Usernames are now unique per church instead of
  globally, and profile errors are shown in plain language instead of raw
  exceptions.
  - Files: `lib/ui/screens/profile_selection_screen.dart`,
    `lib/services/admin_profile_service.dart`,
    `lib/repositories/admin_user_repository.dart`,
    `lib/ui/widgets/profile_switcher_widget.dart`

- **[FEATURE]** Currency and region: church currency is a searchable ISO
  4217 picker (no more free text or hardcoded USD default), and an optional
  Region choice at church creation seeds currency, locale, and timezone —
  all still overridable.
  - Files: `lib/models/iso_currencies.dart`, `lib/models/regions.dart`,
    `lib/ui/widgets/currency_picker_field.dart`,
    `lib/ui/screens/church_selection_screen.dart`,
    `lib/ui/screens/church_settings_screen.dart`

- **[FEATURE]** App Logs: identical consecutive entries collapse into one
  row with a ×N badge, and caught exceptions now log (and display) their
  stack traces, so crashes are diagnosable from inside the app.
  - Files: `lib/ui/screens/log_viewer_screen.dart`, entry/import screens

### Maintenance

- Church Settings tucks Church ID / Created / Last Updated into a collapsed
  Advanced section; the onboarding tutorial was rewritten (7 slides, current
  feature set, consistent "Chart Center" naming, financial-glossary link);
  PDF report charts are regression-tested to render populated data for all
  20 catalogue graphs; dead code removed (legacy CSV importer, unused PDF
  helpers, duplicate onboarding flag); schema comments de-identified.

---

## [1.5.0] — 2026-05-16

### Bug Fixes

- **[BUG-14]** Fixed onboarding/update-gating edge cases so startup and
  dashboard navigation recover cleanly after update prompts and install
  attempts.
  - Files: `lib/ui/screens/startup_gate_screen.dart`,
    `lib/ui/screens/dashboard_screen.dart`,
    `lib/platform/platform_installer_launch_service.dart`,
    `test/services/update_download_service_test.dart`

- **[BUG-15]** Update downloads now use stronger result handling, checksum
  validation, Android install permission checks, and foreground download
  support.
  - Files: `lib/services/update_download_service.dart`,
    `lib/services/update_download_result.dart`,
    `lib/platform/install_permission_service.dart`,
    `lib/services/download_foreground_service.dart`,
    `android/app/src/main/AndroidManifest.xml`,
    `test/services/update_download_service_test.dart`,
    `test/services/download_state_service_test.dart`

### New Features

- **[FEATURE]** Enhanced in-app update flow with backup prompts, visible
  download progress, install failure recovery, and update controls in settings.
  - Files: `lib/ui/screens/startup_gate_screen.dart`,
    `lib/ui/widgets/about_updates_card.dart`,
    `lib/ui/widgets/pre_update_backup_dialog.dart`,
    `lib/ui/widgets/update_download_progress_dialog.dart`,
    `lib/services/download_state_service.dart`,
    `lib/ui/screens/app_settings_screen.dart`

- **[FEATURE]** Background update checks now respect connectivity state and
  app lifecycle startup paths.
  - Files: `lib/main.dart`, `lib/services/background_update_service.dart`,
    `lib/ui/widgets/about_updates_card.dart`,
    `test/services/background_update_service_test.dart`

- **[FEATURE]** Release CI now builds Android, Windows, and web container
  assets from branch and version tag pushes.
  - Files: `.github/workflows/build-release.yml`,
    `.github/workflows/build-android.yml`, `android/app/build.gradle.kts`

### Documentation

- Refreshed forking, customization, platform parity, and technical report
  documentation for the update/release workflow.
  - Files: `README.md`, `TECHNICAL_REPORT.md`, `docs/FORKING.md`,
    `docs/FORK_GUIDE.md`, `docs/CUSTOMISATION.md`,
    `docs/PLATFORM_PARITY.md`

---

## [1.4.0] — 2026-05-13

### Bug Fixes

- **[BUG-11]** Fixed startup back-navigation race that could expose a stuck
  loading screen.
  - Files: `lib/ui/screens/startup_gate_screen.dart`,
    `lib/ui/screens/dashboard_screen.dart`

- **[BUG-12]** Android log export now resolves a valid save location.
  - Files: `lib/ui/screens/log_viewer_screen.dart`

- **[BUG-13]** Optional event counts in imports remain nullable and XLSX
  integers parse correctly.
  - Files: `lib/services/import_service.dart`

### New Features

- **[FEATURE]** Full imported-data list with filtering, edit entry points,
  and safe delete across all modules.
  - Files: `lib/ui/screens/imported_data_screen.dart`,
    `lib/ui/screens/dashboard_screen.dart`,
    `lib/services/weekly_records_provider.dart`,
    `lib/repositories/weekly_record_repository.dart`,
    `lib/repositories/board_meeting_repository.dart`,
    `lib/repositories/holy_communion_repository.dart`,
    `lib/repositories/business_meeting_repository.dart`,
    `lib/ui/screens/weekly_entry_screen.dart`,
    `lib/ui/screens/board_meeting_entry_screen.dart`,
    `lib/ui/screens/holy_communion_entry_screen.dart`,
    `lib/ui/screens/business_meeting_entry_screen.dart`,
    `lib/ui/screens/screens.dart`, `test/database/database_test.dart`

- **[FEATURE]** Excel (.xlsx) import support plus downloadable CSV/XLSX
  templates from the import screen.
  - Files: `lib/services/import_service.dart`,
    `lib/services/import_template_service.dart`,
    `lib/ui/screens/import_screen.dart`, `lib/services/services.dart`

- **[FEATURE]** PDF report export now includes an expanded chart catalogue.
  - Files: `lib/services/pdf_chart_builder.dart`,
    `lib/services/pdf_graph_catalogue.dart`,
    `lib/services/pdf_report_service.dart`

---

## [1.3.0] — 2026-05-12

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
