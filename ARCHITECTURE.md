# Architecture

> A layer-by-layer technical reference for the Church Analytics codebase.

---

## Table of Contents

- [Overview](#overview)
- [Layer Diagram](#layer-diagram)
- [Layers In Detail](#layers-in-detail)
  - [Entry Point & Routing](#entry-point--routing)
  - [Database Layer](#database-layer)
  - [Model Layer](#model-layer)
  - [Repository Layer](#repository-layer)
  - [Service Layer](#service-layer)
  - [Analytics Layer](#analytics-layer)
  - [Platform Layer](#platform-layer)
  - [State Management — Riverpod](#state-management--riverpod)
  - [UI Layer](#ui-layer)
- [Data Flow](#data-flow)
- [Key Design Decisions](#key-design-decisions)

---

## Overview

Church Analytics follows a **layered architecture** with strict dependency rules:

```
UI ──→ Providers ──→ Services ──→ Repositories ──→ Database
               ↘               ↘
              Analytics       Platform I/O
```

- **Each layer depends only on the layer below it.** UI never touches the database directly.
- **Dependency injection** is handled by Riverpod `Provider`s. Screens call `ref.read(someProvider)` — they never instantiate repositories or services manually.
- **Models are pure.** They are immutable Dart classes with no Flutter imports, no Riverpod imports, and no side effects.

---

## Layer Diagram

```
┌───────────────────────────────────────────────────────────┐
│                      UI Layer                             │
│   lib/ui/screens/         lib/ui/widgets/                 │
│   ConsumerWidget / ConsumerStatefulWidget                 │
│   Reads: Riverpod providers                               │
│   Writes: ref.read(provider.notifier).method()            │
└───────────────────────┬───────────────────────────────────┘
                        │ ref.watch / ref.read
┌───────────────────────▼───────────────────────────────────┐
│                  Riverpod Providers                       │
│   lib/services/weekly_records_provider.dart               │
│   lib/services/settings_service.dart                      │
│   lib/services/theme_service.dart                         │
└──────┬─────────────────────────────────┬──────────────────┘
       │                                 │
┌──────▼──────────┐           ┌──────────▼──────────────────┐
│  Service Layer  │           │      Analytics Layer        │
│  lib/services/  │           │  lib/analytics/             │
│  Orchestration, │           │  lib/services/              │
│  business logic │           │    analytics_service.dart   │
└──────┬──────────┘           └──────────┬──────────────────┘
       │                                 │
┌──────▼──────────────────────────────────────────────────┐
│                  Repository Layer                       │
│   lib/repositories/                                     │
│   Type-safe Drift queries → domain models               │
└──────┬──────────────────────────────────────────────────┘
       │
┌──────▼──────────────────────────────────────────────────┐
│                   Database Layer                        │
│   lib/database/app_database.dart     (schema, ORM)      │
│   lib/database/app_database.g.dart   (generated)        │
│   lib/database/connection/           (per-platform)     │
│   SQLite via Drift 2.30                                 │
└─────────────────────────────────────────────────────────┘
```

---

## Layers In Detail

### Entry Point & Routing

**File:** `lib/main.dart`

`main()` performs sequential startup:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `LogService.init()` — sets up file-based logging before anything else runs.
3. Installs `FlutterError.onError` and a `runZonedGuarded` zone to capture all unhandled errors.
4. Initialises date formatting via `intl`.
5. Loads `SharedPreferences` once and injects it into the Riverpod scope via `sharedPreferencesProvider.overrideWithValue(...)`.
6. Runs `ChurchAnalyticsApp` inside a `ProviderScope`.

**Routing** is implemented as a `MaterialApp.onGenerateRoute` switch statement. All routes are named strings. Route arguments are passed as a single `int` (church ID) for routes that require it.

> ⚠️ **Known issue (see SE audit):** Route strings are hardcoded literals. A future refactor should introduce an `AppRoutes` constants class and migrate to GoRouter for typed parameters.

**Startup flow:**

```
main() → StartupGateScreen
  ├── No church exists   → ChurchSelectionScreen → ProfileSelectionScreen → /dashboard
  ├── Church exists      → ProfileSelectionScreen → /dashboard
  └── Profile selected   → DashboardScreen(churchId)
```

---

### Database Layer

**Files:** `lib/database/`

The app uses [Drift](https://drift.simonbinder.eu/) — a type-safe SQLite ORM for Flutter.

#### Tables

| Table | Class | Description |
|---|---|---|
| `churches` | `Churches` | Church profiles |
| `admin_users` | `AdminUsers` | Per-church admin accounts |
| `weekly_records` | `WeeklyRecords` | Sabbath attendance & finance (one row/week) |
| `derived_metrics` | `DerivedMetricsList` | Pre-computed period summaries |
| `export_history` | `ExportHistoryList` | Audit log of exports |
| `home_churches` | `HomeChurches` | Sub-congregations / ministry groups |
| `board_meeting_records` | `BoardMeetingRecords` | Monthly board meeting attendance |
| `holy_communion_events` | `HolyCommunionEvents` | Quarterly communion event headers |
| `holy_communion_attendance` | `HolyCommunionAttendance` | Per-home-church attendance rows |
| `business_meeting_events` | `BusinessMeetingEvents` | Quarterly business meeting headers |
| `business_meeting_attendance` | `BusinessMeetingAttendance` | Per-home-church attendance rows |

#### Schema Versioning

Current version: **6**. See [DATABASE.md](DATABASE.md) for the full migration history.

#### Platform Connections

`lib/database/connection/connection.dart` exports the correct `openConnection()` implementation per compile-time platform:

| File | Platform |
|---|---|
| `native.dart` | Android, iOS, Windows, macOS, Linux |
| `web.dart` | Web (stub — WASM not yet implemented) |
| `unsupported.dart` | Fallback — throws at runtime |

#### Code Generation

The `app_database.g.dart` file is auto-generated by `drift_dev`. **Always regenerate after any schema change:**

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

### Model Layer

**Directory:** `lib/models/`

All models are **pure Dart** — no Flutter, no Riverpod, no DB imports.

```
models/
├── church.dart
├── weekly_record.dart
├── admin_user.dart
├── app_settings.dart
├── home_church.dart
├── board_meeting_record.dart
├── holy_communion_event.dart
├── business_meeting_event.dart
├── derived_metrics.dart
├── export_history.dart
├── dashboard_config.dart
├── charts/
│   ├── time_series_point.dart   # (DateTime x, double y)
│   ├── category_point.dart      # (String label, double value)
│   ├── scatter_point.dart
│   ├── box_plot_point.dart
│   ├── heatmap_point.dart
│   ├── distribution_point.dart
│   └── charts.dart              # barrel export
└── models.dart                  # barrel export (includes charts/)
```

**All models implement:**
- `Equatable` — value equality via `props` list.
- `copyWith(...)` — immutable updates.
- `toJson()` / `fromJson()` — JSON serialisation for CSV/backup.
- `validate()` — returns a `String?` error message, or `null` if valid.
- `isValid()` — shortcut for `validate() == null`.

#### Chart Models

`lib/models/charts/` holds lightweight point types used as data sources for Syncfusion chart series. These are intentionally kept separate from domain models to avoid coupling the chart library's API to business entities.

---

### Repository Layer

**Directory:** `lib/repositories/`

Repositories are the **only** layer that touches Drift directly. Each repository:

- Accepts an `AppDatabase` instance via constructor (injected by a Riverpod provider).
- Exposes async methods that return domain models (not Drift-generated `Data` classes).
- Uses a private `_toModel()` method to map DB rows to domain models.
- Never contains business logic — only query construction.

```
repositories/
├── church_repository.dart
├── weekly_record_repository.dart
├── admin_user_repository.dart
├── settings_repository.dart
├── derived_metrics_repository.dart
├── home_church_repository.dart
├── board_meeting_repository.dart
├── holy_communion_repository.dart
├── business_meeting_repository.dart
└── repositories.dart            # barrel export
```

**Example pattern:**

```dart
class WeeklyRecordRepository {
  final AppDatabase _db;
  WeeklyRecordRepository(this._db);

  Future<List<WeeklyRecord>> getRecordsByChurch(int churchId) async {
    final rows = await (_db.select(_db.weeklyRecords)
          ..where((t) => t.churchId.equals(churchId))
          ..orderBy([(t) => OrderingTerm.desc(t.weekStartDate)]))
        .get();
    return rows.map(_toModel).toList();
  }

  WeeklyRecord _toModel(db.WeeklyRecord row) => WeeklyRecord(
    id: row.id,
    churchId: row.churchId,
    // ... all fields
  );
}
```

---

### Service Layer

**Directory:** `lib/services/`

Services orchestrate multiple repositories and implement business logic that spans more than one entity. They do **not** own UI state — that belongs to Riverpod notifiers.

| Service | Responsibility |
|---|---|
| `AnalyticsService` | Converts `List<WeeklyRecord>` into chart datasets |
| `BackupService` | Full DB backup to JSON file and restore |
| `CsvExportService` | Generates CSV from weekly records |
| `CsvImportService` | Parses and validates CSV imports |
| `PdfReportService` | Builds PDF documents with `pdf` package |
| `ChartExportService` | Captures chart widget to PNG |
| `AdminProfileService` | PIN verification, profile switching |
| `ChurchService` | Church selection state (see audit — consolidate with AppSettings) |
| `BackgroundUpdateService` | Polls update manifest URL, compares versions |
| `LogService` | File-based logging with severity levels |
| `ActivityLogService` | User-action audit trail |
| `PerformanceMonitor` | Tracks query timings |
| `ValidationService` | Cross-field form validation |
| `DashboardConfigService` | Saves/loads dashboard layout configuration |
| `FileService` | Platform-agnostic file read/write |
| `ImportService` | Orchestrates CSV import with validation |

---

### Analytics Layer

**Directory:** `lib/analytics/`

Pure computation — no Flutter imports, no Riverpod, no DB.

| File | Responsibility |
|---|---|
| `analytics_service.dart` | Converts records to `TimeSeriesPoint`, `CategoryPoint` etc. for Syncfusion chart series |
| `metrics_calculator.dart` | Calculates summary statistics (averages, growth %, ratios, demographics) |

> ⚠️ **Known issue (see SE audit):** These two classes have overlapping responsibilities. `MetricsCalculator` should own all raw computation; `AnalyticsService` should own transformation to chart-ready types.

---

### Platform Layer

**Directory:** `lib/platform/`

Thin adapters that isolate platform-specific file I/O behaviour.

| File | Responsibility |
|---|---|
| `file_storage_interface.dart` | Abstract interface for file operations |
| `file_storage_mobile.dart` | Android / iOS implementation |
| `file_storage_web.dart` | Web implementation (downloads via browser) |
| `default_export_path_resolver.dart` | Resolves the OS-appropriate export directory |
| `filename_sanitizer.dart` | Strips illegal characters from filenames |
| `filename_conflict_resolver.dart` | Adds numeric suffix on filename collision |
| `path_safety_guard.dart` | Prevents path traversal attacks |
| `platform_installer_launch_service.dart` | Launches platform-specific update installers |

---

### State Management — Riverpod

**Primary file:** `lib/services/weekly_records_provider.dart`

All Riverpod providers are centralised here (along with `settings_service.dart` and `theme_service.dart`).

#### Provider Inventory

| Provider | Type | Returns |
|---|---|---|
| `databaseProvider` | `Provider` | `AppDatabase` |
| `sharedPreferencesProvider` | `Provider` | `SharedPreferences` (overridden at startup) |
| `weeklyRecordRepositoryProvider` | `Provider` | `WeeklyRecordRepository` |
| `churchRepositoryProvider` | `Provider` | `ChurchRepository` |
| `boardMeetingRepositoryProvider` | `Provider` | `BoardMeetingRepository` |
| `holyCommunionRepositoryProvider` | `Provider` | `HolyCommunionRepository` |
| `homeChurchesProvider` | `FutureProvider.family` | `List<HomeChurch>` |
| `boardMeetingRecordsProvider` | `FutureProvider.family` | `List<BoardMeetingRecord>` |
| `holyCommunionEventsProvider` | `FutureProvider.family` | `List<HolyCommunionEvent>` |
| `weeklyRecordsProvider` | `FutureProvider.family` | `List<WeeklyRecord>` |
| `appSettingsProvider` | `StateNotifierProvider` | `AppSettings` |
| `themeProvider` | `Provider` | `ThemeData` (light) |
| `darkThemeProvider` | `Provider` | `ThemeData` (dark) |
| `themeModeProvider` | `Provider` | `ThemeMode` |

#### Settings Notifier

`SettingsNotifier extends StateNotifier<AppSettings>` owns all persisted app-level state:

```dart
// Reading settings reactively:
final settings = ref.watch(appSettingsProvider);
final currency = settings.currency;
final churchId = settings.selectedChurchId;

// Writing:
ref.read(appSettingsProvider.notifier).updateTheme(AppThemeMode.dark);
ref.read(appSettingsProvider.notifier).updateChurchId(newChurchId);
```

---

### UI Layer

**Directory:** `lib/ui/`

```
ui/
├── screens/          # One file per named route
└── widgets/          # Reusable components
    ├── charts/       # Chart wrapper widgets
    └── ...
```

#### Screen Conventions

- All screens that read Riverpod state use `ConsumerWidget` or `ConsumerStatefulWidget`.
- Screens read data via `ref.watch(someProvider)` and trigger writes via `ref.read(someProvider.notifier).method()`.
- Screens do **not** instantiate repositories or services directly.
- Every async method that calls `setState()` or `Navigator` after an `await` must begin with `if (!mounted) return`.

#### Route Map

| Route | Screen | Requires churchId arg |
|---|---|---|
| `/` | `StartupGateScreen` | No |
| `/dashboard` | `DashboardScreen` | Yes |
| `/select-church` | `ChurchSelectionScreen` | No |
| `/select-profile` | `ProfileSelectionScreen` | Yes |
| `/entry` | `WeeklyEntryScreen` | Yes |
| `/import` | `ImportScreen` | Yes |
| `/settings` | `ChurchSettingsScreen` | Yes |
| `/charts` | `GraphCenterScreen` | Yes |
| `/analytics` | `AnalyticsDashboard` | Yes |
| `/charts/advanced` | `AdvancedChartsScreen` | Yes |
| `/charts/attendance` | `AttendanceChartsScreen` | Yes |
| `/charts/correlation` | `CorrelationChartsScreen` | Yes |
| `/charts/financial` | `FinancialChartsScreen` | Yes |
| `/charts/custom` | `CustomGraphBuilderScreen` | Yes |
| `/charts/detail` | `DetailedMetricsScreen` | Yes |
| `/charts/distribution` | `DistributionScreen` | Yes |
| `/charts/targets` | `TargetAnalysisScreen` | Yes |
| `/charts/cross` | `CrossDatasetScreen` | Yes |
| `/reports` | `ReportsScreen` | Yes |
| `/app-settings` | `AppSettingsScreen` | No |
| `/board-meeting` | `BoardMeetingAnalyticsScreen` | No (reads from AppSettings) |
| `/board-meeting/entry` | `BoardMeetingEntryScreen` | No |
| `/home-churches` | `HomeChurchScreen` | No |
| `/home-church-analytics` | `HomeChurchAnalyticsScreen` | No |
| `/special-events` | `SpecialEventsScreen` | No |
| `/holy-communion/entry` | `HolyCommunionEntryScreen` | No |
| `/business-meeting/entry` | `BusinessMeetingEntryScreen` | No |
| `/financial-glossary` | `FinancialGlossaryScreen` | No |
| `/dashboard/layout` | `DashboardLayoutEditorScreen` | No |
| `/restore-backup` | `FirstLaunchBackupImportScreen` | No |

---

## Data Flow

### Writing a Weekly Record (Happy Path)

```
User fills form in WeeklyEntryScreen
  │
  ▼
_saveRecord() called
  │
  ├─ Validates via WeeklyRecord.validate()
  │
  ├─ ref.read(weeklyRecordRepositoryProvider)
  │     .createRecord(record)
  │
  ├─ ref.invalidate(weeklyRecordsProvider(churchId))
  │     → forces re-fetch on next watch
  │
  └─ Navigator.pop() → Dashboard refreshes via invalidated provider
```

### Reading the Dashboard

```
DashboardScreen builds
  │
  ├─ ref.watch(weeklyRecordsProvider(churchId))
  │     → AsyncValue<List<WeeklyRecord>>
  │     → shows loading / error / data
  │
  ├─ AnalyticsService.totalAttendanceTrend(records)
  │     → List<TimeSeriesPoint>
  │
  └─ Syncfusion chart renders the series
```

---

## Key Design Decisions

### Why Drift?

Drift gives type-safe query building in Dart, auto-generated data classes, schema migrations, and an in-memory test backend — all without writing raw SQL strings. The alternative (sqflite) requires manual row mapping and offers no compile-time query safety.

### Why Riverpod?

Riverpod gives compile-time safe provider access, zero context dependence (`ref` vs `BuildContext`), and a clean family/autoDispose pattern for per-church data providers. The alternative (Provider package) has well-documented issues with testing and state lifecycle.

### Why Offline-First?

Church data entry happens in environments with unreliable internet (rural Kenya). All data lives in a local SQLite file. Backup/restore gives the administrator control over their own data. No server dependency means no subscriptions, no downtime, and no privacy concerns.

### Why Not GoRouter?

The current `onGenerateRoute` switch is simple and works. GoRouter becomes worth the migration cost when you need deep linking (web), shell routes (nested navigation), or typed parameters. These are planned for a future version when web support is fully implemented.

### Why Equatable?

Riverpod's `FutureProvider` compares the previous and next state to decide whether to rebuild. Without value equality, two identical `AppSettings` objects would be treated as different, causing spurious rebuilds. `Equatable` provides this with minimal boilerplate via the `props` list.
