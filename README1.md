# Church Analytics

> A multiplatform Flutter application for church administrators to track, analyse, and report on weekly attendance and financial data.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Proprietary-lightgrey)]()
[![Version](https://img.shields.io/badge/Version-1.2.4-informational)]()
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20Windows%20%7C%20Linux%20%7C%20iOS%20%7C%20macOS-green)]()

---

## Overview

Church Analytics replaces a legacy Python CLI + matplotlib workflow with a modern, offline-first, cross-platform tool purpose-built for Seventh-day Adventist church administration. It covers the full data lifecycle: entry → storage → analysis → reporting.

The app is designed for a **multi-church, multi-admin** environment where:
- A clerk enters weekly Sabbath attendance and financial collections.
- Administrators view analytics dashboards to track growth trends, demographic ratios, and financial health.
- Board secretaries record monthly board meeting attendance.
- The Holy Communion and Business Meeting secretary tracks quarterly event attendance broken down by home church.

---

## Features

### Data Entry
| Feature | Description |
|---|---|
| **Weekly Records** | Men, women, youth, children, home church, baptisms, holy communion, sabbath school, visitors |
| **Finance Entry** | Tithe, offerings, emergency collection, planned collection, mission offering, local church budget |
| **Board Meeting** | Monthly attendance vs. expected board member count |
| **Holy Communion** | Quarterly per-home-church attendance with expected vs. actual |
| **Business Meeting** | Quarterly meeting attendance per home church (up to 3 meetings per quarter) |
| **Home Church Management** | Manage all home churches/ministry groups with category and expected membership |

### Analytics & Charts
| Feature | Description |
|---|---|
| **Attendance Trends** | Weekly time-series for total and per-demographic attendance |
| **Financial Trends** | Tithe, offerings, and total income over time |
| **Demographic Distribution** | Pie and bar charts for gender/age composition |
| **Correlation Analysis** | Attendance-to-income correlation scatter plots |
| **Target Analysis** | Set attendance/income targets and track progress |
| **Board Meeting Analytics** | Monthly attendance trend with expected vs. actual |
| **Special Events** | Holy Communion and Business Meeting trends by home church |
| **Custom Graph Builder** | Drag-and-drop chart composer for custom views |

### Data Management
| Feature | Description |
|---|---|
| **CSV Import** | Bulk import from legacy CSV files |
| **CSV Export** | Export records in standard format |
| **PDF Reports** | Formatted PDF reports with charts |
| **Chart Export** | PNG export for any chart |
| **Backup & Restore** | Full database backup to local file system |
| **In-App Update** | Self-updating with SHA-256 hash verification |

### System
| Feature | Description |
|---|---|
| **Multi-church** | One installation, multiple church profiles |
| **Multi-admin** | Per-church admin profiles with optional PIN |
| **Offline-first** | All data stored locally via SQLite (Drift ORM) |
| **Theming** | Light / Dark / System theme |
| **Log Viewer** | In-app log viewer with severity filtering |
| **Activity Log** | Audit trail of all data changes |

---

## Architecture

```
lib/
├── main.dart                    # App entry point, routing, error zone
├── database/
│   ├── app_database.dart        # Drift schema, migrations (schema v6)
│   └── connection/              # Platform-specific DB connections
├── models/                      # Pure Dart data classes (Equatable)
│   └── charts/                  # Chart-specific data point types
├── repositories/                # Data access layer (Drift queries)
├── services/                    # Business logic and orchestration
├── analytics/                   # Pure computation — metrics & charts
├── platform/                    # Platform-specific file I/O
└── ui/
    ├── screens/                 # One file per route/screen
    └── widgets/                 # Reusable UI components
```

See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full layer-by-layer breakdown.

---

## Supported Platforms

| Platform | Build | Notes |
|---|---|---|
| Android | `flutter build apk --release` | Min SDK 21 |
| Windows | `flutter build windows --release` | x64 only |
| Linux | `flutter build linux --release` | x64 only |
| iOS | `flutter build ipa --release` | Requires macOS + Xcode 15 |
| macOS | `flutter build macos --release` | Requires macOS + Xcode 15 |
| Web | Not production-ready | Drift WASM integration pending |

---

## Quick Start

### Prerequisites

- Flutter 3.x stable channel
- Dart SDK 3.9+
- For Android: Android SDK with API 21+
- For iOS/macOS: Xcode 15+

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/GarisonMike/church_data_analysis.git
cd church_data_analysis

# 2. Install dependencies
flutter pub get

# 3. Generate Drift database bindings
#    REQUIRED — must be run after every schema change
dart run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run
```

### First Launch

On first launch the app shows a setup wizard:

1. **Select or create a church** — enter name, address, and contact details.
2. **Create an admin profile** — choose a username and optionally set a PIN.
3. You are taken to the **Dashboard** for that church.

To add more churches or admins later, use the profile/church selector accessible from the dashboard header.

---

## Development

### Running Tests

```bash
# Unit + widget tests
flutter test

# With coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Code Generation

Always regenerate after modifying `lib/database/app_database.dart`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Static Analysis

```bash
flutter analyze --fatal-infos
```

### Project Structure Conventions

| Layer | Rule |
|---|---|
| **Screens** | No business logic. Read from providers. Delegate writes to repositories via providers. |
| **Repositories** | Drift queries only. No business logic. Map DB rows to domain models via `_toModel()`. |
| **Services** | Orchestrate multiple repositories. Contain business logic. No direct DB access. |
| **Models** | Immutable. `Equatable`. `copyWith`, `toJson`, `fromJson`, `validate()`. |
| **Providers** | Defined in `lib/services/weekly_records_provider.dart`. One provider per dependency. |

---

## Database Schema

The app uses SQLite via the Drift ORM. Current schema version: **6**.

See [DATABASE.md](docs/DATABASE.md) for the full schema reference and migration history.

---

## Configuration

### Syncfusion License

The app uses `syncfusion_flutter_charts`. Provide a valid license key at build time:

```bash
flutter build apk --dart-define=SF_KEY=your_license_key_here
```

In `main.dart`:

```dart
const sfKey = String.fromEnvironment('SF_KEY');
if (sfKey.isNotEmpty) SfLicenseKey.registerLicense(sfKey);
```

Without a key, Syncfusion renders a watermark on charts in builds that exceed the community license threshold.

### Demo / Seed Data

Set `const bool _kDemoMode = true` in `lib/database/app_database.dart` before first launch to pre-populate the database with 12 weeks of sample data for Kisii Central SDA Church. **Never enable this in production.**

---

## Deployment & Release

See [DEPLOYMENT.md](docs/DEPLOYMENT.md) for the full release process, including CI/CD pipeline details, platform-specific packaging, and the in-app update flow.

---

## Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for the branch strategy, PR process, commit conventions, and code style guide.

---

## Changelog

See [docs/RELEASE.md](docs/RELEASE.md) for the version history and release notes.

---

## Tech Stack

| Dependency | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.6.1 | State management / DI |
| `drift` | ^2.30.0 | Type-safe SQLite ORM |
| `syncfusion_flutter_charts` | ^32.2.8 | Charts and visualisations |
| `pdf` + `printing` | ^3.11 / ^5.13 | PDF report generation |
| `file_picker` | ^8.1.6 | File selection (import/backup) |
| `share_plus` | ^10.1.3 | Native share sheet |
| `http` + `crypto` | ^1.2.2 / ^3.0.3 | Update checker + SHA-256 verification |
| `package_info_plus` | ^8.0.3 | Runtime version info |
| `equatable` | ^2.0.8 | Value equality for models |
| `csv` | ^6.0.0 | CSV parsing |
| `excel` | ^2.1.0 | Excel export |
| `intl` | ^0.19.0 | Date and number formatting |
