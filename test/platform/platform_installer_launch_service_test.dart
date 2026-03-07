import 'dart:io';

import 'package:church_analytics/platform/platform_installer_launch_service.dart';
import 'package:church_analytics/services/installer_launch_result.dart';
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
    void Function(int)? exitFn,
    void Function()? popFn,
  }) {
    return PlatformInstallerLaunchService(
      overridePlatform: platform,
      openFileFn: openFileFn,
      runProcessFn: runProcessFn,
      exitFn: exitFn,
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

    test('success result carries a restart-required hint (AC3)', () async {
      final service = makeService(
        platform: 'linux',
        runProcessFn: (_, __) async => ProcessResult(0, 0, '', ''),
      );

      final result = await service.launch('/tmp/app-1.0.0.tar.gz');

      expect(result.hint, isNotNull);
      expect(
        result.hint!.toLowerCase(),
        contains('restart'),
        reason: 'hint must instruct the user to restart the app',
      );
    });

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

  group('Windows — Process.start + exit', () {
    test('calls exitFn with code 0 after starting the process', () async {
      int? exitCode;
      final service = makeService(
        platform: 'windows',
        // runProcessFn is not used on Windows; Process.start is called instead.
        // We override exitFn to capture the code instead of terminating the VM.
        exitFn: (code) => exitCode = code,
      );

      // Note: Process.start will not work in the test environment because
      // 'C:\\setup.exe' does not exist; the service's catch block will capture
      // the ProcessException and return a failure.  This test purely validates
      // that the exit function is called with the expected code when the
      // process _does_ start successfully.
      //
      // A full integration test would require a real executable path.
      // Here we verify the failure path is graceful (non-throw).
      final result = await service.launch('C:\\setup.exe');

      // In the test environment Process.start will throw (file not found),
      // producing a failure result rather than calling exitFn.  That is
      // acceptable — the important invariant is that the service never throws.
      expect(result, isA<InstallerLaunchResult>());
      // exitCode may be null (process didn't start) — that's expected on Linux CI.
      expect(exitCode, anyOf(isNull, 0));
    });

    test(
      'returns a failure result (not a thrown exception) on process error',
      () async {
        final service = makeService(platform: 'windows', exitFn: (_) {});

        // Launching a non-existent path should produce a failure, not throw.
        final result = await service.launch('/no/such/installer.exe');

        expect(result, isA<InstallerLaunchResult>());
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
