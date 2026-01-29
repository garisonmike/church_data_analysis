import 'dart:convert';
import 'dart:io';

import 'package:church_analytics/models/models.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

/// Result of a CSV export operation
class CsvExportResult {
  final bool success;
  final String? filePath;
  final String? error;
  final int recordCount;

  const CsvExportResult._({
    required this.success,
    this.filePath,
    this.error,
    this.recordCount = 0,
  });

  factory CsvExportResult.success(String filePath, int recordCount) {
    return CsvExportResult._(
      success: true,
      filePath: filePath,
      recordCount: recordCount,
    );
  }

  factory CsvExportResult.error(String error) {
    return CsvExportResult._(success: false, error: error);
  }
}

/// Service for exporting data to CSV files
class CsvExportService {
  /// CSV headers for weekly records export
  static const List<String> weeklyRecordHeaders = [
    'id',
    'church_id',
    'created_by_admin_id',
    'week_start_date',
    'men',
    'women',
    'youth',
    'children',
    'sunday_home_church',
    'total_attendance',
    'tithe',
    'offerings',
    'emergency_collection',
    'planned_collection',
    'total_income',
    'created_at',
    'updated_at',
  ];

  /// CSV headers for churches export
  static const List<String> churchHeaders = [
    'id',
    'name',
    'address',
    'contact_phone',
    'contact_email',
    'currency',
    'created_at',
    'updated_at',
  ];

  /// CSV headers for admin users export
  static const List<String> adminUserHeaders = [
    'id',
    'username',
    'full_name',
    'email',
    'church_id',
    'is_active',
    'created_at',
    'last_login_at',
  ];

  /// Get the export directory path
  Future<Directory> getExportDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${appDir.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  /// Generate a timestamped filename for exports
  String generateExportFilename(String prefix) {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return '${prefix}_$timestamp.csv';
  }

  /// Convert a WeeklyRecord to a CSV row
  List<dynamic> weeklyRecordToRow(WeeklyRecord record) {
    return [
      record.id ?? '',
      record.churchId,
      record.createdByAdminId ?? '',
      record.weekStartDate.toIso8601String(),
      record.men,
      record.women,
      record.youth,
      record.children,
      record.sundayHomeChurch,
      record.totalAttendance,
      record.tithe,
      record.offerings,
      record.emergencyCollection,
      record.plannedCollection,
      record.totalIncome,
      record.createdAt.toIso8601String(),
      record.updatedAt.toIso8601String(),
    ];
  }

  /// Convert a Church to a CSV row
  List<dynamic> churchToRow(Church church) {
    return [
      church.id ?? '',
      church.name,
      church.address ?? '',
      church.contactPhone ?? '',
      church.contactEmail ?? '',
      church.currency,
      church.createdAt.toIso8601String(),
      church.updatedAt.toIso8601String(),
    ];
  }

  /// Convert an AdminUser to a CSV row
  List<dynamic> adminUserToRow(AdminUser admin) {
    return [
      admin.id ?? '',
      admin.username,
      admin.fullName,
      admin.email ?? '',
      admin.churchId,
      admin.isActive ? 'true' : 'false',
      admin.createdAt.toIso8601String(),
      admin.lastLoginAt.toIso8601String(),
    ];
  }

  /// Export weekly records to CSV
  Future<CsvExportResult> exportWeeklyRecords(
    List<WeeklyRecord> records, {
    String? customPath,
  }) async {
    if (records.isEmpty) {
      return CsvExportResult.error('No records to export');
    }

    try {
      final rows = <List<dynamic>>[
        weeklyRecordHeaders,
        ...records.map(weeklyRecordToRow),
      ];

      final csv = const ListToCsvConverter().convert(rows);
      final filePath =
          customPath ?? await _getDefaultFilePath('weekly_records');
      final file = File(filePath);
      await file.writeAsString(csv, encoding: utf8);

      return CsvExportResult.success(filePath, records.length);
    } catch (e) {
      return CsvExportResult.error('Failed to export weekly records: $e');
    }
  }

  /// Export churches to CSV
  Future<CsvExportResult> exportChurches(
    List<Church> churches, {
    String? customPath,
  }) async {
    if (churches.isEmpty) {
      return CsvExportResult.error('No churches to export');
    }

    try {
      final rows = <List<dynamic>>[churchHeaders, ...churches.map(churchToRow)];

      final csv = const ListToCsvConverter().convert(rows);
      final filePath = customPath ?? await _getDefaultFilePath('churches');
      final file = File(filePath);
      await file.writeAsString(csv, encoding: utf8);

      return CsvExportResult.success(filePath, churches.length);
    } catch (e) {
      return CsvExportResult.error('Failed to export churches: $e');
    }
  }

  /// Export admin users to CSV
  Future<CsvExportResult> exportAdminUsers(
    List<AdminUser> admins, {
    String? customPath,
  }) async {
    if (admins.isEmpty) {
      return CsvExportResult.error('No admin users to export');
    }

    try {
      final rows = <List<dynamic>>[
        adminUserHeaders,
        ...admins.map(adminUserToRow),
      ];

      final csv = const ListToCsvConverter().convert(rows);
      final filePath = customPath ?? await _getDefaultFilePath('admin_users');
      final file = File(filePath);
      await file.writeAsString(csv, encoding: utf8);

      return CsvExportResult.success(filePath, admins.length);
    } catch (e) {
      return CsvExportResult.error('Failed to export admin users: $e');
    }
  }

  /// Export all data to multiple CSV files
  /// Returns a map of export type to result
  Future<Map<String, CsvExportResult>> exportAll({
    required List<WeeklyRecord> records,
    required List<Church> churches,
    required List<AdminUser> admins,
    String? exportDirectory,
  }) async {
    final results = <String, CsvExportResult>{};
    final exportDir = exportDirectory ?? (await getExportDirectory()).path;

    // Export weekly records
    if (records.isNotEmpty) {
      final recordsPath =
          '$exportDir/${generateExportFilename('weekly_records')}';
      results['weekly_records'] = await exportWeeklyRecords(
        records,
        customPath: recordsPath,
      );
    } else {
      results['weekly_records'] = CsvExportResult.error('No records to export');
    }

    // Export churches
    if (churches.isNotEmpty) {
      final churchesPath = '$exportDir/${generateExportFilename('churches')}';
      results['churches'] = await exportChurches(
        churches,
        customPath: churchesPath,
      );
    } else {
      results['churches'] = CsvExportResult.error('No churches to export');
    }

    // Export admin users
    if (admins.isNotEmpty) {
      final adminsPath = '$exportDir/${generateExportFilename('admin_users')}';
      results['admin_users'] = await exportAdminUsers(
        admins,
        customPath: adminsPath,
      );
    } else {
      results['admin_users'] = CsvExportResult.error(
        'No admin users to export',
      );
    }

    return results;
  }

  /// Convert CSV string to list of WeeklyRecord objects (for import verification)
  List<WeeklyRecord> parseWeeklyRecordsCsv(String csvContent, int churchId) {
    final fields = const CsvToListConverter().convert(csvContent);
    if (fields.length <= 1) return [];

    // Skip header row
    return fields.skip(1).map((row) {
      return WeeklyRecord(
        id: row[0] != '' ? int.tryParse(row[0].toString()) : null,
        churchId: churchId,
        createdByAdminId: row[2] != '' ? int.tryParse(row[2].toString()) : null,
        weekStartDate: DateTime.parse(row[3].toString()),
        men: int.parse(row[4].toString()),
        women: int.parse(row[5].toString()),
        youth: int.parse(row[6].toString()),
        children: int.parse(row[7].toString()),
        sundayHomeChurch: int.parse(row[8].toString()),
        tithe: double.parse(row[10].toString()),
        offerings: double.parse(row[11].toString()),
        emergencyCollection: double.parse(row[12].toString()),
        plannedCollection: double.parse(row[13].toString()),
        createdAt: DateTime.parse(row[15].toString()),
        updatedAt: DateTime.parse(row[16].toString()),
      );
    }).toList();
  }

  /// Get default file path for exports
  Future<String> _getDefaultFilePath(String prefix) async {
    final exportDir = await getExportDirectory();
    return '${exportDir.path}/${generateExportFilename(prefix)}';
  }

  /// Verify that an exported CSV file is valid
  Future<bool> verifyCsvExport(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final content = await file.readAsString();
      if (content.isEmpty) return false;

      // Try to parse as CSV
      final fields = const CsvToListConverter().convert(content);
      return fields.isNotEmpty && fields.first.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
