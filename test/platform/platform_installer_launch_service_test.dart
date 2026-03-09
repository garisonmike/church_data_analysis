import 'dart:io';

import 'package:church_analytics/platform/platform_installer_launch_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_file/open_file.dart';

void main() {
  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  const kFakePath = '/tmp/app-1.0.0.apk';

  PlatformInstallerLaunchService makeService({
    required String platform,
    OpenFileFn? openFileFn,
    RunProcessFn? runProcessFn,
    void Function()? popFn,
  }) {
    return PlatformInstallerLaunchService(
      overridePlatform: platform,
      openFileFn: openFileFn,
      runProcessFn: runProcessFn,
      popFn: popFn,
    );
  }

  // -------------------------------------------------------------------------
  // Web
  // -------------------------------------------------------------------------

  group('Web — no-op', () {
    test('returns success without any I/O', () async {
      var fileFnCalled = false;
      final service = makeService(
        platform: 'web',
        openFileFn: (_) async {
          fileFnCalled = true;
          return OpenResult(type: ResultType.done);
        },
      );

      final result = await service.launch(kFakePath);

      expect(result.isSuccess, isTrue);
      expect(fileFnCalled, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // Android
  // -------------------------------------------------------------------------

  group('Android — APK install via open_file', () {
    test('returns success when OpenFile returns done', () async {
      final service = makeService(
        platform: 'android',
        openFileFn: (_) async => OpenResult(type: ResultType.done),
        popFn: () {},
      );

      final result = await service.launch(kFakePath);

      expect(result.isSuccess, isTrue);
      expect(result.error, isNull);
    });

    test(
      'returns failure with instructions when permission is denied',
      () async {
        final service = makeService(
          platform: 'android',
          openFileFn: (_) async =>
              OpenResult(type: ResultType.permissionDenied),
        );

        final result = await service.launch(kFakePath);

        expect(result.isError, isTrue);
        expect(result.error, isNotNull);
        // Should contain actionable instructions for the Android settings path.
        expect(result.error, contains('Settings'));
      },
    );

    test('returns failure when file not found', () async {
      final service = makeService(
        platform: 'android',
        openFileFn: (_) async => OpenResult(type: ResultType.fileNotFound),
      );

      final result = await service.launch(kFakePath);

      expect(result.isError, isTrue);
      expect(result.error, isNotNull);
    });

    test('returns failure when no app can handle the file type', () async {
      final service = makeService(
        platform: 'android',
        openFileFn: (_) async => OpenResult(type: ResultType.noAppToOpen),
      );

      final result = await service.launch(kFakePath);

      expect(result.isError, isTrue);
      expect(result.error, isNotNull);
    });

    test('returns failure with non-empty message on generic error', () async {
      const errMsg = 'ActivityNotFound';
      final service = makeService(
        platform: 'android',
        openFileFn: (_) async =>
            OpenResult(type: ResultType.error, message: errMsg),
      );

      final result = await service.launch(kFakePath);

      expect(result.isError, isTrue);
      expect(result.error, contains(errMsg));
    });

    test('passes the installer path to the open-file function', () async {
      String? receivedPath;
      final service = makeService(
        platform: 'android',
        openFileFn: (path) async {
          receivedPath = path;
          return OpenResult(type: ResultType.done);
        },
        popFn: () {},
      );

      await service.launch(kFakePath);

      expect(receivedPath, kFakePath);
    });

    test('calls popFn after successful APK handoff (AC6)', () async {
      var popCalled = false;
      final service = makeService(
        platform: 'android',
        openFileFn: (_) async => OpenResult(type: ResultType.done),
        popFn: () => popCalled = true,
      );

      await service.launch(kFakePath);

      expect(popCalled, isTrue);
    });

    test('does not call popFn when APK launch fails', () async {
      var popCalled = false;
      final service = makeService(
        platform: 'android',
        openFileFn: (_) async => OpenResult(type: ResultType.permissionDenied),
        popFn: () => popCalled = true,
      );

      await service.launch(kFakePath);

      expect(popCalled, isFalse);
    });

    // -----------------------------------------------------------------------
    // Android-specific installation failure detection (Issue 6 — 6.2 / 6.4)
    // -----------------------------------------------------------------------

    group('Android — specific installation failure detection', () {
      test(
        'returns signature-mismatch guidance for INSTALL_FAILED_UPDATE_INCOMPATIBLE',
        () async {
          final service = makeService(
            platform: 'android',
            openFileFn: (_) async => OpenResult(
              type: ResultType.error,
              message: 'INSTALL_FAILED_UPDATE_INCOMPATIBLE',
            ),
          );

          final result = await service.launch(kFakePath);

          expect(result.isError, isTrue);
          // Should mention uninstalling as the recovery step.
          expect(result.error!.toLowerCase(), contains('uninstall'));
          // Should not expose the raw Android error code to the user.
          expect(
            result.error,
            isNot(equals('INSTALL_FAILED_UPDATE_INCOMPATIBLE')),
          );
        },
      );

      test(
        'returns signature-mismatch guidance for INSTALL_PARSE_FAILED_INCONSISTENT_CERTIFICATES',
        () async {
          final service = makeService(
            platform: 'android',
            openFileFn: (_) async => OpenResult(
              type: ResultType.error,
              message: 'INSTALL_PARSE_FAILED_INCONSISTENT_CERTIFICATES',
            ),
          );

          final result = await service.launch(kFakePath);

          expect(result.isError, isTrue);
          expect(result.error!.toLowerCase(), contains('uninstall'));
        },
      );

      test(
        'returns version-downgrade message for INSTALL_FAILED_VERSION_DOWNGRADE',
        () async {
          final service = makeService(
            platform: 'android',
            openFileFn: (_) async => OpenResult(
              type: ResultType.error,
              message: 'INSTALL_FAILED_VERSION_DOWNGRADE',
            ),
          );

          final result = await service.launch(kFakePath);

          expect(result.isError, isTrue);
          expect(result.error!.toLowerCase(), contains('downgrade'));
        },
      );

      test(
        'returns conflict message for INSTALL_FAILED_CONFLICTING_PROVIDER',
        () async {
          final service = makeService(
            platform: 'android',
            openFileFn: (_) async => OpenResult(
              type: ResultType.error,
              message: 'INSTALL_FAILED_CONFLICTING_PROVIDER',
            ),
          );

          final result = await service.launch(kFakePath);

          expect(result.isError, isTrue);
          expect(result.error!.toLowerCase(), contains('conflict'));
        },
      );

      test('returns generic fallback for unrecognised empty error', () async {
        final service = makeService(
          platform: 'android',
          openFileFn: (_) async =>
              OpenResult(type: ResultType.error, message: ''),
        );

        final result = await service.launch(kFakePath);

        expect(result.isError, isTrue);
        // Generic message must not be empty.
        expect(result.error, isNotNull);
        expect(result.error, isNotEmpty);
      });

      test('returns raw message for unrecognised non-empty error', () async {
        const rawMsg = 'INSTALL_FAILED_SOME_UNKNOWN_REASON';
        final service = makeService(
          platform: 'android',
          openFileFn: (_) async =>
              OpenResult(type: ResultType.error, message: rawMsg),
        );

        final result = await service.launch(kFakePath);

        expect(result.isError, isTrue);
        expect(result.error, equals(rawMsg));
      });
    });
  });

  // -------------------------------------------------------------------------
  // Linux
  // -------------------------------------------------------------------------

  group('Linux — tar extraction', () {
    test('returns success when tar exits with code 0', () async {
      final service = makeService(
        platform: 'linux',
        runProcessFn: (_, __) async =>
            ProcessResult(0, 0, '', ''), // exitCode 0 = success
      );

      final result = await service.launch('/tmp/app-1.0.0.tar.gz');

      expect(result.isSuccess, isTrue);
    });

    test(
      'success result carries extraction path and copy instructions (AC3)',
      () async {
        final service = makeService(
          platform: 'linux',
          runProcessFn: (_, __) async => ProcessResult(0, 0, '', ''),
        );

        final result = await service.launch('/tmp/app-1.0.0.tar.gz');

        expect(result.hint, isNotNull);
        // The hint must expose the extraction directory (/tmp) so the user
        // knows where to find the extracted files.
        expect(
          result.hint,
          contains('/tmp'),
          reason: 'hint must include the extraction directory path',
        );
        // The hint must instruct the user to copy the files — not merely restart.
        expect(
          result.hint!.toLowerCase(),
          contains('copy'),
          reason:
              'hint must instruct the user to copy files to their install folder',
        );
      },
    );

    test('returns failure when tar exits with non-zero code', () async {
      final service = makeService(
        platform: 'linux',
        runProcessFn: (_, __) async =>
            ProcessResult(0, 1, '', 'tar: cannot open: no such file'),
      );

      final result = await service.launch('/tmp/app-1.0.0.tar.gz');

      expect(result.isError, isTrue);
      expect(result.error, isNotNull);
    });

    test('passes correct tar arguments for the installer path', () async {
      String? capturedExe;
      List<String>? capturedArgs;

      final service = makeService(
        platform: 'linux',
        runProcessFn: (exe, args) async {
          capturedExe = exe;
          capturedArgs = args;
          return ProcessResult(0, 0, '', '');
        },
      );

      await service.launch('/tmp/app-1.0.0.tar.gz');

      expect(capturedExe, 'tar');
      expect(capturedArgs, contains('-xzf'));
      expect(capturedArgs, contains('/tmp/app-1.0.0.tar.gz'));
      // Destination directory should be the parent of the installer file.
      expect(capturedArgs, contains('/tmp'));
    });

    test('returns failure and includes stderr in message', () async {
      const stderrMsg = 'gzip: stdin: not in gzip format';
      final service = makeService(
        platform: 'linux',
        runProcessFn: (_, __) async => ProcessResult(0, 1, '', stderrMsg),
      );

      final result = await service.launch('/tmp/app.tar.gz');

      expect(result.isError, isTrue);
      expect(result.error, contains(stderrMsg));
    });
  });

  // -------------------------------------------------------------------------
  // Windows
  // -------------------------------------------------------------------------

  group('Windows — PowerShell Expand-Archive', () {
    test('returns success with hint when powershell exits 0', () async {
      final service = makeService(
        platform: 'windows',
        runProcessFn: (cmd, args) async => ProcessResult(
          0, // pid
          0, // exitCode — success
          '', // stdout
          '',
        ),
      );

      final result = await service.launch('C:\\Downloads\\update.zip');

      expect(result.isSuccess, isTrue);
      expect(result.hint, isNotNull);
      expect(result.hint, contains('ChurchAnalytics-Update'));
    });

    test('returns failure when powershell fails', () async {
      final service = makeService(
        platform: 'windows',
        runProcessFn: (cmd, args) async => ProcessResult(
          0,
          1, // non-zero exit code
          '',
          'Expand-Archive: Cannot create file',
        ),
      );

      final result = await service.launch('C:\\Downloads\\update.zip');

      expect(result.isError, isTrue);
      expect(result.error, contains('Failed to extract'));
    });

    test(
      'returns a failure result (not a thrown exception) on process error',
      () async {
        final service = makeService(
          platform: 'windows',
          runProcessFn: (cmd, args) =>
              Future.error(Exception('process failed')),
        );

        final result = await service.launch('C:\\Downloads\\update.zip');

        expect(result.isError, isTrue);
      },
    );
  });

  // -------------------------------------------------------------------------
  // macOS / iOS / unknown
  // -------------------------------------------------------------------------

  group('Unsupported platforms', () {
    for (final platform in ['macos', 'ios', 'unknown']) {
      test(
        '$platform returns failure with manual-install instructions',
        () async {
          final service = makeService(platform: platform);

          final result = await service.launch(kFakePath);

          expect(result.isError, isTrue);
          expect(result.error, isNotNull);
          expect(result.error!.toLowerCase(), contains('github'));
        },
      );
    }
  });

  // -------------------------------------------------------------------------
  // Exception safety
  // -------------------------------------------------------------------------

  group('Exception safety', () {
    test('never throws even when openFileFn throws', () async {
      final service = makeService(
        platform: 'android',
        openFileFn: (_) async => throw Exception('unexpected crash'),
      );

      expect(() => service.launch(kFakePath), returnsNormally);

      final result = await service.launch(kFakePath);
      expect(result.isError, isTrue);
    });

    test('never throws even when runProcessFn throws on Linux', () async {
      final service = makeService(
        platform: 'linux',
        runProcessFn: (_, __) async => throw Exception('process failed'),
      );

      expect(() => service.launch(kFakePath), returnsNormally);

      final result = await service.launch(kFakePath);
      expect(result.isError, isTrue);
    });
  });
}
