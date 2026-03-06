import 'package:church_analytics/models/activity_log_entry.dart';
import 'package:church_analytics/services/activity_log_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // -------------------------------------------------------------------------
  // Test helper
  // -------------------------------------------------------------------------

  Future<SharedPreferencesActivityLogService> makeService({
    Map<String, Object> initialValues = const {},
  }) async {
    SharedPreferences.setMockInitialValues(
      Map<String, Object>.from(initialValues),
    );
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesActivityLogService(prefs);
  }

  // =========================================================================
  // ActivityLogEntryType
  // =========================================================================

  group('ActivityLogEntryType', () {
    test('displayName returns correct label for each type', () {
      expect(ActivityLogEntryType.export.displayName, 'Export');
      expect(ActivityLogEntryType.import.displayName, 'Import');
      expect(ActivityLogEntryType.installerLaunch.displayName, 'Install');
    });

    test('all types survive entry toJson/fromJson round-trip', () {
      for (final type in ActivityLogEntryType.values) {
        final entry = ActivityLogEntry(
          id: 'test_${type.name}',
          type: type,
          filename: 'file.csv',
          success: true,
          timestamp: DateTime(2026, 3, 6),
        );
        final restored = ActivityLogEntry.fromJson(entry.toJson());
        expect(
          restored.type,
          type,
          reason: 'Type ${type.name} must survive serialization',
        );
      }
    });

    test(
      'unknown type value in JSON falls back to export (forward-compat)',
      () {
        final json = ActivityLogEntry(
          id: 'x',
          type: ActivityLogEntryType.export,
          filename: 'f.csv',
          success: true,
          timestamp: DateTime(2026, 1, 1),
        ).toJson()..['type'] = 'someFutureUnknownType';

        final entry = ActivityLogEntry.fromJson(json);
        expect(entry.type, ActivityLogEntryType.export);
      },
    );
  });

  // =========================================================================
  // ActivityLogEntry
  // =========================================================================

  group('ActivityLogEntry', () {
    test('now() sets all fields, id is non-empty', () {
      final before = DateTime.now();
      final entry = ActivityLogEntry.now(
        type: ActivityLogEntryType.export,
        filename: 'data.csv',
        path: '/home/user/downloads/data.csv',
        success: true,
        message: null,
      );
      final after = DateTime.now();

      expect(entry.id, isNotEmpty);
      expect(entry.type, ActivityLogEntryType.export);
      expect(entry.filename, 'data.csv');
      expect(entry.path, '/home/user/downloads/data.csv');
      expect(entry.success, isTrue);
      expect(entry.message, isNull);
      expect(
        entry.timestamp.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        entry.timestamp.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('now() with failure populates message', () {
      final entry = ActivityLogEntry.now(
        type: ActivityLogEntryType.import,
        filename: 'backup.zip',
        success: false,
        message: 'File not found',
      );

      expect(entry.success, isFalse);
      expect(entry.message, 'File not found');
      expect(entry.path, isNull);
    });

    test('toJson/fromJson round-trip preserves all fields', () {
      final original = ActivityLogEntry(
        id: '1700000000000_export',
        type: ActivityLogEntryType.export,
        filename: 'records.csv',
        path: '/downloads/records.csv',
        success: true,
        message: null,
        timestamp: DateTime(2026, 3, 6, 10, 30),
      );

      final json = original.toJson();
      final restored = ActivityLogEntry.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.filename, original.filename);
      expect(restored.path, original.path);
      expect(restored.success, original.success);
      expect(restored.message, original.message);
      expect(restored.timestamp, original.timestamp);
    });

    test('toJson/fromJson round-trip with null path and non-null message', () {
      final original = ActivityLogEntry(
        id: '9999_import',
        type: ActivityLogEntryType.import,
        filename: 'backup.zip',
        path: null,
        success: false,
        message: 'Permission denied',
        timestamp: DateTime(2026, 1, 1),
      );

      final restored = ActivityLogEntry.fromJson(original.toJson());

      expect(restored.path, isNull);
      expect(restored.message, 'Permission denied');
      expect(restored.success, isFalse);
    });

    test('toJson omits null fields (path and message)', () {
      final entry = ActivityLogEntry.now(
        type: ActivityLogEntryType.export,
        filename: 'file.csv',
        success: true,
      );
      final json = entry.toJson();

      expect(json.containsKey('path'), isFalse);
      expect(json.containsKey('message'), isFalse);
    });

    test('toString includes type, filename, success and timestamp', () {
      final entry = ActivityLogEntry.now(
        type: ActivityLogEntryType.installerLaunch,
        filename: 'android',
        success: false,
        message: 'launch error',
      );
      final str = entry.toString();
      expect(str, contains('installerLaunch'));
      expect(str, contains('android'));
      expect(str, contains('false'));
    });
  });

  // =========================================================================
  // SharedPreferencesActivityLogService — logging
  // =========================================================================

  group('SharedPreferencesActivityLogService — logExport', () {
    test('creates an entry with correct type and fields', () async {
      final svc = await makeService();
      svc.logExport(
        filename: 'data.csv',
        path: '/home/data.csv',
        success: true,
      );

      final entries = svc.getRecentEntries();
      expect(entries, hasLength(1));
      expect(entries[0].type, ActivityLogEntryType.export);
      expect(entries[0].filename, 'data.csv');
      expect(entries[0].path, '/home/data.csv');
      expect(entries[0].success, isTrue);
      expect(entries[0].message, isNull);
    });

    test('records failure with error message', () async {
      final svc = await makeService();
      svc.logExport(
        filename: 'report.pdf',
        path: null,
        success: false,
        error: 'Storage full',
      );

      final entries = svc.getRecentEntries();
      expect(entries[0].success, isFalse);
      expect(entries[0].message, 'Storage full');
      expect(entries[0].path, isNull);
    });
  });

  group('SharedPreferencesActivityLogService — logImport', () {
    test('creates an import entry on success', () async {
      final svc = await makeService();
      svc.logImport(filename: 'backup.zip', success: true);

      final entries = svc.getRecentEntries();
      expect(entries[0].type, ActivityLogEntryType.import);
      expect(entries[0].filename, 'backup.zip');
      expect(entries[0].success, isTrue);
    });

    test('records import failure with error message', () async {
      final svc = await makeService();
      svc.logImport(filename: 'bad.csv', success: false, error: 'Parse error');

      final entries = svc.getRecentEntries();
      expect(entries[0].success, isFalse);
      expect(entries[0].message, 'Parse error');
    });
  });

  group('SharedPreferencesActivityLogService — logInstallerLaunch', () {
    test('uses platform as filename when provided', () async {
      final svc = await makeService();
      svc.logInstallerLaunch(success: true, platform: 'android');

      final entries = svc.getRecentEntries();
      expect(entries[0].type, ActivityLogEntryType.installerLaunch);
      expect(entries[0].filename, 'android');
      expect(entries[0].success, isTrue);
    });

    test('falls back to "installer" when platform is null', () async {
      final svc = await makeService();
      svc.logInstallerLaunch(success: false, error: 'launch failed');

      final entries = svc.getRecentEntries();
      expect(entries[0].filename, 'installer');
      expect(entries[0].message, 'launch failed');
    });
  });

  // =========================================================================
  // SharedPreferencesActivityLogService — getRecentEntries
  // =========================================================================

  group('SharedPreferencesActivityLogService — getRecentEntries', () {
    test('returns empty list when no entries exist', () async {
      final svc = await makeService();
      expect(svc.getRecentEntries(), isEmpty);
    });

    test(
      'returns entries in reverse-chronological order (newest first)',
      () async {
        final svc = await makeService();
        svc.logExport(filename: 'first.csv', path: null, success: true);
        svc.logImport(filename: 'second.csv', success: true);
        svc.logExport(filename: 'third.csv', path: null, success: false);

        final entries = svc.getRecentEntries();
        expect(entries[0].filename, 'third.csv');
        expect(entries[1].filename, 'second.csv');
        expect(entries[2].filename, 'first.csv');
      },
    );

    test('count parameter limits returned entries', () async {
      final svc = await makeService();
      for (var i = 0; i < 15; i++) {
        svc.logExport(filename: 'file$i.csv', path: null, success: true);
      }

      expect(svc.getRecentEntries(5), hasLength(5));
      expect(svc.getRecentEntries(10), hasLength(10));
      expect(svc.getRecentEntries(20), hasLength(15));
    });

    test('default count is 10', () async {
      final svc = await makeService();
      for (var i = 0; i < 12; i++) {
        svc.logExport(filename: 'f$i.csv', path: null, success: true);
      }
      expect(svc.getRecentEntries(), hasLength(10));
    });
  });

  // =========================================================================
  // FIFO cap at 50 entries
  // =========================================================================

  group('SharedPreferencesActivityLogService — FIFO cap', () {
    test('stores up to kMaxEntries (50) without trimming', () async {
      final svc = await makeService();
      for (
        var i = 0;
        i < SharedPreferencesActivityLogService.kMaxEntries;
        i++
      ) {
        svc.logExport(filename: 'file$i.csv', path: null, success: true);
      }
      expect(
        svc.getRecentEntries(SharedPreferencesActivityLogService.kMaxEntries),
        hasLength(SharedPreferencesActivityLogService.kMaxEntries),
      );
    });

    test('51st entry causes the oldest entry to be dropped', () async {
      final svc = await makeService();
      // Log 50 entries with a distinctive first entry.
      svc.logExport(filename: 'OLDEST.csv', path: null, success: true);
      for (
        var i = 1;
        i < SharedPreferencesActivityLogService.kMaxEntries;
        i++
      ) {
        svc.logExport(filename: 'file$i.csv', path: null, success: true);
      }

      // 51st entry.
      svc.logExport(filename: 'NEWEST.csv', path: null, success: true);

      final allEntries = svc.getRecentEntries(
        SharedPreferencesActivityLogService.kMaxEntries + 10,
      );
      expect(
        allEntries,
        hasLength(SharedPreferencesActivityLogService.kMaxEntries),
      );
      expect(
        allEntries.any((e) => e.filename == 'OLDEST.csv'),
        isFalse,
        reason: 'Oldest entry must be evicted when cap is exceeded',
      );
      expect(allEntries.first.filename, 'NEWEST.csv');
    });

    test('after 100 entries exactly 50 remain', () async {
      final svc = await makeService();
      for (var i = 0; i < 100; i++) {
        svc.logExport(filename: 'f$i.csv', path: null, success: true);
      }
      expect(
        svc.getRecentEntries(100),
        hasLength(SharedPreferencesActivityLogService.kMaxEntries),
      );
    });
  });

  // =========================================================================
  // Persistence across instances
  // =========================================================================

  group('SharedPreferencesActivityLogService — persistence', () {
    test(
      'entries survive creation of a new service instance on the same prefs',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final svc1 = SharedPreferencesActivityLogService(prefs);
        svc1.logExport(filename: 'persisted.csv', path: '/tmp', success: true);

        // New instance — same shared prefs object (simulates app restart within test).
        final svc2 = SharedPreferencesActivityLogService(prefs);
        final entries = svc2.getRecentEntries();

        expect(entries, hasLength(1));
        expect(entries[0].filename, 'persisted.csv');
      },
    );

    test('multiple log types are all persisted', () async {
      final svc = await makeService();
      svc.logExport(filename: 'a.csv', path: '/tmp/a.csv', success: true);
      svc.logImport(filename: 'b.zip', success: false, error: 'bad zip');
      svc.logInstallerLaunch(success: true, platform: 'linux');

      final entries = svc.getRecentEntries(3);
      expect(entries.map((e) => e.type).toList(), [
        ActivityLogEntryType.installerLaunch,
        ActivityLogEntryType.import,
        ActivityLogEntryType.export,
      ]);
    });
  });

  // =========================================================================
  // Resilience — corrupted stored data
  // =========================================================================

  group('SharedPreferencesActivityLogService — resilience', () {
    test('corrupted JSON returns empty list without throwing', () async {
      final svc = await makeService(
        initialValues: {
          SharedPreferencesActivityLogService.kLogKey:
              '{this is not valid json',
        },
      );
      expect(svc.getRecentEntries(), isEmpty);
    });

    test('can append new entries after corrupt data is ignored', () async {
      final svc = await makeService(
        initialValues: {SharedPreferencesActivityLogService.kLogKey: 'null'},
      );
      svc.logExport(filename: 'recovered.csv', path: null, success: true);

      final entries = svc.getRecentEntries();
      expect(entries, hasLength(1));
      expect(entries[0].filename, 'recovered.csv');
    });
  });

  // =========================================================================
  // NoOpActivityLogService
  // =========================================================================

  group('NoOpActivityLogService', () {
    test('all methods complete without throwing', () {
      const noop = NoOpActivityLogService();
      expect(() {
        noop.logExport(filename: 'x.csv', path: null, success: true);
        noop.logImport(filename: 'x.csv', success: false, error: 'oops');
        noop.logInstallerLaunch(success: true, platform: 'android');
      }, returnsNormally);
    });
  });
}
