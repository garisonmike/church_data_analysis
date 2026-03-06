import 'package:church_analytics/services/installer_launch_result.dart';
import 'package:church_analytics/services/installer_launch_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // -------------------------------------------------------------------------
  // InstallerLaunchResult
  // -------------------------------------------------------------------------

  group('InstallerLaunchResult', () {
    test('success() has isSuccess=true and null error', () {
      const result = InstallerLaunchResult.success();
      expect(result.isSuccess, isTrue);
      expect(result.isError, isFalse);
      expect(result.error, isNull);
    });

    test('failure() has isSuccess=false and non-null error', () {
      const result = InstallerLaunchResult.failure('Could not open APK');
      expect(result.isSuccess, isFalse);
      expect(result.isError, isTrue);
      expect(result.error, 'Could not open APK');
    });

    test('toString reflects success state', () {
      const r = InstallerLaunchResult.success();
      expect(r.toString(), contains('success'));
    });

    test('toString reflects failure state with message', () {
      const r = InstallerLaunchResult.failure('permission denied');
      expect(r.toString(), contains('failure'));
      expect(r.toString(), contains('permission denied'));
    });
  });

  // -------------------------------------------------------------------------
  // NoOpInstallerLaunchService
  // -------------------------------------------------------------------------

  group('NoOpInstallerLaunchService', () {
    test('always returns a failure result', () async {
      const service = NoOpInstallerLaunchService();
      final result = await service.launch('/some/path/installer.apk');
      expect(result.isError, isTrue);
      expect(result.error, isNotNull);
      expect(result.error, isNotEmpty);
    });

    test('failure message mentions manual install guidance', () async {
      const service = NoOpInstallerLaunchService();
      final result = await service.launch('');
      expect(result.error, contains('manually'));
    });

    test('never throws — returns failure instead', () async {
      const service = NoOpInstallerLaunchService();
      // Passing an empty path must not throw.
      await expectLater(service.launch(''), completes);
    });
  });
}
