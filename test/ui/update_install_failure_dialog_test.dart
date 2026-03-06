import 'dart:convert';

import 'package:church_analytics/services/activity_log_service.dart';
import 'package:church_analytics/services/installer_launch_result.dart';
import 'package:church_analytics/services/installer_launch_service.dart';
import 'package:church_analytics/services/update_service.dart';
import 'package:church_analytics/ui/widgets/about_updates_card.dart';
import 'package:church_analytics/ui/widgets/update_install_failure_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

/// An [InstallerLaunchService] that always returns a failure with [error].
class _FailingLaunchService implements InstallerLaunchService {
  final String error;
  int launchCallCount = 0;

  _FailingLaunchService({this.error = 'Test launch failure'});

  @override
  Future<InstallerLaunchResult> launch(String installerPath) async {
    launchCallCount++;
    return InstallerLaunchResult.failure(error);
  }
}

/// An [InstallerLaunchService] that always returns success.
class _SucceedingLaunchService implements InstallerLaunchService {
  int launchCallCount = 0;

  @override
  Future<InstallerLaunchResult> launch(String installerPath) async {
    launchCallCount++;
    return const InstallerLaunchResult.success();
  }
}

/// A recording [ActivityLogService] for assertion in tests.
class _RecordingActivityLog implements ActivityLogService {
  final List<Map<String, dynamic>> installerLogs = [];

  @override
  void logExport({
    required String filename,
    required String? path,
    required bool success,
    String? error,
  }) {}

  @override
  void logImport({
    required String filename,
    required bool success,
    String? error,
  }) {}

  @override
  void logInstallerLaunch({
    required bool success,
    String? platform,
    String? error,
  }) {
    installerLogs.add({
      'success': success,
      'platform': platform,
      'error': error,
    });
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const kManifestUrl = 'https://example.com/update.json';

Map<String, dynamic> makeManifestJson(String version) => {
  'version': version,
  'release_date': '2026-01-01',
  'min_supported_version': '1.0.0',
  'release_notes': 'Release $version',
  'platforms': {
    'android': {
      'download_url':
          'https://github.com/example/releases/download/$version/app.apk',
      'sha256': 'a' * 64,
    },
  },
};

/// Builds a testable widget that shows [AboutUpdatesCard] in an update-available
/// state, wired with the given [launchService] and [activityLog].
Widget buildCardWithUpdateAvailable({
  required InstallerLaunchService launchService,
  required ActivityLogService activityLog,
}) {
  final rawManigest = jsonEncode(makeManifestJson('99.0.0'));
  final service = UpdateService(
    client: MockClient((_) async => http.Response(rawManigest, 200)),
    manifestUrl: kManifestUrl,
    getPackageInfo: () async => PackageInfo(
      appName: 'church_analytics',
      packageName: 'com.example.church_analytics',
      version: '1.0.0',
      buildNumber: '1',
    ),
  );

  return ProviderScope(
    overrides: [updateServiceProvider.overrideWithValue(service)],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: AboutUpdatesCard(
            launchService: launchService,
            activityLog: activityLog,
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'church_analytics',
      packageName: 'com.example.church_analytics',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  // -------------------------------------------------------------------------
  // UpdateInstallFailureDialog — widget content
  // -------------------------------------------------------------------------

  group('UpdateInstallFailureDialog — widget content', () {
    testWidgets('renders title, main message, and action buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UpdateInstallFailureDialog())),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('install_failure_title')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('install_failure_message')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('install_failure_dismiss_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('install_failure_github_button')),
        findsOneWidget,
      );
    });

    testWidgets('shows errorDetail when provided', (tester) async {
      const detail = 'Process exit code 1: permission denied';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UpdateInstallFailureDialog(errorDetail: detail)),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('install_failure_detail')),
        findsOneWidget,
      );
      expect(find.text(detail), findsWidgets);
    });

    testWidgets('does NOT show errorDetail widget when errorDetail is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UpdateInstallFailureDialog())),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('install_failure_detail')),
        findsNothing,
      );
    });

    testWidgets('shows manual install instructions box', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UpdateInstallFailureDialog())),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('manual_install_instructions')),
        findsOneWidget,
      );
      expect(find.textContaining('manually'), findsWidgets);
    });

    testWidgets('show() helper presents dialog via showDialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => UpdateInstallFailureDialog.show(ctx),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('install_failure_title')),
        findsOneWidget,
      );
    });

    testWidgets('Dismiss button closes the dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => UpdateInstallFailureDialog.show(ctx),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('install_failure_title')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('install_failure_dismiss_button')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('install_failure_title')), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // AboutUpdatesCard — failure recovery integration
  // -------------------------------------------------------------------------

  group('AboutUpdatesCard — install failure recovery (UPDATE-011)', () {
    Future<void> reachUpdateAvailableState(WidgetTester tester) async {
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('check_updates_button')));
      await tester.pumpAndSettle();
    }

    testWidgets(
      '"Download Update" tap shows UpdateInstallFailureDialog when launch fails',
      (tester) async {
        final launchService = _FailingLaunchService(
          error: 'APK intent not supported',
        );
        final activityLog = _RecordingActivityLog();

        await tester.pumpWidget(
          buildCardWithUpdateAvailable(
            launchService: launchService,
            activityLog: activityLog,
          ),
        );

        await reachUpdateAvailableState(tester);

        // The "update available" state must be showing.
        expect(
          find.byKey(const ValueKey('update_available_result')),
          findsOneWidget,
        );

        // Tap "Download Update".
        await tester.tap(find.byKey(const ValueKey('download_update_button')));
        await tester.pumpAndSettle();

        // Failure dialog must be visible.
        expect(
          find.byKey(const ValueKey('install_failure_title')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'failure dialog shows the error detail from InstallerLaunchService',
      (tester) async {
        const errorMsg = 'Could not open APK installer';
        final launchService = _FailingLaunchService(error: errorMsg);
        final activityLog = _RecordingActivityLog();

        await tester.pumpWidget(
          buildCardWithUpdateAvailable(
            launchService: launchService,
            activityLog: activityLog,
          ),
        );
        await reachUpdateAvailableState(tester);

        await tester.tap(find.byKey(const ValueKey('download_update_button')));
        await tester.pumpAndSettle();

        // The error text from the service must appear in the dialog.
        expect(find.text(errorMsg), findsWidgets);
      },
    );

    testWidgets(
      'ActivityLogService.logInstallerLaunch called with success=false on failure',
      (tester) async {
        final launchService = _FailingLaunchService();
        final activityLog = _RecordingActivityLog();

        await tester.pumpWidget(
          buildCardWithUpdateAvailable(
            launchService: launchService,
            activityLog: activityLog,
          ),
        );
        await reachUpdateAvailableState(tester);

        await tester.tap(find.byKey(const ValueKey('download_update_button')));
        await tester.pumpAndSettle();

        expect(activityLog.installerLogs, hasLength(1));
        expect(activityLog.installerLogs.first['success'], isFalse);
        expect(activityLog.installerLogs.first['error'], isNotNull);
      },
    );

    testWidgets(
      'ActivityLogService.logInstallerLaunch called with success=true on success',
      (tester) async {
        final launchService = _SucceedingLaunchService();
        final activityLog = _RecordingActivityLog();

        await tester.pumpWidget(
          buildCardWithUpdateAvailable(
            launchService: launchService,
            activityLog: activityLog,
          ),
        );
        await reachUpdateAvailableState(tester);

        await tester.tap(find.byKey(const ValueKey('download_update_button')));
        await tester.pumpAndSettle();

        expect(activityLog.installerLogs, hasLength(1));
        expect(activityLog.installerLogs.first['success'], isTrue);
        expect(activityLog.installerLogs.first['error'], isNull);
      },
    );

    testWidgets('failure dialog is NOT shown when install succeeds', (
      tester,
    ) async {
      final launchService = _SucceedingLaunchService();
      final activityLog = _RecordingActivityLog();

      await tester.pumpWidget(
        buildCardWithUpdateAvailable(
          launchService: launchService,
          activityLog: activityLog,
        ),
      );
      await reachUpdateAvailableState(tester);

      await tester.tap(find.byKey(const ValueKey('download_update_button')));
      await tester.pumpAndSettle();

      // Dialog must NOT be shown when launch succeeds.
      expect(find.byKey(const ValueKey('install_failure_title')), findsNothing);
    });

    testWidgets(
      'InstallerLaunchService.launch is called exactly once per tap',
      (tester) async {
        final launchService = _FailingLaunchService();
        final activityLog = _RecordingActivityLog();

        await tester.pumpWidget(
          buildCardWithUpdateAvailable(
            launchService: launchService,
            activityLog: activityLog,
          ),
        );
        await reachUpdateAvailableState(tester);

        await tester.tap(find.byKey(const ValueKey('download_update_button')));
        await tester.pumpAndSettle();

        expect(launchService.launchCallCount, 1);
      },
    );
  });
}
