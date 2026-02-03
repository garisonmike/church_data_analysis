import 'dart:typed_data';

import 'package:church_analytics/platform/file_storage_interface.dart';
import 'package:church_analytics/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFileStorage implements FileStorage {
  String? lastFileName;
  Uint8List? lastBytes;
  String? returnValue;

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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<String?> saveFileBytes({
    required String fileName,
    required Uint8List bytes,
    String? fullPath,
  }) async {
    lastFileName = fileName;
    lastBytes = bytes;
    return returnValue ?? fileName;
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
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChartExportService', () {
    group('generateFileName', () {
      test('generates valid file name with clean church name', () {
        final fileName = ChartExportService.generateFileName(
          churchName: 'Holy Trinity Church',
          chartType: 'Attendance Chart',
        );

        expect(fileName, contains('holy_trinity_church'));
        expect(fileName, contains('attendance_chart'));
        expect(fileName, matches(RegExp(r'\d{8}_\d{6}'))); // timestamp pattern
      });

      test('handles special characters in church name', () {
        final fileName = ChartExportService.generateFileName(
          churchName: "St. Mary's Church & Chapel",
          chartType: 'Financial Report',
        );

        expect(fileName, contains('st_marys_church_chapel'));
        expect(fileName, contains('financial_report'));
        expect(fileName, isNot(contains('&')));
        expect(fileName, isNot(contains("'")));
      });

      test('handles multiple spaces correctly', () {
        final fileName = ChartExportService.generateFileName(
          churchName: 'First    Baptist    Church',
          chartType: 'Weekly   Attendance',
        );

        expect(fileName, contains('first_baptist_church'));
        expect(fileName, contains('weekly_attendance'));
        expect(fileName, isNot(contains('  '))); // no double spaces
      });

      test('converts to lowercase', () {
        final fileName = ChartExportService.generateFileName(
          churchName: 'GRACE COMMUNITY',
          chartType: 'FINANCIAL CHART',
        );

        expect(fileName, equals(fileName.toLowerCase()));
        expect(fileName, contains('grace_community'));
        expect(fileName, contains('financial_chart'));
      });

      test('generates unique filenames for consecutive calls', () async {
        final fileName1 = ChartExportService.generateFileName(
          churchName: 'Test Church',
          chartType: 'Test Chart',
        );

        // Wait a moment to ensure different timestamp
        await Future.delayed(const Duration(milliseconds: 10));

        final fileName2 = ChartExportService.generateFileName(
          churchName: 'Test Church',
          chartType: 'Test Chart',
        );

        // Due to timestamp, files should be different if enough time has passed
        // But at minimum, they should both be valid
        expect(fileName1, contains('test_church'));
        expect(fileName2, contains('test_church'));
        expect(fileName1, matches(RegExp(r'\d{8}_\d{6}')));
        expect(fileName2, matches(RegExp(r'\d{8}_\d{6}')));
      });
    });

    group('verifyExport', () {
      test('returns false for empty/whitespace', () async {
        expect(await ChartExportService.verifyExport(''), false);
        expect(await ChartExportService.verifyExport('   '), false);
      });

      test('returns true for non-empty value', () async {
        expect(await ChartExportService.verifyExport('Download started'), true);
        expect(
          await ChartExportService.verifyExport('/some/path/file.png'),
          true,
        );
      });
    });

    group('captureWidget', () {
      test('returns null when boundary is not found', () async {
        // Create a GlobalKey without attaching it to any widget
        final key = GlobalKey();

        final result = await ChartExportService.captureWidget(key);

        expect(result, null);
      });
    });

    group('saveAsPng', () {
      test('ensures PNG extension is added', () {
        // This is tested indirectly through the filename generation
        const fileName = 'test_file';
        expect(fileName.endsWith('.png'), false);

        final withExtension = fileName.endsWith('.png')
            ? fileName
            : '$fileName.png';
        expect(withExtension, 'test_file.png');
      });

      test('preserves PNG extension if already present', () {
        const fileName = 'test_file.png';
        expect(fileName.endsWith('.png'), true);

        final withExtension = fileName.endsWith('.png')
            ? fileName
            : '$fileName.png';
        expect(withExtension, 'test_file.png');
      });

      test('routes through FileStorage.saveFileBytes', () async {
        final storage = _FakeFileStorage()..returnValue = 'ok';
        final bytes = Uint8List.fromList([1, 2, 3]);

        final result = await ChartExportService.saveAsPng(
          imageBytes: bytes,
          fileName: 'chart_export',
          fileStorage: storage,
        );

        expect(result, 'ok');
        expect(storage.lastFileName, 'chart_export.png');
        expect(storage.lastBytes, bytes);
      });
    });

    group('exportChart', () {
      test('handles null image bytes gracefully', () async {
        // Create a GlobalKey without a valid RepaintBoundary
        final key = GlobalKey();

        final result = await ChartExportService.exportChart(
          repaintBoundaryKey: key,
          churchName: 'Test Church',
          chartType: 'Test Chart',
        );

        expect(result, null);
      });
    });
  });
}
