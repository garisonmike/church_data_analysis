import 'dart:convert';
import 'dart:io';

import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/services/validation_service.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

/// Service for importing weekly records from CSV files
class CsvImportService {
  final ValidationService _validationService = ValidationService();

  /// Pick a CSV file from the device
  Future<File?> pickCsvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }

    return null;
  }

  /// Parse CSV file and return raw data as list of lists
  Future<CsvParseResult> parseCsvFile(File file) async {
    try {
      final input = await file.readAsString(encoding: utf8);
      final fields = const CsvToListConverter().convert(input);

      if (fields.isEmpty) {
        return CsvParseResult.error('CSV file is empty');
      }

      // First row is assumed to be headers
      final headers = fields.first.map((e) => e.toString().trim()).toList();
      final rows = fields.skip(1).toList();

      return CsvParseResult.success(headers, rows);
    } catch (e) {
      return CsvParseResult.error('Failed to parse CSV: ${e.toString()}');
    }
  }

  /// Validate and convert row data to WeeklyRecord
  WeeklyRecordImportResult validateAndConvertRow(
    List<dynamic> row,
    Map<String, int> columnMapping,
    int churchId,
    int rowNumber,
    int? adminId,
  ) {
    final errors = <String>[];

    try {
      // Helper to get value from row
      dynamic getValue(String fieldName) {
        final index = columnMapping[fieldName];
        if (index == null || index >= row.length) {
          return null;
        }
        final value = row[index];
        return value?.toString().trim();
      }

      // Parse date
      final dateStr = getValue('weekStartDate');
      if (dateStr == null || dateStr.isEmpty) {
        errors.add('Week start date is required');
      }
      DateTime? weekStartDate;
      try {
        weekStartDate = DateTime.parse(dateStr);
      } catch (e) {
        errors.add('Invalid date format. Expected: YYYY-MM-DD');
      }

      // Parse attendance fields
      int? parseIntField(String fieldName, String label) {
        final valueStr = getValue(fieldName);
        if (valueStr == null || valueStr.isEmpty) {
          errors.add('$label is required');
          return null;
        }
        final value = int.tryParse(valueStr);
        if (value == null) {
          errors.add('$label must be a valid integer');
          return null;
        }
        if (value < 0) {
          errors.add('$label must be positive');
          return null;
        }
        return value;
      }

      // Parse financial fields
      double? parseDoubleField(String fieldName, String label) {
        final valueStr = getValue(fieldName);
        if (valueStr == null || valueStr.isEmpty) {
          errors.add('$label is required');
          return null;
        }
        final value = double.tryParse(valueStr);
        if (value == null) {
          errors.add('$label must be a valid number');
          return null;
        }
        if (value < 0) {
          errors.add('$label must be positive');
          return null;
        }
        return value;
      }

      final men = parseIntField('men', 'Men attendance');
      final women = parseIntField('women', 'Women attendance');
      final youth = parseIntField('youth', 'Youth attendance');
      final children = parseIntField('children', 'Children attendance');
      final sundayHomeChurch = parseIntField(
        'sundayHomeChurch',
        'Sunday Home Church attendance',
      );

      final tithe = parseDoubleField('tithe', 'Tithe');
      final offerings = parseDoubleField('offerings', 'Offerings');
      final emergencyCollection = parseDoubleField(
        'emergencyCollection',
        'Emergency Collection',
      );
      final plannedCollection = parseDoubleField(
        'plannedCollection',
        'Planned Collection',
      );

      if (errors.isNotEmpty) {
        return WeeklyRecordImportResult.error(rowNumber, errors);
      }

      final now = DateTime.now();
      final record = WeeklyRecord(
        churchId: churchId,
        createdByAdminId: adminId,
        weekStartDate: weekStartDate!,
        men: men!,
        women: women!,
        youth: youth!,
        children: children!,
        sundayHomeChurch: sundayHomeChurch!,
        tithe: tithe!,
        offerings: offerings!,
        emergencyCollection: emergencyCollection!,
        plannedCollection: plannedCollection!,
        createdAt: now,
        updatedAt: now,
      );

      return WeeklyRecordImportResult.success(rowNumber, record);
    } catch (e) {
      return WeeklyRecordImportResult.error(rowNumber, [
        'Unexpected error: ${e.toString()}',
      ]);
    }
  }

  /// Get suggested column mapping based on header names
  Map<String, int> suggestColumnMapping(List<String> headers) {
    final mapping = <String, int>{};

    // Common variations of field names
    final fieldVariations = {
      'weekStartDate': [
        'date',
        'week',
        'weekdate',
        'week_start_date',
        'week_date',
        'startdate',
      ],
      'men': ['men', 'male', 'males', 'men_attendance'],
      'women': ['women', 'female', 'females', 'women_attendance'],
      'youth': ['youth', 'youths', 'youth_attendance', 'teenagers'],
      'children': ['children', 'kids', 'children_attendance'],
      'sundayHomeChurch': [
        'sundayhomechurch',
        'sunday_home_church',
        'home_church',
        'shc',
      ],
      'tithe': ['tithe', 'tithes', 'tithing'],
      'offerings': ['offerings', 'offering', 'offertory'],
      'emergencyCollection': [
        'emergencycollection',
        'emergency_collection',
        'emergency',
      ],
      'plannedCollection': [
        'plannedcollection',
        'planned_collection',
        'planned',
      ],
    };

    for (final entry in fieldVariations.entries) {
      final fieldName = entry.key;
      final variations = entry.value;

      for (var i = 0; i < headers.length; i++) {
        final header = headers[i].toLowerCase().replaceAll(' ', '');
        if (variations.contains(header)) {
          mapping[fieldName] = i;
          break;
        }
      }
    }

    return mapping;
  }

  /// Validate that the CSV schema has all required columns mapped
  CsvSchemaValidationResult validateSchema(
    List<String> headers,
    Map<String, int> columnMapping,
  ) {
    return _validationService.validateCsvSchema(headers, columnMapping);
  }
}

/// Result of CSV parsing
class CsvParseResult {
  final bool success;
  final String? error;
  final List<String>? headers;
  final List<List<dynamic>>? rows;

  CsvParseResult.success(this.headers, this.rows)
    : success = true,
      error = null;

  CsvParseResult.error(this.error)
    : success = false,
      headers = null,
      rows = null;
}

/// Result of importing a single row
class WeeklyRecordImportResult {
  final int rowNumber;
  final bool success;
  final WeeklyRecord? record;
  final List<String>? errors;

  WeeklyRecordImportResult.success(this.rowNumber, this.record)
    : success = true,
      errors = null;

  WeeklyRecordImportResult.error(this.rowNumber, this.errors)
    : success = false,
      record = null;
}
