import 'dart:async';
import 'dart:convert';

import 'package:church_analytics/services/update_service.dart';
import 'package:church_analytics/ui/widgets/about_updates_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  const kManifestUrl = 'https://example.com/update.json';

  // ---------------------------------------------------------------------------
  // Test helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> makeManifestJson(String version) => {
    'version': version,
    'release_date': '2024-01-15',
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

  PackageInfo makePackageInfo(String version) => PackageInfo(
    appName: 'church_analytics',
    packageName: 'com.example.church_analytics',
    version: version,
    buildNumber: '1',
  );

  /// Builds a testable widget tree with the given [service] override.
  Widget buildWidget(UpdateService service) => ProviderScope(
    overrides: [updateServiceProvider.overrideWithValue(service)],
    child: const MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: AboutUpdatesCard())),
    ),
  );

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'church_analytics',
      packageName: 'com.example.church_analytics',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  // ---------------------------------------------------------------------------
  // Initial render
  // ---------------------------------------------------------------------------

  group('AboutUpdatesCard — initial render', () {
    testWidgets('displays section heading "About & Updates"', (tester) async {
      final service = UpdateService(
        client: MockClient((_) async => http.Response('{}', 200)),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      expect(find.text('About & Updates'), findsOneWidget);
    });

    testWidgets('displays current version from PackageInfo', (tester) async {
      final service = UpdateService(
        client: MockClient((_) async => http.Response('{}', 200)),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      // Allow initState async (PackageInfo.fromPlatform) to complete.
      await tester.pumpAndSettle();

      // Version "1.0.0" should be visible (PackageInfo.setMockInitialValues).
      expect(find.text('1.0.0'), findsWidgets);
    });

    testWidgets('"Check for Updates" button is present and enabled initially', (
      tester,
    ) async {
      final service = UpdateService(
        client: MockClient((_) async => http.Response('{}', 200)),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('check_updates_button')),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('no last-checked timestamp before any check', (tester) async {
      final service = UpdateService(
        client: MockClient((_) async => http.Response('{}', 200)),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('last_checked_text')), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Loading state
  // ---------------------------------------------------------------------------

  group('AboutUpdatesCard — loading state', () {
    testWidgets('button is disabled and spinner shown while checking', (
      tester,
    ) async {
      final responseCompleter = Completer<http.Response>();
      final service = UpdateService(
        client: MockClient((_) => responseCompleter.future),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      // Trigger the check.
      await tester.tap(find.byKey(const ValueKey('check_updates_button')));
      await tester.pump(); // one frame — network call not yet resolved

      // Button must be disabled.
      final button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('check_updates_button')),
      );
      expect(button.onPressed, isNull);

      // Spinner must be visible inside the button.
      expect(find.byKey(const ValueKey('loading_spinner')), findsOneWidget);

      // Clean up — complete the future so the widget can settle.
      responseCompleter.complete(http.Response('{}', 200));
      await tester.pumpAndSettle();
    });

    testWidgets('second tap while checking is a no-op', (tester) async {
      var callCount = 0;
      final responseCompleter = Completer<http.Response>();
      final service = UpdateService(
        client: MockClient((_) async {
          callCount++;
          return responseCompleter.future;
        }),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('check_updates_button')));
      await tester.pump();

      // A second tap on the now-disabled button should not trigger another call.
      await tester.tap(
        find.byKey(const ValueKey('check_updates_button')),
        warnIfMissed: false,
      );
      await tester.pump();

      responseCompleter.complete(
        http.Response(jsonEncode(makeManifestJson('1.0.0')), 200),
      );
      await tester.pumpAndSettle();

      expect(callCount, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // Up-to-date state
  // ---------------------------------------------------------------------------

  group('AboutUpdatesCard — up-to-date state', () {
    testWidgets('shows "up to date" message when no update available', (
      tester,
    ) async {
      final service = UpdateService(
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode(makeManifestJson('1.0.0')), 200),
        ),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('check_updates_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('up_to_date_result')), findsOneWidget);
      expect(find.textContaining('up to date'), findsOneWidget);
    });

    testWidgets('up-to-date message includes the latest version number', (
      tester,
    ) async {
      final service = UpdateService(
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode(makeManifestJson('1.0.0')), 200),
        ),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('check_updates_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('1.0.0'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // Update-available state
  // ---------------------------------------------------------------------------

  group('AboutUpdatesCard — update-available state', () {
    testWidgets('shows update-available result with new version number', (
      tester,
    ) async {
      final service = UpdateService(
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode(makeManifestJson('1.1.0')), 200),
        ),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('check_updates_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('update_available_result')),
        findsOneWidget,
      );
      expect(find.textContaining('1.1.0'), findsWidgets);
    });

    testWidgets('"Download Update" button is shown when update available', (
      tester,
    ) async {
      final service = UpdateService(
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode(makeManifestJson('2.0.0')), 200),
        ),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('check_updates_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('download_update_button')),
        findsOneWidget,
      );
    });

    testWidgets('"View Release Notes" button is shown when update available', (
      tester,
    ) async {
      final service = UpdateService(
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode(makeManifestJson('2.0.0')), 200),
        ),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('check_updates_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('view_release_notes_button')),
        findsOneWidget,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Error state
  // ---------------------------------------------------------------------------

  group('AboutUpdatesCard — error state', () {
    testWidgets('shows error result on network failure', (tester) async {
      final service = UpdateService(
        client: MockClient((_) async => throw Exception('connection refused')),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('check_updates_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('error_result')), findsOneWidget);
    });

    testWidgets('shows a human-readable error message', (tester) async {
      final service = UpdateService(
        client: MockClient((_) async => http.Response('Internal Error', 500)),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('check_updates_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('error_message_text')), findsOneWidget);
    });

    testWidgets('retry button is shown in error state', (tester) async {
      final service = UpdateService(
        client: MockClient((_) async => throw Exception('timeout')),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('check_updates_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('retry_button')), findsOneWidget);
    });

    testWidgets('retry button re-triggers a fresh check', (tester) async {
      var callCount = 0;
      final service = UpdateService(
        client: MockClient((_) async {
          callCount++;
          if (callCount == 1) throw Exception('first attempt fails');
          return http.Response(jsonEncode(makeManifestJson('1.0.0')), 200);
        }),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      // First check → error.
      await tester.tap(find.byKey(const ValueKey('check_updates_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('error_result')), findsOneWidget);

      // Retry → up to date.
      await tester.tap(find.byKey(const ValueKey('retry_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('up_to_date_result')), findsOneWidget);
      expect(callCount, 2);
    });
  });

  // ---------------------------------------------------------------------------
  // Last-checked timestamp
  // ---------------------------------------------------------------------------

  group('AboutUpdatesCard — last-checked timestamp', () {
    testWidgets('timestamp appears after a successful check', (tester) async {
      final service = UpdateService(
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode(makeManifestJson('1.0.0')), 200),
        ),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('last_checked_text')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('check_updates_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('last_checked_text')), findsOneWidget);
      expect(find.textContaining('Last checked:'), findsOneWidget);
    });

    testWidgets('timestamp appears after a failed check', (tester) async {
      final service = UpdateService(
        client: MockClient((_) async => throw Exception('network error')),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('check_updates_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('last_checked_text')), findsOneWidget);
    });

    testWidgets('timestamp reads "Just now" immediately after a check', (
      tester,
    ) async {
      final service = UpdateService(
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode(makeManifestJson('1.0.0')), 200),
        ),
        manifestUrl: kManifestUrl,
        getPackageInfo: () async => makePackageInfo('1.0.0'),
      );

      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('check_updates_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Just now'), findsOneWidget);
    });
  });
}
