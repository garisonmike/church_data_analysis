# graphs_update.md — Integration Report

This document tracks all changes made to integrate the planned graphs from `graphs.md` into the Flutter application.

---

## Summary

| Category | Total Charts | Previously [done] | Newly Integrated | Remaining [pending] |
|----------|-------------|---------------|-----------------|--------------|
| Dataset 1 (G-01–G-48) | 48 | ~22 | ~22 | 4 |
| Dataset 2 (G-49–G-74) | 26 | 0 | 26 | 0 |
| Combined (G-75–G-83) | 9 | 0 | 9 | 0 |
| **Total** | **83** | **~22** | **~57** | **4** |

### Remaining / Partial Items

| Graph | Status | Notes |
|-------|--------|-------|
| G-04 | [done] partial | Area chart exists; trendline overlay added via `attendanceTrendLine()` — method ready, overlay not wired into existing area chart |
| G-07 | [done] partial | Same as G-04 but for income — `incomeTrendLine()` method ready |
| G-12 | [done] partial | Line chart exists; regression overlay method ready via `linearRegressionSeries()` |
| G-14 | [done] partial | Same as G-12 for income |
| G-48 | [done] | Already served by `AnalyticsDashboard` — stats text panel not added |

---

## New Files Created

### Data Models
| File | Purpose |
|------|---------|
| `lib/models/charts/box_plot_point.dart` | Data model for box-and-whisker charts (`label`, `values`) |
| `lib/models/charts/heatmap_point.dart` | Data model for heatmap grid cells (`xLabel`, `yLabel`, `value`) |

### Chart Widgets
| File | Purpose | Used By |
|------|---------|---------|
| `lib/widgets/charts/histogram_chart_widget.dart` | Binned frequency column chart with optional mean/median lines | G-17, G-60 |
| `lib/widgets/charts/box_plot_widget.dart` | Box-and-whisker chart using Syncfusion `BoxAndWhiskerSeries` | G-18–G-21, G-47 |
| `lib/widgets/charts/heatmap_chart_widget.dart` | Custom grid-based heatmap with diverging/sequential color scales | G-73, G-74, G-77 |

### New Screens
| File | Charts | Purpose |
|------|--------|---------|
| `lib/ui/screens/detailed_metrics_screen.dart` | G-03, G-08, G-10 | Individual metric bars, pairwise demographic comparisons, home church vs all metrics |
| `lib/ui/screens/distribution_screen.dart` | G-17, G-18, G-19, G-20, G-21, G-47 | Histograms, box plots, violin approximations, demographic % variability |
| `lib/ui/screens/target_analysis_screen.dart` | G-49–G-74 | DS2 target analysis: trends, target lines, scatter correlations, ratios, achievement bars, heatmaps |
| `lib/ui/screens/cross_dataset_screen.dart` | G-75–G-83 | Cross-dataset comparison: average bars, change waterfall, dual scatter, three-way benchmarks, summary dashboard |

---

## Modified Files

### Barrel Exports
- `lib/models/charts/charts.dart` — added `box_plot_point.dart`, `heatmap_point.dart`
- `lib/widgets/charts/charts.dart` — added `histogram_chart_widget.dart`, `box_plot_widget.dart`, `heatmap_chart_widget.dart`
- `lib/ui/screens/screens.dart` — added `detailed_metrics_screen.dart`, `distribution_screen.dart`, `target_analysis_screen.dart`, `cross_dataset_screen.dart`

### Analytics Service
`lib/services/analytics_service.dart` — ~400 lines of new methods added:

| Method | Returns | Used By |
|--------|---------|---------|
| `singleMetricPerWeek(records, field)` | `({List<CategoryPoint> points, double mean})` | G-03 |
| `linearRegressionSeries(data)` | `List<TimeSeriesPoint>` | G-04, G-07, G-12, G-14 |
| `attendanceTrendLine(records)` | `List<TimeSeriesPoint>` | G-04, G-12 |
| `incomeTrendLine(records)` | `List<TimeSeriesPoint>` | G-07, G-14 |
| `demographicPairPerWeek(records, fieldA, fieldB)` | `Map<String, List<CategoryPoint>>` | G-08 |
| `totalIncomePerWeek(records)` | `List<CategoryPoint>` | G-09, G-31 |
| `metricPairPerWeek(records, fieldA, fieldB)` | `Map<String, List<CategoryPoint>>` | G-10 |
| `demographicTrend(records, field)` | `List<TimeSeriesPoint>` | G-33, G-34 |
| `boxPlotStats(records, fields)` | `List<BoxPlotPoint>` | G-18–G-21, G-47 |
| `allRatiosPerWeek(records)` | `Map<String, List<CategoryPoint>>` | G-43, G-67 |
| `fieldCorrelationScatter(records, fieldX, fieldY)` | `List<ScatterPoint>` | G-52, G-53, G-58, G-63 |
| `correlationMatrix(records, fields)` | `List<HeatmapPoint>` | G-73, G-77 |
| `targetAchievementHeatmap(records, targets)` | `List<HeatmapPoint>` | G-74 |
| `datasetAverages(records)` | `Map<String, double>` | G-75, G-80 |
| `crossDatasetChangePercent(ds1, ds2)` | `List<CategoryPoint>` | G-76 |
| `attendanceVsIncomeScatterBoth(ds1, ds2)` | `Map<String, List<ScatterPoint>>` | G-78 |
| `titheVsOfferingsScatterBoth(ds1, ds2)` | `Map<String, List<ScatterPoint>>` | G-79 |
| `threeWayComparisonAttendance(ds1, ds2, targets)` | `Map<String, List<CategoryPoint>>` | G-81 |
| `threeWayComparisonFinancial(ds1, ds2, targets)` | `Map<String, List<CategoryPoint>>` | G-82 |
| `crossDatasetSummaryStats(ds1, ds2)` | `Map<String, dynamic>` | G-83 |
| `_fieldValue(record, field)` | `double` | Internal helper |
| `_pearsonR(xs, ys)` | `double` | Internal helper |

### Existing Screens Modified
| Screen | Charts Added |
|--------|-------------|
| `attendance_charts_screen.dart` | G-30 (Adult vs Young bar), G-45 (Demographic % lines), G-46 (Average demographic % bar) |
| `financial_charts_screen.dart` | G-09 (Financial pairwise ×3), G-31 (Regular vs Total Income), G-37 (Tithe per attendee), G-38 (Regular income per adult), G-39 (All per-capita lines) |
| `correlation_charts_screen.dart` | G-33 (Men + Tithe dual axis), G-34 (Women + Offerings dual axis) |
| `advanced_charts_screen.dart` | G-43 (All ratios grouped bar) |

### Navigation
`lib/ui/screens/graph_center_screen.dart` — added 4 new `ChartItem` entries for:
- Detailed Metrics (attendance category)
- Distributions (analysis category)
- Target Analysis (analysis category)
- Cross-Dataset Comparison (advanced category)

---

## Architecture Notes

- All analytics logic lives in `AnalyticsService` — no calculations in widgets or screens
- Chart data flows: `AnalyticsService` → data models → chart widgets → screens
- New widgets use Syncfusion only (`syncfusion_flutter_charts`)
- Heatmap uses a custom `Container`-based grid since Syncfusion does not provide a native heatmap series
- Violin plots are approximated using `BoxAndWhiskerSeries` with `BoxPlotMode.exclusive`
- Cross-dataset screen splits records by half when only one data source is available; designed for true multi-dataset use
- Target constants are defined as `const Map<String, double>` in the target screens

---

## Testing Recommendations

1. Run `flutter analyze` to verify no compile errors
2. Add weekly records for ≥4 weeks to test all charts
3. Verify chart rendering on different screen sizes (responsive wrappers in place)
4. Test with edge cases: 0 records, 1 record, all-zero values
5. Verify heatmap color scales render correctly for correlation (−1 to +1) and achievement (0% to 120%)
