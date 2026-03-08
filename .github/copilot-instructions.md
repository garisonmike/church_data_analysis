# Copilot Development Guardrails

This repository uses strict architectural rules.  
GitHub Copilot must follow these rules when generating or modifying code.

---

# Architecture Overview

The application contains an **analytics chart system implemented in Flutter**.

Charts must replicate the analytics produced in:
data.py


The Python file is the **reference implementation for graph logic only**.

Python code is **never executed in the Flutter application**.

All analytics logic must be **reimplemented in Dart**.

---

# Required Technologies

Charts must use:
syncfusion_flutter_charts


No alternative chart libraries are allowed.

---

# Core Architecture

The project separates concerns into three layers:

### Analytics Layer
lib/services/analytics_service.dart


Responsibilities:

- replicate analytics logic found in `data.py`
- transform raw app data into chart datasets
- perform aggregations and calculations

This layer must **contain all analytical logic**.

---

### Data Models

Chart data models live in:
lib/models/charts/


Examples:
chart_point.dart
time_series_point.dart
category_point.dart
distribution_point.dart


These models:

- are used only for chart rendering
- must not depend on database entities
- must remain lightweight

---

### Chart Widgets

Reusable chart widgets live in:
lib/widgets/charts/


Examples:
line_chart_widget.dart
bar_chart_widget.dart
pie_chart_widget.dart
area_chart_widget.dart


These widgets:

- must use Syncfusion charts
- must accept chart data models
- must contain **no analytics logic**

---

# Analytics Implementation Rules

When implementing analytics:

1. Study the transformations in `data.py`.
2. Replicate the **same calculations in Dart**.
3. Return structured datasets for charts.

Analytics must include:

- grouping
- aggregations
- time series calculations
- distribution calculations

All analytics must work **offline**.

---

# Strict Prohibitions

Copilot must **never introduce**:

- Python execution in the Flutter app
- matplotlib image generation
- server-side analytics
- external analytics APIs
- new chart libraries

Analytics must run **fully inside Flutter using Dart**.

---

# Coding Rules

Copilot must follow these principles:

- keep analytics separate from UI
- keep chart widgets reusable
- avoid tight coupling with database models
- avoid generating large monolithic widgets
- prefer small, modular files

---

# When Adding Charts

When implementing a new chart:

1. Add analytics logic to `analytics_service.dart`
2. Return chart data models
3. Use a reusable chart widget
4. Render the chart in the analytics dashboard

---

# Goal

The goal of this repository is to:

- replicate analytics from `data.py`
- build a reusable Flutter chart system
- maintain a clean separation between analytics and UI
- ensure charts remain performant and maintainable