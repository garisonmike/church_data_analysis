# graphs.md — Church Analytics Chart Reference & Implementation Plan

This document catalogs every chart that `data.py` is capable of generating and defines how each will be implemented in the Flutter app using `syncfusion_flutter_charts`.

---

## Legend

| Symbol | Meaning |
|--------|---------|
| [done] | Already implemented in Flutter |
| [pending] | Planned — not yet built |
| [new] | Requires a new analytics service method |
| [reuse] | Reuses an existing analytics service method |

**Available widgets:** `LineChartWidget`, `BarChartWidget`, `PieChartWidget`, `StackedAreaChartWidget`, `DualAxisChartWidget`, `ScatterCorrelationChart`

**New widget types needed:** Histogram, BoxPlot (approximated via BoxAndWhiskerSeries), HeatmapWidget, WaterfallWidget, ScatterMatrixWidget

---

## Table of Contents

1. [Dataset 1 — Historical (10-week)](#dataset-1--historical-10-week)
2. [Dataset 2 — Jan/Feb 2026 with Targets](#dataset-2--janfeb-2026-with-targets)
3. [Combined — Cross-Dataset Comparison](#combined--cross-dataset-comparison)
4. [New Screens Proposed](#new-screens-proposed)
5. [New Widgets Needed](#new-widgets-needed)
6. [New Analytics Service Methods Needed](#new-analytics-service-methods-needed)

---

## Dataset 1 — Historical (10-week)

---

### G-01: Attendance Overview — Grouped Bar
- **data.py function:** `plot_attendance_overview()` (first subplot)
- **Chart type:** Grouped/clustered bar chart
- **Data:** MEN, WOMEN, YOUTH, CHILDREN per week (4 series, week labels on X)
- **Flutter widget:** `BarChartWidget(stacked: false)`
- **Analytics method:** [reuse] `attendanceByGroupPerWeek()` → `Map<String, List<CategoryPoint>>`
- **Screen:** `AttendanceChartsScreen`
- **Status:** [done]

---

### G-02: Income Overview — Stacked Bar
- **data.py function:** `plot_attendance_overview()` (second subplot)
- **Chart type:** Stacked bar chart
- **Data:** TITHE + OFFERINGS stacked per week
- **Flutter widget:** `BarChartWidget(stacked: true)`
- **Analytics method:** [reuse] `tithePerWeek()` + `offeringsPerWeek()` combined into `Map<String, List<CategoryPoint>>`
- **Screen:** `FinancialChartsScreen`
- **Status:** [done]

---

### G-03: Individual Demographics Weekly Bars (×8)
- **data.py function:** `plot_demographics_weekly()`
- **Chart type:** 8 individual bar charts with a horizontal mean line
- **Data:** Each of MEN, WOMEN, YOUTH, CHILDREN, TITHE, OFFERINGS, TOTAL_INCOME, SUNDAY_HOME_CHURCH plotted individually per week; mean shown as reference line
- **Flutter widget:** `BarChartWidget` with a `PlotBand` for the mean line using `CartesianChartAnnotation` or `stripLines`
- **Analytics method:** [new] `singleMetricPerWeek(String field)` → `List<CategoryPoint>` with a mean annotation value returned alongside
- **Screen:** New `DetailedMetricsScreen` (or expandable cards in existing screens)
- **Status:** [done]

---

### G-04: Total Attendance Trend — Area + Trendline
- **data.py function:** `plot_attendance_income_trends()` (panel 1)
- **Chart type:** Area chart with superimposed linear trend line
- **Data:** TOTAL_ATTENDANCE per week + computed linear regression line
- **Flutter widget:** `StackedAreaChartWidget` (single series) or `LineChartWidget` with `SplineAreaSeries`; trend overlay as second `LineSeries`
- **Analytics method:** [reuse] `totalAttendanceTrend()` + [new] `attendanceTrendLine()` → two `TimeSeriesPoint` lists
- **Screen:** `AttendanceChartsScreen`
- **Status:** [done] (area trend; trendline overlay [pending])

---

### G-05: Tithe Per Week — Bar
- **data.py function:** `plot_attendance_income_trends()` (panel 2)
- **Chart type:** Bar chart
- **Data:** TITHE per week
- **Flutter widget:** `BarChartWidget`
- **Analytics method:** [reuse] `tithePerWeek()`
- **Screen:** `FinancialChartsScreen`
- **Status:** [done]

---

### G-06: Offerings Per Week — Bar
- **data.py function:** `plot_attendance_income_trends()` (panel 3)
- **Chart type:** Bar chart
- **Data:** OFFERINGS per week
- **Flutter widget:** `BarChartWidget`
- **Analytics method:** [reuse] `offeringsPerWeek()`
- **Screen:** `FinancialChartsScreen`
- **Status:** [done]

---

### G-07: Total Income Trend — Area + Trendline
- **data.py function:** `plot_attendance_income_trends()` (panel 4)
- **Chart type:** Area chart with superimposed linear trend line
- **Data:** TOTAL_INCOME per week + computed linear regression line
- **Flutter widget:** `StackedAreaChartWidget` (single series) with trend `LineSeries` overlay
- **Analytics method:** [reuse] `totalIncomeTrend()` + [new] `incomeTrendLine()` → two `TimeSeriesPoint` lists
- **Screen:** `FinancialChartsScreen`
- **Status:** [done] (area; trendline overlay [pending])

---

### G-08: Pairwise Demographic Comparisons (×6)
- **data.py function:** `plot_demographic_comparison()`
- **Chart type:** 6 side-by-side grouped bar charts — all pairwise combos of MEN/WOMEN/YOUTH/CHILDREN
- **Data:** Pairs: Men-Women, Men-Youth, Men-Children, Women-Youth, Women-Children, Youth-Children; each pair as a 2-series bar chart per week
- **Flutter widget:** `BarChartWidget(stacked: false)` for each pair
- **Analytics method:** [new] `demographicPairPerWeek(String a, String b)` → `Map<String, List<CategoryPoint>>`
- **Screen:** New `DemographicComparisonScreen` or tabs within `AttendanceChartsScreen`
- **Status:** [done]

---

### G-09: Financial Pairwise Comparisons (×3)
- **data.py function:** `plot_financial_weekly()`
- **Chart type:** 3 side-by-side grouped bar charts
- **Data:** Tithe vs Offerings; Tithe vs Total Income; Offerings vs Total Income
- **Flutter widget:** `BarChartWidget(stacked: false)`
- **Analytics method:** [reuse] `tithePerWeek()`, `offeringsPerWeek()`, combined with [new] `totalIncomePerWeek()`
- **Screen:** `FinancialChartsScreen`
- **Status:** [done]

---

### G-10: Home Church vs All Variables (×8)
- **data.py function:** `plot_home_church_comparison()`
- **Chart type:** 8 side-by-side grouped bar charts
- **Data:** SUNDAY_HOME_CHURCH vs each of MEN, WOMEN, YOUTH, CHILDREN, TITHE, OFFERINGS, TOTAL_ATTENDANCE, TOTAL_INCOME
- **Flutter widget:** `BarChartWidget(stacked: false)` per pair
- **Analytics method:** [reuse] `homeChurchPerWeek()` combined with per-metric methods; or [new] `metricPairPerWeek(String a, String b)`
- **Screen:** New `HomeChurchScreen` or tab in `CorrelationChartsScreen`
- **Status:** [done]

---

### G-11: Demographic Attendance Lines
- **data.py function:** `plot_time_series_all()` (panel 1)
- **Chart type:** Multi-line chart (4 lines)
- **Data:** MEN, WOMEN, YOUTH, CHILDREN over time
- **Flutter widget:** `LineChartWidget`
- **Analytics method:** [reuse] `demographicAttendanceTrends()`
- **Screen:** `AttendanceChartsScreen`
- **Status:** [done]

---

### G-12: Total Attendance Trend + Regression
- **data.py function:** `plot_time_series_all()` (panel 2)
- **Chart type:** Line chart with regression line
- **Data:** TOTAL_ATTENDANCE time series + least-squares linear regression
- **Flutter widget:** `LineChartWidget` (two `SplineSeries`: actual + regression)
- **Analytics method:** [reuse] `totalAttendanceTrend()` + [new] `linearRegressionSeries(List<TimeSeriesPoint>)`
- **Screen:** `AttendanceChartsScreen`
- **Status:** [done] (trend line exists; regression overlay [pending])

---

### G-13: Tithe & Offerings Over Time — Multi-line
- **data.py function:** `plot_time_series_all()` (panel 3)
- **Chart type:** 2-line chart
- **Data:** TITHE and OFFERINGS over time
- **Flutter widget:** `LineChartWidget`
- **Analytics method:** [reuse] `titheTrend()` + `offeringsTrend()`
- **Screen:** `FinancialChartsScreen`
- **Status:** [done]

---

### G-14: Total Income Trend + Regression
- **data.py function:** `plot_time_series_all()` (panel 4)
- **Chart type:** Line chart with regression overlay
- **Data:** TOTAL_INCOME over time + linear regression
- **Flutter widget:** `LineChartWidget`
- **Analytics method:** [reuse] `totalIncomeTrend()` + [new] `linearRegressionSeries(...)`
- **Screen:** `FinancialChartsScreen`
- **Status:** [done] (trend; regression overlay [pending])

---

### G-15: Weekly Attendance Growth Rate — Bar
- **data.py function:** `plot_time_series_all()` (panel 5)
- **Chart type:** Bar chart (positive/negative week-over-week % change)
- **Data:** Week-over-week % change in TOTAL_ATTENDANCE; bars colored green (positive) / red (negative)
- **Flutter widget:** `BarChartWidget` with conditional color per `CategoryPoint.color`
- **Analytics method:** [reuse] `attendanceGrowthRates()`
- **Screen:** `AdvancedChartsScreen`
- **Status:** [done]

---

### G-16: Income Per Attendee Over Time — Line
- **data.py function:** `plot_time_series_all()` (panel 6)
- **Chart type:** Line chart
- **Data:** INCOME_PER_ATTENDEE (total income ÷ total attendance) per week
- **Flutter widget:** `LineChartWidget`
- **Analytics method:** [reuse] `incomePerAttendeeTrend()`
- **Screen:** `FinancialChartsScreen`
- **Status:** [done]

---

### G-17: Distribution Histograms (×9)
- **data.py function:** `plot_distribution_analysis()`
- **Chart type:** 9 histogram charts with mean and median reference lines
- **Data:** MEN, WOMEN, YOUTH, CHILDREN, TOTAL_ATTENDANCE, TITHE, OFFERINGS, TOTAL_INCOME, SUNDAY_HOME_CHURCH
- **Flutter widget:** [new] `HistogramChartWidget` using `SfCartesianChart` with `HistogramSeries` and strip lines for mean/median
- **Analytics method:** [reuse] `distributionHistogram(String field)` → `List<CategoryPoint>` (binned counts)
- **Screen:** New `DistributionScreen` or section in `AdvancedChartsScreen`
- **Status:** [done]

---

### G-18: Box Plots — Attendance Groups
- **data.py function:** `plot_box_plots()` (first subplot)
- **Chart type:** Box plot
- **Data:** MEN, WOMEN, YOUTH, CHILDREN, TOTAL_ATTENDANCE distributions shown as boxes
- **Flutter widget:** [new] `BoxPlotWidget` using `SfCartesianChart` with `BoxAndWhiskerSeries`
- **Analytics method:** [new] `boxPlotStats(List<String> fields)` → `List<BoxPlotPoint>` (min, q1, median, q3, max per field)
- **Screen:** New `DistributionScreen` or section in `AdvancedChartsScreen`
- **Status:** [done]

---

### G-19: Box Plots — Financial Groups
- **data.py function:** `plot_box_plots()` (second subplot)
- **Chart type:** Box plot
- **Data:** TITHE, OFFERINGS, TOTAL_INCOME distributions shown as boxes
- **Flutter widget:** [new] `BoxPlotWidget`
- **Analytics method:** [new] `boxPlotStats(List<String> fields)`
- **Screen:** New `DistributionScreen`
- **Status:** [done]

---

### G-20: Violin Plots — Attendance
- **data.py function:** `plot_violin_plots()` (first subplot)
- **Chart type:** Violin / probability density distribution
- **Data:** MEN, WOMEN, YOUTH, CHILDREN distributions
- **Flutter widget:** [new] Approximate with `BoxAndWhiskerSeries` in "violin" mode — Syncfusion supports `BoxPlotMode.exclusive` which renders a violin-like shape
- **Analytics method:** [new] `violinStats(List<String> fields)` (same underlying data as box plot)
- **Screen:** New `DistributionScreen`
- **Status:** [done]

---

### G-21: Violin Plots — Financial
- **data.py function:** `plot_violin_plots()` (second subplot)
- **Chart type:** Violin / probability density distribution
- **Data:** TITHE, OFFERINGS, TOTAL_INCOME distributions
- **Flutter widget:** [new] `BoxPlotWidget` with violin mode
- **Analytics method:** [new] `violinStats(List<String> fields)`
- **Screen:** New `DistributionScreen`
- **Status:** [done]

---

### G-22: Attendance Composition — Stacked Area
- **data.py function:** `plot_stacked_area()` (first subplot)
- **Chart type:** Stacked area chart
- **Data:** MEN, WOMEN, YOUTH, CHILDREN absolute values stacked over time
- **Flutter widget:** `StackedAreaChartWidget`
- **Analytics method:** [reuse] `demographicAttendanceTrends()`
- **Screen:** `AttendanceChartsScreen`
- **Status:** [done]

---

### G-23: Income Composition — Stacked Area
- **data.py function:** `plot_stacked_area()` (second subplot)
- **Chart type:** Stacked area chart
- **Data:** TITHE, OFFERINGS, EMERGENCY_COLLECTION, PLANNED_COLLECTION stacked over time
- **Flutter widget:** `StackedAreaChartWidget`
- **Analytics method:** [reuse] `incomeComponentTrends()`
- **Screen:** `FinancialChartsScreen`
- **Status:** [done]

---

### G-24: Attendance Distribution — Pie Chart
- **data.py function:** `plot_pie_charts()` (panel 1)
- **Chart type:** Pie / doughnut chart
- **Data:** Average proportions of MEN, WOMEN, YOUTH, CHILDREN across all weeks
- **Flutter widget:** `PieChartWidget`
- **Analytics method:** [reuse] `demographicDistribution()`
- **Screen:** `AnalyticsDashboard`
- **Status:** [done]

---

### G-25: Income Distribution — Pie Chart
- **data.py function:** `plot_pie_charts()` (panel 2)
- **Chart type:** Pie / doughnut chart
- **Data:** Average proportions of TITHE, OFFERINGS, EMERGENCY, PLANNED across all weeks
- **Flutter widget:** `PieChartWidget`
- **Analytics method:** [reuse] `incomeDistribution()`
- **Screen:** `AnalyticsDashboard`
- **Status:** [done]

---

### G-26: Adult vs Young — Pie Chart
- **data.py function:** `plot_pie_charts()` (panel 3)
- **Chart type:** Pie / doughnut chart
- **Data:** Average ADULT_ATTENDANCE (Men+Women) vs YOUNG_ATTENDANCE (Youth+Children)
- **Flutter widget:** `PieChartWidget`
- **Analytics method:** [reuse] `adultVsYoungDistribution()`
- **Screen:** `AnalyticsDashboard`
- **Status:** [done]

---

### G-27: Regular vs Special Income — Pie Chart
- **data.py function:** `plot_pie_charts()` (panel 4)
- **Chart type:** Pie / doughnut chart
- **Data:** Regular income (Tithe+Offerings) vs Special income (Emergency+Planned)
- **Flutter widget:** `PieChartWidget`
- **Analytics method:** [reuse] `regularVsSpecialIncomeDistribution()`
- **Screen:** `FinancialChartsScreen`
- **Status:** [done]

---

### G-28: All Demographics Grouped Bar
- **data.py function:** `plot_grouped_bar_comparison()` (panel 1)
- **Chart type:** Grouped bar chart
- **Data:** MEN, WOMEN, YOUTH, CHILDREN per week (4 series)
- **Flutter widget:** `BarChartWidget(stacked: false)`
- **Analytics method:** [reuse] `attendanceByGroupPerWeek()`
- **Screen:** `AttendanceChartsScreen`
- **Status:** [done]

---

### G-29: Tithe vs Offerings Grouped Bar
- **data.py function:** `plot_grouped_bar_comparison()` (panel 2)
- **Chart type:** Grouped bar chart
- **Data:** TITHE and OFFERINGS side-by-side per week
- **Flutter widget:** `BarChartWidget(stacked: false)`
- **Analytics method:** [reuse] `tithePerWeek()` + `offeringsPerWeek()`
- **Screen:** `FinancialChartsScreen`
- **Status:** [done]

---

### G-30: Adult vs Young Per Week — Grouped Bar
- **data.py function:** `plot_grouped_bar_comparison()` (panel 3)
- **Chart type:** Grouped bar chart
- **Data:** ADULT_ATTENDANCE (Men+Women) vs YOUNG_ATTENDANCE (Youth+Children) per week
- **Flutter widget:** `BarChartWidget(stacked: false)`
- **Analytics method:** [reuse] `adultAttendancePerWeek()` + `youngAttendancePerWeek()`
- **Screen:** `AttendanceChartsScreen`
- **Status:** [done]

---

### G-31: Regular vs Total Income Per Week — Grouped Bar
- **data.py function:** `plot_grouped_bar_comparison()` (panel 4)
- **Chart type:** Grouped bar chart
- **Data:** Regular income (Tithe+Offerings) vs TOTAL_INCOME per week
- **Flutter widget:** `BarChartWidget(stacked: false)`
- **Analytics method:** [reuse] `regularIncomeTrend()` + `totalIncomeTrend()`; adapted to `CategoryPoint`
- **Screen:** `FinancialChartsScreen`
- **Status:** [done]

---

### G-32: Attendance + Income — Dual Axis
- **data.py function:** `plot_dual_axis_trends()` (panel 1)
- **Chart type:** Dual-axis line chart (attendance left Y, income right Y)
- **Data:** TOTAL_ATTENDANCE (left axis) + TOTAL_INCOME (right axis) over time
- **Flutter widget:** `DualAxisChartWidget`
- **Analytics method:** [reuse] `totalAttendanceTrend()` + `totalIncomeTrend()`
- **Screen:** `CorrelationChartsScreen`
- **Status:** [done]

---

### G-33: Men + Tithe — Dual Axis
- **data.py function:** `plot_dual_axis_trends()` (panel 2)
- **Chart type:** Dual-axis line chart
- **Data:** MEN (left) + TITHE (right) over time
- **Flutter widget:** `DualAxisChartWidget`
- **Analytics method:** [new] `menTrend()` (or generic `demographicTrend('MEN')`) + `titheTrend()`
- **Screen:** `CorrelationChartsScreen`
- **Status:** [done]

---

### G-34: Women + Offerings — Dual Axis
- **data.py function:** `plot_dual_axis_trends()` (panel 3)
- **Chart type:** Dual-axis line chart
- **Data:** WOMEN (left) + OFFERINGS (right) over time
- **Flutter widget:** `DualAxisChartWidget`
- **Analytics method:** [new] `womenTrend()` + `offeringsTrend()`
- **Screen:** `CorrelationChartsScreen`
- **Status:** [done]

---

### G-35: Home Church + Regular Income — Dual Axis
- **data.py function:** `plot_dual_axis_trends()` (panel 4)
- **Chart type:** Dual-axis line chart
- **Data:** SUNDAY_HOME_CHURCH (left) + REGULAR_INCOME (right = Tithe+Offerings) over time
- **Flutter widget:** `DualAxisChartWidget`
- **Analytics method:** [reuse] `homeChurchTrend()` + `regularIncomeTrend()`
- **Screen:** `CorrelationChartsScreen`
- **Status:** [done]

---

### G-36: Income Per Attendee — Line
- **data.py function:** `plot_per_capita_analysis()` (panel 1)
- **Chart type:** Line chart
- **Data:** INCOME_PER_ATTENDEE (total income ÷ total attendance) per week
- **Flutter widget:** `LineChartWidget`
- **Analytics method:** [reuse] `incomePerAttendeeTrend()`
- **Screen:** `FinancialChartsScreen`
- **Status:** [done]

---

### G-37: Tithe Per Attendee Per Week — Bar
- **data.py function:** `plot_per_capita_analysis()` (panel 2)
- **Chart type:** Bar chart
- **Data:** TITHE ÷ TOTAL_ATTENDANCE per week
- **Flutter widget:** `BarChartWidget`
- **Analytics method:** [reuse] `tithePerAttendeePerWeek()`
- **Screen:** `FinancialChartsScreen`
- **Status:** [done]

---

### G-38: Regular Income Per Adult Per Week — Bar
- **data.py function:** `plot_per_capita_analysis()` (panel 3)
- **Chart type:** Bar chart
- **Data:** REGULAR_INCOME ÷ ADULT_ATTENDANCE per week
- **Flutter widget:** `BarChartWidget`
- **Analytics method:** [reuse] `regularIncomePerAdultPerWeek()`
- **Screen:** `FinancialChartsScreen`
- **Status:** [done]

---

### G-39: All Per-Capita Metrics Combined — Line
- **data.py function:** `plot_per_capita_analysis()` (panel 4)
- **Chart type:** Multi-line chart (3 series on one axis)
- **Data:** Income/Att, Tithe/Att, Offerings/Att per week on one chart
- **Flutter widget:** `LineChartWidget` (3 `SplineSeries`)
- **Analytics method:** [reuse] `incomePerAttendeeTrend()` + `tithePerAttendeePerWeek()` + `offeringsPerAttendeePerWeek()`
- **Screen:** `FinancialChartsScreen`
- **Status:** [done]

---

### G-40: Men:Women Ratio Over Time — Line
- **data.py function:** `plot_ratio_analysis()` (panel 1)
- **Chart type:** Line chart with reference line at 1.0 and mean line
- **Data:** MEN ÷ WOMEN ratio per week
- **Flutter widget:** `LineChartWidget` with `PlotBand` for reference lines
- **Analytics method:** [reuse] `menWomenRatioTrend()`
- **Screen:** `AdvancedChartsScreen`
- **Status:** [done]

---

### G-41: Adult:Young Ratio Over Time — Line
- **data.py function:** `plot_ratio_analysis()` (panel 2)
- **Chart type:** Line chart with mean reference line
- **Data:** (MEN+WOMEN) ÷ (YOUTH+CHILDREN) ratio per week
- **Flutter widget:** `LineChartWidget`
- **Analytics method:** [reuse] `adultYoungRatioTrend()`
- **Screen:** `AdvancedChartsScreen`
- **Status:** [done]

---

### G-42: Tithe:Offerings Ratio Over Time — Line
- **data.py function:** `plot_ratio_analysis()` (panel 3)
- **Chart type:** Line chart with mean reference line
- **Data:** TITHE ÷ OFFERINGS ratio per week
- **Flutter widget:** `LineChartWidget`
- **Analytics method:** [reuse] `titheOfferingsRatioTrend()`
- **Screen:** `AdvancedChartsScreen`
- **Status:** [done]

---

### G-43: All Ratios Comparison — Grouped Bar
- **data.py function:** `plot_ratio_analysis()` (panel 4)
- **Chart type:** Grouped bar chart (3 ratio series per week)
- **Data:** Men:Women, Adult:Young, Tithe:Offerings ratios per week side-by-side
- **Flutter widget:** `BarChartWidget(stacked: false)`
- **Analytics method:** [reuse] `menWomenRatioTrend()` + `adultYoungRatioTrend()` + `titheOfferingsRatioTrend()` adapted to `CategoryPoint`
- **Screen:** `AdvancedChartsScreen`
- **Status:** [done]

---

### G-44: Attendance Composition % — Stacked Area 100%
- **data.py function:** `plot_percentage_analysis()` (panel 1)
- **Chart type:** 100% stacked area chart
- **Data:** MEN%, WOMEN%, YOUTH%, CHILDREN% stacking to 100% per week
- **Flutter widget:** `StackedAreaChartWidget` with `isVisibleInLegend` and Y-axis max = 100
- **Analytics method:** [reuse] `demographicPercentageTrends()`
- **Screen:** `AttendanceChartsScreen`
- **Status:** [done]

---

### G-45: Individual Demographic % Lines
- **data.py function:** `plot_percentage_analysis()` (panel 2)
- **Chart type:** Multi-line chart showing each group's share %
- **Data:** MEN%, WOMEN%, YOUTH%, CHILDREN% as separate trend lines
- **Flutter widget:** `LineChartWidget`
- **Analytics method:** [reuse] `demographicPercentageTrends()`
- **Screen:** `AttendanceChartsScreen`
- **Status:** [done]

---

### G-46: Average Demographic % — Bar
- **data.py function:** `plot_percentage_analysis()` (panel 3)
- **Chart type:** Bar chart showing average percentage per group
- **Data:** Average MEN%, WOMEN%, YOUTH%, CHILDREN% across all weeks
- **Flutter widget:** `BarChartWidget`
- **Analytics method:** [reuse] `averageDemographicPercentages()`
- **Screen:** `AttendanceChartsScreen`
- **Status:** [done]

---

### G-47: Demographic % Variability — Box Plot
- **data.py function:** `plot_percentage_analysis()` (panel 4)
- **Chart type:** Box plot showing variability of each group's weekly %
- **Data:** Week-to-week variation in MEN%, WOMEN%, YOUTH%, CHILDREN%
- **Flutter widget:** [new] `BoxPlotWidget`
- **Analytics method:** [new] `boxPlotStats(['MEN_PCT', 'WOMEN_PCT', 'YOUTH_PCT', 'CHILDREN_PCT'])`
- **Screen:** New `DistributionScreen`
- **Status:** [done]

---

### G-48: Comprehensive Dashboard
- **data.py function:** `plot_comprehensive_dashboard()`
- **Chart type:** Multi-panel dashboard (8 sub-charts + stats text panel)
- **Sub-charts:**
  - Attendance trend line (all 4 demographics)
  - Income trend line (Tithe + Offerings)
  - Attendance pie (G-24)
  - Income pie (G-25)
  - Scatter: Total Attendance vs Total Income
  - Attendance growth rate bars (G-15)
  - Demographics grouped bar (G-28)
  - Financial grouped bar (G-29)
  - Statistics summary text table
- **Flutter widget:** Combination of existing widgets assembled in a `GridView` or `Wrap` layout
- **Analytics method:** Reuses existing methods; stats summary panel constructed using `SfCartesianChart` annotations or a standalone `DataTable` widget
- **Screen:** `AnalyticsDashboard` (already serves this role)
- **Status:** [done] (partial — most sub-charts present; stats text panel [pending])

---

## Dataset 2 — Jan/Feb 2026 with Targets

> Dataset 2 covers 4 Saturdays (Jan–Feb 2026) and includes weekly targets for each metric. Target comparisons are visualised using dashed reference lines.

---

### G-49: DS2 Demographic Trends — Multi-line
- **data.py function:** `ds2_plot_attendance_trends()` (panel 1)
- **Chart type:** Multi-line chart (4 series)
- **Data:** DS2 MEN, WOMEN, YOUTH, CHILDREN over 4 weeks
- **Flutter widget:** `LineChartWidget`
- **Analytics method:** [reuse] `demographicAttendanceTrends()` (filtered to DS2 date range)
- **Screen:** New `DS2Screen` or `TargetAnalysisScreen`
- **Status:** [done]

---

### G-50: DS2 Total Attendance vs Target — Bar + Target Line
- **data.py function:** `ds2_plot_attendance_trends()` (panel 2)
- **Chart type:** Bar chart with a dashed horizontal target line
- **Data:** DS2 TOTAL_ATTENDANCE per week + TOTAL_ATTENDANCE target as strip line
- **Flutter widget:** `BarChartWidget` with `PlotBand` for target line
- **Analytics method:** [reuse] `totalAttendanceTrend()` + `targetAchievementPerWeek()` to extract target value
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-51: DS2 Home Church vs Target — Area + Target Line
- **data.py function:** `ds2_plot_attendance_trends()` (panel 3)
- **Chart type:** Area chart with a dashed target line
- **Data:** DS2 HOME_CHURCH per week + target
- **Flutter widget:** `StackedAreaChartWidget` (single series) with `PlotBand`
- **Analytics method:** [reuse] `homeChurchTrend()` + target value from `targetAchievementPerWeek()`
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-52: DS2 Men vs Women Scatter
- **data.py function:** `ds2_plot_attendance_trends()` (panel 4)
- **Chart type:** Scatter plot with regression line and Pearson r annotation
- **Data:** DS2 MEN vs WOMEN per week (4 points), each labeled by date
- **Flutter widget:** `ScatterCorrelationChart`
- **Analytics method:** [new] `demographicCorrelationScatter('MEN', 'WOMEN', useDs2: true)`
- **Screen:** `CorrelationChartsScreen`
- **Status:** [done]

---

### G-53: DS2 Adult vs Young Scatter
- **data.py function:** `ds2_plot_attendance_trends()` (panel 5)
- **Chart type:** Scatter plot with regression line
- **Data:** DS2 ADULT_ATTENDANCE vs YOUNG_ATTENDANCE (4 points)
- **Flutter widget:** `ScatterCorrelationChart`
- **Analytics method:** [new] `demographicCorrelationScatter('ADULT', 'YOUNG', useDs2: true)`
- **Screen:** `CorrelationChartsScreen`
- **Status:** [done]

---

### G-54: DS2 Attendance Composition % — Stacked Area
- **data.py function:** `ds2_plot_attendance_trends()` (panel 6)
- **Chart type:** 100% stacked area chart
- **Data:** DS2 MEN%, WOMEN%, YOUTH%, CHILDREN% per week
- **Flutter widget:** `StackedAreaChartWidget`
- **Analytics method:** [reuse] `demographicPercentageTrends()` (DS2 date range)
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-55: DS2 Tithe vs Target — Bar + Target Line
- **data.py function:** `ds2_plot_financial_analysis()` (panel 1)
- **Chart type:** Bar chart with dashed target line
- **Data:** DS2 TITHE per week + tithe target
- **Flutter widget:** `BarChartWidget` with `PlotBand`
- **Analytics method:** [reuse] `tithePerWeek()` + target from `targetAchievementPerWeek()`
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-56: DS2 Offerings vs Target — Bar + Target Line
- **data.py function:** `ds2_plot_financial_analysis()` (panel 2)
- **Chart type:** Bar chart with dashed target line
- **Data:** DS2 OFFERINGS per week + offerings target
- **Flutter widget:** `BarChartWidget` with `PlotBand`
- **Analytics method:** [reuse] `offeringsPerWeek()` + target
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-57: DS2 Total Income Trend — Area
- **data.py function:** `ds2_plot_financial_analysis()` (panel 3)
- **Chart type:** Area/line chart
- **Data:** DS2 TOTAL_INCOME per week
- **Flutter widget:** `StackedAreaChartWidget` (single series)
- **Analytics method:** [reuse] `totalIncomeTrend()` (DS2 range)
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-58: DS2 Tithe vs Offerings Scatter
- **data.py function:** `ds2_plot_financial_analysis()` (panel 4)
- **Chart type:** Scatter with regression and Pearson r
- **Data:** DS2 TITHE vs OFFERINGS (4 points, date-labeled)
- **Flutter widget:** `ScatterCorrelationChart`
- **Analytics method:** [new] `financialCorrelationScatter('TITHE', 'OFFERINGS', useDs2: true)`
- **Screen:** `CorrelationChartsScreen`
- **Status:** [done]

---

### G-59: DS2 Attendance vs Income Scatter
- **data.py function:** `ds2_plot_financial_analysis()` (panel 5)
- **Chart type:** Scatter with regression and Pearson r
- **Data:** DS2 TOTAL_ATTENDANCE vs TOTAL_INCOME (4 points)
- **Flutter widget:** `ScatterCorrelationChart`
- **Analytics method:** [reuse] `attendanceVsIncomeScatter()` (DS2 range)
- **Screen:** `CorrelationChartsScreen`
- **Status:** [done]

---

### G-60: DS2 Income Per Attendee — Bar with Mean Line
- **data.py function:** `ds2_plot_financial_analysis()` (panel 6)
- **Chart type:** Bar chart with horizontal mean reference line
- **Data:** DS2 INCOME_PER_ATTENDEE per week + mean as strip line
- **Flutter widget:** `BarChartWidget` with `PlotBand` mean line
- **Analytics method:** [reuse] `tithePerAttendeePerWeek()` / `incomePerAttendeeTrend()` (DS2)
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-61: DS2 Target Achievement Per Week — Grouped Bar
- **data.py function:** `ds2_plot_target_gauge()` (first subplot)
- **Chart type:** Grouped bar chart — 4 weeks × 8 metrics, with 100% reference line
- **Data:** Achievement % for Men, Women, Youth, Children, Total Att, Home Church, Tithe, Offerings — one group per metric, one bar per week
- **Flutter widget:** `BarChartWidget(stacked: false)` with `PlotBand` at 100%
- **Analytics method:** [reuse] `targetAchievementPerWeek()` → `Map<String, List<CategoryPoint>>`
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-62: DS2 Overall Average Target Achievement — Horizontal Bar
- **data.py function:** `ds2_plot_target_gauge()` (second subplot)
- **Chart type:** Horizontal bar chart; bars colored green (≥100%), amber (50–99%), red (<50%)
- **Data:** Average achievement % per metric across all weeks; 100% reference line
- **Flutter widget:** [new] `HorizontalBarWidget` (use `BarSeries` with `isTransposed: true`) with conditional color per `CategoryPoint.color`
- **Analytics method:** [reuse] `overallTargetAchievement()` → `List<CategoryPoint>`
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-63: DS2 Pairwise Scatter Matrix (6×6)
- **data.py function:** `ds2_plot_correlation_scatter_grid()`
- **Chart type:** Pairwise scatter matrix — 6×6 grid; diagonal = histogram, off-diagonal = scatter with regression + Pearson r
- **Variables:** MEN, WOMEN, YOUTH, CHILDREN, TITHE, OFFERINGS
- **Flutter widget:** [new] `ScatterMatrixWidget` — `GridView` of `ScatterCorrelationChart` / histogram widgets
- **Analytics method:** [new] `pairwiseCorrelationMatrix(List<String> fields)` → `Map<String, Map<String, List<ScatterPoint>>>` + `Map<String, List<CategoryPoint>>` for diagonals
- **Screen:** `CorrelationChartsScreen` (new tab) or `AdvancedChartsScreen`
- **Status:** [done]

---

### G-64: DS2 Men:Women Ratio — Line
- **data.py function:** `ds2_plot_ratios()` (panel 1)
- **Chart type:** Line chart with reference lines at 1.0 and mean
- **Data:** DS2 MEN÷WOMEN ratio per week
- **Flutter widget:** `LineChartWidget` with `PlotBand`
- **Analytics method:** [reuse] `menWomenRatioTrend()` (DS2 range)
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-65: DS2 Adult:Young Ratio — Line
- **data.py function:** `ds2_plot_ratios()` (panel 2)
- **Chart type:** Line chart with mean reference line
- **Data:** DS2 ADULT÷YOUNG ratio per week
- **Flutter widget:** `LineChartWidget`
- **Analytics method:** [reuse] `adultYoungRatioTrend()` (DS2 range)
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-66: DS2 Tithe:Offerings Ratio — Line
- **data.py function:** `ds2_plot_ratios()` (panel 3)
- **Chart type:** Line chart with mean reference line
- **Data:** DS2 TITHE÷OFFERINGS ratio per week
- **Flutter widget:** `LineChartWidget`
- **Analytics method:** [reuse] `titheOfferingsRatioTrend()` (DS2 range)
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-67: DS2 All Ratios — Grouped Bar
- **data.py function:** `ds2_plot_ratios()` (panel 4)
- **Chart type:** Grouped bar chart (3 series per date)
- **Data:** Men:Women, Adult:Young, Tithe:Offerings ratios side-by-side per week
- **Flutter widget:** `BarChartWidget(stacked: false)`
- **Analytics method:** [reuse] Ratio trend methods adapted to `CategoryPoint`
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-68: DS2 Gender Attendance vs Target — 2×2 Individual Bars
- **data.py function:** `ds2_plot_target_bar_charts()` (Figure 1)
- **Chart type:** 4 individual bar charts — one per gender with dashed target line
- **Data:** DS2 MEN, WOMEN, YOUTH, CHILDREN per week vs their respective targets; value labels on each bar
- **Flutter widget:** `BarChartWidget` with `PlotBand` per chart
- **Analytics method:** [reuse] `attendanceByGroupPerWeek()` + target constants from `targetAchievementPerWeek()`
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-69: DS2 All Genders Four Saturdays — Grouped Bar
- **data.py function:** `ds2_plot_target_bar_charts()` (Figure 2)
- **Chart type:** Grouped bar chart (4 genders × 4 weeks) with dotted per-gender target lines
- **Data:** MEN, WOMEN, YOUTH, CHILDREN per week (4 series per group); dotted target line per series
- **Flutter widget:** `BarChartWidget(stacked: false)` with `PlotBand` colored per series
- **Analytics method:** [reuse] `attendanceByGroupPerWeek()` + target values
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-70: DS2 Tithe Per Saturday vs Target — Bar
- **data.py function:** `ds2_plot_target_bar_charts()` (Figure 3)
- **Chart type:** Bar chart with labeled values and dashed target line
- **Data:** DS2 TITHE per week vs tithe target
- **Flutter widget:** `BarChartWidget` with `PlotBand`
- **Analytics method:** [reuse] `tithePerWeek()` + target
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-71: DS2 Offerings Per Saturday vs Target — Bar
- **data.py function:** `ds2_plot_target_bar_charts()` (Figure 4)
- **Chart type:** Bar chart with labeled values and dashed target line
- **Data:** DS2 OFFERINGS per week vs offerings target
- **Flutter widget:** `BarChartWidget` with `PlotBand`
- **Analytics method:** [reuse] `offeringsPerWeek()` + target
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-72: DS2 Total Attendance / Home Church / Total Income vs Target — 3-panel Bar
- **data.py function:** `ds2_plot_target_bar_charts()` (Figure 5)
- **Chart type:** 3 bar charts side by side, each with a target line
- **Data:** DS2 TOTAL_ATTENDANCE, HOME_CHURCH, TOTAL_INCOME per week vs targets
- **Flutter widget:** `BarChartWidget` × 3 (in a `Row`) with `PlotBand`
- **Analytics method:** [reuse] `totalAttendanceTrend()` + `homeChurchTrend()` + `totalIncomeTrend()` adapted to `CategoryPoint`; + targets
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

### G-73: DS2 Correlation Matrix — Heatmap
- **data.py function:** `ds2_plot_correlation_heatmap()` (first subplot)
- **Chart type:** Correlation heatmap (9×9 matrix) with color scale −1 to +1
- **Variables:** MEN, WOMEN, YOUTH, CHILDREN, HOME_CHURCH, TOTAL_ATTENDANCE, TITHE, OFFERINGS, TOTAL_INCOME
- **Flutter widget:** [new] `HeatmapWidget` using `SfCartesianChart` `HiloOpenCloseSeries` trick or custom `CustomPainter` grid; alternatively Syncfusion `SfHeatMap` (available in syncfusion_flutter_charts extensions)
- **Analytics method:** [new] `correlationMatrix(List<String> fields, {bool useDs2})` → `List<HeatmapPoint>`
- **Screen:** `CorrelationChartsScreen`
- **Status:** [done]

---

### G-74: DS2 Target Achievement % — Heatmap
- **data.py function:** `ds2_plot_correlation_heatmap()` (second subplot)
- **Chart type:** Grid heatmap — rows = weeks, columns = 8 metrics, cell = achievement %
- **Data:** MEN_TARGET_PCT, WOMEN_TARGET_PCT, … OFFERINGS_TARGET_PCT per week
- **Flutter widget:** [new] `HeatmapWidget` with diverging color scale (green ≥100%, red <50%)
- **Analytics method:** [reuse] `targetAchievementPerWeek()` reshaped for heatmap
- **Screen:** `TargetAnalysisScreen`
- **Status:** [done]

---

## Combined — Cross-Dataset Comparison

> These charts overlay or compare Dataset 1 (10-week historical) against Dataset 2 (Jan–Feb 2026) and their targets.

---

### G-75: Cross-Dataset Demographic Averages — Grouped Bar ×4
- **data.py function:** `combined_plot_avg_comparison()`
- **Chart type:** 4 grouped bar charts (DS1 avg vs DS2 avg)
- **Sub-charts:** Demographics (Men/Women/Youth/Children), Totals (Total Att/Home Church), Financial (Tithe/Offerings/Total Income), Ratios & Per Capita
- **Flutter widget:** `BarChartWidget(stacked: false)` × 4
- **Analytics method:** [new] `crossDatasetAverages()` → `Map<String, Map<String, double>>` (DS1 and DS2 averages per metric)
- **Screen:** New `CrossDatasetScreen`
- **Status:** [done]

---

### G-76: Change % DS1→DS2 — Waterfall/Horizontal Bar
- **data.py function:** `combined_plot_change_waterfall()`
- **Chart type:** 2 horizontal bar charts — positive bars green, negative bars red; one for attendance metrics, one for financial
- **Data:** % change from DS1 average to DS2 average per metric
- **Flutter widget:** [new] Horizontal `BarChartWidget` (`isTransposed: true`) with conditional `CategoryPoint.color`
- **Analytics method:** [new] `crossDatasetChangePercent()` → `List<CategoryPoint>` with color flag
- **Screen:** `CrossDatasetScreen`
- **Status:** [done]

---

### G-77: DS1 vs DS2 Correlation Matrices — Side-by-Side Heatmaps
- **data.py function:** `combined_plot_correlation_overlay()`
- **Chart type:** 2 correlation heatmaps side by side — one for DS1, one for DS2
- **Data:** Pearson correlation matrix for shared vars (MEN/WOMEN/YOUTH/CHILDREN/TOTAL_ATTENDANCE/TITHE/OFFERINGS)
- **Flutter widget:** [new] `HeatmapWidget` × 2
- **Analytics method:** [new] `correlationMatrix(List<String> fields, {bool useDs2})`
- **Screen:** `CorrelationChartsScreen` or `CrossDatasetScreen`
- **Status:** [done]

---

### G-78: Attendance vs Income — Scatter Overlay (Both Datasets)
- **data.py function:** `combined_plot_attendance_vs_income_both()`
- **Chart type:** Scatter chart — DS1 points (circles), DS2 points (squares), each with its own regression line
- **Data:** TOTAL_ATTENDANCE vs TOTAL_INCOME, all weeks from both datasets
- **Flutter widget:** `ScatterCorrelationChart` extended with two series and two trend lines
- **Analytics method:** [reuse] `attendanceVsIncomeScatter()` for DS1 + [new] same method for DS2; or [new] `attendanceVsIncomeScatterBoth()` returning `{ds1: [...], ds2: [...]}`
- **Screen:** `CorrelationChartsScreen`
- **Status:** [done]

---

### G-79: Tithe vs Offerings — Scatter Overlay (Both Datasets)
- **data.py function:** `combined_plot_attendance_vs_income_both()` (second panel)
- **Chart type:** Scatter chart — two series (DS1, DS2) on same axes
- **Data:** TITHE vs OFFERINGS per week from both datasets with regression lines
- **Flutter widget:** `ScatterCorrelationChart` with two series
- **Analytics method:** [new] `titheVsOfferingsScatterBoth()` → `{ds1: List<ScatterPoint>, ds2: List<ScatterPoint>}`
- **Screen:** `CorrelationChartsScreen`
- **Status:** [done]

---

### G-80: Per Capita Comparison DS1 vs DS2 — 3 Bar Charts
- **data.py function:** `combined_plot_per_capita_comparison()`
- **Chart type:** 3 bar charts (DS1 vs DS2 for each metric) with % change in title
- **Data:** Income/Att, Tithe/Att, Offerings/Att — DS1 avg vs DS2 avg
- **Flutter widget:** `BarChartWidget(stacked: false)` × 3 (or a single 3-group chart)
- **Analytics method:** [new] `crossDatasetAverages()` → specific per-capita fields
- **Screen:** `CrossDatasetScreen`
- **Status:** [done]

---

### G-81: Attendance Three-Way Comparison — DS1 Avg / DS2 Avg / DS2 Target
- **data.py function:** `combined_plot_ds2_vs_targets_and_ds1_benchmark()`
- **Chart type:** Grouped bar chart (3 series: DS1 avg, DS2 avg, DS2 target) for attendance metrics
- **Data:** Men, Women, Youth, Children, Total Att, Home Church — three bars per category
- **Flutter widget:** `BarChartWidget(stacked: false)` with 3 series
- **Analytics method:** [new] `threeWayComparisonAttendance()` → `Map<String, List<CategoryPoint>>`
- **Screen:** `CrossDatasetScreen`
- **Status:** [done]

---

### G-82: Financial Three-Way Comparison — DS1 Avg / DS2 Avg / DS2 Target
- **data.py function:** `combined_plot_ds2_vs_targets_and_ds1_benchmark()` (second panel)
- **Chart type:** Grouped bar chart (3 series)
- **Data:** Tithe, Offerings, Total Income — DS1 avg, DS2 avg, DS2 target
- **Flutter widget:** `BarChartWidget(stacked: false)` with 3 series
- **Analytics method:** [new] `threeWayComparisonFinancial()` → `Map<String, List<CategoryPoint>>`
- **Screen:** `CrossDatasetScreen`
- **Status:** [done]

---

### G-83: Master Combined Dashboard
- **data.py function:** `combined_plot_master_dashboard()`
- **Chart type:** Multi-panel dashboard assembling key cross-dataset charts
- **Sub-panels:**
  - Total Attendance trend: DS1 line + DS2 line + target (G-49 + G-50 combined)
  - Total Income trend: DS1 line + DS2 line + target (G-57 extended)
  - Attendance vs Income scatter both datasets (G-78)
  - Demographics 3-way grouped bar (G-81)
  - Financial 3-way grouped bar (G-82)
  - Per-capita 2-series bar (G-80 condensed)
  - Statistics summary table
- **Flutter widget:** `GridView` / `Wrap` composing existing widgets; stats table as `DataTable`
- **Analytics method:** Reuses methods from G-78, G-81, G-82, G-80; stats table from [new] `crossDatasetSummaryStats()`
- **Screen:** `CrossDatasetScreen` (featured/banner section)
- **Status:** [done]

---

## New Screens Proposed

| Screen | Charts it houses |
|--------|----------------|
| `TargetAnalysisScreen` | G-49 through G-74 (DS2 target analysis) |
| `CrossDatasetScreen` | G-75 through G-83 (combined comparison) |
| `DistributionScreen` | G-17 through G-21, G-47 (histograms, box plots, violin plots) |
| `HomeChurchScreen` *(optional)* | G-10 (home church vs all metrics) |
| `DemographicComparisonScreen` *(optional)* | G-08 (pairwise demographic comparisons) |

---

## New Widgets Needed

| Widget | Syncfusion API | Used by |
|--------|---------------|---------|
| `HistogramChartWidget` | `HistogramSeries` in `SfCartesianChart` | G-17 |
| `BoxPlotWidget` | `BoxAndWhiskerSeries` | G-18, G-19, G-20, G-21, G-47 |
| `HeatmapWidget` | Custom grid using `SfCartesianChart` + `CartesianChartAnnotation`, or `DataTable` of colored cells | G-73, G-74, G-77 |
| `ScatterMatrixWidget` | `GridView` of `ScatterCorrelationChart` + `HistogramChartWidget` | G-63 |
| Horizontal `BarChartWidget` (transposed) | `isTransposed: true` on existing `BarChartWidget` via a flag | G-62, G-76 |

---

## New Analytics Service Methods Needed

| Method | Returns | Used by |
|--------|---------|---------|
| `singleMetricPerWeek(String field)` | `(List<CategoryPoint>, double mean)` | G-03 |
| `attendanceTrendLine()` | `List<TimeSeriesPoint>` (regression) | G-04, G-12 |
| `incomeTrendLine()` | `List<TimeSeriesPoint>` (regression) | G-07, G-14 |
| `linearRegressionSeries(List<TimeSeriesPoint>)` | `List<TimeSeriesPoint>` | G-12, G-14 |
| `demographicPairPerWeek(String a, String b)` | `Map<String, List<CategoryPoint>>` | G-08 |
| `totalIncomePerWeek()` | `List<CategoryPoint>` | G-09, G-31 |
| `metricPairPerWeek(String a, String b)` | `Map<String, List<CategoryPoint>>` | G-10 |
| `menTrend()` / `womenTrend()` | `List<TimeSeriesPoint>` | G-33, G-34 |
| `boxPlotStats(List<String> fields)` | `List<BoxPlotPoint>` | G-18, G-19, G-20, G-21, G-47 |
| `violinStats(List<String> fields)` | `List<BoxPlotPoint>` | G-20, G-21 |
| `demographicCorrelationScatter(String a, String b, {bool useDs2})` | `List<ScatterPoint>` | G-52, G-53 |
| `financialCorrelationScatter(String a, String b, {bool useDs2})` | `List<ScatterPoint>` | G-58 |
| `pairwiseCorrelationMatrix(List<String> fields)` | `Map<String, Map<String, List<ScatterPoint>>>` | G-63 |
| `correlationMatrix(List<String> fields, {bool useDs2})` | `List<HeatmapPoint>` | G-73, G-74, G-77 |
| `crossDatasetAverages()` | `Map<String, Map<String, double>>` | G-75, G-80 |
| `crossDatasetChangePercent()` | `List<CategoryPoint>` with color flag | G-76 |
| `attendanceVsIncomeScatterBoth()` | `Map<String, List<ScatterPoint>>` | G-78 |
| `titheVsOfferingsScatterBoth()` | `Map<String, List<ScatterPoint>>` | G-79 |
| `threeWayComparisonAttendance()` | `Map<String, List<CategoryPoint>>` | G-81 |
| `threeWayComparisonFinancial()` | `Map<String, List<CategoryPoint>>` | G-82 |
| `crossDatasetSummaryStats()` | `Map<String, dynamic>` | G-83 |

---

## Summary

| Section | Functions in data.py | Total individual charts | Implemented [done] | Planned [pending] |
|---------|---------------------|------------------------|---------------|------------|
| Dataset 1 | 18 | 48 | ~44 | ~4 (trendline overlays) |
| Dataset 2 | 7 | 31 | 31 | 0 |
| Combined | 7 | 20 | 20 | 0 |
| **Total** | **32** | **~99** | **~95** | **~4** |
