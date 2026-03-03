# Church Analytics — Multiplatform App

A Flutter multiplatform application for church administrators to track and analyze weekly attendance and financial data.


### This app is majorly vibe coded.


## Overview

This app replaces the legacy Python CLI + matplotlib workflow with a modern, UI-driven, cross-platform analytics tool.


## Features

- Weekly attendance and financial data entry
- CSV dataset upload support
- Automated metrics calculations (totals, trends, growth rates, correlations)
- Interactive analytics charts and dashboards
- Export graphs and reports (PNG/PDF)
- Offline-first architecture with local storage
- Multi-admin local profiles

## Supported Platforms

- ✅ Web
- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS
- ✅ Linux

## Getting Started

### Prerequisites

- Flutter SDK 3.35.7 or higher
- Dart 3.9.2 or higher

### Clone & Run (Recommended)

```bash
git clone https://github.com/garisonmike/church_data_analysis.git
cd church_data_analysis

# Fetch dependencies
flutter pub get

# If you ever see missing generated Drift code (rare if generated files are committed)
# dart run build_runner build --delete-conflicting-outputs

# Run on Linux desktop
flutter run -d linux
```

### Linux Desktop Prerequisites (Debian/Ubuntu/Kali)

Linux desktop builds require some system packages. On Debian/Ubuntu/Kali, the usual set is:

```bash
sudo apt update
sudo apt install -y \
  clang cmake ninja-build pkg-config \
  libgtk-3-dev liblzma-dev
```

If `flutter doctor` reports additional missing dependencies, install those too.

### Installation

```bash
# Get dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on desktop (Linux)
flutter run -d linux

# Build for web
flutter build web --release

# Clean up large build artifacts (frees disk space)
flutter clean
```

## Disk Usage Notes

Flutter builds can generate large folders (especially `build/` and `.dart_tool/`). It is safe to delete these and regenerate them:

- `build/`
- `.dart_tool/`
- `android/.gradle/` (project-local Gradle cache)
- `linux/flutter/ephemeral/`

The fastest “reset” is usually `flutter clean` followed by `flutter pub get`.

## Project Structure

```
lib/
  models/         # Data models
  services/       # Business logic
  repositories/   # Data persistence layer
  ui/            # UI screens and widgets
```

## Architecture

- **State Management**: Riverpod
- **Local Database**: SQLite (Drift/sqflite)
- **Charts**: fl_chart
- **CSV Handling**: csv package
- **PDF Export**: pdf + printing packages

## Development

See `tasks.md` for current development roadmap.
See `plan.md` for detailed feature specifications.

### Demo Mode

The app includes a demo mode flag in `lib/database/app_database.dart`:

```dart
const bool _kDemoMode = false;
```

- **Production (false)**: Fresh installs start with empty data. Users create their own churches and profiles.
- **Demo/Testing (true)**: Fresh installs auto-seed with sample church, admin, and weekly records.

Change this flag to `true` during development/testing to explore the app with pre-populated data.


## Legacy Reference

The `data.py` file contains the original Python CLI prototype and serves as a reference for business logic and analytics calculations.