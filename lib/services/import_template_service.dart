import 'dart:typed_data';

import 'package:church_analytics/services/file_service.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

/// Generates and exports a ready-to-fill import template in XLSX or CSV format.
///
/// The template contains the canonical column names that [ImportService]
/// accepts, plus a populated example row so users can open it in Excel or
/// Google Sheets, delete the example row, fill in their data, and re-import
/// without guesswork.
///
/// Dependencies: `excel ^2.1.0` and `csv` — both already declared in
/// `pubspec.yaml`. No changes to `pubspec.yaml` are required.
class ImportTemplateService {
  final FileService _fileService;

  ImportTemplateService({FileService? fileService})
      : _fileService = fileService ?? FileService();

  // ---------------------------------------------------------------------------
  // Column definitions
  // ---------------------------------------------------------------------------

  /// The 12 canonical import column names, in order.
  ///
  /// These match the headers produced by [CsvExportService], so the template
  /// stays in sync with the export format automatically.
  static const List<String> templateColumns = [
    'week_start_date',
    'men',
    'women',
    'youth',
    'children',
    'sunday_home_church',
    'tithe',
    'offerings',
    'emergency_collection',
    'planned_collection',
    'baptisms',
    'holy_communion',
  ];

  /// A single example row with plausible values, aligned to [templateColumns].
  static const List<dynamic> _exampleRow = [
    '2025-01-05', // week_start_date  — ISO 8601, Sunday of the week
    120,          // men
    95,           // women
    40,           // youth
    30,           // children
    25,           // sunday_home_church
    15000.00,     // tithe
    3200.50,      // offerings
    0,            // emergency_collection  (optional, defaults to 0)
    500.00,       // planned_collection    (optional, defaults to 0)
    2,            // baptisms              (optional, defaults to 0)
    1,            // holy_communion        (count of services held; optional, defaults to 0)
  ];

  /// One explanatory note per column, used to populate the Notes sheet.
  ///
  /// Each entry is [columnName, description, example].
  static const List<List<String>> _columnNotes = [
    [
      'week_start_date',
      'Start of the week in ISO format (YYYY-MM-DD). Required. Use the Sunday of the week.',
      '2025-01-05',
    ],
    [
      'men',
      'Attendance count for men. Required. Integer, no decimals.',
      '120',
    ],
    [
      'women',
      'Attendance count for women. Required. Integer, no decimals.',
      '95',
    ],
    [
      'youth',
      'Attendance count for youth. Required. Integer, no decimals.',
      '40',
    ],
    [
      'children',
      'Attendance count for children. Required. Integer, no decimals.',
      '30',
    ],
    [
      'sunday_home_church',
      'Attendance at the Sunday Home Church service. Required. Integer.',
      '25',
    ],
    [
      'tithe',
      'Tithe income for the week. Required. Decimal, no currency symbol.',
      '15000.00',
    ],
    [
      'offerings',
      'Offerings income for the week. Required. Decimal, no currency symbol.',
      '3200.50',
    ],
    [
      'emergency_collection',
      'Emergency collection income. Optional — leave blank or enter 0 to default to 0.',
      '0',
    ],
    [
      'planned_collection',
      'Planned collection income. Optional — leave blank or enter 0 to default to 0.',
      '500.00',
    ],
    [
      'baptisms',
      'Number of baptisms that week. Optional — leave blank or enter 0 to default to 0.',
      '2',
    ],
    [
      'holy_communion',
      'Number of Holy Communion services held that week. Optional — leave blank or enter 0 to default to 0.',
      '1',
    ],
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generates a .xlsx template and writes it to the device documents directory
  /// via [FileService.exportFileBytes].
  ///
  /// Returns the absolute path where the file was saved, or null on failure.
  Future<String?> downloadXlsx() async {
    try {
      final excel = Excel.createExcel();

      // Sheet 1: Weekly Records
      const dataSheetName = 'Weekly Records';
      final dataSheet = excel[dataSheetName];
      excel.setDefaultSheet(dataSheetName);

      // Header row (bold)
      dataSheet.appendRow(templateColumns.toList());
      for (var col = 0; col < templateColumns.length; col++) {
        final cell = dataSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
        );
        cell.cellStyle = CellStyle(bold: true);
      }

      // Example data row
      dataSheet.appendRow(_exampleRow.toList());

      // Sheet 2: Notes
      const notesSheetName = 'Notes';
      final notesSheet = excel[notesSheetName];

      notesSheet.appendRow(['Column', 'Description', 'Example']);
      for (var col = 0; col < 3; col++) {
        final cell = notesSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
        );
        cell.cellStyle = CellStyle(bold: true);
      }
      for (final note in _columnNotes) {
        notesSheet.appendRow(note.toList());
      }

      // excel.save() returns List<int>?; exportFileBytes requires Uint8List.
      final rawBytes = excel.save();
      if (rawBytes == null) return null;

      final result = await _fileService.exportFileBytes(
        filename: 'church_analytics_import_template.xlsx',
        bytes: Uint8List.fromList(rawBytes),
      );

      return result.filePath;
    } catch (_) {
      return null;
    }
  }

  /// Generates a .csv template and writes it to the device documents directory
  /// via [FileService.exportFile].
  ///
  /// Returns the absolute path where the file was saved, or null on failure.
  Future<String?> downloadCsv() async {
    try {
      // exportFile accepts a String and handles encoding internally —
      // no manual utf8.encode call needed.
      final csvString = const ListToCsvConverter().convert([
        templateColumns,
        _exampleRow,
      ]);

      final result = await _fileService.exportFile(
        filename: 'church_analytics_import_template.csv',
        content: csvString,
      );

      return result.filePath;
    } catch (_) {
      return null;
    }
  }
}
