import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart'; // FEAT-018
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart'; // FEAT-008
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/background_update_service.dart'; // FEAT-018
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

  // FEAT-008: Open the port that lets the task isolate send data to the main
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
// FEAT-018: ChurchAnalyticsApp converted from ConsumerWidget to
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

class _ChurchAnalyticsAppState extends ConsumerState<ChurchAnalyticsApp> {
  /// FEAT-018: Subscription to the connectivity change stream.
  ///
  /// Cancelled in [dispose] to prevent listener leaks.
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    // FEAT-018: Subscribe to connectivity changes so that an update check is
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
    // FEAT-018: Cancel the connectivity stream to avoid leaked listeners.
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

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => const StartupGateScreen(),
            );
          case '/dashboard':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => DashboardScreen(churchId: churchId),
            );
          case '/select-church':
            return MaterialPageRoute(
              builder: (context) => const ChurchSelectionScreen(),
            );
          case '/select-profile':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => ProfileSelectionScreen(churchId: churchId),
            );
          case '/entry':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => WeeklyEntryScreen(churchId: churchId),
            );
          case '/import':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => ImportScreen(churchId: churchId),
            );
          case '/settings':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => ChurchSettingsScreen(churchId: churchId),
            );
          case '/charts':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => GraphCenterScreen(churchId: churchId),
            );
          case '/analytics':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => AnalyticsDashboard(churchId: churchId),
            );
          case '/charts/advanced':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => AdvancedChartsScreen(churchId: churchId),
            );
          case '/charts/attendance':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => AttendanceChartsScreen(churchId: churchId),
            );
          case '/charts/correlation':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => CorrelationChartsScreen(churchId: churchId),
            );
          case '/charts/financial':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => FinancialChartsScreen(churchId: churchId),
            );
          case '/charts/custom':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) =>
                  CustomGraphBuilderScreen(churchId: churchId),
            );
          case '/app-settings':
            // FEAT-003: churchId is passed as route arguments from DashboardScreen
            // so that AboutUpdatesCard can offer a pre-update backup.
            // Falls back to 0 when the route is reached without arguments
            // (e.g. from a test or a deep link that does not carry a churchId).
            return MaterialPageRoute(
              builder: (context) => AppSettingsScreen(
                churchId: churchId ?? 0,
              ),
            );
          case '/restore-backup':
            return MaterialPageRoute(
              builder: (context) => const FirstLaunchBackupImportScreen(),
            );
          case '/charts/detail':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => DetailedMetricsScreen(churchId: churchId),
            );
          case '/charts/distribution':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => DistributionScreen(churchId: churchId),
            );
          case '/charts/targets':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => TargetAnalysisScreen(churchId: churchId),
            );
          case '/charts/cross':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => CrossDatasetScreen(churchId: churchId),
            );
          case '/reports':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => ReportsScreen(churchId: churchId),
            );
          case '/dashboard/layout':
            return MaterialPageRoute(
              builder: (context) => const DashboardLayoutEditorScreen(),
            );
          case '/home-churches':
            return MaterialPageRoute(
              builder: (context) => const HomeChurchScreen(),
            );
          case '/home-church-analytics':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) =>
                  HomeChurchAnalyticsScreen(churchId: churchId),
            );
          case '/board-meeting':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) =>
                  BoardMeetingAnalyticsScreen(churchId: churchId),
            );
          case '/board-meeting/entry':
            return MaterialPageRoute(
              builder: (context) => const BoardMeetingEntryScreen(),
            );
          case '/special-events':
            if (churchId == null) {
              return MaterialPageRoute(
                builder: (context) => const StartupGateScreen(),
              );
            }
            return MaterialPageRoute(
              builder: (context) => SpecialEventsScreen(churchId: churchId),
            );
          case '/holy-communion/entry':
            return MaterialPageRoute(
              builder: (context) => const HolyCommunionEntryScreen(),
            );
          case '/business-meeting/entry':
            return MaterialPageRoute(
              builder: (context) => const BusinessMeetingEntryScreen(),
            );
          case '/financial-glossary':
            return MaterialPageRoute(
              builder: (context) => const FinancialGlossaryScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) =>
                  NotFoundScreen(attemptedRoute: settings.name),
            );
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
