import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/screens/advanced_charts_screen.dart';
import 'ui/screens/attendance_charts_screen.dart';
import 'ui/screens/church_selection_screen.dart';
import 'ui/screens/church_settings_screen.dart';
import 'ui/screens/correlation_charts_screen.dart';
import 'ui/screens/csv_import_screen.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/financial_charts_screen.dart';
import 'ui/screens/graph_center_screen.dart';
import 'ui/screens/profile_selection_screen.dart';
import 'ui/screens/startup_gate_screen.dart';
import 'ui/screens/weekly_entry_screen.dart';

void main() {
  runApp(const ProviderScope(child: ChurchAnalyticsApp()));
}

class ChurchAnalyticsApp extends StatelessWidget {
  const ChurchAnalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Church Analytics',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
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
              builder: (context) => CsvImportScreen(churchId: churchId),
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
          default:
            return null;
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
