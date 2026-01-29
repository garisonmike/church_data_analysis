import 'package:church_analytics/models/models.dart';

/// Core analytics engine for calculating basic metrics from weekly records
class MetricsCalculator {
  /// Calculate total attendance from a single record
  int calculateTotalAttendance(WeeklyRecord record) {
    return record.totalAttendance;
  }

  /// Calculate total income from a single record
  double calculateTotalIncome(WeeklyRecord record) {
    return record.totalIncome;
  }

  /// Calculate total attendance for multiple records
  int calculateTotalAttendanceForRecords(List<WeeklyRecord> records) {
    return records.fold<int>(0, (sum, record) => sum + record.totalAttendance);
  }

  /// Calculate total income for multiple records
  double calculateTotalIncomeForRecords(List<WeeklyRecord> records) {
    return records.fold<double>(0, (sum, record) => sum + record.totalIncome);
  }

  /// Calculate average attendance across multiple records
  double calculateAverageAttendance(List<WeeklyRecord> records) {
    if (records.isEmpty) return 0.0;

    final total = calculateTotalAttendanceForRecords(records);
    return total / records.length;
  }

  /// Calculate average income across multiple records
  double calculateAverageIncome(List<WeeklyRecord> records) {
    if (records.isEmpty) return 0.0;

    final total = calculateTotalIncomeForRecords(records);
    return total / records.length;
  }

  /// Calculate week-over-week growth percentage for attendance
  /// Returns null if there's no previous record to compare
  double? calculateAttendanceGrowthPercentage(
    WeeklyRecord currentWeek,
    WeeklyRecord? previousWeek,
  ) {
    if (previousWeek == null || previousWeek.totalAttendance == 0) {
      return null;
    }

    final growth = currentWeek.totalAttendance - previousWeek.totalAttendance;
    return (growth / previousWeek.totalAttendance) * 100;
  }

  /// Calculate week-over-week growth percentage for income
  /// Returns null if there's no previous record to compare
  double? calculateIncomeGrowthPercentage(
    WeeklyRecord currentWeek,
    WeeklyRecord? previousWeek,
  ) {
    if (previousWeek == null || previousWeek.totalIncome == 0) {
      return null;
    }

    final growth = currentWeek.totalIncome - previousWeek.totalIncome;
    return (growth / previousWeek.totalIncome) * 100;
  }

  /// Calculate overall growth percentage for a period
  /// Compares the last week to the first week in the list
  double? calculatePeriodGrowthPercentage(List<WeeklyRecord> records) {
    if (records.length < 2) return null;

    // Assume records are sorted by date (oldest first)
    final firstWeek = records.first;
    final lastWeek = records.last;

    return calculateAttendanceGrowthPercentage(lastWeek, firstWeek);
  }

  /// Calculate attendance-to-income ratio
  /// Returns the average income per attendee
  double calculateAttendanceToIncomeRatio(WeeklyRecord record) {
    if (record.totalAttendance == 0) return 0.0;
    return record.totalIncome / record.totalAttendance;
  }

  /// Calculate average attendance-to-income ratio across multiple records
  double calculateAverageAttendanceToIncomeRatio(List<WeeklyRecord> records) {
    if (records.isEmpty) return 0.0;

    final totalAttendance = calculateTotalAttendanceForRecords(records);
    final totalIncome = calculateTotalIncomeForRecords(records);

    if (totalAttendance == 0) return 0.0;
    return totalIncome / totalAttendance;
  }

  /// Calculate per-capita giving (income per attendee)
  double calculatePerCapitaGiving(WeeklyRecord record) {
    return calculateAttendanceToIncomeRatio(record);
  }

  /// Calculate average per-capita giving across multiple records
  double calculateAveragePerCapitaGiving(List<WeeklyRecord> records) {
    return calculateAverageAttendanceToIncomeRatio(records);
  }

  /// Calculate category percentages for attendance
  Map<String, double> calculateAttendanceCategoryPercentages(
    WeeklyRecord record,
  ) {
    final total = record.totalAttendance;
    if (total == 0) {
      return {
        'men': 0.0,
        'women': 0.0,
        'youth': 0.0,
        'children': 0.0,
        'sundayHomeChurch': 0.0,
      };
    }

    return {
      'men': (record.men / total) * 100,
      'women': (record.women / total) * 100,
      'youth': (record.youth / total) * 100,
      'children': (record.children / total) * 100,
      'sundayHomeChurch': (record.sundayHomeChurch / total) * 100,
    };
  }

  /// Calculate average category percentages across multiple records
  Map<String, double> calculateAverageAttendanceCategoryPercentages(
    List<WeeklyRecord> records,
  ) {
    if (records.isEmpty) {
      return {
        'men': 0.0,
        'women': 0.0,
        'youth': 0.0,
        'children': 0.0,
        'sundayHomeChurch': 0.0,
      };
    }

    int totalMen = 0;
    int totalWomen = 0;
    int totalYouth = 0;
    int totalChildren = 0;
    int totalSundayHomeChurch = 0;

    for (final record in records) {
      totalMen += record.men;
      totalWomen += record.women;
      totalYouth += record.youth;
      totalChildren += record.children;
      totalSundayHomeChurch += record.sundayHomeChurch;
    }

    final grandTotal =
        totalMen +
        totalWomen +
        totalYouth +
        totalChildren +
        totalSundayHomeChurch;

    if (grandTotal == 0) {
      return {
        'men': 0.0,
        'women': 0.0,
        'youth': 0.0,
        'children': 0.0,
        'sundayHomeChurch': 0.0,
      };
    }

    return {
      'men': (totalMen / grandTotal) * 100,
      'women': (totalWomen / grandTotal) * 100,
      'youth': (totalYouth / grandTotal) * 100,
      'children': (totalChildren / grandTotal) * 100,
      'sundayHomeChurch': (totalSundayHomeChurch / grandTotal) * 100,
    };
  }

  /// Calculate category percentages for income
  Map<String, double> calculateIncomeCategoryPercentages(WeeklyRecord record) {
    final total = record.totalIncome;
    if (total == 0) {
      return {
        'tithe': 0.0,
        'offerings': 0.0,
        'emergencyCollection': 0.0,
        'plannedCollection': 0.0,
      };
    }

    return {
      'tithe': (record.tithe / total) * 100,
      'offerings': (record.offerings / total) * 100,
      'emergencyCollection': (record.emergencyCollection / total) * 100,
      'plannedCollection': (record.plannedCollection / total) * 100,
    };
  }

  /// Calculate average income category percentages across multiple records
  Map<String, double> calculateAverageIncomeCategoryPercentages(
    List<WeeklyRecord> records,
  ) {
    if (records.isEmpty) {
      return {
        'tithe': 0.0,
        'offerings': 0.0,
        'emergencyCollection': 0.0,
        'plannedCollection': 0.0,
      };
    }

    double totalTithe = 0;
    double totalOfferings = 0;
    double totalEmergency = 0;
    double totalPlanned = 0;

    for (final record in records) {
      totalTithe += record.tithe;
      totalOfferings += record.offerings;
      totalEmergency += record.emergencyCollection;
      totalPlanned += record.plannedCollection;
    }

    final grandTotal =
        totalTithe + totalOfferings + totalEmergency + totalPlanned;

    if (grandTotal == 0) {
      return {
        'tithe': 0.0,
        'offerings': 0.0,
        'emergencyCollection': 0.0,
        'plannedCollection': 0.0,
      };
    }

    return {
      'tithe': (totalTithe / grandTotal) * 100,
      'offerings': (totalOfferings / grandTotal) * 100,
      'emergencyCollection': (totalEmergency / grandTotal) * 100,
      'plannedCollection': (totalPlanned / grandTotal) * 100,
    };
  }

  /// Calculate all core metrics for a single record
  Map<String, dynamic> calculateAllMetrics(WeeklyRecord record) {
    return {
      'totalAttendance': calculateTotalAttendance(record),
      'totalIncome': calculateTotalIncome(record),
      'perCapitaGiving': calculatePerCapitaGiving(record),
      'attendanceToIncomeRatio': calculateAttendanceToIncomeRatio(record),
      'attendanceCategoryPercentages': calculateAttendanceCategoryPercentages(
        record,
      ),
      'incomeCategoryPercentages': calculateIncomeCategoryPercentages(record),
    };
  }

  /// Calculate summary metrics for multiple records
  Map<String, dynamic> calculateSummaryMetrics(List<WeeklyRecord> records) {
    return {
      'totalAttendance': calculateTotalAttendanceForRecords(records),
      'totalIncome': calculateTotalIncomeForRecords(records),
      'averageAttendance': calculateAverageAttendance(records),
      'averageIncome': calculateAverageIncome(records),
      'averagePerCapitaGiving': calculateAveragePerCapitaGiving(records),
      'periodGrowthPercentage': calculatePeriodGrowthPercentage(records),
      'averageAttendanceCategoryPercentages':
          calculateAverageAttendanceCategoryPercentages(records),
      'averageIncomeCategoryPercentages':
          calculateAverageIncomeCategoryPercentages(records),
      'recordCount': records.length,
    };
  }
}
