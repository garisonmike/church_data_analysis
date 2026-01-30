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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Church Analytics',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/entry': (context) => const WeeklyEntryScreen(),
        '/import': (context) => const CsvImportScreen(),
        '/settings': (context) => const ChurchSettingsScreen(),
        '/charts/advanced': (context) => const AdvancedChartsScreen(),
        '/charts/attendance': (context) => const AttendanceChartsScreen(),
        '/charts/correlation': (context) => const CorrelationChartsScreen(),
        '/charts/financial': (context) => const FinancialChartsScreen(),
        '/charts': (context) => const GraphCenterScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
