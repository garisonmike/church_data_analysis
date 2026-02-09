import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/platform/file_storage.dart';
import 'package:church_analytics/platform/file_storage_interface.dart';
import 'package:church_analytics/services/import_service.dart';
import 'package:csv/csv.dart';

/// Service for importing weekly records from CSV files
class CsvImportService {
  final FileStorage _fileStorage;

  CsvImportService({FileStorage? fileStorage})
    : _fileStorage = fileStorage ?? getFileStorage();

  /// Pick a CSV file from the device
  Future<PlatformFileResult?> pickFile() async {
    return _fileStorage.pickFile(allowedExtensions: ['csv']);
  }

  /// Parse CSV file and return raw data as list of lists
  Future<ParseResult> parseCsvFile(PlatformFileResult file) async {
    try {
      final input = await _fileStorage.readFileAsString(file);
      final normalized = input
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n')
          .replaceFirst('\uFEFF', '');

      final fields = const CsvToListConverter(eol: '\n').convert(normalized);

      if (fields.isEmpty) {
        return ParseResult.error('CSV file is empty');
      }

      final headers = fields.first.map((e) => e.toString().trim()).toList();
      final rows = fields.skip(1).toList();

      return ParseResult.success(headers, rows);
    } catch (e) {
      return ParseResult.error('Failed to parse CSV: ${e.toString()}');
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
      dynamic getValue(String fieldName) {
        final index = columnMapping[fieldName];
        if (index == null || index >= row.length) {
          return null;
        }
        final value = row[index];
        return value?.toString().trim();
      }

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

    final fieldVariations = {
      'weekStartDate': ['date', 'week', 'weekdate', 'week_date', 'startdate'],
      'men': ['men', 'male', 'males', 'men_attendance'],
      'women': ['women', 'female', 'females', 'women_attendance'],
      'youth': ['youth', 'youths', 'youth_attendance', 'teenagers'],
      'children': ['children', 'kids', 'children_attendance'],
      'sundayHomeChurch': ['sundayhomechurch', 'home_church', 'shc'],
      'tithe': ['tithe', 'tithes', 'tithing'],
      'offerings': ['offerings', 'offering', 'offertory'],
      'emergencyCollection': ['emergencycollection', 'emergency'],
      'plannedCollection': ['plannedcollection', 'planned'],
    };

    final allFields = fieldVariations.keys.toList();

    final cleanedHeaders = headers
        .map((h) => h.toLowerCase().replaceAll(' ', '').replaceAll('_', ''))
        .toList();

    for (final fieldName in allFields) {
      var headerIndex = cleanedHeaders.indexOf(fieldName.toLowerCase());

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
        if (!mapping.containsValue(headerIndex)) {
          mapping[fieldName] = headerIndex;
        }
      }
    }

    return mapping;
  }
}
