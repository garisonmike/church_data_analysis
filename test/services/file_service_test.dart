import 'dart:typed_data';

import 'package:church_analytics/platform/default_export_path_resolver.dart';
import 'package:church_analytics/platform/file_storage_interface.dart';
import 'package:church_analytics/platform/filename_conflict_resolver.dart';
import 'package:church_analytics/services/file_service.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// A [FileStorage] that records the parameters of every [saveFile] /
/// [saveFileBytes] call.  Returns the [fullPath] (or a synthetic path) so
/// that [ExportResult.success] is returned by [FileService].
class _FakeFileStorage implements FileStorage {
  final List<Map<String, dynamic>> saveCalls = [];

  @override
  Future<String?> saveFile({
    required String fileName,
    required String content,
    String? fullPath,
  }) async {
    final recorded = {'fileName': fileName, 'fullPath': fullPath};
    saveCalls.add(recorded);
    return fullPath ?? '/default/$fileName';
  }

  @override
  Future<String?> saveFileBytes({
    required String fileName,
    required Uint8List bytes,
    String? fullPath,
  }) async {
    final recorded = {'fileName': fileName, 'fullPath': fullPath};
    saveCalls.add(recorded);
    return fullPath ?? '/default/$fileName';
  }

  @override
  Future<PlatformFileResult?> pickFile({
    required List<String> allowedExtensions,
  }) async => null;

  @override
  Future<String?> pickSaveLocation({
    required String suggestedName,
    required List<String> allowedExtensions,
  }) async => null;

  @override
  Future<String> readFileAsString(PlatformFileResult file) async => '';

  @override
  Future<Uint8List> readFileAsBytes(PlatformFileResult file) async =>
      Uint8List(0);
}

/// A [DefaultExportPathResolver] that resolves to a hard-coded path without
/// touching the filesystem or `path_provider`.
class _FakeExportPathResolver extends DefaultExportPathResolver {
  final String? fakePath;

  const _FakeExportPathResolver({
    this.fakePath = '/fake/downloads/ChurchAnalytics',
  });

  @override
  Future<String?> resolve() async => fakePath;
}

/// A no-conflict [FilenameConflictResolver] that always returns the given
/// path unchanged (simulates the file not existing).
final _noConflictResolver = FilenameConflictResolver(
  fileExists: (_) async => false,
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

FileService makeService({
  _FakeFileStorage? storage,
  DefaultExportPathResolver? resolver,
}) {
  return FileService(
    fileStorage: storage ?? _FakeFileStorage(),
    conflictResolver: _noConflictResolver,
    exportPathResolver: resolver ?? const _FakeExportPathResolver(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FileService', () {
    // -----------------------------------------------------------------------
    // exportFile — default path (no forcedPath)
    // -----------------------------------------------------------------------

    group('exportFile without forcedPath', () {
      test(
        'passes resolver-derived full path to FileStorage.saveFile',
        () async {
          final storage = _FakeFileStorage();
          const expectedDir = '/fake/downloads/ChurchAnalytics';
          const filename = 'data.csv';

          final service = makeService(
            storage: storage,
            resolver: const _FakeExportPathResolver(fakePath: expectedDir),
          );
          final result = await service.exportFile(
            filename: filename,
            content: 'a,b,c',
          );

          expect(result.success, isTrue);
          expect(storage.saveCalls, hasLength(1));
          expect(
            storage.saveCalls.first['fullPath'],
            equals('$expectedDir/$filename'),
          );
        },
      );

      test(
        'fullPath passed to saveFile is non-null when resolver returns a dir',
        () async {
          final storage = _FakeFileStorage();
          final service = makeService(storage: storage);

          await service.exportFile(filename: 'report.pdf', content: 'content');

          expect(storage.saveCalls.first['fullPath'], isNotNull);
        },
      );

      test(
        'fullPath is null when resolver returns null (Web simulation)',
        () async {
          final storage = _FakeFileStorage();
          final service = makeService(
            storage: storage,
            resolver: const _FakeExportPathResolver(fakePath: null),
          );

          await service.exportFile(filename: 'export.csv', content: 'x');

          expect(storage.saveCalls.first['fullPath'], isNull);
        },
      );

      test(
        'filename is sanitized before being joined to the default dir',
        () async {
          final storage = _FakeFileStorage();
          const dir = '/fake/downloads/ChurchAnalytics';
          final service = makeService(
            storage: storage,
            resolver: const _FakeExportPathResolver(fakePath: dir),
          );

          // Filename with invalid char — sanitizer should clean it.
          await service.exportFile(filename: r'bad:name?.csv', content: 'data');

          final passedPath = storage.saveCalls.first['fullPath'] as String;
          // Should NOT contain ':' or '?'
          expect(passedPath, isNot(contains(':')));
          expect(passedPath, isNot(contains('?')));
          // Should still start with the default dir.
          expect(passedPath, startsWith(dir));
        },
      );

      test(
        'returns ExportResult.success when storage returns a path',
        () async {
          final service = makeService();
          final result = await service.exportFile(
            filename: 'ok.csv',
            content: 'data',
          );
          expect(result.success, isTrue);
          expect(result.filePath, isNotNull);
        },
      );
    });

    // -----------------------------------------------------------------------
    // exportFile — forcedPath (resolver must NOT be called)
    // -----------------------------------------------------------------------

    group('exportFile with forcedPath', () {
      test(
        'passes forcedPath directly to FileStorage — resolver not invoked',
        () async {
          final storage = _FakeFileStorage();
          const forced = '/user/chosen/path/report.csv';

          // Use a resolver that would return a completely different dir.
          final service = makeService(
            storage: storage,
            resolver: const _FakeExportPathResolver(
              fakePath: '/should/not/be/used',
            ),
          );

          await service.exportFile(
            filename: 'report.csv',
            content: 'x',
            forcedPath: forced,
          );

          expect(storage.saveCalls.first['fullPath'], equals(forced));
        },
      );

      test('does not prepend default dir to forcedPath', () async {
        final storage = _FakeFileStorage();
        const forced = '/explicit/dir/out.json';

        final service = makeService(storage: storage);
        await service.exportFile(
          filename: 'out.json',
          content: '{}',
          forcedPath: forced,
        );

        expect(storage.saveCalls.first['fullPath'], equals(forced));
      });
    });

    // -----------------------------------------------------------------------
    // exportFileBytes — default path
    // -----------------------------------------------------------------------

    group('exportFileBytes without forcedPath', () {
      test(
        'passes resolver-derived full path to FileStorage.saveFileBytes',
        () async {
          final storage = _FakeFileStorage();
          const dir = '/fake/downloads/ChurchAnalytics';

          final service = makeService(
            storage: storage,
            resolver: const _FakeExportPathResolver(fakePath: dir),
          );
          await service.exportFileBytes(
            filename: 'chart.png',
            bytes: Uint8List.fromList([1, 2, 3]),
          );

          expect(storage.saveCalls.first['fullPath'], equals('$dir/chart.png'));
        },
      );

      test(
        'fullPath is null when resolver returns null (Web simulation)',
        () async {
          final storage = _FakeFileStorage();
          final service = makeService(
            storage: storage,
            resolver: const _FakeExportPathResolver(fakePath: null),
          );

          await service.exportFileBytes(
            filename: 'chart.png',
            bytes: Uint8List.fromList([1, 2, 3]),
          );

          expect(storage.saveCalls.first['fullPath'], isNull);
        },
      );
    });

    // -----------------------------------------------------------------------
    // exportFileBytes — forcedPath
    // -----------------------------------------------------------------------

    group('exportFileBytes with forcedPath', () {
      test('passes forcedPath directly to FileStorage', () async {
        final storage = _FakeFileStorage();
        const forced = '/user/chosen/chart.png';

        final service = makeService(storage: storage);
        await service.exportFileBytes(
          filename: 'chart.png',
          bytes: Uint8List.fromList([0, 1]),
          forcedPath: forced,
        );

        expect(storage.saveCalls.first['fullPath'], equals(forced));
      });
    });

    // -----------------------------------------------------------------------
    // getDefaultExportPath
    // -----------------------------------------------------------------------

    group('getDefaultExportPath', () {
      test('delegates to the injected resolver', () async {
        const expected = '/fake/downloads/ChurchAnalytics';
        final service = makeService(
          resolver: const _FakeExportPathResolver(fakePath: expected),
        );
        expect(await service.getDefaultExportPath(), equals(expected));
      });

      test('returns null when resolver returns null (Web simulation)', () async {
        final service = makeService(
          resolver: const _FakeExportPathResolver(fakePath: null),
        );
        expect(await service.getDefaultExportPath(), isNull);
      });
    });

    // -----------------------------------------------------------------------
    // ExportResult values
    // -----------------------------------------------------------------------

    group('ExportResult', () {
      test('success result carries filePath returned by storage', () async {
        const returned = '/fake/downloads/ChurchAnalytics/data.csv';
        // Override saveFile to return a specific path.
        final service = FileService(
          fileStorage: _FixedPathStorage(returned),
          conflictResolver: _noConflictResolver,
          exportPathResolver: const _FakeExportPathResolver(
            fakePath: '/fake/downloads/ChurchAnalytics',
          ),
        );

        final result = await service.exportFile(
          filename: 'data.csv',
          content: 'x',
        );
        expect(result.success, isTrue);
        expect(result.filePath, equals(returned));
      });

      test('failure result when storage returns null', () async {
        final service = FileService(
          fileStorage: _NullReturnStorage(),
          conflictResolver: _noConflictResolver,
          exportPathResolver: const _FakeExportPathResolver(),
        );

        final result = await service.exportFile(
          filename: 'data.csv',
          content: 'x',
        );
        expect(result.success, isFalse);
        expect(result.error, isNotNull);
      });
    });
  });
}

// ---------------------------------------------------------------------------
// Additional storage fakes for ExportResult tests
// ---------------------------------------------------------------------------

class _FixedPathStorage extends _FakeFileStorage {
  final String path;
  _FixedPathStorage(this.path);

  @override
  Future<String?> saveFile({
    required String fileName,
    required String content,
    String? fullPath,
  }) async => path;
}

class _NullReturnStorage extends _FakeFileStorage {
  @override
  Future<String?> saveFile({
    required String fileName,
    required String content,
    String? fullPath,
  }) async => null;
}
