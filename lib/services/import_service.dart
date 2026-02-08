import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/platform/file_storage.dart';
import 'package:church_analytics/platform/file_storage_interface.dart';
import 'package:church_analytics/services/validation_service.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

/// Service for importing weekly records from CSV or XLSX files
class ImportService {
  final ValidationService _validationService = ValidationService();
  final FileStorage _fileStorage;

  ImportService({FileStorage? fileStorage})
    : _fileStorage = fileStorage ?? getFileStorage();

  /// Pick a CSV or XLSX file from the device
  Future<PlatformFileResult?> pickFile() async {
    return _fileStorage.pickFile(allowedExtensions: ['csv', 'xlsx']);
  }
  
  /// Parse file and return raw data as list of lists
  Future<ParseResult> parseFile(PlatformFileResult file) async {
    if (file.name.toLowerCase().endsWith('.csv')) {
      return _parseCsvFile(file);
    } else if (file.name.toLowerCase().endsWith('.xlsx')) {
      return _parseXlsxFile(file);
    } else {
      return ParseResult.error('Unsupported file type. Please select a .csv or .xlsx file.');
    }
  }

  /// Parse CSV file and return raw data as list of lists
  Future<ParseResult> _parseCsvFile(PlatformFileResult file) async {
    try {
      final input = await _fileStorage.readFileAsString(file);
      final normalized = input
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n')
          // Handle UTF-8 BOM if present
          .replaceFirst('\uFEFF', '');

      final fields = const CsvToListConverter(eol: '\n').convert(normalized);

      if (fields.isEmpty) {
        return ParseResult.error('CSV file is empty');
      }

      // First row is assumed to be headers
      final headers = fields.first.map((e) => e.toString().trim()).toList();
      final rows = fields.skip(1).toList();

      return ParseResult.success(headers, rows);
    } catch (e) {
      return ParseResult.error('Failed to parse CSV: ${e.toString()}');
    }
  }

  /// Parse XLSX file and return raw data as list of lists
  Future<ParseResult> _parseXlsxFile(PlatformFileResult file) async {
    try {
      final bytes = await _fileStorage.readFileAsBytes(file);
      final excel = Excel.decodeBytes(bytes);

      if (excel.tables.keys.isEmpty) {
        return ParseResult.error('XLSX file contains no sheets');
      }

      final sheet = excel.tables[excel.tables.keys.first]!;
      if (sheet.rows.isEmpty) {
        return ParseResult.error('XLSX sheet is empty');
      }
      
      final headers = sheet.rows.first.map((e) => e?.value.toString().trim() ?? '').toList();
      final rows = sheet.rows.skip(1).map((row) {
        return row.map((cell) => cell?.value).toList();
      }).toList();

      return ParseResult.success(headers, rows);
    } catch (e) {
      return ParseResult.error('Failed to parse XLSX: ${e.toString()}');
    }
  }

  /// Validate and convert row data to WeeklyRecord
  WeeklyRecordImportResult validateAndConvertRow(
    List<dynamic> row,
    Map<String, int> columnMapping,
    int churchId,
    int rowNumber,
    int? adminId,
    Set<String> optionalFields,
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
      int? parseIntField(
        String fieldName,
        String label, {
        bool required = true,
      }) {
        final valueStr = getValue(fieldName);
        if (valueStr == null || valueStr.isEmpty) {
          if (required) {
            errors.add('$label is required');
            return null;
          }
          return 0;
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
      double? parseDoubleField(
        String fieldName,
        String label, {
        bool required = true,
      }) {
        final valueStr = getValue(fieldName);
        if (valueStr == null || valueStr.isEmpty) {
          if (required) {
            errors.add('$label is required');
            return null;
          }
          return 0;
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
        required: !optionalFields.contains('emergencyCollection'),
      );
      final plannedCollection = parseDoubleField(
        'plannedCollection',
        'Planned Collection',
        required: !optionalFields.contains('plannedCollection'),
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
        'week_date',
        'startdate',
      ],
      'men': ['men', 'male', 'males', 'men_attendance'],
      'women': ['women', 'female', 'females', 'women_attendance'],
      'youth': ['youth', 'youths', 'youth_attendance', 'teenagers'],
      'children': ['children', 'kids', 'children_attendance'],
      'sundayHomeChurch': [
        'sundayhomechurch',
        'home_church',
        'shc',
      ],
      'tithe': ['tithe', 'tithes', 'tithing'],
      'offerings': ['offerings', 'offering', 'offertory'],
      'emergencyCollection': [
        'emergencycollection',
        'emergency',
      ],
      'plannedCollection': [
        'plannedcollection',
        'planned',
      ],
    };

    final allFields = fieldVariations.keys.toList();
    final cleanedHeaders = headers
        .map((h) => h.toLowerCase().replaceAll(' ', '').replaceAll('_', ''))
        .toList();

    for (final fieldName in allFields) {
      // 1. Prioritize exact match (after cleaning)
      var headerIndex = cleanedHeaders.indexOf(fieldName.toLowerCase());

      // 2. If no exact match, check common variations
      if (headerIndex == -1) {
        for (final variation in fieldVariations[fieldName]!) {
          final variationIndex = cleanedHeaders.indexOf(variation);
          if (variationIndex != -1) {
            headerIndex = variationIndex;
            break;
          }
        }
      }
      
      if (headerIndex != -1) {
        // Ensure the same header is not used for multiple fields
        if (!mapping.containsValue(headerIndex)) {
            mapping[fieldName] = headerIndex;
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

/// Result of parsing
class ParseResult {
  final bool success;
  final String? error;
  final List<String>? headers;
  final List<List<dynamic>>? rows;

  ParseResult.success(this.headers, this.rows)
    : success = true,
      error = null;

  ParseResult.error(this.error)
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
