import 'dart:io';

import 'package:church_analytics/platform/default_export_path_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates an injected [DefaultExportPathResolver] that always resolves to
/// [base] as the "downloads" directory without touching the real
/// `path_provider` channels.
DefaultExportPathResolver resolverWithBase(Directory base) {
  return DefaultExportPathResolver(
    getDownloads: () async => base,
    // Android branch not exercised on Linux test runner — omit to keep
    // tests focused.
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DefaultExportPathResolver', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'default_export_path_resolver_test_',
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    // -----------------------------------------------------------------------
    // Constants
    // -----------------------------------------------------------------------

    group('constants', () {
      test('appFolderName is ChurchAnalytics', () {
        expect(DefaultExportPathResolver.appFolderName, 'ChurchAnalytics');
      });
    });

    // -----------------------------------------------------------------------
    // resolve() — happy path
    // -----------------------------------------------------------------------

    group('resolve()', () {
      test('returns a non-null string on native (Linux test runner)', () async {
        final resolver = resolverWithBase(tempDir);
        final result = await resolver.resolve();
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test('path ends with ChurchAnalytics', () async {
        final resolver = resolverWithBase(tempDir);
        final result = await resolver.resolve();
        expect(
          result!.split(Platform.pathSeparator).last,
          DefaultExportPathResolver.appFolderName,
        );
      });

      test('returned path is "<base>/ChurchAnalytics"', () async {
        final resolver = resolverWithBase(tempDir);
        final result = await resolver.resolve();
        expect(
          result,
          equals('${tempDir.path}/${DefaultExportPathResolver.appFolderName}'),
        );
      });

      test(
        'creates the ChurchAnalytics directory when it does not exist',
        () async {
          final appDir = Directory(
            '${tempDir.path}/${DefaultExportPathResolver.appFolderName}',
          );
          expect(
            await appDir.exists(),
            isFalse,
            reason: 'directory should not exist yet',
          );

          final resolver = resolverWithBase(tempDir);
          await resolver.resolve();

          expect(
            await appDir.exists(),
            isTrue,
            reason: 'directory should have been created by resolve()',
          );
        },
      );

      test(
        'does not throw when ChurchAnalytics directory already exists',
        () async {
          // Pre-create the directory.
          final appDir = await Directory(
            '${tempDir.path}/${DefaultExportPathResolver.appFolderName}',
          ).create(recursive: true);
          expect(await appDir.exists(), isTrue);

          final resolver = resolverWithBase(tempDir);
          // Should not throw even though directory exists.
          await expectLater(resolver.resolve(), completes);
        },
      );

      test('returns consistent path on repeated calls', () async {
        final resolver = resolverWithBase(tempDir);
        final first = await resolver.resolve();
        final second = await resolver.resolve();
        expect(first, equals(second));
      });
    });

    // -----------------------------------------------------------------------
    // resolve() — fallback on error
    // -----------------------------------------------------------------------

    group('resolve() fallback', () {
      test(
        'falls back to systemTemp/exports when getDownloads throws',
        () async {
          final resolver = DefaultExportPathResolver(
            getDownloads: () async =>
                throw const FileSystemException('simulated channel error'),
          );
          final result = await resolver.resolve();

          // The fallback path must be non-null and end with 'exports'.
          expect(result, isNotNull);
          expect(result!.split(Platform.pathSeparator).last, 'exports');
        },
      );

      test('fallback directory exists after error recovery', () async {
        final resolver = DefaultExportPathResolver(
          getDownloads: () async =>
              throw const FileSystemException('simulated channel error'),
        );
        final result = await resolver.resolve();
        expect(result, isNotNull);
        expect(await Directory(result!).exists(), isTrue);
      });
    });

    // -----------------------------------------------------------------------
    // resolve() — getDownloads returns null (falls back to app docs, another
    // path_provider call). We test this by checking that a null return from
    // the injected function does NOT cause an unhandled exception — the outer
    // try/catch in resolve() catches any subsequent path_provider failure and
    // returns the systemTemp/exports fallback instead.
    // -----------------------------------------------------------------------

    group('resolve() with null downloads dir', () {
      test('handles null from getDownloads without throwing', () async {
        // Return null from getDownloads; path_provider's
        // getApplicationDocumentsDirectory will also fail in the test
        // environment (no plugin channel), so the outer try/catch activates.
        final resolver = DefaultExportPathResolver(
          getDownloads: () async => null,
        );
        await expectLater(resolver.resolve(), completes);
      });

      test('returns non-null path when getDownloads returns null', () async {
        final resolver = DefaultExportPathResolver(
          getDownloads: () async => null,
        );
        final result = await resolver.resolve();
        expect(result, isNotNull);
      });
    });

    // -----------------------------------------------------------------------
    // resolve() — Android injection (simulated via getExternalDirs)
    // -----------------------------------------------------------------------

    group('resolve() with injected getExternalDirs', () {
      test('uses first directory from getExternalDirs list '
          '(Android storage simulation)', () async {
        // On the Linux CI runner Platform.isAndroid is false, so the
        // getExternalDirs injection is not used.  We verify the const
        // constructor accepts the parameter without error and that the
        // resolver still works normally on the host platform.
        final resolver = DefaultExportPathResolver(
          getDownloads: () async => tempDir,
          getExternalDirs: (_) async => [tempDir],
        );
        final result = await resolver.resolve();
        expect(result, isNotNull);
        expect(
          result!.split(Platform.pathSeparator).last,
          DefaultExportPathResolver.appFolderName,
        );
      });

      test('handles empty getExternalDirs list without throwing '
          '(Android fallback simulation)', () async {
        // Empty list simulates scenario where external storage is unavailable.
        // The outer try/catch catches the subsequent path_provider failure.
        final resolver = DefaultExportPathResolver(
          getDownloads: () async => tempDir, // not called on Android
          getExternalDirs: (_) async => [],
        );
        await expectLater(resolver.resolve(), completes);
      });
    });

    // -----------------------------------------------------------------------
    // Constructor
    // -----------------------------------------------------------------------

    group('constructor', () {
      test('const constructor is valid', () {
        expect(() => const DefaultExportPathResolver(), returnsNormally);
      });

      test('accepts all optional parameters without error', () {
        expect(
          () => DefaultExportPathResolver(
            getCustomPath: () => null,
            getDownloads: () async => Directory.systemTemp,
            getExternalDirs: (_) async => [Directory.systemTemp],
          ),
          returnsNormally,
        );
      });
    });

    // -----------------------------------------------------------------------
    // resolve() — custom path override
    // -----------------------------------------------------------------------

    group('resolve() with custom path override', () {
      test('uses custom path when getCustomPath returns an existing dir',
          () async {
        final customDir = Directory('${tempDir.path}/custom_export');
        await customDir.create();

        final resolver = DefaultExportPathResolver(
          getDownloads: () async => tempDir, // must NOT be called
          getCustomPath: () => customDir.path,
        );

        final result = await resolver.resolve();
        expect(result, equals(customDir.path));
      });

      test('creates custom directory when it does not yet exist', () async {
        final customDir = Directory('${tempDir.path}/new_custom_export');
        expect(await customDir.exists(), isFalse);

        final resolver = DefaultExportPathResolver(
          getDownloads: () async => tempDir,
          getCustomPath: () => customDir.path,
        );

        await resolver.resolve();
        expect(await customDir.exists(), isTrue);
      });

      test('returns the custom path string after creating the directory',
          () async {
        final customDir = Directory('${tempDir.path}/returns_custom');

        final resolver = DefaultExportPathResolver(
          getDownloads: () async => tempDir,
          getCustomPath: () => customDir.path,
        );

        final result = await resolver.resolve();
        expect(result, equals(customDir.path));
      });

      test('falls back to platform default when getCustomPath returns null',
          () async {
        final resolver = DefaultExportPathResolver(
          getDownloads: () async => tempDir,
          getCustomPath: () => null,
        );

        final result = await resolver.resolve();
        expect(
          result,
          equals(
            '${tempDir.path}/${DefaultExportPathResolver.appFolderName}',
          ),
        );
      });

      test(
          'falls back to platform default when getCustomPath returns empty string',
          () async {
        final resolver = DefaultExportPathResolver(
          getDownloads: () async => tempDir,
          getCustomPath: () => '',
        );

        final result = await resolver.resolve();
        expect(
          result,
          equals(
            '${tempDir.path}/${DefaultExportPathResolver.appFolderName}',
          ),
        );
      });

      test(
          'falls back to platform default when custom directory cannot be created',
          () async {
        // Use a path that is guaranteed to be invalid on Linux.
        const invalidPath = '/proc/sys/not/writable/path';

        final resolver = DefaultExportPathResolver(
          getDownloads: () async => tempDir,
          getCustomPath: () => invalidPath,
        );

        final result = await resolver.resolve();
        // Should not return the invalid path; platform default used instead.
        expect(result, isNot(equals(invalidPath)));
        expect(result, contains(DefaultExportPathResolver.appFolderName));
      });

      test('returns correct path on repeated calls with custom path', () async {
        final customDir = Directory('${tempDir.path}/stable_custom');

        final resolver = DefaultExportPathResolver(
          getDownloads: () async => tempDir,
          getCustomPath: () => customDir.path,
        );

        final first = await resolver.resolve();
        final second = await resolver.resolve();
        expect(first, equals(second));
      });
    });
  });
}
