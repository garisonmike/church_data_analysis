import 'dart:io';

import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/services/csv_export_service.dart';
import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  late CsvExportService service;
  late Directory tempDir;

  setUp(() async {
    service = CsvExportService();
    tempDir = await Directory.systemTemp.createTemp('csv_export_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('CsvExportService', () {
    group('generateExportFilename', () {
      test('should generate filename with timestamp', () {
        final filename = service.generateExportFilename('test');
        expect(filename, startsWith('test_'));
        expect(filename, endsWith('.csv'));
        expect(filename.length, greaterThan(15));
      });

      test('should generate unique filenames', () async {
        final filename1 = service.generateExportFilename('test');
        await Future.delayed(const Duration(seconds: 1));
        final filename2 = service.generateExportFilename('test');
        expect(filename1, isNot(equals(filename2)));
      });
    });

    group('weeklyRecordToRow', () {
      test('should convert WeeklyRecord to CSV row', () {
        final record = WeeklyRecord(
          id: 1,
          churchId: 10,
          createdByAdminId: 5,
          weekStartDate: DateTime(2025, 1, 5),
          men: 50,
          women: 60,
          youth: 30,
          children: 20,
          sundayHomeChurch: 10,
          tithe: 1000.0,
          offerings: 500.0,
          emergencyCollection: 100.0,
          plannedCollection: 200.0,
          createdAt: DateTime(2025, 1, 5, 10, 0),
          updatedAt: DateTime(2025, 1, 5, 10, 0),
        );

        final row = service.weeklyRecordToRow(record);

        expect(row[0], equals(1)); // id
        expect(row[1], equals(10)); // church_id
        expect(row[2], equals(5)); // created_by_admin_id
        expect(row[4], equals(50)); // men
        expect(row[5], equals(60)); // women
        expect(row[6], equals(30)); // youth
        expect(row[7], equals(20)); // children
        expect(row[8], equals(10)); // sunday_home_church
        expect(row[9], equals(170)); // total_attendance
        expect(row[10], equals(1000.0)); // tithe
        expect(row[11], equals(500.0)); // offerings
        expect(row[14], equals(1800.0)); // total_income
      });

      test('should handle null values', () {
        final record = WeeklyRecord(
          churchId: 10,
          weekStartDate: DateTime(2025, 1, 5),
          men: 50,
          women: 60,
          youth: 30,
          children: 20,
          sundayHomeChurch: 10,
          tithe: 1000.0,
          offerings: 500.0,
          emergencyCollection: 100.0,
          plannedCollection: 200.0,
          createdAt: DateTime(2025, 1, 5, 10, 0),
          updatedAt: DateTime(2025, 1, 5, 10, 0),
        );

        final row = service.weeklyRecordToRow(record);

        expect(row[0], equals('')); // id is null
        expect(row[2], equals('')); // created_by_admin_id is null
      });
    });

    group('churchToRow', () {
      test('should convert Church to CSV row', () {
        final church = Church(
          id: 1,
          name: 'Test Church',
          address: '123 Main St',
          contactPhone: '555-1234',
          contactEmail: 'test@church.com',
          currency: 'USD',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final row = service.churchToRow(church);

        expect(row[0], equals(1));
        expect(row[1], equals('Test Church'));
        expect(row[2], equals('123 Main St'));
        expect(row[3], equals('555-1234'));
        expect(row[4], equals('test@church.com'));
        expect(row[5], equals('USD'));
      });

      test('should handle null optional fields', () {
        final church = Church(
          id: 1,
          name: 'Test Church',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final row = service.churchToRow(church);

        expect(row[2], equals('')); // address is null
        expect(row[3], equals('')); // contactPhone is null
        expect(row[4], equals('')); // contactEmail is null
        expect(row[5], equals('USD')); // currency has default
      });
    });

    group('adminUserToRow', () {
      test('should convert AdminUser to CSV row', () {
        final admin = AdminUser(
          id: 1,
          username: 'testadmin',
          fullName: 'Test Admin',
          email: 'admin@test.com',
          churchId: 10,
          isActive: true,
          createdAt: DateTime(2025, 1, 1),
          lastLoginAt: DateTime(2025, 1, 15),
        );

        final row = service.adminUserToRow(admin);

        expect(row[0], equals(1));
        expect(row[1], equals('testadmin'));
        expect(row[2], equals('Test Admin'));
        expect(row[3], equals('admin@test.com'));
        expect(row[4], equals(10));
        expect(row[5], equals('true'));
      });

      test('should convert inactive admin correctly', () {
        final admin = AdminUser(
          id: 1,
          username: 'testadmin',
          fullName: 'Test Admin',
          churchId: 10,
          isActive: false,
          createdAt: DateTime(2025, 1, 1),
          lastLoginAt: DateTime(2025, 1, 15),
        );

        final row = service.adminUserToRow(admin);
        expect(row[5], equals('false'));
      });
    });

    group('exportWeeklyRecords', () {
      test('should export records to CSV file', () async {
        final records = [
          WeeklyRecord(
            id: 1,
            churchId: 10,
            weekStartDate: DateTime(2025, 1, 5),
            men: 50,
            women: 60,
            youth: 30,
            children: 20,
            sundayHomeChurch: 10,
            tithe: 1000.0,
            offerings: 500.0,
            emergencyCollection: 100.0,
            plannedCollection: 200.0,
            createdAt: DateTime(2025, 1, 5),
            updatedAt: DateTime(2025, 1, 5),
          ),
          WeeklyRecord(
            id: 2,
            churchId: 10,
            weekStartDate: DateTime(2025, 1, 12),
            men: 55,
            women: 65,
            youth: 35,
            children: 25,
            sundayHomeChurch: 12,
            tithe: 1100.0,
            offerings: 550.0,
            emergencyCollection: 110.0,
            plannedCollection: 220.0,
            createdAt: DateTime(2025, 1, 12),
            updatedAt: DateTime(2025, 1, 12),
          ),
        ];

        final filePath = path.join(tempDir.path, 'weekly_records.csv');
        final result = await service.exportWeeklyRecords(
          records,
          customPath: filePath,
        );

        expect(result.success, isTrue);
        expect(result.recordCount, equals(2));
        expect(result.filePath, equals(filePath));

        // Verify file contents
        final file = File(filePath);
        expect(await file.exists(), isTrue);

        final content = await file.readAsString();
        final parsed = const CsvToListConverter().convert(content);
        expect(parsed.length, equals(3)); // header + 2 records
        expect(parsed[0], equals(CsvExportService.weeklyRecordHeaders));
      });

      test('should return error for empty records list', () async {
        final result = await service.exportWeeklyRecords([]);
        expect(result.success, isFalse);
        expect(result.error, contains('No records to export'));
      });
    });

    group('exportChurches', () {
      test('should export churches to CSV file', () async {
        final churches = [
          Church(
            id: 1,
            name: 'Church A',
            address: '123 Main St',
            createdAt: DateTime(2025, 1, 1),
            updatedAt: DateTime(2025, 1, 1),
          ),
          Church(
            id: 2,
            name: 'Church B',
            address: '456 Oak Ave',
            createdAt: DateTime(2025, 1, 2),
            updatedAt: DateTime(2025, 1, 2),
          ),
        ];

        final filePath = path.join(tempDir.path, 'churches.csv');
        final result = await service.exportChurches(
          churches,
          customPath: filePath,
        );

        expect(result.success, isTrue);
        expect(result.recordCount, equals(2));

        final file = File(filePath);
        final content = await file.readAsString();
        final parsed = const CsvToListConverter().convert(content);
        expect(parsed.length, equals(3));
        expect(parsed[0], equals(CsvExportService.churchHeaders));
      });

      test('should return error for empty churches list', () async {
        final result = await service.exportChurches([]);
        expect(result.success, isFalse);
        expect(result.error, contains('No churches to export'));
      });
    });

    group('exportAdminUsers', () {
      test('should export admin users to CSV file', () async {
        final admins = [
          AdminUser(
            id: 1,
            username: 'admin1',
            fullName: 'Admin One',
            churchId: 10,
            isActive: true,
            createdAt: DateTime(2025, 1, 1),
            lastLoginAt: DateTime(2025, 1, 15),
          ),
        ];

        final filePath = path.join(tempDir.path, 'admins.csv');
        final result = await service.exportAdminUsers(
          admins,
          customPath: filePath,
        );

        expect(result.success, isTrue);
        expect(result.recordCount, equals(1));

        final file = File(filePath);
        final content = await file.readAsString();
        final parsed = const CsvToListConverter().convert(content);
        expect(parsed.length, equals(2));
        expect(parsed[0], equals(CsvExportService.adminUserHeaders));
      });

      test('should return error for empty admins list', () async {
        final result = await service.exportAdminUsers([]);
        expect(result.success, isFalse);
        expect(result.error, contains('No admin users to export'));
      });
    });

    group('exportAll', () {
      test('should export all data types', () async {
        final records = [
          WeeklyRecord(
            id: 1,
            churchId: 10,
            weekStartDate: DateTime(2025, 1, 5),
            men: 50,
            women: 60,
            youth: 30,
            children: 20,
            sundayHomeChurch: 10,
            tithe: 1000.0,
            offerings: 500.0,
            emergencyCollection: 100.0,
            plannedCollection: 200.0,
            createdAt: DateTime(2025, 1, 5),
            updatedAt: DateTime(2025, 1, 5),
          ),
        ];

        final churches = [
          Church(
            id: 1,
            name: 'Test Church',
            createdAt: DateTime(2025, 1, 1),
            updatedAt: DateTime(2025, 1, 1),
          ),
        ];

        final admins = [
          AdminUser(
            id: 1,
            username: 'admin',
            fullName: 'Test Admin',
            churchId: 1,
            isActive: true,
            createdAt: DateTime(2025, 1, 1),
            lastLoginAt: DateTime(2025, 1, 15),
          ),
        ];

        final results = await service.exportAll(
          records: records,
          churches: churches,
          admins: admins,
          exportDirectory: tempDir.path,
        );

        expect(results['weekly_records']!.success, isTrue);
        expect(results['churches']!.success, isTrue);
        expect(results['admin_users']!.success, isTrue);

        // Verify files were created
        final files = await tempDir.list().toList();
        expect(files.length, equals(3));
      });

      test('should handle empty data gracefully', () async {
        final results = await service.exportAll(
          records: [],
          churches: [],
          admins: [],
          exportDirectory: tempDir.path,
        );

        expect(results['weekly_records']!.success, isFalse);
        expect(results['churches']!.success, isFalse);
        expect(results['admin_users']!.success, isFalse);
      });
    });

    group('verifyCsvExport', () {
      test('should return true for valid CSV file', () async {
        final filePath = path.join(tempDir.path, 'test.csv');
        final file = File(filePath);
        await file.writeAsString('header1,header2\nvalue1,value2');

        final result = await service.verifyCsvExport(filePath);
        expect(result, isTrue);
      });

      test('should return false for non-existent file', () async {
        final result = await service.verifyCsvExport('/nonexistent/file.csv');
        expect(result, isFalse);
      });

      test('should return false for empty file', () async {
        final filePath = path.join(tempDir.path, 'empty.csv');
        final file = File(filePath);
        await file.writeAsString('');

        final result = await service.verifyCsvExport(filePath);
        expect(result, isFalse);
      });
    });

    group('parseWeeklyRecordsCsv', () {
      test('should parse CSV content back to WeeklyRecord objects', () async {
        // Create a record and export it first
        final originalRecord = WeeklyRecord(
          id: 1,
          churchId: 10,
          createdByAdminId: 5,
          weekStartDate: DateTime(2025, 1, 5),
          men: 50,
          women: 60,
          youth: 30,
          children: 20,
          sundayHomeChurch: 10,
          tithe: 1000.0,
          offerings: 500.0,
          emergencyCollection: 100.0,
          plannedCollection: 200.0,
          createdAt: DateTime(2025, 1, 5, 10, 0),
          updatedAt: DateTime(2025, 1, 5, 10, 0),
        );

        // Export to CSV
        final filePath = path.join(tempDir.path, 'round_trip.csv');
        await service.exportWeeklyRecords([
          originalRecord,
        ], customPath: filePath);

        // Read back the CSV content
        final csvContent = await File(filePath).readAsString();

        // Parse it back
        final records = service.parseWeeklyRecordsCsv(csvContent, 10);

        expect(records.length, equals(1));
        expect(records[0].men, equals(50));
        expect(records[0].women, equals(60));
        expect(records[0].tithe, equals(1000.0));
      });

      test('should return empty list for header-only CSV', () {
        const csvContent = 'id,church_id,created_by_admin_id';
        final records = service.parseWeeklyRecordsCsv(csvContent, 10);
        expect(records, isEmpty);
      });
    });
  });
}
