import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/screens/advanced_charts_screen.dart';
import 'ui/screens/attendance_charts_screen.dart';
import 'ui/screens/church_settings_screen.dart';
import 'ui/screens/correlation_charts_screen.dart';
import 'ui/screens/csv_import_screen.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/financial_charts_screen.dart';
import 'ui/screens/graph_center_screen.dart';
import 'ui/screens/weekly_entry_screen.dart';

void main() {
  runApp(const ProviderScope(child: ChurchAnalyticsApp()));
}

class ChurchAnalyticsApp extends StatelessWidget {
  const ChurchAnalyticsApp({super.key});

  static const int _defaultChurchId = 1;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Church Analytics',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DashboardScreen(churchId: _defaultChurchId),
      onGenerateRoute: (settings) {
        final args = settings.arguments;
        final int churchId = (args is int) ? args : _defaultChurchId;

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) =>
                  const DashboardScreen(churchId: _defaultChurchId),
            );
          case '/entry':
            return MaterialPageRoute(
              builder: (context) => const WeeklyEntryScreen(),
            );
          case '/import':
            return MaterialPageRoute(
              builder: (context) => CsvImportScreen(churchId: churchId),
            );
          case '/settings':
            return MaterialPageRoute(
              builder: (context) => ChurchSettingsScreen(churchId: churchId),
            );
          case '/charts':
            return MaterialPageRoute(
              builder: (context) => GraphCenterScreen(churchId: churchId),
            );
          case '/charts/advanced':
            return MaterialPageRoute(
              builder: (context) => AdvancedChartsScreen(churchId: churchId),
            );
          case '/charts/attendance':
            return MaterialPageRoute(
              builder: (context) => AttendanceChartsScreen(churchId: churchId),
            );
          case '/charts/correlation':
            return MaterialPageRoute(
              builder: (context) => CorrelationChartsScreen(churchId: churchId),
            );
          case '/charts/financial':
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
