# Python Graph Reference — `data.py`

This document catalogues every graph and chart produced by `data.py` and maps
each one to its equivalent Flutter / Syncfusion chart type and the Dart method
that produces the required dataset in `analytics_service.dart`.

---

## Datasets

`data.py` defines two datasets that share the same column schema.

| Symbol | Description |
|--------|-------------|
| `df`   | Dataset 1 — four Saturday records (Jan–Feb 2026, no named targets) |
| `df2`  | Dataset 2 — same four records with explicit annual targets and baptism data |

---

## Derived columns (computed before graphing)

### Dataset 1 (`df`)

| Column | Formula |
|--------|---------|
| `TOTAL_ATTENDANCE` | `MEN + WOMEN + YOUTH + CHILDREN` |
| `TOTAL_WITH_HOME_CHURCH` | `TOTAL_ATTENDANCE + SUNDAY_HOME_CHURCH` |
| `ADULT_ATTENDANCE` | `MEN + WOMEN` |
| `YOUNG_ATTENDANCE` | `YOUTH + CHILDREN` |
| `TOTAL_INCOME` | `TITHE + OFFERINGS + EMERGENCY_COLLECTION + PLANNED_COLLECTION` |
| `REGULAR_INCOME` | `TITHE + OFFERINGS` |
| `SPECIAL_COLLECTIONS` | `EMERGENCY_COLLECTION + PLANNED_COLLECTION` |
| `MEN_PCT` | `MEN / TOTAL_ATTENDANCE × 100` |
| `WOMEN_PCT` | `WOMEN / TOTAL_ATTENDANCE × 100` |
| `YOUTH_PCT` | `YOUTH / TOTAL_ATTENDANCE × 100` |
| `CHILDREN_PCT` | `CHILDREN / TOTAL_ATTENDANCE × 100` |
| `INCOME_PER_ATTENDEE` | `TOTAL_INCOME / TOTAL_ATTENDANCE` |
| `TITHE_PER_ATTENDEE` | `TITHE / TOTAL_ATTENDANCE` |
| `OFFERINGS_PER_ATTENDEE` | `OFFERINGS / TOTAL_ATTENDANCE` |
| `REGULAR_INCOME_PER_ADULT` | `REGULAR_INCOME / ADULT_ATTENDANCE` |
| `ATTENDANCE_GROWTH` | `TOTAL_ATTENDANCE.pct_change() × 100` |
| `INCOME_GROWTH` | `TOTAL_INCOME.pct_change() × 100` |
| `TITHE_GROWTH` | `TITHE.pct_change() × 100` |
| `MEN_WOMEN_RATIO` | `MEN / WOMEN` |
| `ADULT_YOUNG_RATIO` | `ADULT_ATTENDANCE / YOUNG_ATTENDANCE` |
| `TITHE_OFFERINGS_RATIO` | `TITHE / OFFERINGS` |

### Dataset 2 (`df2`) — additional columns

| Column | Formula |
|--------|---------|
| `ADULT_ATTENDANCE` | `MEN + WOMEN` |
| `YOUNG_ATTENDANCE` | `YOUTH + CHILDREN` |
| `TOTAL_INCOME` | `TITHE + OFFERINGS` |
| `INCOME_PER_ATTENDEE` | `TOTAL_INCOME / TOTAL_ATTENDANCE` |
| `TITHE_PER_ATTENDEE` | `TITHE / TOTAL_ATTENDANCE` |
| `OFFERINGS_PER_ATTENDEE` | `OFFERINGS / TOTAL_ATTENDANCE` |
| `MEN_PCT … CHILDREN_PCT` | same as Dataset 1 |
| `MEN_WOMEN_RATIO` | `MEN / WOMEN` |
| `ADULT_YOUNG_RATIO` | `ADULT / YOUNG` |
| `TITHE_OFFERINGS_RATIO` | `TITHE / OFFERINGS` |
| `ATTENDANCE_GROWTH` | `pct_change() × 100` |
| `TITHE_GROWTH` | `pct_change() × 100` |
| `*_TARGET_PCT` | `actual / target × 100` |

---

## Graph Catalogue

### Dataset 1 Graphs

---

#### G01 — Attendance & Income Overview (`plot_attendance_overview`)

| Attribute | Value |
|-----------|-------|
| Python function | `plot_attendance_overview` |
| Saved as | `dataset1/attendance_income_overview.png` |
| Chart 1 | Grouped bar — Men / Women / Youth / Children per week |
| Chart 2 | Stacked bar — Tithe (bottom) + Offerings (top) per week |
| Flutter chart | `BarChartWidget` (grouped), `BarChartWidget` (stacked) |
| Dart method | `attendanceByGroupPerWeek`, `tithePerWeek` + `offeringsPerWeek` |

---

#### G02 — Demographics & Financials Weekly (`plot_demographics_weekly`)

| Attribute | Value |
|-----------|-------|
| Python function | `plot_demographics_weekly` |
| Saved as | `dataset1/demographics_weekly.png` |
| Description | 8-panel grid — individual bar per variable (Men, Women, Youth, Children, Tithe, Offerings, Total Income, Home Church) each with a mean reference line |
| Flutter chart | `BarChartWidget` (one series per variable) |
| Dart method | `attendanceByGroupPerWeek`, `tithePerWeek`, `offeringsPerWeek`, `totalIncomeTrend`, per-variable `CategoryPoint` lists |

---

#### G03 — Attendance & Income Trends (`plot_attendance_income_trends`)

| Attribute | Value |
|-----------|-------|
| Python function | `plot_attendance_income_trends` |
| Saved as | `dataset1/attendance_income_trends.png` |
| Chart 1 | Line + fill — Total Attendance with mean reference line |
| Chart 2 | Bar — Tithe per week with mean reference line |
| Chart 3 | Bar — Offerings per week with mean reference line |
| Chart 4 | Line + fill — Total Income with mean reference line |
| Flutter chart | `AreaChartWidget` (1, 4), `BarChartWidget` (2, 3) |
| Dart method | `totalAttendanceTrend`, `titheTrend`, `offeringsTrend`, `totalIncomeTrend` |

---

#### G04 — Demographic Pairwise Comparison (`plot_demographic_comparison`)

| Attribute | Value |
|-----------|-------|
| Python function | `plot_demographic_comparison` |
| Saved as | `dataset1/demographic_comparison.png` |
| Description | 6-panel grid — side-by-side bars for every pair of demographic groups: Men/Women, Men/Youth, Men/Children, Women/Youth, Women/Children, Youth/Children |
| Flutter chart | `BarChartWidget` (grouped, 2 series each) |
| Dart method | `attendanceByGroupPerWeek` (select 2 keys per panel) |

---

#### G05 — Financial Variables Weekly (`plot_financial_weekly`)

| Attribute | Value |
|-----------|-------|
| Python function | `plot_financial_weekly` |
| Saved as | `dataset1/financial_weekly.png` |
| Description | 3-panel grid — side-by-side bars for Tithe/Offerings, Tithe/TotalIncome, Offerings/TotalIncome |
| Flutter chart | `BarChartWidget` (grouped, 2 series) |
| Dart method | `tithePerWeek`, `offeringsPerWeek`, `totalIncomeTrend` mapped to `CategoryPoint` |

---

#### G06 — Home Church vs All Variables (`plot_home_church_comparison`)

| Attribute | Value |
|-----------|-------|
| Python function | `plot_home_church_comparison` |
| Saved as | `dataset1/home_church_comparison.png` |
| Description | 8-panel grid — Sunday Home Church side-by-side with each other variable |
| Flutter chart | `BarChartWidget` (grouped, 2 series) |
| Dart method | `homeChurchPerWeek` (new), `attendanceByGroupPerWeek`, `tithePerWeek`, `offeringsPerWeek` |

---

#### G07 — Full Time Series (`plot_time_series_all`)

| Attribute | Value |
|-----------|-------|
| Python function | `plot_time_series_all` |
| Saved as | `dataset1/time_series_all.png` |
| Chart 1 | Multi-line — Men, Women, Youth, Children over time |
| Chart 2 | Line + fill + trend line — Total Attendance |
| Chart 3 | Multi-line — Tithe & Offerings over time |
| Chart 4 | Line + fill + trend line — Total Income |
| Chart 5 | Bar (green/red) — Weekly Attendance Growth Rate % |
| Chart 6 | Line + fill — Income Per Attendee over time |
| Flutter chart | `LineChartWidget` (1, 3), `AreaChartWidget` (2, 4, 6), `BarChartWidget` (5) |
| Dart method | `demographicAttendanceTrends`, `totalAttendanceTrend`, `titheTrend`, `offeringsTrend`, `totalIncomeTrend`, `attendanceGrowthRates`, `incomePerAttendeeTrend` |

---

#### G08 — Distribution Histograms (`plot_distribution_analysis`)

| Attribute | Value |
|-----------|-------|
| Python function | `plot_distribution_analysis` |
| Saved as | `dataset1/distribution_analysis.png` |
| Description | 9-panel histogram grid — Men, Women, Youth, Children, HomeChurch, Tithe, Offerings, TotalAttendance, TotalIncome each with mean/median reference lines |
| Flutter chart | `BarChartWidget` (value-frequency bars) |
| Dart method | `distributionHistogram` (new) |

---

#### G09 — Stacked Area Charts (`plot_stacked_area`)

| Attribute | Value |
|-----------|-------|
| Python function | `plot_stacked_area` |
| Saved as | `dataset1/stacked_area.png` |
| Chart 1 | Stacked area — Men, Women, Youth, Children composition over time |
| Chart 2 | Stacked area — Tithe, Offerings, Emergency, Planned income composition |
| Flutter chart | `AreaChartWidget` (stacked series) |
| Dart method | `demographicAttendanceTrends`, `incomeComponentTrends` (new) |

---

#### G10 — Pie Charts (`plot_pie_charts`)

| Attribute | Value |
|-----------|-------|
| Python function | `plot_pie_charts` |
| Saved as | `dataset1/pie_charts.png` |
| Pie 1 | Saturday attendance — Men / Women / Youth / Children |
| Pie 2 | Total income — Tithe / Offerings / Emergency / Planned |
| Pie 3 | Adults (Men+Women) vs Young (Youth+Children) |
| Pie 4 | Regular income (Tithe+Offerings) vs Special Collections |
| Flutter chart | `PieChartWidget` |
| Dart method | `demographicDistribution`, `incomeDistribution`, `adultVsYoungDistribution` (new), `regularVsSpecialIncomeDistribution` (new) |

---

#### G11 — Grouped Bar Comparison (`plot_grouped_bar_comparison`)

| Attribute | Value |
|-----------|-------|
| Python function | `plot_grouped_bar_comparison` |
| Saved as | `dataset1/grouped_bar_comparison.png` |
| Chart 1 | All demographics per week (4 groups) |
| Chart 2 | Tithe vs Offerings per week |
| Chart 3 | Adults vs Young per week |
| Chart 4 | Regular Income vs Total Income per week |
| Flutter chart | `BarChartWidget` (grouped) |
| Dart method | `attendanceByGroupPerWeek`, `tithePerWeek`, `offeringsPerWeek`, `adultAttendancePerWeek` (new), `youngAttendancePerWeek` (new), `regularIncomePerWeek` (new) |

---

#### G12 — Dual Axis Trends (`plot_dual_axis_trends`)

| Attribute | Value |
|-----------|-------|
| Python function | `plot_dual_axis_trends` |
| Saved as | `dataset1/dual_axis_trends.png` |
| Chart 1 | Total Attendance vs Total Income (dual axis) |
| Chart 2 | Men vs Tithe (dual axis) |
| Chart 3 | Women vs Offerings (dual axis) |
| Chart 4 | Home Church vs Regular Income (dual axis) |
| Flutter chart | `LineChartWidget` (two separate Y-axis series rendered together) |
| Dart method | `totalAttendanceTrend`, `totalIncomeTrend`, `titheTrend`, `offeringsTrend`, `homeChurchTrend` (new), `regularIncomeTrend` (new) |

---

#### G13 — Per Capita Analysis (`plot_per_capita_analysis`)

| Attribute | Value |
|-----------|-------|
| Python function | `plot_per_capita_analysis` |
| Saved as | `dataset1/per_capita_analysis.png` |
| Chart 1 | Line + fill — Income per Attendee over time |
| Chart 2 | Bar — Tithe per Attendee per week |
| Chart 3 | Bar — Regular Income per Adult per week |
| Chart 4 | Grouped bar — Income/Attendee, Tithe/Attendee, Offerings/Attendee comparison |
| Flutter chart | `AreaChartWidget` (1), `BarChartWidget` (2, 3, 4) |
| Dart method | `incomePerAttendeeTrend`, `tithePerAttendeePerWeek` (new), `regularIncomePerAdultPerWeek` (new), `offeringsPerAttendeePerWeek` (new) |

---

#### G14 — Ratio Analysis (`plot_ratio_analysis`)

| Attribute | Value |
|-----------|-------|
| Python function | `plot_ratio_analysis` |
| Saved as | `dataset1/ratio_analysis.png` |
| Chart 1 | Line — Men:Women Ratio over time |
| Chart 2 | Line — Adult:Young Ratio over time |
| Chart 3 | Line — Tithe:Offerings Ratio over time |
| Chart 4 | Multi-line — All three ratios overlaid |
| Flutter chart | `LineChartWidget` |
| Dart method | `menWomenRatioTrend` (new), `adultYoungRatioTrend` (new), `titheOfferingsRatioTrend` (new) |

---

#### G15 — Percentage Composition Analysis (`plot_percentage_analysis`)

| Attribute | Value |
|-----------|-------|
| Python function | `plot_percentage_analysis` |
| Saved as | `dataset1/percentage_analysis.png` |
| Chart 1 | Stacked area — Men%, Women%, Youth%, Children% composition |
| Chart 2 | Multi-line — Individual percentage trends |
| Chart 3 | Bar — Average percentage per category |
| Chart 4 | Box plot approximation — percentage variability by category |
| Flutter chart | `AreaChartWidget` (1), `LineChartWidget` (2), `BarChartWidget` (3) |
| Dart method | `demographicPercentageTrends` (new), `averageDemographicPercentages` (new) |

---

#### G16 — Comprehensive Dashboard (`plot_comprehensive_dashboard`)

| Attribute | Value |
|-----------|-------|
| Python function | `plot_comprehensive_dashboard` |
| Saved as | `dataset1/comprehensive_dashboard.png` |
| Description | Full summary panel combining: attendance trend + linear trend, income trend + linear trend, attendance pie, income pie, scatter (attendance vs income), growth rate bars, demographics grouped bar, financial grouped bar |
| Flutter chart | Combination of all widget types |
| Dart method | All existing methods |

---

### Dataset 2 Graphs

---

#### G17 — Dataset 2 Attendance Trends (`ds2_plot_attendance_trends`)

| Attribute | Value |
|-----------|-------|
| Python function | `ds2_plot_attendance_trends` |
| Saved as | `dataset2/attendance_trends.png` |
| Charts | Multi-line demographics, Total Attendance bar vs target, Home Church line vs target, Men/Women scatter, Adults/Young scatter, Stacked area percentage |
| Flutter chart | `LineChartWidget`, `BarChartWidget`, `AreaChartWidget` |
| Dart method | `demographicAttendanceTrends`, `totalAttendanceTrend`, `homeChurchTrend`, `attendanceTargetAchievement` (new) |

---

#### G18 — Dataset 2 Financial Analysis (`ds2_plot_financial_analysis`)

| Attribute | Value |
|-----------|-------|
| Python function | `ds2_plot_financial_analysis` |
| Saved as | `dataset2/financial_analysis.png` |
| Charts | Tithe bar vs target, Offerings bar vs target, Total Income area, Tithe/Offerings scatter, Attendance/Income scatter, Income per Attendee bar |
| Flutter chart | `BarChartWidget`, `AreaChartWidget` |
| Dart method | `titheTrend`, `offeringsTrend`, `totalIncomeTrend`, `incomePerAttendeeTrend` |

---

#### G19 — Target Achievement (`ds2_plot_target_gauge`)

| Attribute | Value |
|-----------|-------|
| Python function | `ds2_plot_target_gauge` |
| Saved as | `dataset2/target_achievement.png` |
| Charts | Grouped bar — target achievement % per week per metric; horizontal bar — overall average achievement |
| Flutter chart | `BarChartWidget` |
| Dart method | `targetAchievementPerWeek` (new), `overallTargetAchievement` (new) |

---

#### G20 — Dataset 2 Ratio Analysis (`ds2_plot_ratios`)

| Attribute | Value |
|-----------|-------|
| Python function | `ds2_plot_ratios` |
| Saved as | `dataset2/ratio_analysis.png` |
| Charts | Men:Women, Adult:Young, Tithe:Offerings trend lines + grouped bar comparison |
| Flutter chart | `LineChartWidget`, `BarChartWidget` |
| Dart method | `menWomenRatioTrend`, `adultYoungRatioTrend`, `titheOfferingsRatioTrend` |

---

#### G21 — Gender vs Target Bar Charts (`ds2_plot_target_bar_charts`)

| Attribute | Value |
|-----------|-------|
| Python function | `ds2_plot_target_bar_charts` |
| Saved as | `dataset2/gender_per_saturday_vs_target.png`, `all_genders_four_saturdays.png`, `tithe_per_saturday_vs_target.png`, `offerings_per_saturday_vs_target.png` |
| Charts | Individual gender bar + target line; all genders grouped + dotted target lines; Tithe bar + target; Offerings bar + target; Total Attendance / Home Church / Total Income vs targets |
| Flutter chart | `BarChartWidget` |
| Dart method | `attendanceByGroupPerWeek`, `tithePerWeek`, `offeringsPerWeek`, `targetAchievementPerWeek` |

---

## Flutter Chart Mapping Summary

| Python Graph Type | Syncfusion Widget | `analytics_service.dart` method(s) |
|---|---|---|
| Grouped bar — demographics | `BarChartWidget` (grouped) | `attendanceByGroupPerWeek` |
| Stacked bar — income | `BarChartWidget` (stacked) | `tithePerWeek`, `offeringsPerWeek` |
| Line + fill — attendance trend | `AreaChartWidget` | `totalAttendanceTrend` |
| Line + fill — income trend | `AreaChartWidget` | `totalIncomeTrend` |
| Multi-line — demographics | `LineChartWidget` | `demographicAttendanceTrends` |
| Multi-line — tithe + offerings | `LineChartWidget` | `titheTrend`, `offeringsTrend` |
| Bar — growth rate | `BarChartWidget` | `attendanceGrowthRates` |
| Bar — income growth rate | `BarChartWidget` | `incomeGrowthRates` |
| Line + fill — income/attendee | `AreaChartWidget` | `incomePerAttendeeTrend` |
| Stacked area — composition | `AreaChartWidget` (stacked) | `demographicAttendanceTrends` |
| Pie — attendance distribution | `PieChartWidget` | `demographicDistribution` |
| Pie — income distribution | `PieChartWidget` | `incomeDistribution` |
| Pie — adults vs young | `PieChartWidget` | `adultVsYoungDistribution` |
| Pie — regular vs special income | `PieChartWidget` | `regularVsSpecialIncomeDistribution` |
| Bar — per capita tithe | `BarChartWidget` | `tithePerAttendeePerWeek` |
| Bar — per capita offerings | `BarChartWidget` | `offeringsPerAttendeePerWeek` |
| Bar — regular income per adult | `BarChartWidget` | `regularIncomePerAdultPerWeek` |
| Line — Men:Women ratio | `LineChartWidget` | `menWomenRatioTrend` |
| Line — Adult:Young ratio | `LineChartWidget` | `adultYoungRatioTrend` |
| Line — Tithe:Offerings ratio | `LineChartWidget` | `titheOfferingsRatioTrend` |
| Bar — target achievement | `BarChartWidget` | `targetAchievementPerWeek` |
| Area — percentage trends | `AreaChartWidget` | `demographicPercentageTrends` |
| Bar — average percentages | `BarChartWidget` | `averageDemographicPercentages` |
| Bar — home church per week | `BarChartWidget` | `homeChurchPerWeek` |
| Line — home church trend | `LineChartWidget` | `homeChurchTrend` |
| Line — regular income trend | `LineChartWidget` | `regularIncomeTrend` |
| Bar — adults per week | `BarChartWidget` | `adultAttendancePerWeek` |
| Bar — young per week | `BarChartWidget` | `youngAttendancePerWeek` |
| Bar — regular income per week | `BarChartWidget` | `regularIncomePerWeek` |
| Bar — overall target achievement | `BarChartWidget` | `overallTargetAchievement` |
