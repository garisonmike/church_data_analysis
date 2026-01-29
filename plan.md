# 📘 Church Analytics Multiplatform App

## 1. Project Overview

Build a multiplatform Flutter application that allows multiple church administrators to:

- Enter weekly attendance + financial data
- Upload CSV datasets
- Automatically compute totals, trends, growth rates, and correlations
- Generate interactive analytics charts and dashboards
- Export graphs and reports (PNG / PDF)
- Work offline-first (local storage)
- Scale later into multi-tenant SaaS with cloud sync

The app replaces the current Python CLI + matplotlib workflow with a UI-driven, cross-platform analytics tool.

**Target platforms:**

- Web
- Android
- iOS
- Desktop (Windows, Linux, macOS)

## 2. Core Feature Parity (Match Current Python Script)

### Data Fields (Per Week Record)

**Attendance:**

- Men
- Women
- Youth
- Children
- Sunday Home Church

**Finance:**

- Tithe
- Offerings
- Emergency Collection
- Planned Collection

**Derived:**

- Total Attendance
- Total Income
- Growth %
- Averages
- Category distributions

## 3. Expanded Analytics (Beyond Original Script)

Add higher-value analytics:

### 📊 New Metrics

- Week-over-week growth rate
- Moving averages (attendance + income)
- Attendance-to-income ratio
- Per-capita giving
- Category contribution %
- Trend slope indicators

### 📈 Advanced Graphs

- Forecast projection (linear + smoothing)
- Heatmap of attendance vs funds
- Contribution per demographic vs income
- Rolling 4-week averages
- Outlier detection markers
- Correlation coefficient display

## 4. User Roles (Phase-Based)

### Phase 1 — Local Multi-Admin (Device Based)

- Multiple admins per device
- Local profiles
- Data separated per church

### Phase 2 — SaaS Ready

- Church entity model
- Multi-tenant schema ready
- Cloud sync hooks prepared

## 5. Data Input Methods

### Manual Entry UI

- Weekly form screen
- Numeric validation
- Quick-entry layout
- Duplicate-week prevention

### CSV Upload

- CSV parser
- Column mapping UI
- Validation preview
- Error reporting

**Supported formats:**

- CSV first
- Excel later (phase add-on)

## 6. Storage Architecture (Offline First)

### Local Database

**Use:**

- SQLite (via Drift or sqflite)

**Tables:**

- Church
- AdminUser
- WeeklyRecord
- DerivedMetrics (cached)
- ExportHistory

Computed fields stored or cached for performance.

## 7. Flutter Tech Stack

### Framework

- Flutter (stable channel)

### State Management

- Riverpod (preferred) or Bloc

### Charts Library

- fl_chart or Syncfusion Flutter Charts (if license acceptable)

### Storage

- SQLite (Drift ORM)

### CSV Handling

- csv package

### PDF Export

- pdf + printing packages

### Image Export

- RepaintBoundary → PNG capture

## 8. UI / UX Structure

### Main Screens

**Dashboard**

- KPI cards
- Quick stats
- Trend indicators
- Recent weeks
- Quick graph buttons

**Data Entry**

- Weekly entry form
- Edit history
- Bulk CSV import

**Graph Center**

Graph selector grid with buttons:

- Attendance graphs
- Finance graphs
- Correlations
- Dashboards
- Advanced analytics

**Graph View Screen**

- Interactive chart
- Toggle datasets
- Export buttons
- Time filters

**Reports**

- Export bundles
- PDF report builder

**Settings**

- Church profile
- Admins
- Units / currency

## 9. Graph Modules (Mapped from Python)

We modularize graph builders:

```
graph_modules/
  attendance_by_category.dart
  total_attendance_trend.dart
  attendance_pie.dart
  tithe_vs_offerings.dart
  income_breakdown.dart
  income_pie.dart
  attendance_vs_income.dart
  dashboard_summary.dart
  demographics_vs_funds.dart
  funds_vs_attendance.dart
  correlation_scatter.dart
  projections.dart   ← new
```

Each module:

- Accepts dataset
- Returns chart widget
- Supports export

## 10. Analytics Engine Layer

Create a pure Dart analytics layer:

```
analytics/
  metrics_calculator.dart
  trend_engine.dart
  correlation_engine.dart
  forecast_engine.dart
  anomaly_detector.dart
```

**Responsibilities:**

- Derived totals
- Growth %
- Moving averages
- Regression lines
- Correlation coefficients

No UI code inside analytics layer.

## 11. Export System

### Export Types

- PNG graph
- Multi-graph PDF report
- CSV export (cleaned dataset)

### Report Templates

- Weekly report
- Monthly summary
- Full dashboard report

## 12. Validation Rules

- All numeric ≥ 0
- Required fields enforced
- CSV schema validation
- Duplicate week detection
- Outlier warnings

## 13. Performance Considerations

- Precompute derived metrics
- Cache chart datasets
- Lazy load graphs
- Paginate records

## 14. Testing Strategy

### Unit Tests

- Metric calculations
- Growth rates
- Correlations
- Forecast outputs

### Widget Tests

- Graph renderers
- Forms
- CSV import flow

### Integration Tests

- Full data → dashboard → export pipeline

## 15. Security & Data Integrity (Local Phase)

- Local DB encryption ready hook
- Input sanitization
- Backup/export feature

## 16. Future Upgrade Path

**Cloud SaaS Phase:**

- Firebase / Supabase backend
- Church multi-tenant accounts
- Cloud sync
- Role-based permissions
- Shared dashboards
- Remote reporting

Architecture prepared but not implemented in v1.

## 17. Build Phases

### Phase 1 — Foundation

- Flutter project
- DB schema
- Data models
- Analytics engine

### Phase 2 — Data Entry + CSV

- Forms
- Import parser
- Validation

### Phase 3 — Graph Engine

- Chart modules
- Export images

### Phase 4 — Dashboard

- KPI panels
- Multi-chart views

### Phase 5 — Reports

- PDF exports
- Bundled analytics

### Phase 6 — Advanced Analytics

- Forecasting
- Correlation scoring
- Anomaly flags