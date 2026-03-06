import 'package:church_analytics/platform/filename_conflict_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Builds a resolver whose [fileExists] returns true for every path in
  /// [existing] and false for everything else.
  FilenameConflictResolver resolverWith(Set<String> existing) {
    return FilenameConflictResolver(
      fileExists: (path) async => existing.contains(path),
    );
  }

  // ---------------------------------------------------------------------------
  // AC1: Duplicate detection
  // ---------------------------------------------------------------------------
  group('AC1 — duplicate detection', () {
    test('returns path unchanged when file does not exist', () async {
      final resolver = resolverWith({});
      final result = await resolver.resolve('/exports/report.csv');
      expect(result, equals('/exports/report.csv'));
    });

    test('detects existing file and returns first free candidate', () async {
      final resolver = resolverWith({'/exports/report.csv'});
      final result = await resolver.resolve('/exports/report.csv');
      expect(result, equals('/exports/report (1).csv'));
    });

    test('works with files that have no extension', () async {
      final resolver = resolverWith({'/exports/backup'});
      final result = await resolver.resolve('/exports/backup');
      expect(result, equals('/exports/backup (1)'));
    });

    test('works with multi-dot filenames (last dot is extension)', () async {
      final resolver = resolverWith({'/exports/report.2024.csv'});
      final result = await resolver.resolve('/exports/report.2024.csv');
      expect(result, equals('/exports/report.2024 (1).csv'));
    });

    test('preserves directory path in resolved name', () async {
      final resolver = resolverWith({'/home/user/documents/data.pdf'});
      final result = await resolver.resolve('/home/user/documents/data.pdf');
      expect(result, startsWith('/home/user/documents/'));
      expect(result, equals('/home/user/documents/data (1).pdf'));
    });
  });

  // ---------------------------------------------------------------------------
  // AC2: Auto-rename logic
  // ---------------------------------------------------------------------------
  group('AC2 — auto-rename incremental logic', () {
    test('skips (1) if already taken and uses (2)', () async {
      final resolver = resolverWith({'/out/file.csv', '/out/file (1).csv'});
      final result = await resolver.resolve('/out/file.csv');
      expect(result, equals('/out/file (2).csv'));
    });

    test('increments through multiple occupied slots', () async {
      final resolver = resolverWith({
        '/out/file.csv',
        '/out/file (1).csv',
        '/out/file (2).csv',
        '/out/file (3).csv',
      });
      final result = await resolver.resolve('/out/file.csv');
      expect(result, equals('/out/file (4).csv'));
    });

    test('handles 10+ conflicts without issue', () async {
      final existing = {'/out/file.csv'};
      for (int i = 1; i <= 15; i++) {
        existing.add('/out/file ($i).csv');
      }
      final resolver = resolverWith(existing);
      final result = await resolver.resolve('/out/file.csv');
      expect(result, equals('/out/file (16).csv'));
    });

    test('timestamp fallback used when maxAttempts exhausted', () async {
      // With maxAttempts = 3, fill slots 1–3 plus the original.
      final existing = {
        '/out/file.csv',
        '/out/file (1).csv',
        '/out/file (2).csv',
        '/out/file (3).csv',
      };
      final resolver = resolverWith(existing);
      final result = await resolver.resolve('/out/file.csv', maxAttempts: 3);
      // Should be a timestamp fallback: stem_<digits>.csv
      expect(result, matches(r'^/out/file_\d+\.csv$'));
    });
  });

  // ---------------------------------------------------------------------------
  // AC3: No silent overwrites
  // ---------------------------------------------------------------------------
  group('AC3 — no silent overwrites', () {
    test('never returns a path that is in the existing set', () async {
      final existing = {
        '/exports/data.pdf',
        '/exports/data (1).pdf',
        '/exports/data (2).pdf',
      };
      final resolver = resolverWith(existing);
      final result = await resolver.resolve('/exports/data.pdf');
      expect(
        existing.contains(result),
        isFalse,
        reason: 'Resolved path must not already exist',
      );
    });

    test('resolved path (3) is not in occupied set', () async {
      final existing = {'/d/f.txt', '/d/f (1).txt', '/d/f (2).txt'};
      final resolver = resolverWith(existing);
      final result = await resolver.resolve('/d/f.txt');
      expect(result, equals('/d/f (3).txt'));
      expect(existing.contains(result), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // AC4: Behaviour documented (edge cases)
  // ---------------------------------------------------------------------------
  group('edge cases', () {
    test('path without directory component is handled', () async {
      // p.dirname('file.csv') returns '.' on all platforms
      final resolver = resolverWith({'file.csv'});
      final result = await resolver.resolve('file.csv');
      // Should be 'file (1).csv' (relative, dot directory stripped by p.join)
      expect(result, endsWith('file (1).csv'));
    });

    test('maxAttempts = 0 immediately jumps to timestamp fallback', () async {
      final resolver = resolverWith({'/out/x.csv'});
      final result = await resolver.resolve('/out/x.csv', maxAttempts: 0);
      expect(result, matches(r'^.*x_\d+\.csv$'));
    });

    test('free path with maxAttempts = 0 returns unchanged', () async {
      final resolver = resolverWith({});
      final result = await resolver.resolve('/out/x.csv', maxAttempts: 0);
      expect(result, equals('/out/x.csv'));
    });

    test('different extensions are preserved for each candidate', () async {
      final resolver = resolverWith({'/d/img.png'});
      final result = await resolver.resolve('/d/img.png');
      expect(result, equals('/d/img (1).png'));
      expect(result.endsWith('.png'), isTrue);
    });

    test('PDF extension preserved in conflict chain', () async {
      final resolver = resolverWith({'/d/report.pdf', '/d/report (1).pdf'});
      final result = await resolver.resolve('/d/report.pdf');
      expect(result, equals('/d/report (2).pdf'));
      expect(result.endsWith('.pdf'), isTrue);
    });
  });
}
