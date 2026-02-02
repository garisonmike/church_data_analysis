import 'dart:convert';
import 'dart:io';

import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/platform/file_storage_interface.dart';
import 'package:church_analytics/services/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  late BackupService service;
  late Directory tempDir;

  PlatformFileResult fileFromPath(String filePath) {
    return PlatformFileResult(name: path.basename(filePath), path: filePath);
  }

  setUp(() async {
    service = BackupService();
    tempDir = await Directory.systemTemp.createTemp('backup_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  // Test data factories
  Church createTestChurch({int? id, String name = 'Test Church'}) => Church(
    id: id,
    name: name,
    address: '123 Main St',
    contactEmail: 'test@church.com',
    contactPhone: '555-1234',
    currency: 'USD',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  AdminUser createTestAdmin({int? id, int churchId = 1}) => AdminUser(
    id: id,
    username: 'testadmin',
    fullName: 'Test Admin',
    email: 'admin@test.com',
    churchId: churchId,
    isActive: true,
    createdAt: DateTime(2025, 1, 1),
    lastLoginAt: DateTime(2025, 1, 15),
  );

  WeeklyRecord createTestRecord({int? id, int churchId = 1}) => WeeklyRecord(
    id: id,
    churchId: churchId,
    createdByAdminId: 1,
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
  );

  group('BackupService', () {
    group('generateBackupFilename', () {
      test('should generate filename with timestamp', () {
        final filename = service.generateBackupFilename();
        expect(filename, startsWith('church_backup_'));
        expect(filename, endsWith('.json'));
      });

      test('should generate unique filenames', () async {
        final f1 = service.generateBackupFilename();
        await Future.delayed(const Duration(seconds: 1));
        final f2 = service.generateBackupFilename();
        expect(f1, isNot(equals(f2)));
      });
    });

    group('churchToJson / churchFromJson', () {
      test('should convert church to JSON and back', () {
        final church = createTestChurch(id: 1);
        final json = service.churchToJson(church);
        final restored = service.churchFromJson(json);

        expect(restored.id, equals(church.id));
        expect(restored.name, equals(church.name));
        expect(restored.address, equals(church.address));
        expect(restored.contactEmail, equals(church.contactEmail));
        expect(restored.currency, equals(church.currency));
      });

      test('should handle null optional fields', () {
        final church = Church(
          id: 1,
          name: 'Minimal Church',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );
        final json = service.churchToJson(church);
        final restored = service.churchFromJson(json);

        expect(restored.address, isNull);
        expect(restored.contactEmail, isNull);
        expect(restored.contactPhone, isNull);
      });
    });

    group('adminUserToJson / adminUserFromJson', () {
      test('should convert admin to JSON and back', () {
        final admin = createTestAdmin(id: 1);
        final json = service.adminUserToJson(admin);
        final restored = service.adminUserFromJson(json);

        expect(restored.id, equals(admin.id));
        expect(restored.username, equals(admin.username));
        expect(restored.fullName, equals(admin.fullName));
        expect(restored.churchId, equals(admin.churchId));
        expect(restored.isActive, equals(admin.isActive));
      });
    });

    group('weeklyRecordToJson / weeklyRecordFromJson', () {
      test('should convert record to JSON and back', () {
        final record = createTestRecord(id: 1);
        final json = service.weeklyRecordToJson(record);
        final restored = service.weeklyRecordFromJson(json);

        expect(restored.id, equals(record.id));
        expect(restored.churchId, equals(record.churchId));
        expect(restored.men, equals(record.men));
        expect(restored.women, equals(record.women));
        expect(restored.tithe, equals(record.tithe));
        expect(restored.offerings, equals(record.offerings));
      });

      test('should handle null adminId', () {
        final record = WeeklyRecord(
          id: 1,
          churchId: 1,
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
        );
        final json = service.weeklyRecordToJson(record);
        final restored = service.weeklyRecordFromJson(json);

        expect(restored.createdByAdminId, isNull);
      });
    });

    group('createBackup', () {
      test('should create backup file with all data', () async {
        final churches = [
          createTestChurch(id: 1),
          createTestChurch(id: 2, name: 'Church 2'),
        ];
        final admins = [
          createTestAdmin(id: 1),
          createTestAdmin(id: 2, churchId: 2),
        ];
        final records = [
          createTestRecord(id: 1),
          createTestRecord(id: 2, churchId: 2),
        ];

        final customPath = path.join(tempDir.path, 'test_backup.json');
        final result = await service.createBackup(
          churches: churches,
          admins: admins,
          records: records,
          customPath: customPath,
        );

        expect(result.success, isTrue);
        expect(result.filePath, isNotNull);
        expect(result.filePath, endsWith('test_backup.json'));
        expect(result.metadata!.churchCount, equals(2));
        expect(result.metadata!.adminCount, equals(2));
        expect(result.metadata!.recordCount, equals(2));

        // Verify file exists
        expect(await File(result.filePath!).exists(), isTrue);
      });

      test('should create valid JSON structure', () async {
        final churches = [createTestChurch(id: 1)];
        final admins = [createTestAdmin(id: 1)];
        final records = [createTestRecord(id: 1)];

        final customPath = path.join(tempDir.path, 'test_backup.json');
        final result = await service.createBackup(
          churches: churches,
          admins: admins,
          records: records,
          customPath: customPath,
        );

        expect(result.success, isTrue);
        expect(result.filePath, isNotNull);

        final content = await File(result.filePath!).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;

        expect(json.containsKey('metadata'), isTrue);
        expect(json.containsKey('churches'), isTrue);
        expect(json.containsKey('adminUsers'), isTrue);
        expect(json.containsKey('weeklyRecords'), isTrue);
      });

      test('should handle empty data', () async {
        final filePath = path.join(tempDir.path, 'empty_backup.json');
        final result = await service.createBackup(
          churches: [],
          admins: [],
          records: [],
          customPath: filePath,
        );

        expect(result.success, isTrue);
        expect(result.metadata!.churchCount, equals(0));
      });
    });

    group('readBackup', () {
      test('should read valid backup file', () async {
        final churches = [createTestChurch(id: 1)];
        final admins = [createTestAdmin(id: 1)];
        final records = [createTestRecord(id: 1)];

        final filePath = path.join(tempDir.path, 'test_backup.json');
        final createResult = await service.createBackup(
          churches: churches,
          admins: admins,
          records: records,
          customPath: filePath,
        );

        expect(createResult.success, isTrue);
        expect(createResult.filePath, isNotNull);

        final backupData = await service.readBackup(
          fileFromPath(createResult.filePath!),
        );

        expect(backupData, isNotNull);
        expect(backupData!.metadata.churchCount, equals(1));
        expect(backupData.churches.length, equals(1));
        expect(backupData.adminUsers.length, equals(1));
        expect(backupData.weeklyRecords.length, equals(1));
      });

      test('should return null for non-existent file', () async {
        final result = await service.readBackup(
          fileFromPath('/nonexistent/file.json'),
        );
        expect(result, isNull);
      });
    });

    group('validateBackup', () {
      test('should return true for valid backup', () async {
        final filePath = path.join(tempDir.path, 'valid_backup.json');
        final createResult = await service.createBackup(
          churches: [createTestChurch(id: 1)],
          admins: [createTestAdmin(id: 1)],
          records: [createTestRecord(id: 1)],
          customPath: filePath,
        );

        expect(createResult.success, isTrue);
        expect(createResult.filePath, isNotNull);

        final isValid = await service.validateBackup(
          fileFromPath(createResult.filePath!),
        );
        expect(isValid, isTrue);
      });

      test('should return false for invalid JSON', () async {
        final filePath = path.join(tempDir.path, 'invalid.json');
        await File(filePath).writeAsString('not valid json');

        final isValid = await service.validateBackup(fileFromPath(filePath));
        expect(isValid, isFalse);
      });

      test('should return false for missing required fields', () async {
        final filePath = path.join(tempDir.path, 'incomplete.json');
        await File(filePath).writeAsString('{"metadata": {"version": "1.0"}}');

        final isValid = await service.validateBackup(fileFromPath(filePath));
        expect(isValid, isFalse);
      });

      test('should return false for invalid church data', () async {
        final filePath = path.join(tempDir.path, 'bad_church.json');
        final badData = {
          'metadata': {
            'version': '1.0',
            'createdAt': DateTime.now().toIso8601String(),
            'appVersion': '1.0.0',
            'churchCount': 1,
            'adminCount': 0,
            'recordCount': 0,
          },
          'churches': [
            {'invalid': 'data'},
          ], // Missing required fields
          'adminUsers': [],
          'weeklyRecords': [],
        };
        await File(filePath).writeAsString(jsonEncode(badData));

        final isValid = await service.validateBackup(fileFromPath(filePath));
        expect(isValid, isFalse);
      });
    });

    group('restoreFromBackup', () {
      test('should restore data from valid backup', () async {
        final churches = [
          createTestChurch(id: 1),
          createTestChurch(id: 2, name: 'Church 2'),
        ];
        final admins = [createTestAdmin(id: 1)];
        final records = [createTestRecord(id: 1), createTestRecord(id: 2)];

        final filePath = path.join(tempDir.path, 'restore_test.json');
        final createResult = await service.createBackup(
          churches: churches,
          admins: admins,
          records: records,
          customPath: filePath,
        );

        expect(createResult.success, isTrue);
        expect(createResult.filePath, isNotNull);

        final result = await service.restoreFromBackup(
          fileFromPath(createResult.filePath!),
        );

        expect(result.success, isTrue);
        expect(result.churchesRestored, equals(2));
        expect(result.adminsRestored, equals(1));
        expect(result.recordsRestored, equals(2));
        expect(result.totalRestored, equals(5));
      });

      test('should return error for invalid backup', () async {
        final filePath = path.join(tempDir.path, 'invalid.json');
        await File(filePath).writeAsString('invalid');

        final result = await service.restoreFromBackup(fileFromPath(filePath));

        expect(result.success, isFalse);
        expect(result.error, contains('Invalid backup'));
      });

      test('should return error for non-existent file', () async {
        final result = await service.restoreFromBackup(
          fileFromPath('/nonexistent/backup.json'),
        );
        expect(result.success, isFalse);
      });
    });

    group('getRestoreData', () {
      test('should return parsed data objects', () async {
        final churches = [createTestChurch(id: 1)];
        final admins = [createTestAdmin(id: 1)];
        final records = [createTestRecord(id: 1)];

        final filePath = path.join(tempDir.path, 'data_test.json');
        final createResult = await service.createBackup(
          churches: churches,
          admins: admins,
          records: records,
          customPath: filePath,
        );

        expect(createResult.success, isTrue);
        expect(createResult.filePath, isNotNull);

        final data = await service.getRestoreData(
          fileFromPath(createResult.filePath!),
        );

        expect(data, isNotNull);
        expect(data!.churches.length, equals(1));
        expect(data.churches.first.name, equals('Test Church'));
        expect(data.admins.length, equals(1));
        expect(data.admins.first.username, equals('testadmin'));
        expect(data.records.length, equals(1));
        expect(data.records.first.men, equals(50));
      });

      test('should return null for invalid file', () async {
        final data = await service.getRestoreData(
          fileFromPath('/nonexistent/file.json'),
        );
        expect(data, isNull);
      });
    });

    group('verifyBackupIntegrity', () {
      test('should return true for valid backup', () async {
        final filePath = path.join(tempDir.path, 'integrity_test.json');
        final createResult = await service.createBackup(
          churches: [createTestChurch(id: 1)],
          admins: [createTestAdmin(id: 1)],
          records: [createTestRecord(id: 1)],
          customPath: filePath,
        );

        expect(createResult.success, isTrue);
        expect(createResult.filePath, isNotNull);

        final isValid = await service.verifyBackupIntegrity(
          fileFromPath(createResult.filePath!),
        );
        expect(isValid, isTrue);
      });

      test('should return false for non-existent file', () async {
        final isValid = await service.verifyBackupIntegrity(
          fileFromPath('/nonexistent.json'),
        );
        expect(isValid, isFalse);
      });

      test('should return false for empty file', () async {
        final filePath = path.join(tempDir.path, 'empty.json');
        await File(filePath).writeAsString('');

        final isValid = await service.verifyBackupIntegrity(
          fileFromPath(filePath),
        );
        expect(isValid, isFalse);
      });

      test('should return false for missing keys', () async {
        final filePath = path.join(tempDir.path, 'missing_keys.json');
        await File(filePath).writeAsString('{"metadata": {}}');

        final isValid = await service.verifyBackupIntegrity(
          fileFromPath(filePath),
        );
        expect(isValid, isFalse);
      });
    });

    group('backup content comparison', () {
      test('should have equivalent content for identical inputs', () async {
        final churches = [createTestChurch(id: 1)];
        final admins = [createTestAdmin(id: 1)];
        final records = [createTestRecord(id: 1)];

        final name1 = path.join(tempDir.path, 'backup1.json');
        final name2 = path.join(tempDir.path, 'backup2.json');

        final r1 = await service.createBackup(
          churches: churches,
          admins: admins,
          records: records,
          customPath: name1,
        );
        final r2 = await service.createBackup(
          churches: churches,
          admins: admins,
          records: records,
          customPath: name2,
        );

        expect(r1.success, isTrue);
        expect(r2.success, isTrue);
        expect(r1.filePath, isNotNull);
        expect(r2.filePath, isNotNull);

        final b1 = await service.readBackup(fileFromPath(r1.filePath!));
        final b2 = await service.readBackup(fileFromPath(r2.filePath!));

        expect(b1, isNotNull);
        expect(b2, isNotNull);
        expect(b1!.churches.length, equals(b2!.churches.length));
        expect(b1.adminUsers.length, equals(b2.adminUsers.length));
        expect(b1.weeklyRecords.length, equals(b2.weeklyRecords.length));
      });

      test('should differ for different inputs', () async {
        final name1 = path.join(tempDir.path, 'backup1.json');
        final name2 = path.join(tempDir.path, 'backup2.json');

        final r1 = await service.createBackup(
          churches: [createTestChurch(id: 1)],
          admins: [],
          records: [],
          customPath: name1,
        );
        final r2 = await service.createBackup(
          churches: [
            createTestChurch(id: 1),
            createTestChurch(id: 2, name: 'C2'),
          ],
          admins: [],
          records: [],
          customPath: name2,
        );

        expect(r1.success, isTrue);
        expect(r2.success, isTrue);
        expect(r1.filePath, isNotNull);
        expect(r2.filePath, isNotNull);

        final b1 = await service.readBackup(fileFromPath(r1.filePath!));
        final b2 = await service.readBackup(fileFromPath(r2.filePath!));

        expect(b1, isNotNull);
        expect(b2, isNotNull);
        expect(b1!.churches.length, isNot(equals(b2!.churches.length)));
      });
    });

    group('round-trip data integrity', () {
      test(
        'should preserve all data through backup and restore cycle',
        () async {
          final originalChurch = Church(
            id: 42,
            name: 'Full Data Church',
            address: '456 Oak Ave',
            contactEmail: 'full@church.org',
            contactPhone: '555-9999',
            currency: 'EUR',
            createdAt: DateTime(2024, 6, 15, 10, 30),
            updatedAt: DateTime(2025, 1, 20, 14, 45),
          );

          final originalAdmin = AdminUser(
            id: 99,
            username: 'superadmin',
            fullName: 'Super Administrator',
            email: 'super@admin.com',
            churchId: 42,
            isActive: true,
            createdAt: DateTime(2024, 6, 15),
            lastLoginAt: DateTime(2025, 1, 28),
          );

          final originalRecord = WeeklyRecord(
            id: 777,
            churchId: 42,
            createdByAdminId: 99,
            weekStartDate: DateTime(2025, 1, 19),
            men: 123,
            women: 234,
            youth: 56,
            children: 78,
            sundayHomeChurch: 15,
            tithe: 5432.10,
            offerings: 2345.67,
            emergencyCollection: 500.0,
            plannedCollection: 1000.0,
            createdAt: DateTime(2025, 1, 19, 12, 0),
            updatedAt: DateTime(2025, 1, 19, 12, 30),
          );

          // Create backup
          final filePath = path.join(tempDir.path, 'full_roundtrip.json');
          final createResult = await service.createBackup(
            churches: [originalChurch],
            admins: [originalAdmin],
            records: [originalRecord],
            customPath: filePath,
          );

          expect(createResult.success, isTrue);
          expect(createResult.filePath, isNotNull);

          // Restore
          final data = await service.getRestoreData(
            fileFromPath(createResult.filePath!),
          );
          expect(data, isNotNull);

          final restoredChurch = data!.churches.first;
          final restoredAdmin = data.admins.first;
          final restoredRecord = data.records.first;

          // Verify church
          expect(restoredChurch.id, equals(originalChurch.id));
          expect(restoredChurch.name, equals(originalChurch.name));
          expect(restoredChurch.address, equals(originalChurch.address));
          expect(
            restoredChurch.contactEmail,
            equals(originalChurch.contactEmail),
          );
          expect(
            restoredChurch.contactPhone,
            equals(originalChurch.contactPhone),
          );
          expect(restoredChurch.currency, equals(originalChurch.currency));

          // Verify admin
          expect(restoredAdmin.id, equals(originalAdmin.id));
          expect(restoredAdmin.username, equals(originalAdmin.username));
          expect(restoredAdmin.fullName, equals(originalAdmin.fullName));
          expect(restoredAdmin.email, equals(originalAdmin.email));
          expect(restoredAdmin.churchId, equals(originalAdmin.churchId));
          expect(restoredAdmin.isActive, equals(originalAdmin.isActive));

          // Verify record
          expect(restoredRecord.id, equals(originalRecord.id));
          expect(restoredRecord.churchId, equals(originalRecord.churchId));
          expect(
            restoredRecord.createdByAdminId,
            equals(originalRecord.createdByAdminId),
          );
          expect(restoredRecord.men, equals(originalRecord.men));
          expect(restoredRecord.women, equals(originalRecord.women));
          expect(restoredRecord.youth, equals(originalRecord.youth));
          expect(restoredRecord.children, equals(originalRecord.children));
          expect(restoredRecord.tithe, equals(originalRecord.tithe));
          expect(restoredRecord.offerings, equals(originalRecord.offerings));
          expect(
            restoredRecord.emergencyCollection,
            equals(originalRecord.emergencyCollection),
          );
          expect(
            restoredRecord.plannedCollection,
            equals(originalRecord.plannedCollection),
          );
        },
      );
    });
  });

  group('BackupResult', () {
    test('success factory creates correct result', () {
      final metadata = BackupMetadata(
        version: '1.0',
        createdAt: DateTime.now(),
        appVersion: '1.0.0',
        churchCount: 1,
        adminCount: 2,
        recordCount: 3,
      );
      final result = BackupResult.success('/path/to/backup.json', metadata);

      expect(result.success, isTrue);
      expect(result.filePath, equals('/path/to/backup.json'));
      expect(result.metadata, equals(metadata));
      expect(result.error, isNull);
    });

    test('error factory creates correct result', () {
      final result = BackupResult.error('Something went wrong');

      expect(result.success, isFalse);
      expect(result.error, equals('Something went wrong'));
      expect(result.filePath, isNull);
      expect(result.metadata, isNull);
    });
  });

  group('RestoreResult', () {
    test('success factory creates correct result', () {
      final result = RestoreResult.success(churches: 2, admins: 3, records: 10);

      expect(result.success, isTrue);
      expect(result.churchesRestored, equals(2));
      expect(result.adminsRestored, equals(3));
      expect(result.recordsRestored, equals(10));
      expect(result.totalRestored, equals(15));
      expect(result.error, isNull);
    });

    test('error factory creates correct result', () {
      final result = RestoreResult.error('Restore failed');

      expect(result.success, isFalse);
      expect(result.error, equals('Restore failed'));
      expect(result.totalRestored, equals(0));
    });
  });

  group('BackupMetadata', () {
    test('toJson and fromJson round-trip', () {
      final original = BackupMetadata(
        version: '1.0',
        createdAt: DateTime(2025, 1, 29, 10, 30),
        appVersion: '2.0.0',
        churchCount: 5,
        adminCount: 10,
        recordCount: 100,
      );

      final json = original.toJson();
      final restored = BackupMetadata.fromJson(json);

      expect(restored.version, equals(original.version));
      expect(restored.appVersion, equals(original.appVersion));
      expect(restored.churchCount, equals(original.churchCount));
      expect(restored.adminCount, equals(original.adminCount));
      expect(restored.recordCount, equals(original.recordCount));
    });
  });
}
