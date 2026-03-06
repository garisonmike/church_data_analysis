// Tests for STORAGE-001: Trimmed export path must be returned and stored.
//
// Verifies that normalizeExportPath() always returns a trimmed path (or null
// for blank/null input) so that no untrimmed path can flow into FileService.

import 'package:church_analytics/ui/screens/reports_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeExportPath – STORAGE-001', () {
    test('returns null when input is null', () {
      expect(normalizeExportPath(null), isNull);
    });

    test('returns null when input is an empty string', () {
      expect(normalizeExportPath(''), isNull);
    });

    test('returns null when input is whitespace only', () {
      expect(normalizeExportPath('   '), isNull);
      expect(normalizeExportPath('\t'), isNull);
      expect(normalizeExportPath('\n'), isNull);
    });

    test('trims trailing whitespace', () {
      expect(
        normalizeExportPath('/storage/emulated/0/Download/report.pdf   '),
        equals('/storage/emulated/0/Download/report.pdf'),
      );
    });

    test('trims leading whitespace', () {
      expect(
        normalizeExportPath('   /storage/emulated/0/Download/report.pdf'),
        equals('/storage/emulated/0/Download/report.pdf'),
      );
    });

    test('trims both leading and trailing whitespace', () {
      expect(
        normalizeExportPath(
          '  /home/user/Downloads/ChurchAnalytics/backup.json  ',
        ),
        equals('/home/user/Downloads/ChurchAnalytics/backup.json'),
      );
    });

    test('returns clean path unchanged', () {
      const path = '/home/user/Downloads/ChurchAnalytics/export.csv';
      expect(normalizeExportPath(path), equals(path));
    });

    test(
      'returned path is always equal to its own trim (no residual whitespace)',
      () {
        const inputs = [
          '/data/path ',
          ' /data/path',
          '\t/data/path\t',
          '/data/path',
        ];
        for (final input in inputs) {
          final result = normalizeExportPath(input);
          if (result != null) {
            expect(
              result,
              equals(result.trim()),
              reason: 'Path "$result" still contains whitespace',
            );
          }
        }
      },
    );

    test('Windows-style path is trimmed correctly', () {
      expect(
        normalizeExportPath(r'  C:\Users\Admin\Downloads\report.pdf  '),
        equals(r'C:\Users\Admin\Downloads\report.pdf'),
      );
    });
  });
}
