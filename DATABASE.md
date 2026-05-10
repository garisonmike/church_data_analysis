# Database Reference

> Schema definition, column reference, relationship diagram, and migration history for the Church Analytics SQLite database (Drift ORM, schema version 6).

---

## Table of Contents

- [Overview](#overview)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Table Reference](#table-reference)
  - [churches](#churches)
  - [admin_users](#admin_users)
  - [weekly_records](#weekly_records)
  - [derived_metrics](#derived_metrics)
  - [export_history](#export_history)
  - [home_churches](#home_churches)
  - [board_meeting_records](#board_meeting_records)
  - [holy_communion_events](#holy_communion_events)
  - [holy_communion_attendance](#holy_communion_attendance)
  - [business_meeting_events](#business_meeting_events)
  - [business_meeting_attendance](#business_meeting_attendance)
- [Unique Constraints](#unique-constraints)
- [Migration History](#migration-history)
- [Adding a New Table](#adding-a-new-table)
- [Working with Drift](#working-with-drift)

---

## Overview

| Property | Value |
|---|---|
| Engine | SQLite 3 |
| ORM | Drift 2.30.x |
| Schema version | 6 |
| Foreign key enforcement | `PRAGMA foreign_keys = ON` (set in `beforeOpen`) |
| Primary keys | Auto-incrementing integer on all tables |

The database file lives at the path returned by `path_provider`'s `getApplicationDocumentsDirectory()`, under `church_analytics.sqlite`.

---

## Entity Relationship Diagram

```
┌──────────────────┐
│    churches      │◄──────────────────────────────────┐
│──────────────────│                                    │
│ id (PK)          │                                    │
│ name             │                                    │
│ address          │                                    │
│ contactEmail     │                                    │
│ contactPhone     │                                    │
│ currency         │                                    │
│ website          │                                    │
│ boardMemberCount │                                    │
│ totalMembership  │                                    │
│ createdAt        │                                    │
│ updatedAt        │                                    │
└──────┬───────────┘                                    │
       │ 1:N                                            │
       ├──────────────────┐                             │
       │                  │                             │
┌──────▼───────────┐ ┌────▼──────────────┐             │
│  admin_users     │ │  weekly_records   │             │
│──────────────────│ │──────────────────-│             │
│ id (PK)          │ │ id (PK)           │             │
│ username         │ │ churchId (FK)     │             │
│ fullName         │ │ createdByAdminId  │             │
│ email            │ │ weekStartDate     │             │
│ churchId (FK) ───┘ │ men               │             │
│ isActive         │ │ women             │             │
│ pinHash          │ │ youth             │             │
│ createdAt        │ │ children          │             │
│ lastLoginAt      │ │ sundayHomeChurch  │             │
└──────────────────┘ │ baptisms          │             │
                     │ holyCommunion     │             │
                     │ tithe             │             │
                     │ offerings         │             │
                     │ emergencyCol.     │             │
                     │ plannedCol.       │             │
                     │ sabbathSchoolAttn │             │
                     │ visitorsCount     │             │
                     │ missionOffering   │             │
                     │ localChurchBudget │             │
                     │ createdAt         │             │
                     │ updatedAt         │             │
                     └───────────────────┘             │
                                                       │
┌──────────────────────────────────────────────────────┘
│ 1:N
│
├────────────────────┐
│                    │
▼                    ▼
┌──────────────┐  ┌───────────────────────┐
│home_churches │  │ board_meeting_records │
│──────────────│  │───────────────────────│
│ id (PK)      │  │ id (PK)               │
│ churchId(FK) │  │ churchId (FK)         │
│ name         │  │ createdByAdminId      │
│ category     │  │ meetingDate           │
│ expectedMemb │  │ year                  │
│ expectedAtKcc│  │ month                 │
│ isActive     │  │ actualAttendance      │
│ sortOrder    │  │ expectedAttendance    │
│ createdAt    │  │ notes                 │
│ updatedAt    │  │ createdAt             │
└──────┬───────┘  │ updatedAt             │
       │          └───────────────────────┘
       │ 1:N (via attendance child tables)
       │
       ├──────────────────────────────────────┐
       │                                      │
┌──────▼──────────────┐    ┌──────────────────▼──────────────┐
│holy_communion_events│    │   business_meeting_events        │
│─────────────────────│    │─────────────────────────────────-│
│ id (PK)             │    │ id (PK)                          │
│ churchId (FK)       │    │ churchId (FK)                    │
│ createdByAdminId    │    │ createdByAdminId                 │
│ eventDate           │    │ eventDate                        │
│ year                │    │ year                             │
│ quarter             │    │ quarter                          │
│ totalExpectedAtKcc  │    │ meetingNumber (1–3)              │
│ notes               │    │ totalExpectedAtKcc               │
│ createdAt           │    │ notes                            │
│ updatedAt           │    │ createdAt                        │
└──────┬──────────────┘    │ updatedAt                        │
       │ 1:N               └──────────────┬───────────────────┘
       ▼                                  │ 1:N
┌──────────────────────────┐             ▼
│holy_communion_attendance │  ┌──────────────────────────────┐
│──────────────────────────│  │ business_meeting_attendance  │
│ id (PK)                  │  │──────────────────────────────│
│ eventId (FK)             │  │ id (PK)                      │
│ homeChurchId (FK) ───────┼─▶│ eventId (FK)                │
│ actualAttendance         │  │ homeChurchId (FK)            │
│ expectedAtHc             │  │ actualAttendance              │
└──────────────────────────┘  │ expectedAtHc                 │
                              └──────────────────────────────┘
```

---

## Table Reference

### churches

Stores one row per registered church profile.

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | INTEGER | No | autoincrement | Primary key |
| `name` | TEXT (1–200) | No | — | Church display name |
| `address` | TEXT | Yes | NULL | Physical address |
| `contactEmail` | TEXT | Yes | NULL | Contact email |
| `contactPhone` | TEXT | Yes | NULL | Contact phone number |
| `currency` | TEXT | No | `'USD'` | 3-letter currency code (e.g. `'KES'`) |
| `website` | TEXT | Yes | NULL | Church website URL *(added v6)* |
| `boardMemberCount` | INTEGER | No | `0` | Total board members — used as expected attendance in board meeting tracking *(added v6)* |
| `totalMembership` | INTEGER | No | `0` | Total registered church membership *(added v6)* |
| `createdAt` | DATETIME | No | — | Row creation timestamp |
| `updatedAt` | DATETIME | No | — | Last update timestamp |

---

### admin_users

One row per admin/clerk account, scoped to a church.

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | INTEGER | No | autoincrement | Primary key |
| `username` | TEXT (3–50) | No | — | Unique within a church |
| `fullName` | TEXT (1–100) | No | — | Display name |
| `email` | TEXT | Yes | NULL | Optional email |
| `churchId` | INTEGER | No | — | FK → `churches.id` |
| `isActive` | BOOLEAN | No | `true` | Soft-delete flag |
| `pinHash` | TEXT | Yes | NULL | Bcrypt hash of 4-digit PIN, or NULL if no PIN set *(added v5)* |
| `createdAt` | DATETIME | No | — | Account creation timestamp |
| `lastLoginAt` | DATETIME | No | — | Last login timestamp |

---

### weekly_records

The core table. One row per Sabbath week per church. Enforces uniqueness via `(churchId, weekStartDate)`.

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | INTEGER | No | autoincrement | Primary key |
| `churchId` | INTEGER | No | — | FK → `churches.id` |
| `createdByAdminId` | INTEGER | Yes | NULL | FK → `admin_users.id` |
| `weekStartDate` | DATETIME | No | — | Saturday (Sabbath) date for the week |
| `men` | INTEGER | No | `0` | Adult male attendance |
| `women` | INTEGER | No | `0` | Adult female attendance |
| `youth` | INTEGER | No | `0` | Youth attendance |
| `children` | INTEGER | No | `0` | Children attendance |
| `sundayHomeChurch` | INTEGER | No | `0` | Members attending from home church |
| `baptisms` | INTEGER | Yes | NULL | Baptisms this week *(added v3)* |
| `holyCommunion` | INTEGER | Yes | NULL | Holy Communion attendance count *(added v4)* |
| `tithe` | REAL | No | `0.0` | Tithe collected |
| `offerings` | REAL | No | `0.0` | Offerings collected |
| `emergencyCollection` | REAL | No | `0.0` | Emergency/special collection |
| `plannedCollection` | REAL | No | `0.0` | Planned/budgeted collection |
| `sabbathSchoolAttendance` | INTEGER | Yes | NULL | Sabbath school attendance *(added v6)* |
| `visitorsCount` | INTEGER | Yes | NULL | First-time visitors *(added v6)* |
| `missionOffering` | REAL | Yes | NULL | 13th Sabbath / Ingathering / World Budget *(added v6)* |
| `localChurchBudget` | REAL | Yes | NULL | Local operations and maintenance *(added v6)* |
| `createdAt` | DATETIME | No | — | Row creation timestamp |
| `updatedAt` | DATETIME | No | — | Last update timestamp |

**Unique constraint:** `(churchId, weekStartDate)` — one record per church per week.

**Computed fields** (on the `WeeklyRecord` domain model, not stored):
- `totalAttendance` = `men + women + youth + children + sundayHomeChurch`
- `totalIncome` = sum of all 6 financial columns
- `coreIncome` = sum of the original 4 financial columns

---

### derived_metrics

Pre-computed period summaries. Calculated and cached by `DerivedMetricsRepository`.

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER | Primary key |
| `churchId` | INTEGER | FK → `churches.id` |
| `periodStart` | DATETIME | Start of the period |
| `periodEnd` | DATETIME | End of the period |
| `averageAttendance` | REAL | Average weekly total attendance |
| `averageIncome` | REAL | Average weekly total income |
| `growthPercentage` | REAL | Attendance growth vs. previous period |
| `attendanceToIncomeRatio` | REAL | Avg attendance ÷ avg income |
| `perCapitaGiving` | REAL | Total income ÷ total attendance |
| `menPercentage` | REAL | Men as % of total attendance |
| `womenPercentage` | REAL | Women as % of total attendance |
| `youthPercentage` | REAL | Youth as % of total attendance |
| `childrenPercentage` | REAL | Children as % of total attendance |
| `tithePercentage` | REAL | Tithe as % of total income |
| `offeringsPercentage` | REAL | Offerings as % of total income |
| `calculatedAt` | DATETIME | When this row was computed |

---

### export_history

Audit log of all export operations.

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER | Primary key |
| `churchId` | INTEGER | FK → `churches.id` |
| `exportType` | TEXT | `'csv'` / `'pdf'` / `'chart_png'` / `'excel'` |
| `exportName` | TEXT | Human-readable name of the export |
| `filePath` | TEXT? | Absolute path to the output file (nullable on web) |
| `graphType` | TEXT? | For chart exports: the chart identifier |
| `exportedAt` | DATETIME | Timestamp |
| `recordCount` | INTEGER | Number of records included in the export |

---

### home_churches

Sub-congregations or ministry groups that report to the main church.

| Column | Type | Default | Description |
|---|---|---|---|
| `id` | INTEGER | autoincrement | Primary key |
| `churchId` | INTEGER | — | FK → `churches.id` |
| `name` | TEXT (1–200) | — | Home church name |
| `category` | TEXT | `'geographical'` | `'geographical'` / `'ministry'` / `'special'` |
| `expectedMembership` | INTEGER | `0` | Total members registered at this home church |
| `expectedAtKcc` | INTEGER | `0` | Expected number to appear at main church events |
| `isActive` | BOOLEAN | `true` | Whether this home church is active |
| `sortOrder` | INTEGER | `0` | Display order |
| `createdAt` | DATETIME | — | — |
| `updatedAt` | DATETIME | — | — |

---

### board_meeting_records

One row per monthly board meeting.

| Column | Type | Constraint | Description |
|---|---|---|---|
| `id` | INTEGER | PK | Primary key |
| `churchId` | INTEGER | FK | FK → `churches.id` |
| `createdByAdminId` | INTEGER? | FK | FK → `admin_users.id` |
| `meetingDate` | DATETIME | — | Actual date of the meeting |
| `year` | INTEGER | — | Calendar year |
| `month` | INTEGER | 1–12 | Calendar month |
| `actualAttendance` | INTEGER | ≥ 0 | Board members who attended |
| `expectedAttendance` | INTEGER | ≥ 0 | Snapshot of `churches.boardMemberCount` at recording time |
| `notes` | TEXT? | — | Optional clerk notes |
| `createdAt` | DATETIME | — | — |
| `updatedAt` | DATETIME | — | — |

**Unique constraint:** `(churchId, year, month)` — one record per church per calendar month.

---

### holy_communion_events

Header row for each quarterly Holy Communion service.

| Column | Type | Constraint | Description |
|---|---|---|---|
| `id` | INTEGER | PK | Primary key |
| `churchId` | INTEGER | FK | FK → `churches.id` |
| `createdByAdminId` | INTEGER? | FK | FK → `admin_users.id` |
| `eventDate` | DATETIME | — | Date of the service |
| `year` | INTEGER | — | Calendar year |
| `quarter` | INTEGER | 1–4 | Quarter (1 = Jan–Mar) |
| `totalExpectedAtKcc` | INTEGER | ≥ 0 | KCC-wide expected total at time of recording |
| `notes` | TEXT? | — | Optional notes |
| `createdAt` | DATETIME | — | — |
| `updatedAt` | DATETIME | — | — |

**Unique constraint:** `(churchId, year, quarter)` — one event per church per quarter.

---

### holy_communion_attendance

Per-home-church attendance rows for a Holy Communion event.

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER | Primary key |
| `eventId` | INTEGER | FK → `holy_communion_events.id` |
| `homeChurchId` | INTEGER | FK → `home_churches.id` |
| `actualAttendance` | INTEGER | Members from this home church who attended |
| `expectedAtHc` | INTEGER | Snapshot of `home_churches.expectedMembership` at recording time |

**Unique constraint:** `(eventId, homeChurchId)` — one row per home church per event.

---

### business_meeting_events

Header row for each Business Meeting occurrence. Up to 3 meetings per quarter are supported.

| Column | Type | Constraint | Description |
|---|---|---|---|
| `id` | INTEGER | PK | Primary key |
| `churchId` | INTEGER | FK | FK → `churches.id` |
| `createdByAdminId` | INTEGER? | FK | FK → `admin_users.id` |
| `eventDate` | DATETIME | — | Date of the meeting |
| `year` | INTEGER | — | Calendar year |
| `quarter` | INTEGER | 1–4 | Quarter |
| `meetingNumber` | INTEGER | 1–3 | Which meeting within the quarter |
| `totalExpectedAtKcc` | INTEGER | ≥ 0 | KCC-wide expected total |
| `notes` | TEXT? | — | Optional notes |
| `createdAt` | DATETIME | — | — |
| `updatedAt` | DATETIME | — | — |

**Unique constraint:** `(churchId, year, quarter, meetingNumber)`.

---

### business_meeting_attendance

Per-home-church attendance for a Business Meeting.

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER | Primary key |
| `eventId` | INTEGER | FK → `business_meeting_events.id` |
| `homeChurchId` | INTEGER | FK → `home_churches.id` |
| `actualAttendance` | INTEGER | Members who attended |
| `expectedAtHc` | INTEGER | Snapshot of `home_churches.expectedMembership` |

**Unique constraint:** `(eventId, homeChurchId)`.

---

## Unique Constraints

| Table | Constraint | Meaning |
|---|---|---|
| `weekly_records` | `(churchId, weekStartDate)` | One record per church per Sabbath |
| `board_meeting_records` | `(churchId, year, month)` | One meeting per church per month |
| `holy_communion_events` | `(churchId, year, quarter)` | One service per church per quarter |
| `business_meeting_events` | `(churchId, year, quarter, meetingNumber)` | One meeting per number per quarter |
| `holy_communion_attendance` | `(eventId, homeChurchId)` | One row per home church per event |
| `business_meeting_attendance` | `(eventId, homeChurchId)` | One row per home church per event |

---

## Migration History

| Version | Changes |
|---|---|
| **1** (baseline) | `churches`, `admin_users`, `weekly_records` (original columns), `derived_metrics`, `export_history` |
| **2** | Added `weekly_records.createdByAdminId` |
| **3** | Added `weekly_records.baptisms` |
| **4** | Added `weekly_records.holyCommunion` |
| **5** | Added `admin_users.pinHash` |
| **6** | Added `churches.website`, `churches.boardMemberCount`, `churches.totalMembership`; added `weekly_records.sabbathSchoolAttendance`, `weekly_records.visitorsCount`, `weekly_records.missionOffering`, `weekly_records.localChurchBudget`; created `home_churches`, `board_meeting_records`, `holy_communion_events`, `holy_communion_attendance`, `business_meeting_events`, `business_meeting_attendance` |

---

## Adding a New Table

1. **Define the table class** in `lib/database/app_database.dart`:

```dart
class MyNewTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get churchId => integer().references(Churches, #id)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  DateTimeColumn get createdAt => dateTime()();
}
```

2. **Add it to `@DriftDatabase(tables: [...])`** in the same file.

3. **Increment `schemaVersion`** and add a migration branch:

```dart
@override
int get schemaVersion => 7; // was 6

// In onUpgrade:
if (from < 7) {
  await m.createTable(myNewTable);
}
```

4. **Regenerate** the Drift binding:

```bash
dart run build_runner build --delete-conflicting-outputs
```

5. **Create a repository** in `lib/repositories/my_new_table_repository.dart`.

6. **Add a provider** in `lib/services/weekly_records_provider.dart`.

7. **Write tests** in `test/repositories/my_new_table_repository_test.dart` using `NativeDatabase.memory()`.

---

## Working with Drift

### In-memory database for tests

```dart
setUp(() {
  database = AppDatabase.forTesting(NativeDatabase.memory());
});

tearDown(() async {
  await database.close();
});
```

### Selecting with a filter

```dart
final results = await (db.select(db.weeklyRecords)
      ..where((t) => t.churchId.equals(churchId))
      ..orderBy([(t) => OrderingTerm.desc(t.weekStartDate)])
      ..limit(20))
    .get();
```

### Inserting with a Companion

```dart
await db.into(db.weeklyRecords).insert(
  WeeklyRecordsCompanion.insert(
    churchId: record.churchId,
    weekStartDate: record.weekStartDate,
    men: Value(record.men),
    // ... required fields as positional, optional as Value(...)
    createdAt: record.createdAt,
    updatedAt: record.updatedAt,
  ),
);
```

### Updating with replace

```dart
await db.update(db.weeklyRecords).replace(
  WeeklyRecordsCompanion(
    id: Value(record.id!),
    churchId: Value(record.churchId),
    updatedAt: Value(DateTime.now()),
    // ... other fields
  ),
);
```
