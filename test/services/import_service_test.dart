import 'dart:io';
import 'dart:typed_data';

import 'package:church_analytics/platform/file_storage_interface.dart';
import 'package:church_analytics/services/file_service.dart';
import 'package:church_analytics/services/import_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// FileStorage fake that serves the bytes carried by the picked file.
class _BytesFileStorage implements FileStorage {
  @override
  Future<Uint8List> readFileAsBytes(PlatformFileResult file) async =>
      file.bytes!;

  @override
  Future<String> readFileAsString(PlatformFileResult file) async =>
      String.fromCharCodes(file.bytes!);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  final service = ImportService(
    fileService: FileService(fileStorage: _BytesFileStorage()),
  );

  group('suggestColumnMapping', () {
    test('maps the canonical template headers', () {
      final result = service.suggestColumnMapping([
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
      ]);
      expect(result.mapping.length, 12);
      expect(result.ignoredColumns, isEmpty);
    });

    test('maps human-styled headers, including "Home Church"', () {
      final result = service.suggestColumnMapping([
        'Date',
        'Men',
        'Women',
        'Youth',
        'Kids',
        'Home Church',
        'Tithe (KES)',
        'Offering',
      ]);
      expect(result.mapping['weekStartDate'], 0);
      expect(result.mapping['children'], 4);
      expect(result.mapping['sundayHomeChurch'], 5);
      expect(result.mapping['tithe'], 6);
      expect(result.mapping['offerings'], 7);
    });

    test('maps underscore variations that headers may carry', () {
      final result = service.suggestColumnMapping([
        'week_date',
        'men_attendance',
        'women_attendance',
      ]);
      expect(result.mapping['weekStartDate'], 0);
      expect(result.mapping['men'], 1);
      expect(result.mapping['women'], 2);
    });
  });

  group('validateAndConvertRow — dates', () {
    final mapping = {
      'weekStartDate': 0,
      'men': 1,
      'women': 2,
      'youth': 3,
      'children': 4,
      'sundayHomeChurch': 5,
      'tithe': 6,
      'offerings': 7,
    };
    const optional = {'emergencyCollection', 'plannedCollection'};

    List<dynamic> row(dynamic date) => [date, 120, 95, 40, 30, 25, 15000.0, 3200.5];

    test('accepts ISO date strings', () {
      final result =
          service.validateAndConvertRow(row('2025-01-05'), mapping, 1, 2, null, optional);
      expect(result.success, isTrue);
      expect(result.record!.weekStartDate, DateTime(2025, 1, 5));
    });

    test('accepts Excel date serials (date-formatted spreadsheet cells)', () {
      final result =
          service.validateAndConvertRow(row(45662), mapping, 1, 2, null, optional);
      expect(result.success, isTrue, reason: result.errors?.join('; '));
      expect(result.record!.weekStartDate, DateTime(2025, 1, 5));
    });

    test('rejects nonsense dates with a single clear error', () {
      final result =
          service.validateAndConvertRow(row('next sabbath'), mapping, 1, 2, null, optional);
      expect(result.success, isFalse);
      expect(result.errors, ['Invalid date format. Expected: YYYY-MM-DD']);
    });

    test('missing date reports only the required error', () {
      final result =
          service.validateAndConvertRow(row(''), mapping, 1, 2, null, optional);
      expect(result.success, isFalse);
      expect(result.errors, ['Week start date is required']);
    });
  });

  group('parseFile — XLSX from non-Microsoft writers', () {
    test('parses an openpyxl-written workbook with real date cells', () async {
      final bytes = File(
        'test/fixtures/openpyxl_weekly_records.xlsx',
      ).readAsBytesSync();
      final parsed = await service.parseFile(
        PlatformFileResult(name: 'weekly.xlsx', bytes: bytes),
      );

      expect(parsed.success, isTrue, reason: parsed.error);
      expect(parsed.headers!.first, 'week_start_date');
      expect(parsed.rows!.length, 2);

      // End-to-end: mapping + row conversion over the parsed content.
      final mapping = service.suggestColumnMapping(parsed.headers!);
      expect(mapping.mapping['sundayHomeChurch'], 5,
          reason: '"Home Church" header must auto-map');

      final first = service.validateAndConvertRow(
        parsed.rows![0], mapping.mapping, 1, 2, null, const {},
      );
      expect(first.success, isTrue, reason: first.errors?.join('; '));
      expect(first.record!.weekStartDate, DateTime(2025, 1, 5));
      expect(first.record!.men, 120);
      expect(first.record!.tithe, 15000.0);

      final second = service.validateAndConvertRow(
        parsed.rows![1], mapping.mapping, 1, 3, null, const {},
      );
      expect(second.success, isTrue, reason: second.errors?.join('; '));
      expect(second.record!.weekStartDate, DateTime(2025, 1, 12));
    });
  });
}
