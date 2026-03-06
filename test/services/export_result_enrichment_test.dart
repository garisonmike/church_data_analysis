// Tests for the enriched ExportResult model added in STORAGE-006.
// Covers: filename extraction, ExportErrorType classification, remediation getter.

import 'package:church_analytics/services/file_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // -------------------------------------------------------------------------
  // ExportResult.success — filename extraction
  // -------------------------------------------------------------------------
  group('ExportResult.success', () {
    test('extracts filename from Unix-style path', () {
      final r = ExportResult.success('/home/user/downloads/report.csv');
      expect(r.success, isTrue);
      expect(r.filename, equals('report.csv'));
      expect(r.filePath, equals('/home/user/downloads/report.csv'));
      expect(r.errorType, isNull);
      expect(r.error, isNull);
    });

    test('extracts filename from Windows-style path', () {
      final r = ExportResult.success(r'C:\Users\user\Documents\backup.json');
      expect(r.filename, equals('backup.json'));
    });

    test('handles bare filename (no directory component)', () {
      final r = ExportResult.success('data.pdf');
      expect(r.filename, equals('data.pdf'));
    });

    test('handles path ending in separator (directory path) gracefully', () {
      // When the last segment is empty, filename falls back to the full path.
      final r = ExportResult.success('/some/dir/');
      expect(r.filename, equals('/some/dir/'));
    });

    test('remediation for success uses null-errorType fallback message', () {
      // success result has errorType == null, which maps to the fallback.
      final r = ExportResult.success('/tmp/file.csv');
      expect(r.remediation, equals('Try again or contact support.'));
    });
  });

  // -------------------------------------------------------------------------
  // ExportResult.failure — error-type classification
  // -------------------------------------------------------------------------
  group('ExportResult.failure — ExportErrorType classification', () {
    test('classifies "permission denied" message as permissionDenied', () {
      final r = ExportResult.failure('permission denied');
      expect(r.success, isFalse);
      expect(r.errorType, equals(ExportErrorType.permissionDenied));
    });

    test('classifies "denied" keyword as permissionDenied', () {
      final r = ExportResult.failure('Access denied by OS');
      expect(r.errorType, equals(ExportErrorType.permissionDenied));
    });

    test('classifies "access" keyword as permissionDenied', () {
      final r = ExportResult.failure('access restricted to this folder');
      expect(r.errorType, equals(ExportErrorType.permissionDenied));
    });

    test('classifies "no space" message as storageFull', () {
      final r = ExportResult.failure('no space left on device');
      expect(r.errorType, equals(ExportErrorType.storageFull));
    });

    test('classifies "disk full" phrase as storageFull', () {
      final r = ExportResult.failure('disk full error');
      expect(r.errorType, equals(ExportErrorType.storageFull));
    });

    test('classifies "enospc" as storageFull', () {
      final r = ExportResult.failure('ENOSPC error writing to disk');
      expect(r.errorType, equals(ExportErrorType.storageFull));
    });

    test('classifies "path" keyword as invalidPath', () {
      final r = ExportResult.failure('Invalid path specified');
      expect(r.errorType, equals(ExportErrorType.invalidPath));
    });

    test('classifies "not found" as invalidPath', () {
      final r = ExportResult.failure('directory not found');
      expect(r.errorType, equals(ExportErrorType.invalidPath));
    });

    test('classifies "enoent" as invalidPath', () {
      final r = ExportResult.failure('ENOENT: no such file or directory');
      expect(r.errorType, equals(ExportErrorType.invalidPath));
    });

    test('classifies "null" as platformError', () {
      final r = ExportResult.failure('Storage returned null');
      expect(r.errorType, equals(ExportErrorType.platformError));
    });

    test('classifies "platform" as platformError', () {
      final r = ExportResult.failure('Platform channel error');
      expect(r.errorType, equals(ExportErrorType.platformError));
    });

    test('classifies unrecognised message as unknown', () {
      final r = ExportResult.failure('Something went wrong');
      expect(r.errorType, equals(ExportErrorType.unknown));
    });

    test('explicit errorType overrides auto-classification', () {
      final r = ExportResult.failure(
        'Some error',
        errorType: ExportErrorType.storageFull,
      );
      expect(r.errorType, equals(ExportErrorType.storageFull));
    });

    test('errorDetail is preserved when supplied', () {
      final r = ExportResult.failure(
        'Export failed',
        errorDetail: 'os error 13',
      );
      expect(r.errorDetail, equals('os error 13'));
    });

    test('filename is null for failure result', () {
      final r = ExportResult.failure('some error');
      expect(r.filename, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // ExportResult.remediation getter
  // -------------------------------------------------------------------------
  group('ExportResult.remediation', () {
    test('remediation for permissionDenied is non-empty', () {
      final r = ExportResult.failure('permission denied');
      expect(r.remediation, isNotEmpty);
    });

    test('remediation for storageFull is non-empty', () {
      final r = ExportResult.failure('disk is full');
      expect(r.remediation, isNotEmpty);
    });

    test('remediation for invalidPath is non-empty', () {
      final r = ExportResult.failure('invalid path');
      expect(r.remediation, isNotEmpty);
    });

    test('remediation for platformError is non-empty', () {
      final r = ExportResult.failure('null pointer');
      expect(r.remediation, isNotEmpty);
    });

    test('remediation for unknown is non-empty', () {
      final r = ExportResult.failure('something mysterious');
      expect(r.remediation, isNotEmpty);
    });

    test('remediation for success (null errorType) uses fallback message', () {
      final r = ExportResult.success('/tmp/test.csv');
      // errorType is null for success → falls through to default case.
      expect(r.remediation, equals('Try again or contact support.'));
    });
  });

  // -------------------------------------------------------------------------
  // ExportErrorType enum coverage
  // -------------------------------------------------------------------------
  group('ExportErrorType enum', () {
    test('has exactly 5 values', () {
      expect(ExportErrorType.values, hasLength(5));
    });

    test('all expected variants are present', () {
      expect(
        ExportErrorType.values,
        containsAll([
          ExportErrorType.permissionDenied,
          ExportErrorType.invalidPath,
          ExportErrorType.storageFull,
          ExportErrorType.platformError,
          ExportErrorType.unknown,
        ]),
      );
    });
  });
}
