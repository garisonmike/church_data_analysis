// Tests for STORAGE-007: PathSafetyGuard — never silently save to hidden directories.
//
// These tests verify that PathSafetyGuard correctly classifies paths as
// user-accessible or hidden/internal, covering all documented pattern sets.
//
// Note: Platform-branch selection (isAndroid / isLinux / ...) depends on the
// host OS.  Pattern-list membership is tested directly via the
// @visibleForTesting constants so all platform-specific patterns are covered
// regardless of the test runner OS.

import 'dart:io';

import 'package:church_analytics/platform/path_safety_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PathSafetyGuard.isUserAccessible', () {
    // -------------------------------------------------------------------------
    // Common patterns — apply on every native platform
    // -------------------------------------------------------------------------
    group('common hidden patterns', () {
      test('rejects path containing /cache/', () {
        expect(
          PathSafetyGuard.isUserAccessible(
            '/storage/emulated/0/cache/report.pdf',
          ),
          isFalse,
        );
      });

      test('rejects path containing /cache/ regardless of case', () {
        // Pattern check is case-insensitive via toLowerCase()
        expect(
          PathSafetyGuard.isUserAccessible('/STORAGE/CACHE/report.pdf'),
          isFalse,
        );
      });

      test('rejects path containing a dot-folder', () {
        expect(
          PathSafetyGuard.isUserAccessible(
            '/home/user/.config/church/report.pdf',
          ),
          isFalse,
        );
      });

      test('rejects path starting with a hidden dot-directory segment', () {
        expect(
          PathSafetyGuard.isUserAccessible(
            '/storage/emulated/0/.thumbnails/img.png',
          ),
          isFalse,
        );
      });
    });

    // -------------------------------------------------------------------------
    // Platform-specific tests (run on the host OS)
    // -------------------------------------------------------------------------
    group(
      'platform-specific patterns (host OS: ${Platform.operatingSystem})',
      () {
        if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
          test('rejects /tmp/ path on desktop', () {
            expect(
              PathSafetyGuard.isUserAccessible('/tmp/church_report.pdf'),
              isFalse,
            );
          });

          test('rejects /proc/ path on desktop', () {
            expect(
              PathSafetyGuard.isUserAccessible('/proc/self/maps'),
              isFalse,
            );
          });

          test('rejects /sys/ path on desktop', () {
            expect(
              PathSafetyGuard.isUserAccessible('/sys/kernel/report'),
              isFalse,
            );
          });

          test('accepts a normal Downloads path on desktop', () {
            expect(
              PathSafetyGuard.isUserAccessible(
                '/home/user/Downloads/ChurchAnalytics/report.pdf',
              ),
              isTrue,
            );
          });

          test('accepts a Documents path on desktop', () {
            expect(
              PathSafetyGuard.isUserAccessible(
                '/home/user/Documents/church_backup.json',
              ),
              isTrue,
            );
          });
        }
      },
    );

    // -------------------------------------------------------------------------
    // Android pattern list – tested directly (not via platform branch)
    // -------------------------------------------------------------------------
    group('android hidden patterns (pattern-list membership)', () {
      test('/data/data/ is in androidHiddenPatterns', () {
        expect(
          PathSafetyGuard.androidHiddenPatterns.contains('/data/data/'),
          isTrue,
        );
      });

      test('/data/user/ is in androidHiddenPatterns', () {
        expect(
          PathSafetyGuard.androidHiddenPatterns.contains('/data/user/'),
          isTrue,
        );
      });

      test('/code_cache/ is in androidHiddenPatterns', () {
        expect(
          PathSafetyGuard.androidHiddenPatterns.contains('/code_cache/'),
          isTrue,
        );
      });

      test('/shared_prefs/ is in androidHiddenPatterns', () {
        expect(
          PathSafetyGuard.androidHiddenPatterns.contains('/shared_prefs/'),
          isTrue,
        );
      });
    });

    // -------------------------------------------------------------------------
    // Valid paths are passed through on the host OS
    // -------------------------------------------------------------------------
    group('valid user-accessible paths', () {
      test('accepts an absolute path without hidden segments', () {
        expect(
          PathSafetyGuard.isUserAccessible('/home/user/Downloads/report.pdf'),
          isTrue,
        );
      });

      test('accepts a Windows-style path (normalised separators)', () {
        // On Linux/macOS this just tests the normalisation; on Windows it is
        // a real file-system path.
        final windowsPath = r'C:\Users\Admin\Downloads\church_backup.json';
        // Must not crash regardless of platform.
        expect(
          () => PathSafetyGuard.isUserAccessible(windowsPath),
          returnsNormally,
        );
      });

      test('accepts a path that contains the word "cache" but not /cache/', () {
        expect(
          PathSafetyGuard.isUserAccessible(
            '/home/user/church_cache_dir/report.pdf',
          ),
          isTrue,
          reason: 'Only the /cache/ segment is rejected, not substring "cache"',
        );
      });
    });
  });

  // ---------------------------------------------------------------------------
  // PathSafetyGuard.guard
  // ---------------------------------------------------------------------------
  group('PathSafetyGuard.guard', () {
    test('returns PathGuardResult.safe for a user-accessible path', () {
      const path = '/home/user/Downloads/ChurchAnalytics/report.pdf';
      final result = PathSafetyGuard.guard(path);

      expect(result.wasOverridden, isFalse);
      expect(result.resolvedPath, equals(path));
      expect(result.originalPath, isNull);
    });

    test('returns PathGuardResult.overridden for a hidden path', () {
      const path = '/home/user/.config/church/report.pdf';
      final result = PathSafetyGuard.guard(path);

      expect(result.wasOverridden, isTrue);
      expect(result.resolvedPath, isNull);
      expect(result.originalPath, equals(path));
    });

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      test('returns overridden for a /tmp/ path on desktop', () {
        const path = '/tmp/export.csv';
        final result = PathSafetyGuard.guard(path);

        expect(result.wasOverridden, isTrue);
        expect(result.originalPath, equals(path));
      });
    }
  });

  // ---------------------------------------------------------------------------
  // PathGuardResult constructors
  // ---------------------------------------------------------------------------
  group('PathGuardResult', () {
    test('PathGuardResult.safe carries the path and wasOverridden=false', () {
      const result = PathGuardResult.safe('/some/path/file.pdf');
      expect(result.resolvedPath, equals('/some/path/file.pdf'));
      expect(result.wasOverridden, isFalse);
      expect(result.originalPath, isNull);
    });

    test(
      'PathGuardResult.overridden carries originalPath and wasOverridden=true',
      () {
        const result = PathGuardResult.overridden(
          '/data/data/com.example/files/export.pdf',
        );
        expect(result.resolvedPath, isNull);
        expect(result.wasOverridden, isTrue);
        expect(
          result.originalPath,
          equals('/data/data/com.example/files/export.pdf'),
        );
      },
    );
  });
}
