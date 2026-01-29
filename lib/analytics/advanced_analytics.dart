import 'dart:math' as math;

import 'package:church_analytics/models/models.dart';

/// Advanced analytics engine for complex calculations
class AdvancedAnalytics {
  /// Calculate simple moving average for attendance over a window
  List<double> calculateMovingAverageAttendance(
    List<WeeklyRecord> records,
    int windowSize,
  ) {
    if (records.isEmpty || windowSize <= 0 || windowSize > records.length) {
      return [];
    }

    final List<double> movingAverages = [];

    for (int i = 0; i <= records.length - windowSize; i++) {
      final window = records.sublist(i, i + windowSize);
      final sum = window.fold<int>(
        0,
        (sum, record) => sum + record.totalAttendance,
      );
      movingAverages.add(sum / windowSize);
    }

    return movingAverages;
  }

  /// Calculate simple moving average for income over a window
  List<double> calculateMovingAverageIncome(
    List<WeeklyRecord> records,
    int windowSize,
  ) {
    if (records.isEmpty || windowSize <= 0 || windowSize > records.length) {
      return [];
    }

    final List<double> movingAverages = [];

    for (int i = 0; i <= records.length - windowSize; i++) {
      final window = records.sublist(i, i + windowSize);
      final sum = window.fold<double>(
        0,
        (sum, record) => sum + record.totalIncome,
      );
      movingAverages.add(sum / windowSize);
    }

    return movingAverages;
  }

  /// Calculate linear trend line (y = mx + b) for attendance
  /// Returns a map with 'slope' and 'intercept'
  Map<String, double>? calculateAttendanceTrendLine(
    List<WeeklyRecord> records,
  ) {
    if (records.length < 2) return null;

    final List<double> x = List.generate(records.length, (i) => i.toDouble());
    final List<double> y = records
        .map((r) => r.totalAttendance.toDouble())
        .toList();

    return _calculateLinearRegression(x, y);
  }

  /// Calculate linear trend line (y = mx + b) for income
  /// Returns a map with 'slope' and 'intercept'
  Map<String, double>? calculateIncomeTrendLine(List<WeeklyRecord> records) {
    if (records.length < 2) return null;

    final List<double> x = List.generate(records.length, (i) => i.toDouble());
    final List<double> y = records.map((r) => r.totalIncome).toList();

    return _calculateLinearRegression(x, y);
  }

  /// Calculate Pearson correlation coefficient between attendance and income
  /// Returns a value between -1 and 1
  /// 1 = perfect positive correlation
  /// 0 = no correlation
  /// -1 = perfect negative correlation
  double? calculateAttendanceIncomeCorrelation(List<WeeklyRecord> records) {
    if (records.length < 2) return null;

    final List<double> attendance = records
        .map((r) => r.totalAttendance.toDouble())
        .toList();
    final List<double> income = records.map((r) => r.totalIncome).toList();

    return _calculatePearsonCorrelation(attendance, income);
  }

  /// Forecast attendance using linear regression
  /// Returns predicted attendance for the next N periods
  List<double> forecastAttendance(List<WeeklyRecord> records, int periods) {
    if (records.length < 2 || periods <= 0) return [];

    final trendLine = calculateAttendanceTrendLine(records);
    if (trendLine == null) return [];

    final slope = trendLine['slope']!;
    final intercept = trendLine['intercept']!;

    final List<double> forecast = [];
    final startIndex = records.length;

    for (int i = 0; i < periods; i++) {
      final x = startIndex + i;
      final predicted = slope * x + intercept;
      forecast.add(
        predicted > 0 ? predicted : 0,
      ); // Don't predict negative values
    }

    return forecast;
  }

  /// Forecast income using linear regression
  /// Returns predicted income for the next N periods
  List<double> forecastIncome(List<WeeklyRecord> records, int periods) {
    if (records.length < 2 || periods <= 0) return [];

    final trendLine = calculateIncomeTrendLine(records);
    if (trendLine == null) return [];

    final slope = trendLine['slope']!;
    final intercept = trendLine['intercept']!;

    final List<double> forecast = [];
    final startIndex = records.length;

    for (int i = 0; i < periods; i++) {
      final x = startIndex + i;
      final predicted = slope * x + intercept;
      forecast.add(
        predicted > 0 ? predicted : 0,
      ); // Don't predict negative values
    }

    return forecast;
  }

  /// Detect outliers in attendance using the IQR method
  /// Returns a list of records that are considered outliers
  List<WeeklyRecord> detectAttendanceOutliers(List<WeeklyRecord> records) {
    if (records.length < 4) return []; // Need at least 4 points for quartiles

    final attendanceValues =
        records.map((r) => r.totalAttendance.toDouble()).toList()..sort();
    final outlierIndices = _detectOutliersIQR(attendanceValues);

    final outliers = <WeeklyRecord>[];
    for (final index in outlierIndices) {
      final originalIndex = records.indexWhere(
        (r) => r.totalAttendance.toDouble() == attendanceValues[index],
      );
      if (originalIndex != -1) {
        outliers.add(records[originalIndex]);
      }
    }

    return outliers;
  }

  /// Detect outliers in income using the IQR method
  /// Returns a list of records that are considered outliers
  List<WeeklyRecord> detectIncomeOutliers(List<WeeklyRecord> records) {
    if (records.length < 4) return []; // Need at least 4 points for quartiles

    final incomeValues = records.map((r) => r.totalIncome).toList()..sort();
    final outlierIndices = _detectOutliersIQR(incomeValues);

    final outliers = <WeeklyRecord>[];
    for (final index in outlierIndices) {
      final originalIndex = records.indexWhere(
        (r) => r.totalIncome == incomeValues[index],
      );
      if (originalIndex != -1) {
        outliers.add(records[originalIndex]);
      }
    }

    return outliers;
  }

  /// Calculate rolling metrics for the last N weeks
  /// Returns a map with various rolling metrics
  Map<String, dynamic> calculateRolling4WeekMetrics(
    List<WeeklyRecord> records,
  ) {
    return calculateRollingMetrics(records, 4);
  }

  /// Calculate rolling metrics for a specified window
  Map<String, dynamic> calculateRollingMetrics(
    List<WeeklyRecord> records,
    int windowSize,
  ) {
    if (records.length < windowSize) {
      return {
        'averageAttendance': 0.0,
        'averageIncome': 0.0,
        'totalAttendance': 0,
        'totalIncome': 0.0,
        'growthRate': null,
        'recordCount': records.length,
      };
    }

    // Take the last N records
    final window = records.sublist(records.length - windowSize);

    final totalAttendance = window.fold<int>(
      0,
      (sum, r) => sum + r.totalAttendance,
    );
    final totalIncome = window.fold<double>(0, (sum, r) => sum + r.totalIncome);
    final avgAttendance = totalAttendance / windowSize;
    final avgIncome = totalIncome / windowSize;

    // Calculate growth rate between first and last in window
    double? growthRate;
    if (window.first.totalAttendance > 0) {
      growthRate =
          ((window.last.totalAttendance - window.first.totalAttendance) /
              window.first.totalAttendance) *
          100;
    }

    return {
      'averageAttendance': avgAttendance,
      'averageIncome': avgIncome,
      'totalAttendance': totalAttendance,
      'totalIncome': totalIncome,
      'growthRate': growthRate,
      'recordCount': windowSize,
      'periodStart': window.first.weekStartDate,
      'periodEnd': window.last.weekStartDate,
    };
  }

  // ========== Private Helper Methods ==========

  /// Calculate linear regression (y = mx + b)
  /// Returns slope (m) and intercept (b)
  Map<String, double>? _calculateLinearRegression(
    List<double> x,
    List<double> y,
  ) {
    if (x.length != y.length || x.length < 2) return null;

    final n = x.length;
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumX2 = x.map((xi) => xi * xi).reduce((a, b) => a + b);

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    return {'slope': slope, 'intercept': intercept};
  }

  /// Calculate Pearson correlation coefficient
  double? _calculatePearsonCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 2) return null;

    final n = x.length;
    final meanX = x.reduce((a, b) => a + b) / n;
    final meanY = y.reduce((a, b) => a + b) / n;

    double numerator = 0;
    double sumSquaredDiffX = 0;
    double sumSquaredDiffY = 0;

    for (int i = 0; i < n; i++) {
      final diffX = x[i] - meanX;
      final diffY = y[i] - meanY;
      numerator += diffX * diffY;
      sumSquaredDiffX += diffX * diffX;
      sumSquaredDiffY += diffY * diffY;
    }

    final denominator = math.sqrt(sumSquaredDiffX * sumSquaredDiffY);

    if (denominator == 0) return null;

    return numerator / denominator;
  }

  /// Detect outliers using IQR (Interquartile Range) method
  /// Returns indices of outliers in the sorted list
  List<int> _detectOutliersIQR(List<double> sortedValues) {
    if (sortedValues.length < 4) return [];

    final q1Index = (sortedValues.length * 0.25).floor();
    final q3Index = (sortedValues.length * 0.75).floor();

    final q1 = sortedValues[q1Index];
    final q3 = sortedValues[q3Index];
    final iqr = q3 - q1;

    final lowerBound = q1 - (1.5 * iqr);
    final upperBound = q3 + (1.5 * iqr);

    final outlierIndices = <int>[];
    for (int i = 0; i < sortedValues.length; i++) {
      if (sortedValues[i] < lowerBound || sortedValues[i] > upperBound) {
        outlierIndices.add(i);
      }
    }

    return outlierIndices;
  }
}
