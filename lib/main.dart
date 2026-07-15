import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/background_update_service.dart';
import 'services/log_service.dart';
import 'services/settings_service.dart';
import 'services/theme_service.dart';
import 'ui/screens/advanced_charts_screen.dart';
import 'ui/screens/analytics_dashboard.dart';
import 'ui/screens/app_settings_screen.dart';
import 'ui/screens/attendance_charts_screen.dart';
import 'ui/screens/board_meeting_analytics_screen.dart';
import 'ui/screens/board_meeting_entry_screen.dart';
import 'ui/screens/business_meeting_entry_screen.dart';
import 'ui/screens/church_selection_screen.dart';
import 'ui/screens/church_settings_screen.dart';
import 'ui/screens/correlation_charts_screen.dart';
import 'ui/screens/cross_dataset_screen.dart';
import 'ui/screens/custom_graph_builder_screen.dart';
import 'ui/screens/dashboard_layout_editor_screen.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/detailed_metrics_screen.dart';
import 'ui/screens/distribution_screen.dart';
import 'ui/screens/financial_charts_screen.dart';
import 'ui/screens/financial_glossary_screen.dart';
import 'ui/screens/first_launch_backup_import_screen.dart';
import 'ui/screens/graph_center_screen.dart';
import 'ui/screens/holy_communion_entry_screen.dart';
import 'ui/screens/home_church_analytics_screen.dart';
import 'ui/screens/home_church_screen.dart';
import 'ui/screens/import_screen.dart';
import 'ui/screens/not_found_screen.dart';
import 'ui/screens/profile_selection_screen.dart';
import 'ui/screens/reports_screen.dart';
import 'ui/screens/special_events_screen.dart';
import 'ui/screens/spiritual_life_screen.dart';
import 'ui/screens/startup_gate_screen.dart';
import 'ui/screens/target_analysis_screen.dart';
import 'ui/screens/weekly_entry_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Logging ──────────────────────────────────────────────────────────────
  await LogService.init();

  // Catch Flutter framework errors.
  FlutterError.onError = (FlutterErrorDetails details) {
    LogService.error(
      'Flutter',
      details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details); // still show red screen in debug
  };

  // Open the port that lets the task isolate send data to the main
  // isolate.  Must be called before any addTaskDataCallback registration
  // (which happens in DownloadForegroundService.init()) so the 'stop' signal
  // from onNotificationDismissed / OS-kill can actually reach the main isolate
  // and cancel the active download.
  FlutterForegroundTask.initCommunicationPort();

  // Initialize date formatting.
  try {
    await initializeDateFormatting();
  } catch (e) {
    LogService.warning('Main', 'Date formatting init failed: $e');
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  // Wrap runApp in a zone so uncaught async errors are also captured.
  await runZonedGuarded(
    () async {
      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            platformBrightnessProvider.overrideWith(
              (ref) =>
                  WidgetsBinding.instance.platformDispatcher.platformBrightness,
            ),
          ],
          child: const ChurchAnalyticsApp(),
        ),
      );
    },
    (Object error, StackTrace stack) {
      // This fires for unhandled errors from any async context.
      LogService.crash(
        'Zone',
        'Unhandled error',
        error: error,
        stackTrace: stack,
      );
    },
  );
}

// ---------------------------------------------------------------------------
// ChurchAnalyticsApp converted from ConsumerWidget to
// ConsumerStatefulWidget so that the connectivity stream subscription has a
// proper lifecycle (initState / dispose).
//
// The subscription lives here — at the app root — so it persists for the
// entire session regardless of which screen is currently active.  Placing it
// in StartupGateScreen would cancel it the moment the gate navigates away.
// ---------------------------------------------------------------------------

class ChurchAnalyticsApp extends ConsumerStatefulWidget {
  const ChurchAnalyticsApp({super.key});

  @override
  ConsumerState<ChurchAnalyticsApp> createState() => _ChurchAnalyticsAppState();
}

/// Routes that stand alone — no churchId argument required.
final Map<String, WidgetBuilder> _plainRoutes = <String, WidgetBuilder>{
  '/': (context) => const StartupGateScreen(),
  '/select-church': (context) => const ChurchSelectionScreen(),
  '/restore-backup': (context) => const FirstLaunchBackupImportScreen(),
  '/dashboard/layout': (context) => const DashboardLayoutEditorScreen(),
  '/home-churches': (context) => const HomeChurchScreen(),
  '/board-meeting/entry': (context) => const BoardMeetingEntryScreen(),
  '/holy-communion/entry': (context) => const HolyCommunionEntryScreen(),
  '/business-meeting/entry': (context) => const BusinessMeetingEntryScreen(),
  '/financial-glossary': (context) => const FinancialGlossaryScreen(),
};

/// Routes that require a churchId argument. Navigating to one without a
/// churchId falls back to the startup gate, which re-establishes context.
final Map<String, Widget Function(int churchId)> _churchRoutes =
    <String, Widget Function(int churchId)>{
  '/dashboard': (id) => DashboardScreen(churchId: id),
  '/select-profile': (id) => ProfileSelectionScreen(churchId: id),
  '/entry': (id) => WeeklyEntryScreen(churchId: id),
  '/import': (id) => ImportScreen(churchId: id),
  '/settings': (id) => ChurchSettingsScreen(churchId: id),
  '/charts': (id) => GraphCenterScreen(churchId: id),
  '/analytics': (id) => AnalyticsDashboard(churchId: id),
  '/charts/advanced': (id) => AdvancedChartsScreen(churchId: id),
  '/charts/attendance': (id) => AttendanceChartsScreen(churchId: id),
  '/charts/correlation': (id) => CorrelationChartsScreen(churchId: id),
  '/charts/financial': (id) => FinancialChartsScreen(churchId: id),
  '/charts/custom': (id) => CustomGraphBuilderScreen(churchId: id),
  '/charts/detail': (id) => DetailedMetricsScreen(churchId: id),
  '/charts/distribution': (id) => DistributionScreen(churchId: id),
  '/charts/targets': (id) => TargetAnalysisScreen(churchId: id),
  '/charts/cross': (id) => CrossDatasetScreen(churchId: id),
  '/reports': (id) => ReportsScreen(churchId: id),
  '/home-church-analytics': (id) => HomeChurchAnalyticsScreen(churchId: id),
  '/board-meeting': (id) => BoardMeetingAnalyticsScreen(churchId: id),
  '/special-events': (id) => SpecialEventsScreen(churchId: id),
  '/charts/spiritual-life': (id) => SpiritualLifeScreen(churchId: id),
};

class _ChurchAnalyticsAppState extends ConsumerState<ChurchAnalyticsApp> {
  /// Subscription to the connectivity change stream.
  ///
  /// Cancelled in [dispose] to prevent listener leaks.
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    // Subscribe to connectivity changes so that an update check is
    // triggered whenever the device transitions from offline to online.
    //
    // The subscription is set up once here at the app root and lives for the
    // entire session.  Each emission from the stream is a List because
    // connectivity_plus v6+ supports multiple simultaneous interfaces (e.g.
    // Wi-Fi + VPN).  We consider the device online if any result is not
    // ConnectivityResult.none.
    //
    // The provider is invalidated before re-reading so that it runs a fresh
    // cooldown + connectivity check rather than returning a prior cached value.
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final isOnline = results.any((r) => r != ConnectivityResult.none);
        if (isOnline) {
          // Connectivity restored — attempt a background update check if the
          // 24-hour cooldown has elapsed.  The provider handles both guards
          // internally; this call is always safe to make unconditionally.
          ref.invalidate(backgroundUpdateCheckProvider);
          unawaited(ref.read(backgroundUpdateCheckProvider.future));
        }
      },
    );
  }

  @override
  void dispose() {
    // Cancel the connectivity stream to avoid leaked listeners.
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Church Analytics',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const StartupGateScreen(),
      onGenerateRoute: (settings) {
        final args = settings.arguments;
        final int? churchId = (args is int) ? args : null;

        final plain = _plainRoutes[settings.name];
        if (plain != null) {
          return MaterialPageRoute(builder: plain);
        }

        // /app-settings accepts a missing
        // churchId (e.g. from a test or a deep link) and falls back to 0.
        if (settings.name == '/app-settings') {
          return MaterialPageRoute(
            builder: (context) => AppSettingsScreen(churchId: churchId ?? 0),
          );
        }

        final church = _churchRoutes[settings.name];
        if (church != null) {
          if (churchId == null) {
            return MaterialPageRoute(
              builder: (context) => const StartupGateScreen(),
            );
          }
          return MaterialPageRoute(builder: (context) => church(churchId));
        }

        return MaterialPageRoute(
          builder: (context) => NotFoundScreen(attemptedRoute: settings.name),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
