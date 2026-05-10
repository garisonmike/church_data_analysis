import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/log_service.dart';
import 'services/settings_service.dart';
import 'services/theme_service.dart';
import 'ui/screens/advanced_charts_screen.dart';
import 'ui/screens/analytics_dashboard.dart';
import 'ui/screens/app_settings_screen.dart';
import 'ui/screens/attendance_charts_screen.dart';
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
import 'ui/screens/first_launch_backup_import_screen.dart';
import 'ui/screens/graph_center_screen.dart';
import 'ui/screens/import_screen.dart';
import 'ui/screens/not_found_screen.dart';
import 'ui/screens/profile_selection_screen.dart';
import 'ui/screens/reports_screen.dart';
import 'ui/screens/startup_gate_screen.dart';
import 'ui/screens/target_analysis_screen.dart';
import 'ui/screens/weekly_entry_screen.dart';
import 'ui/screens/board_meeting_analytics_screen.dart';
import 'ui/screens/board_meeting_entry_screen.dart';
import 'ui/screens/business_meeting_entry_screen.dart';
import 'ui/screens/financial_glossary_screen.dart';
import 'ui/screens/home_church_analytics_screen.dart';
import 'ui/screens/home_church_screen.dart';
import 'ui/screens/holy_communion_entry_screen.dart';
import 'ui/screens/special_events_screen.dart';

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

  // ── Syncfusion License ───────────────────────────────────────────────────
  const String kSyncfusionLicenseKey = '';
  if (kSyncfusionLicenseKey.isNotEmpty) {
    // SfLicenseKey.registerLicense(kSyncfusionLicenseKey);
  }

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
      LogService.crash('Zone', 'Unhandled error', error: error, stackTrace: stack);
    },
  );
}

class ChurchAnalyticsApp extends ConsumerWidget {
  const ChurchAnalyticsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            return MaterialPageRoute(
              builder: (context) => const AppSettingsScreen(),
            );
          case '/restore-backup':
            return MaterialPageRoute(
              builder: (context) =>
                  const FirstLaunchBackupImportScreen(),
            );
          case '/charts/detail':
            if (churchId == null) {
              return MaterialPageRoute(builder: (context) => const StartupGateScreen());
            }
            return MaterialPageRoute(
              builder: (context) => DetailedMetricsScreen(churchId: churchId),
            );
          case '/charts/distribution':
            if (churchId == null) {
              return MaterialPageRoute(builder: (context) => const StartupGateScreen());
            }
            return MaterialPageRoute(
              builder: (context) => DistributionScreen(churchId: churchId),
            );
          case '/charts/targets':
            if (churchId == null) {
              return MaterialPageRoute(builder: (context) => const StartupGateScreen());
            }
            return MaterialPageRoute(
              builder: (context) => TargetAnalysisScreen(churchId: churchId),
            );
          case '/charts/cross':
            if (churchId == null) {
              return MaterialPageRoute(builder: (context) => const StartupGateScreen());
            }
            return MaterialPageRoute(
              builder: (context) => CrossDatasetScreen(churchId: churchId),
            );
          case '/reports':
            if (churchId == null) {
              return MaterialPageRoute(builder: (context) => const StartupGateScreen());
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
            return MaterialPageRoute(
              builder: (context) => const HomeChurchAnalyticsScreen(),
            );
          case '/board-meeting':
            return MaterialPageRoute(
              builder: (context) => const BoardMeetingAnalyticsScreen(),
            );
          case '/board-meeting/entry':
            return MaterialPageRoute(
              builder: (context) => const BoardMeetingEntryScreen(),
            );
          case '/special-events':
            return MaterialPageRoute(
              builder: (context) => const SpecialEventsScreen(),
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
