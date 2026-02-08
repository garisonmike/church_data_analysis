import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/settings_service.dart';
import 'services/theme_service.dart';
import 'ui/screens/advanced_charts_screen.dart';
import 'ui/screens/app_settings_screen.dart';
import 'ui/screens/attendance_charts_screen.dart';
import 'ui/screens/church_selection_screen.dart';
import 'ui/screens/church_settings_screen.dart';
import 'ui/screens/correlation_charts_screen.dart';
import 'ui/screens/import_screen.dart';
import 'ui/screens/custom_graph_builder_screen.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/financial_charts_screen.dart';
import 'ui/screens/graph_center_screen.dart';
import 'ui/screens/not_found_screen.dart';
import 'ui/screens/profile_selection_screen.dart';
import 'ui/screens/startup_gate_screen.dart';
import 'ui/screens/weekly_entry_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override with real SharedPreferences for persistence
        // Without this override, app uses non-persisting in-memory implementation
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        platformBrightnessProvider.overrideWith(
          (ref) =>
              WidgetsBinding.instance.platformDispatcher.platformBrightness,
        ),
      ],
      child: const ChurchAnalyticsApp(),
    ),
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
              builder: (context) => const WeeklyEntryScreen(),
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
