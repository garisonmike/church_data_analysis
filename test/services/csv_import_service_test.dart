import 'dart:convert';
import 'dart:typed_data';

import 'package:church_analytics/platform/file_storage_interface.dart';
import 'package:church_analytics/services/import_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBytesFileStorage implements FileStorage {
  @override
  Future<PlatformFileResult?> pickFile({
    required List<String> allowedExtensions,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> saveFile({
    required String fileName,
    required String content,
    String? fullPath,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> saveFileBytes({
    required String fileName,
    required Uint8List bytes,
    String? fullPath,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> pickSaveLocation({
    required String suggestedName,
    required List<String> allowedExtensions,
  }) async {
    return null;
  }

  @override
  Future<String> readFileAsString(PlatformFileResult file) async {
    final bytes = file.bytes;
    if (bytes == null) {
      throw StateError('Expected in-memory bytes');
    }
    return utf8.decode(bytes);
  }

  @override
  Future<Uint8List> readFileAsBytes(PlatformFileResult file) async {
    final bytes = file.bytes;
    if (bytes == null) {
      throw StateError('Expected in-memory bytes');
    }
    return bytes;
  }
}

void main() {
  group('ImportService', () {
    late ImportService service;

    setUp(() {
      service = ImportService();
    });

    group('parseFile (web bytes)', () {
      test('parses CSV from memory bytes without file paths', () async {
        final bytesStorage = _FakeBytesFileStorage();
        final bytesService = ImportService(fileStorage: bytesStorage);

        const csv =
            'weekStartDate,men,women\n'
            '2026-01-01,10,12\n'
            '2026-01-08,11,13\n';

        final file = PlatformFileResult(
          name: 'weekly.csv',
          path: null,
          bytes: Uint8List.fromList(utf8.encode(csv)),
        );

        final result = await bytesService.parseFile(file);

        expect(result.success, true);
        expect(result.headers, ['weekStartDate', 'men', 'women']);
        expect(result.rows, isNotNull);
        expect(result.rows!.length, 2);
      });
    });

    group('suggestColumnMapping', () {
      test('maps common header variations correctly', () {
        final headers = [
          'Date',
          'Men',
          'Women',
          'Youth',
          'Children',
          'Sunday Home Church',
          'Tithe',
          'Offerings',
          'Emergency Collection',
          'Planned Collection',
        ];

        final mapping = service.suggestColumnMapping(headers);

        expect(mapping.mapping['weekStartDate'], 0);
        expect(mapping.mapping['men'], 1);
        expect(mapping.mapping['women'], 2);
        expect(mapping.mapping['youth'], 3);
        expect(mapping.mapping['children'], 4);
        expect(mapping.mapping['sundayHomeChurch'], 5);
        expect(mapping.mapping['tithe'], 6);
        expect(mapping.mapping['offerings'], 7);
        expect(mapping.mapping['emergencyCollection'], 8);
        expect(mapping.mapping['plannedCollection'], 9);
      });

      test('handles lowercase and underscores', () {
        final headers = [
          'week_start_date',
          'male',
          'female',
          'youths',
          'kids',
          'shc',
          'tithes',
          'offering',
          'emergency',
          'planned',
        ];

        final mapping = service.suggestColumnMapping(headers);

        expect(mapping.mapping['weekStartDate'], 0);
        expect(mapping.mapping['men'], 1);
        expect(mapping.mapping['women'], 2);
        expect(mapping.mapping['youth'], 3);
        expect(mapping.mapping['children'], 4);
        expect(mapping.mapping['sundayHomeChurch'], 5);
        expect(mapping.mapping['tithe'], 6);
        expect(mapping.mapping['offerings'], 7);
        expect(mapping.mapping['emergencyCollection'], 8);
        expect(mapping.mapping['plannedCollection'], 9);
      });

      test('returns empty map for unrecognized headers', () {
        final headers = ['unknown1', 'unknown2', 'unknown3'];

        final mapping = service.suggestColumnMapping(headers);

        expect(mapping.mapping, isEmpty);
      });
    });

    group('validateAndConvertRow', () {
      test('validates and converts valid row', () {
        final row = [
          '2026-01-15',
          '50',
          '60',
          '30',
          '20',
          '10',
          '1000.00',
          '500.00',
          '100.00',
          '200.00',
        ];

        final mapping = {
          'weekStartDate': 0,
          'men': 1,
          'women': 2,
          'youth': 3,
          'children': 4,
          'sundayHomeChurch': 5,
          'tithe': 6,
          'offerings': 7,
          'emergencyCollection': 8,
          'plannedCollection': 9,
        };

        final result = service.validateAndConvertRow(row, mapping, 1, 2, null, {
          'emergencyCollection',
          'plannedCollection',
        });

        expect(result.success, true);
        expect(result.record, isNotNull);
        expect(result.record!.men, 50);
        expect(result.record!.women, 60);
        expect(result.record!.youth, 30);
        expect(result.record!.children, 20);
        expect(result.record!.sundayHomeChurch, 10);
        expect(result.record!.tithe, 1000.00);
        expect(result.record!.offerings, 500.00);
        expect(result.record!.emergencyCollection, 100.00);
        expect(result.record!.plannedCollection, 200.00);
      });

      test('returns errors for missing required fields', () {
        final row = [
          '',
          '50',
          '60',
          '30',
          '20',
          '10',
          '1000',
          '500',
          '100',
          '200',
        ];

        final mapping = {
          'weekStartDate': 0,
          'men': 1,
          'women': 2,
          'youth': 3,
          'children': 4,
          'sundayHomeChurch': 5,
          'tithe': 6,
          'offerings': 7,
          'emergencyCollection': 8,
          'plannedCollection': 9,
        };

        final result = service.validateAndConvertRow(row, mapping, 1, 2, null, {
          'emergencyCollection',
          'plannedCollection',
        });

        expect(result.success, false);
        expect(result.errors, isNotNull);
        expect(result.errors!.any((e) => e.contains('date')), true);
      });

      test('returns errors for invalid numbers', () {
        final row = [
          '2026-01-15',
          'abc',
          '60',
          '30',
          '20',
          '10',
          'xyz',
          '500',
          '100',
          '200',
        ];

        final mapping = {
          'weekStartDate': 0,
          'men': 1,
          'women': 2,
          'youth': 3,
          'children': 4,
          'sundayHomeChurch': 5,
          'tithe': 6,
          'offerings': 7,
          'emergencyCollection': 8,
          'plannedCollection': 9,
        };

        final result = service.validateAndConvertRow(row, mapping, 1, 2, null, {
          'emergencyCollection',
          'plannedCollection',
        });

        expect(result.success, false);
        expect(result.errors, isNotNull);
        expect(result.errors!.length, greaterThanOrEqualTo(2));
      });

      test('returns errors for negative values', () {
        final row = [
          '2026-01-15',
          '-50',
          '60',
          '30',
          '20',
          '10',
          '1000',
          '-500',
          '100',
          '200',
        ];

        final mapping = {
          'weekStartDate': 0,
          'men': 1,
          'women': 2,
          'youth': 3,
          'children': 4,
          'sundayHomeChurch': 5,
          'tithe': 6,
          'offerings': 7,
          'emergencyCollection': 8,
          'plannedCollection': 9,
        };

        final result = service.validateAndConvertRow(row, mapping, 1, 2, null, {
          'emergencyCollection',
          'plannedCollection',
        });

        expect(result.success, false);
        expect(result.errors, isNotNull);
        expect(result.errors!.any((e) => e.contains('positive')), true);
      });

      test('returns errors for invalid date format', () {
        final row = [
          'invalid-date',
          '50',
          '60',
          '30',
          '20',
          '10',
          '1000',
          '500',
          '100',
          '200',
        ];

        final mapping = {
          'weekStartDate': 0,
          'men': 1,
          'women': 2,
          'youth': 3,
          'children': 4,
          'sundayHomeChurch': 5,
          'tithe': 6,
          'offerings': 7,
          'emergencyCollection': 8,
          'plannedCollection': 9,
        };

        final result = service.validateAndConvertRow(row, mapping, 1, 2, null, {
          'emergencyCollection',
          'plannedCollection',
        });

        expect(result.success, false);
        expect(result.errors, isNotNull);
        expect(result.errors!.any((e) => e.contains('date format')), true);
      });
    });

    // ── Change 1k: baptisms / holyCommunion import tests ─────────────────

    group('baptisms and holyCommunion optional fields', () {
      test('parses baptisms and holyCommunion when present', () {
        final row = [
          '2026-01-05',
          '50',
          '60',
          '30',
          '20',
          '10',
          '1000',
          '500',
          '200',
          '300',
          '8',   // baptisms
          '120', // holyCommunion
        ];

        final mapping = {
          'weekStartDate': 0,
          'men': 1,
          'women': 2,
          'youth': 3,
          'children': 4,
          'sundayHomeChurch': 5,
          'tithe': 6,
          'offerings': 7,
          'emergencyCollection': 8,
          'plannedCollection': 9,
          'baptisms': 10,
          'holyCommunion': 11,
        };

        final result = service.validateAndConvertRow(row, mapping, 1, 2, null, {
          'emergencyCollection',
          'plannedCollection',
          'baptisms',
          'holyCommunion',
        });

        expect(result.success, true);
        expect(result.record!.baptisms, 8);
        expect(result.record!.holyCommunion, 120);
      });

      test('returns null for baptisms and holyCommunion when columns absent', () {
        final row = [
          '2026-01-05',
          '50',
          '60',
          '30',
          '20',
          '10',
          '1000',
          '500',
          '200',
          '300',
        ];

        final mapping = {
          'weekStartDate': 0,
          'men': 1,
          'women': 2,
          'youth': 3,
          'children': 4,
          'sundayHomeChurch': 5,
          'tithe': 6,
          'offerings': 7,
          'emergencyCollection': 8,
          'plannedCollection': 9,
          // baptisms and holyCommunion intentionally absent
        };

        final result = service.validateAndConvertRow(row, mapping, 1, 2, null, {
          'emergencyCollection',
          'plannedCollection',
          'baptisms',
          'holyCommunion',
        });

        expect(result.success, true);
        expect(result.record!.baptisms, isNull);
        expect(result.record!.holyCommunion, isNull);
      });

      test('returns null for baptisms when column is blank', () {
        final row = [
          '2026-01-05',
          '50',
          '60',
          '30',
          '20',
          '10',
          '1000',
          '500',
          '200',
          '300',
          '', // baptisms blank
          '', // holyCommunion blank
        ];

        final mapping = {
          'weekStartDate': 0,
          'men': 1,
          'women': 2,
          'youth': 3,
          'children': 4,
          'sundayHomeChurch': 5,
          'tithe': 6,
          'offerings': 7,
          'emergencyCollection': 8,
          'plannedCollection': 9,
          'baptisms': 10,
          'holyCommunion': 11,
        };

        final result = service.validateAndConvertRow(row, mapping, 1, 2, null, {
          'emergencyCollection',
          'plannedCollection',
          'baptisms',
          'holyCommunion',
        });

        expect(result.success, true);
        expect(result.record!.baptisms, isNull);
        expect(result.record!.holyCommunion, isNull);
      });
    });
  });

// ── Section 1.3: ImportService.validateAndConvertRow ─────────────────────────

  group('ImportService.validateAndConvertRow', () {
  final service = ImportService(fileStorage: _FakeBytesFileStorage());

  final Map<String, int> fullMapping = {
    'weekStartDate': 0, 'men': 1, 'women': 2, 'youth': 3,
    'children': 4, 'sundayHomeChurch': 5, 'tithe': 6,
    'offerings': 7, 'emergencyCollection': 8, 'plannedCollection': 9,
  };

  test('converts a valid row to WeeklyRecord', () {
    final row = ['2026-01-03', '100', '120', '80', '60',
                 '40', '5000.0', '3000.0', '500.0', '200.0'];
    final result = service.validateAndConvertRow(
      row, fullMapping, 1, 2, null, const {},
    );
    expect(result.success, isTrue);
    expect(result.record, isNotNull);
    expect(result.record!.men, 100);
    expect(result.record!.tithe, 5000.0);
  });

  test('returns error for invalid date format', () {
    final row = ['not-a-date', '100', '120', '80', '60',
                 '40', '5000.0', '3000.0', '500.0', '200.0'];
    final result = service.validateAndConvertRow(
      row, fullMapping, 1, 2, null, const {},
    );
    expect(result.success, isFalse);
    expect(result.errors, isNotEmpty);
    expect(result.errors!.any((e) => e.toLowerCase().contains('date')), isTrue);
  });

  test('returns error for negative attendance value', () {
    final row = ['2026-01-03', '-5', '120', '80', '60',
                 '40', '5000.0', '3000.0', '500.0', '200.0'];
    final result = service.validateAndConvertRow(
      row, fullMapping, 1, 2, null, const {},
    );
    expect(result.success, isFalse);
    expect(result.errors!.any((e) => e.toLowerCase().contains('positive')), isTrue);
  });

  test('returns error for non-numeric field', () {
    final row = ['2026-01-03', 'abc', '120', '80', '60',
                 '40', '5000.0', '3000.0', '500.0', '200.0'];
    final result = service.validateAndConvertRow(
      row, fullMapping, 1, 2, null, const {},
    );
    expect(result.success, isFalse);
    expect(result.errors!.any((e) => e.toLowerCase().contains('integer')), isTrue);
  });

  test('optional fields default to 0 when absent', () {
    final row = ['2026-01-03', '100', '120', '80', '60', '40', '5000.0', '3000.0'];
    final partialMapping = Map<String, int>.from(fullMapping)
      ..remove('emergencyCollection')
      ..remove('plannedCollection');
    final result = service.validateAndConvertRow(
      row, partialMapping, 1, 2, null,
      const {'emergencyCollection', 'plannedCollection'},
    );
    expect(result.success, isTrue);
    expect(result.record!.emergencyCollection, 0.0);
    expect(result.record!.plannedCollection, 0.0);
  });
  });
}
