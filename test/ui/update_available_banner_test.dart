import 'package:church_analytics/ui/widgets/update_available_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

/// Wraps [UpdateAvailableBanner] in a minimal [MaterialApp]+[Scaffold] so
/// that Theme and MediaQuery are available.
Widget _buildBanner({
  String version = '1.2.3',
  VoidCallback? onDismiss,
  VoidCallback? onGoToSettings,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          UpdateAvailableBanner(
            version: version,
            onDismiss: onDismiss ?? () {},
            onGoToSettings: onGoToSettings ?? () {},
          ),
        ],
      ),
    ),
  );
}

void main() {
  // =========================================================================
  // UpdateAvailableBanner — structural tests
  // =========================================================================

  group('UpdateAvailableBanner — structure & keys', () {
    testWidgets('renders the banner root with the correct ValueKey',
        (tester) async {
      await tester.pumpWidget(_buildBanner());

      expect(
        find.byKey(const ValueKey('update_available_banner')),
        findsOneWidget,
      );
    });

    testWidgets('renders "Go to Settings" button with the correct ValueKey',
        (tester) async {
      await tester.pumpWidget(_buildBanner());

      expect(
        find.byKey(const ValueKey('update_available_banner_settings')),
        findsOneWidget,
      );
    });

    testWidgets('renders dismiss button with the correct ValueKey',
        (tester) async {
      await tester.pumpWidget(_buildBanner());

      expect(
        find.byKey(const ValueKey('update_available_banner_dismiss')),
        findsOneWidget,
      );
    });
  });

  // =========================================================================
  // UpdateAvailableBanner — version display
  // =========================================================================

  group('UpdateAvailableBanner — version text', () {
    testWidgets('displays the version number passed to it', (tester) async {
      await tester.pumpWidget(_buildBanner(version: '2.5.1'));

      expect(find.text('Update available: v2.5.1'), findsOneWidget);
    });

    testWidgets('displays a different version string correctly', (tester) async {
      await tester.pumpWidget(_buildBanner(version: '10.0.0'));

      expect(find.text('Update available: v10.0.0'), findsOneWidget);
    });

    testWidgets('"Go to Settings" button label is correct', (tester) async {
      await tester.pumpWidget(_buildBanner());

      final settingsBtn = find.byKey(
        const ValueKey('update_available_banner_settings'),
      );
      expect(
        find.descendant(of: settingsBtn, matching: find.text('Go to Settings')),
        findsOneWidget,
      );
    });
  });

  // =========================================================================
  // UpdateAvailableBanner — callbacks
  // =========================================================================

  group('UpdateAvailableBanner — callbacks', () {
    testWidgets('tapping dismiss × invokes onDismiss', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        _buildBanner(onDismiss: () => dismissed = true),
      );

      await tester.tap(
        find.byKey(const ValueKey('update_available_banner_dismiss')),
      );
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('tapping "Go to Settings" invokes onGoToSettings',
        (tester) async {
      var navigated = false;
      await tester.pumpWidget(
        _buildBanner(onGoToSettings: () => navigated = true),
      );

      await tester.tap(
        find.byKey(const ValueKey('update_available_banner_settings')),
      );
      await tester.pump();

      expect(navigated, isTrue);
    });

    testWidgets('onDismiss is invoked exactly once per tap', (tester) async {
      var callCount = 0;
      await tester.pumpWidget(
        _buildBanner(onDismiss: () => callCount++),
      );

      await tester.tap(
        find.byKey(const ValueKey('update_available_banner_dismiss')),
      );
      await tester.pump();

      expect(callCount, equals(1));
    });
  });
}
