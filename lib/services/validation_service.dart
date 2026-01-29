import 'package:church_analytics/models/models.dart';

/// Service for data validation and integrity checks
class ValidationService {
  /// Required fields for CSV import
  static const List<String> requiredCsvFields = [
    'weekStartDate',
    'men',
    'women',
    'youth',
    'children',
    'sundayHomeChurch',
    'tithe',
    'offerings',
    'emergencyCollection',
    'plannedCollection',
  ];

  /// Validates that a numeric value is >= 0
  /// Returns an error message if invalid, null if valid
  String? validateNonNegativeInt(int value, String fieldName) {
    if (value < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  /// Validates that a numeric value is >= 0
  /// Returns an error message if invalid, null if valid
  String? validateNonNegativeDouble(double value, String fieldName) {
    if (value < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  /// Validates all required fields are present in a WeeklyRecord
  /// Returns list of error messages for missing/invalid fields
  List<String> validateRequiredFields(WeeklyRecord record) {
    final errors = <String>[];

    if (record.churchId <= 0) {
      errors.add('Church ID is required');
    }

    // Attendance validation
    final attendanceError = validateNonNegativeInt(record.men, 'Men count');
    if (attendanceError != null) errors.add(attendanceError);

    final womenError = validateNonNegativeInt(record.women, 'Women count');
    if (womenError != null) errors.add(womenError);

    final youthError = validateNonNegativeInt(record.youth, 'Youth count');
    if (youthError != null) errors.add(youthError);

    final childrenError = validateNonNegativeInt(
      record.children,
      'Children count',
    );
    if (childrenError != null) errors.add(childrenError);

    final homeChurchError = validateNonNegativeInt(
      record.sundayHomeChurch,
      'Sunday Home Church',
    );
    if (homeChurchError != null) errors.add(homeChurchError);

    // Financial validation
    final titheError = validateNonNegativeDouble(record.tithe, 'Tithe');
    if (titheError != null) errors.add(titheError);

    final offeringsError = validateNonNegativeDouble(
      record.offerings,
      'Offerings',
    );
    if (offeringsError != null) errors.add(offeringsError);

    final emergencyError = validateNonNegativeDouble(
      record.emergencyCollection,
      'Emergency Collection',
    );
    if (emergencyError != null) errors.add(emergencyError);

    final plannedError = validateNonNegativeDouble(
      record.plannedCollection,
      'Planned Collection',
    );
    if (plannedError != null) errors.add(plannedError);

    return errors;
  }

  /// Check if a value appears to be an outlier compared to historical data
  /// Returns a warning message if the value is an outlier, null otherwise
  OutlierWarning? checkForAttendanceOutlier(
    int newValue,
    List<WeeklyRecord> historicalRecords,
  ) {
    if (historicalRecords.length < 4) {
      // Not enough data for outlier detection
      return null;
    }

    final attendanceValues = historicalRecords
        .map((r) => r.totalAttendance.toDouble())
        .toList();
    final stats = _calculateStats(attendanceValues);

    if (stats == null) return null;

    final mean = stats['mean']!;
    final stdDev = stats['stdDev']!;
    final lowerBound = mean - (2 * stdDev);
    final upperBound = mean + (2 * stdDev);

    if (newValue < lowerBound) {
      return OutlierWarning(
        fieldName: 'Total Attendance',
        value: newValue.toDouble(),
        expectedRange: '${lowerBound.round()} - ${upperBound.round()}',
        message:
            'Attendance ($newValue) is unusually low compared to historical average (${mean.round()})',
        type: OutlierType.low,
      );
    } else if (newValue > upperBound) {
      return OutlierWarning(
        fieldName: 'Total Attendance',
        value: newValue.toDouble(),
        expectedRange: '${lowerBound.round()} - ${upperBound.round()}',
        message:
            'Attendance ($newValue) is unusually high compared to historical average (${mean.round()})',
        type: OutlierType.high,
      );
    }

    return null;
  }

  /// Check if income appears to be an outlier compared to historical data
  OutlierWarning? checkForIncomeOutlier(
    double newValue,
    List<WeeklyRecord> historicalRecords,
  ) {
    if (historicalRecords.length < 4) {
      return null;
    }

    final incomeValues = historicalRecords.map((r) => r.totalIncome).toList();
    final stats = _calculateStats(incomeValues);

    if (stats == null) return null;

    final mean = stats['mean']!;
    final stdDev = stats['stdDev']!;
    final lowerBound = mean - (2 * stdDev);
    final upperBound = mean + (2 * stdDev);

    if (newValue < lowerBound) {
      return OutlierWarning(
        fieldName: 'Total Income',
        value: newValue,
        expectedRange:
            '\$${lowerBound.toStringAsFixed(0)} - \$${upperBound.toStringAsFixed(0)}',
        message:
            'Income (\$${newValue.toStringAsFixed(0)}) is unusually low compared to historical average (\$${mean.toStringAsFixed(0)})',
        type: OutlierType.low,
      );
    } else if (newValue > upperBound) {
      return OutlierWarning(
        fieldName: 'Total Income',
        value: newValue,
        expectedRange:
            '\$${lowerBound.toStringAsFixed(0)} - \$${upperBound.toStringAsFixed(0)}',
        message:
            'Income (\$${newValue.toStringAsFixed(0)}) is unusually high compared to historical average (\$${mean.toStringAsFixed(0)})',
        type: OutlierType.high,
      );
    }

    return null;
  }

  /// Validate CSV schema - ensure all required columns are mapped
  CsvSchemaValidationResult validateCsvSchema(
    List<String> headers,
    Map<String, int> columnMapping,
  ) {
    final missingFields = <String>[];
    final mappedFields = <String>[];

    for (final field in requiredCsvFields) {
      if (!columnMapping.containsKey(field) || columnMapping[field] == null) {
        missingFields.add(field);
      } else {
        mappedFields.add(field);
      }
    }

    if (missingFields.isNotEmpty) {
      return CsvSchemaValidationResult(
        isValid: false,
        missingFields: missingFields,
        mappedFields: mappedFields,
        errorMessage:
            'Missing required columns: ${_formatFieldNames(missingFields)}',
      );
    }

    // Check for duplicate column indices
    final indices = columnMapping.values.toSet();
    if (indices.length != columnMapping.length) {
      return CsvSchemaValidationResult(
        isValid: false,
        missingFields: [],
        mappedFields: mappedFields,
        errorMessage: 'Multiple fields mapped to the same column',
      );
    }

    return CsvSchemaValidationResult(
      isValid: true,
      missingFields: [],
      mappedFields: mappedFields,
      errorMessage: null,
    );
  }

  /// Format field names for display
  String _formatFieldNames(List<String> fields) {
    final formatted = fields.map((f) {
      // Convert camelCase to Title Case
      return f
          .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
          .trim()
          .split(' ')
          .map(
            (w) => w.isNotEmpty
                ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
                : '',
          )
          .join(' ');
    });
    return formatted.join(', ');
  }

  /// Calculate basic statistics for outlier detection
  Map<String, double>? _calculateStats(List<double> values) {
    if (values.isEmpty) return null;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => (v - mean) * (v - mean));
    final variance = squaredDiffs.reduce((a, b) => a + b) / values.length;
    final stdDev = variance > 0 ? variance.sqrt() : 0.0;

    return {
      'mean': mean,
      'stdDev': stdDev,
      'min': values.reduce((a, b) => a < b ? a : b),
      'max': values.reduce((a, b) => a > b ? a : b),
    };
  }
}

/// Extension to calculate square root
extension on double {
  double sqrt() {
    if (this < 0) return 0;
    double guess = this / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + this / guess) / 2;
    }
    return guess;
  }
}

/// Result of CSV schema validation
class CsvSchemaValidationResult {
  final bool isValid;
  final List<String> missingFields;
  final List<String> mappedFields;
  final String? errorMessage;

  CsvSchemaValidationResult({
    required this.isValid,
    required this.missingFields,
    required this.mappedFields,
    this.errorMessage,
  });
}

/// Represents an outlier warning for a field
class OutlierWarning {
  final String fieldName;
  final double value;
  final String expectedRange;
  final String message;
  final OutlierType type;

  OutlierWarning({
    required this.fieldName,
    required this.value,
    required this.expectedRange,
    required this.message,
    required this.type,
  });
}

/// Type of outlier
enum OutlierType { high, low }
