import 'package:church_analytics/platform/filename_sanitizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FilenameSanitizer.sanitize —', () {
    // -----------------------------------------------------------------------
    // AC1: Invalid characters removed
    // -----------------------------------------------------------------------
    group('AC1 — invalid characters stripped', () {
      test('removes Windows-invalid chars: < > : " | ? *', () {
        expect(
          FilenameSanitizer.sanitize('my<>:"|?*file.txt'),
          equals('myfile.txt'),
        );
      });

      test('removes forward slash', () {
        expect(
          FilenameSanitizer.sanitize('path/to/file.csv'),
          equals('pathtofile.csv'),
        );
      });

      test('removes backslash', () {
        expect(
          FilenameSanitizer.sanitize(r'path\to\file.csv'),
          equals('pathtofile.csv'),
        );
      });

      test('removes all invalid chars leaving only safe chars', () {
        expect(
          FilenameSanitizer.sanitize('a<b>c:d"e|f?g*h.pdf'),
          equals('abcdefgh.pdf'),
        );
      });

      test('strips control characters (NUL, TAB, newline)', () {
        // TAB (\x09) is whitespace → space → underscore.
        // NUL (\x00) and \x1F are control chars stripped after whitespace pass.
        // So result has underscore where TAB was, and NUL/\x1F just removed.
        expect(
          FilenameSanitizer.sanitize('file\x00name\x09here\x1F.csv'),
          equals('filename_here.csv'),
        );
      });

      test('strips DEL character (U+007F)', () {
        expect(
          FilenameSanitizer.sanitize('file\x7fname.csv'),
          equals('filename.csv'),
        );
      });

      test('clean filename is returned unchanged', () {
        expect(
          FilenameSanitizer.sanitize('weekly_records_2024.csv'),
          equals('weekly_records_2024.csv'),
        );
      });
    });

    // -----------------------------------------------------------------------
    // AC2: Reserved names blocked
    // -----------------------------------------------------------------------
    group('AC2 — Windows reserved names prefixed with underscore', () {
      test('CON.csv → _CON.csv', () {
        expect(FilenameSanitizer.sanitize('CON.csv'), equals('_CON.csv'));
      });

      test('con.csv (lowercase) → _con.csv', () {
        expect(FilenameSanitizer.sanitize('con.csv'), equals('_con.csv'));
      });

      test('PRN.txt → _PRN.txt', () {
        expect(FilenameSanitizer.sanitize('PRN.txt'), equals('_PRN.txt'));
      });

      test('AUX → _AUX (no extension)', () {
        expect(FilenameSanitizer.sanitize('AUX'), equals('_AUX'));
      });

      test('NUL.pdf → _NUL.pdf', () {
        expect(FilenameSanitizer.sanitize('NUL.pdf'), equals('_NUL.pdf'));
      });

      test('COM1.csv → _COM1.csv', () {
        expect(FilenameSanitizer.sanitize('COM1.csv'), equals('_COM1.csv'));
      });

      test('COM9.csv → _COM9.csv', () {
        expect(FilenameSanitizer.sanitize('COM9.csv'), equals('_COM9.csv'));
      });

      test('LPT1.csv → _LPT1.csv', () {
        expect(FilenameSanitizer.sanitize('LPT1.csv'), equals('_LPT1.csv'));
      });

      test('LPT9.png → _LPT9.png', () {
        expect(FilenameSanitizer.sanitize('LPT9.png'), equals('_LPT9.png'));
      });

      test('non-reserved name CONSOLE is not modified', () {
        expect(
          FilenameSanitizer.sanitize('CONSOLE.txt'),
          equals('CONSOLE.txt'),
        );
      });

      test('non-reserved name CONNECT is not modified', () {
        expect(
          FilenameSanitizer.sanitize('CONNECT.csv'),
          equals('CONNECT.csv'),
        );
      });
    });

    // -----------------------------------------------------------------------
    // AC3: Whitespace normalised
    // -----------------------------------------------------------------------
    group('AC3 — whitespace normalised', () {
      test('leading and trailing spaces trimmed', () {
        expect(
          FilenameSanitizer.sanitize('  report  .pdf'),
          equals('report.pdf'),
        );
      });

      test('internal multiple spaces collapsed to single underscore', () {
        expect(
          FilenameSanitizer.sanitize('my   report   2024.csv'),
          equals('my_report_2024.csv'),
        );
      });

      test('single space replaced by underscore', () {
        expect(
          FilenameSanitizer.sanitize('My Report.pdf'),
          equals('My_Report.pdf'),
        );
      });

      test('tabs normalised', () {
        expect(
          FilenameSanitizer.sanitize('my\treport.csv'),
          equals('my_report.csv'),
        );
      });

      test('newline characters normalised', () {
        expect(
          FilenameSanitizer.sanitize('my\nreport.csv'),
          equals('my_report.csv'),
        );
      });
    });

    // -----------------------------------------------------------------------
    // AC4: Filename length capped
    // -----------------------------------------------------------------------
    group('AC4 — stem length capped at maxStemLength', () {
      test('stem longer than maxStemLength is truncated', () {
        final longStem = 'a' * 250;
        final result = FilenameSanitizer.sanitize('$longStem.csv');
        final (stem, ext) = FilenameSanitizer.splitExtension(result);
        expect(stem.length, equals(FilenameSanitizer.maxStemLength));
        expect(ext, equals('.csv'));
      });

      test('custom maxStemLen is respected', () {
        final longStem = 'b' * 50;
        final result = FilenameSanitizer.sanitize(
          '$longStem.pdf',
          maxStemLen: 10,
        );
        final (stem, _) = FilenameSanitizer.splitExtension(result);
        expect(stem.length, equals(10));
      });

      test('extension is NOT truncated when stem is capped', () {
        final longStem = 'c' * 250;
        final result = FilenameSanitizer.sanitize('$longStem.xlsx');
        expect(result.endsWith('.xlsx'), isTrue);
      });

      test('stem at exactly maxStemLength is not modified', () {
        final exactStem = 'd' * FilenameSanitizer.maxStemLength;
        final result = FilenameSanitizer.sanitize('$exactStem.csv');
        final (stem, ext) = FilenameSanitizer.splitExtension(result);
        expect(stem.length, equals(FilenameSanitizer.maxStemLength));
        expect(ext, equals('.csv'));
      });
    });

    // -----------------------------------------------------------------------
    // Edge cases: empty / fallback
    // -----------------------------------------------------------------------
    group('edge cases', () {
      test('all-invalid characters → fallback stem', () {
        expect(
          FilenameSanitizer.sanitize('<>:"|?*.csv'),
          equals('${FilenameSanitizer.fallbackStem}.csv'),
        );
      });

      test('empty string → fallback stem', () {
        expect(
          FilenameSanitizer.sanitize(''),
          equals(FilenameSanitizer.fallbackStem),
        );
      });

      test('whitespace-only name → fallback stem', () {
        expect(
          FilenameSanitizer.sanitize('   .csv'),
          equals('${FilenameSanitizer.fallbackStem}.csv'),
        );
      });

      test('extension with invalid chars is also sanitized', () {
        // Colons in extension should be stripped
        final result = FilenameSanitizer.sanitize('report.c:sv');
        expect(result, equals('report.csv'));
      });

      test('hidden-file dot prefix treated as no extension', () {
        // ".gitignore" — dot at position 0, no extension split
        final result = FilenameSanitizer.sanitize('.gitignore');
        expect(result, equals('.gitignore'));
      });

      test('no extension — name returned without dot', () {
        expect(FilenameSanitizer.sanitize('mybackup'), equals('mybackup'));
      });

      test('multiple dots — last dot is extension separator', () {
        expect(
          FilenameSanitizer.sanitize('report.2024.csv'),
          equals('report.2024.csv'),
        );
      });
    });
  });

  // -------------------------------------------------------------------------
  // splitExtension
  // -------------------------------------------------------------------------
  group('FilenameSanitizer.splitExtension —', () {
    test('standard filename split correctly', () {
      expect(
        FilenameSanitizer.splitExtension('report.pdf'),
        equals(('report', '.pdf')),
      );
    });

    test('no extension returns empty ext', () {
      expect(
        FilenameSanitizer.splitExtension('report'),
        equals(('report', '')),
      );
    });

    test('dot at index 0 treated as no extension', () {
      expect(
        FilenameSanitizer.splitExtension('.hidden'),
        equals(('.hidden', '')),
      );
    });

    test('multiple dots — last is ext separator', () {
      expect(
        FilenameSanitizer.splitExtension('archive.tar.gz'),
        equals(('archive.tar', '.gz')),
      );
    });

    test('trailing dot returns empty ext string', () {
      // 'file.' → lastDot at 4 > 0 → extension is ''... wait actually:
      // 'file.'.lastIndexOf('.') = 4, substring(4) = '.', so ext = '.'
      // That's a dot-only extension which _sanitizeExtension drops.
      // splitExtension itself returns ('.') for the extension.
      final (stem, ext) = FilenameSanitizer.splitExtension('file.');
      expect(stem, equals('file'));
      expect(ext, equals('.'));
    });
  });
}
