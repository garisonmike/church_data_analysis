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
```

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

## Legacy Reference

The `data.py` file contains the original Python CLI prototype and serves as a reference for business logic and analytics calculations.