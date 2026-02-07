import 'package:church_analytics/analytics/metrics_calculator.dart';
import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart' as models;
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:church_analytics/ui/screens/screens.dart';
import 'package:church_analytics/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'reports_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final int churchId;

  const DashboardScreen({super.key, required this.churchId});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  final List<models.WeeklyRecord> _recentRecords = [];
  Map<String, dynamic>? _summaryMetrics;
  AdminProfileService? _profileService;

  @override
  void initState() {
    super.initState();
    _initializeProfileService();
    _loadData();
  }

  Future<void> _initializeProfileService() async {
    final database = ref.read(databaseProvider);
    final repository = AdminUserRepository(database);
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _profileService = AdminProfileService(repository, prefs);
    });
  }

  Future<void> _loadData() async {
    // Start performance measurement
    final perfMonitor = PerformanceMonitor();
    perfMonitor.startTiming('dashboard_load');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final database = ref.read(databaseProvider);
      final repository = WeeklyRecordRepository(database);

      // Get current admin ID if profile service is initialized
      final currentAdminId = _profileService?.getCurrentProfileId();

      // Time the database query
      perfMonitor.startTiming('dashboard_db_query');

      // Get recent records (last 12 weeks) - filtered by admin if ID exists
      List<models.WeeklyRecord> records;
      if (currentAdminId != null) {
        records = await repository.getRecentRecordsByAdmin(
          widget.churchId,
          currentAdminId,
          12,
        );
      } else {
        records = await repository.getRecentRecords(widget.churchId, 12);
      }

      perfMonitor.stopTiming('dashboard_db_query');

      // Time metrics calculation
      perfMonitor.startTiming('dashboard_metrics_calc');

      // Calculate summary metrics if we have data
      Map<String, dynamic>? metrics;
      if (records.isNotEmpty) {
        final calculator = MetricsCalculator();
        metrics = calculator.calculateSummaryMetrics(records);
      }

      perfMonitor.stopTiming('dashboard_metrics_calc');

      if (mounted) {
        setState(() {
          _recentRecords
            ..clear()
            ..addAll(records);
          _summaryMetrics = metrics;
          _isLoading = false;
        });
      }

      // Stop and log total dashboard load time
      perfMonitor.stopTiming('dashboard_load');
    } catch (e) {
      perfMonitor.stopTiming('dashboard_load');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompactLayout = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Church Analytics Dashboard',
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!isCompactLayout) ...[
            IconButton(
              icon: const Icon(Icons.dashboard_customize),
              onPressed: _openLayoutEditor,
              tooltip: 'Customize Dashboard',
            ),
            ChurchSelectorWidget(onChurchChanged: _loadData),
            if (_profileService != null)
              ProfileSwitcherWidget(
                churchId: widget.churchId,
                profileService: _profileService!,
                onProfileChanged: _loadData,
              ),
            IconButton(
              icon: const Icon(Icons.analytics_outlined),
              onPressed: _openReports,
              tooltip: 'Reports & Backup',
            ),
          ],
          _buildSettingsMenu(),
          if (isCompactLayout) _buildOverflowMenu(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _recentRecords.isEmpty
          ? _buildEmptyView()
          : _buildDashboardContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WeeklyEntryScreen()),
          );
          if (result == true) {
            _loadData();
          }
        },
        tooltip: 'Add Weekly Entry',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No data yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first weekly entry to see analytics',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeeklyEntryScreen(),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Weekly Entry'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CsvImportScreen(churchId: widget.churchId),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Import from CSV'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReportsScreen(churchId: widget.churchId),
                  ),
                );
              },
              icon: const Icon(Icons.analytics),
              label: const Text('Reports & Backup'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    final config = ref.watch(dashboardConfigProvider);
    final visibleSections = config.order
        .where((section) => config.isVisible(section))
        .toList();

    final sectionWidgets = <Widget>[];

    for (final section in visibleSections) {
      if (sectionWidgets.isNotEmpty) {
        sectionWidgets.add(const SizedBox(height: 24));
      }
      sectionWidgets.add(_buildSection(section));
    }

    if (sectionWidgets.isEmpty) {
      sectionWidgets.add(_buildEmptyLayoutView());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sectionWidgets,
        ),
      ),
    );
  }

  Widget _buildSection(models.DashboardSection section) {
    return switch (section) {
      models.DashboardSection.kpiCards => _buildKpiCards(),
      models.DashboardSection.quickActions => _buildQuickActions(),
      models.DashboardSection.recentWeeks => _buildRecentWeeksList(),
    };
  }

  Widget _buildEmptyLayoutView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.dashboard_customize,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'No dashboard widgets selected',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Enable sections in the layout editor to see them here.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openLayoutEditor,
              icon: const Icon(Icons.tune),
              label: const Text('Edit Layout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCards() {
    if (_summaryMetrics == null) return const SizedBox.shrink();

    final metrics = _summaryMetrics!;
    final totalAttendance = metrics['totalAttendance'] ?? 0;
    final totalIncome = metrics['totalIncome'] ?? 0.0;
    final avgAttendance = metrics['averageAttendance'] ?? 0.0;
    final avgIncome = metrics['averageIncome'] ?? 0.0;
    final attendanceGrowth = metrics['attendanceGrowthPercentage'];
    final incomeGrowth = metrics['incomeGrowthPercentage'];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive layout: 2 columns on mobile, 4 on tablet+
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        final cardHeight = 120.0;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(
              width: (constraints.maxWidth - 8) / crossAxisCount,
              height: cardHeight,
              child: _buildKpiCard(
                title: 'Total Attendance',
                value: totalAttendance.toString(),
                icon: Icons.people,
                color: Colors.blue,
                growth: attendanceGrowth,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - 8) / crossAxisCount,
              height: cardHeight,
              child: _buildKpiCard(
                title: 'Total Income',
                value: _formatCurrency(totalIncome),
                icon: Icons.attach_money,
                color: Colors.green,
                growth: incomeGrowth,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - 8) / crossAxisCount,
              height: cardHeight,
              child: _buildKpiCard(
                title: 'Avg Attendance',
                value: avgAttendance.toStringAsFixed(0),
                icon: Icons.groups,
                color: Colors.orange,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - 8) / crossAxisCount,
              height: cardHeight,
              child: _buildKpiCard(
                title: 'Avg Income',
                value: _formatCurrency(avgIncome),
                icon: Icons.trending_up,
                color: Colors.purple,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    double? growth,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (growth != null) _buildGrowthIndicator(growth),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthIndicator(double growth) {
    final isPositive = growth >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '${growth.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            if (isWide) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Attendance Charts',
                          Icons.bar_chart,
                          Colors.blue,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendanceChartsScreen(
                                churchId: widget.churchId,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          'Financial Charts',
                          Icons.pie_chart,
                          Colors.green,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FinancialChartsScreen(
                                churchId: widget.churchId,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Correlation Charts',
                          Icons.scatter_plot,
                          Colors.purple,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CorrelationChartsScreen(
                                churchId: widget.churchId,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          'Advanced Charts',
                          Icons.insights,
                          Colors.deepOrange,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdvancedChartsScreen(
                                churchId: widget.churchId,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Import CSV',
                          Icons.upload_file,
                          Colors.orange,
                          () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CsvImportScreen(churchId: widget.churchId),
                              ),
                            );
                            if (result == true) {
                              _loadData();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          'Chart Center',
                          Icons.dashboard,
                          Colors.teal,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GraphCenterScreen(churchId: widget.churchId),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildActionButton(
                    'Attendance Charts',
                    Icons.bar_chart,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AttendanceChartsScreen(churchId: widget.churchId),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    'Financial Charts',
                    Icons.pie_chart,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FinancialChartsScreen(churchId: widget.churchId),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    'Correlation Charts',
                    Icons.scatter_plot,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CorrelationChartsScreen(churchId: widget.churchId),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    'Advanced Charts',
                    Icons.insights,
                    Colors.deepOrange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdvancedChartsScreen(churchId: widget.churchId),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    'Import CSV',
                    Icons.upload_file,
                    Colors.orange,
                    () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CsvImportScreen(churchId: widget.churchId),
                        ),
                      );
                      if (result == true) {
                        _loadData();
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    'Chart Center',
                    Icons.dashboard,
                    Colors.teal,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GraphCenterScreen(churchId: widget.churchId),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildRecentWeeksList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Weeks', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full list view
                _showComingSoon('Full List View');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentRecords.length,
          itemBuilder: (context, index) {
            final record = _recentRecords[index];
            return _buildWeekCard(record);
          },
        ),
      ],
    );
  }

  Widget _buildWeekCard(models.WeeklyRecord record) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
          child: const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
        ),
        title: Text(
          dateFormat.format(record.weekStartDate),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Attendance: ${record.totalAttendance} • Income: ${_formatCurrency(record.totalIncome)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WeeklyEntryScreen(existingRecord: record),
              ),
            );
            if (result == true) {
              _loadData();
            }
          },
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    // Use app settings currency formatter
    final notifier = ref.read(appSettingsProvider.notifier);
    return notifier.formatCurrency(amount);
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openLayoutEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardLayoutEditorScreen(),
      ),
    );
  }

  void _openReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportsScreen(churchId: widget.churchId),
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings),
      tooltip: 'Settings',
      onSelected: (value) async {
        switch (value) {
          case 'church':
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChurchSettingsScreen(churchId: widget.churchId),
              ),
            );
            if (result == true) {
              _loadData();
            }
            break;
          case 'app':
            Navigator.pushNamed(context, '/app-settings');
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'church',
          child: Row(
            children: [
              Icon(Icons.church),
              SizedBox(width: 8),
              Text('Church Settings'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'app',
          child: Row(
            children: [
              Icon(Icons.settings_applications),
              SizedBox(width: 8),
              Text('App Settings'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverflowMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'More',
      onSelected: (value) {
        switch (value) {
          case 'customize':
            _openLayoutEditor();
            break;
          case 'reports':
            _openReports();
            break;
          case 'church':
            _showChurchSelectorSheet();
            break;
          case 'profile':
            _showProfileSwitcherSheet();
            break;
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'customize',
          child: Row(
            children: [
              Icon(Icons.dashboard_customize),
              SizedBox(width: 8),
              Text('Customize Dashboard'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'reports',
          child: Row(
            children: [
              Icon(Icons.analytics_outlined),
              SizedBox(width: 8),
              Text('Reports & Backup'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'church',
          child: Row(
            children: [
              Icon(Icons.church),
              SizedBox(width: 8),
              Text('Switch Church'),
            ],
          ),
        ),
        if (_profileService != null)
          const PopupMenuItem<String>(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.switch_account),
                SizedBox(width: 8),
                Text('Switch Profile'),
              ],
            ),
          ),
      ],
    );
  }

  void _showChurchSelectorSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Switch Church',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ChurchSelectorWidget(onChurchChanged: _loadData),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileSwitcherSheet() {
    if (_profileService == null) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Switch Profile',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ProfileSwitcherWidget(
                churchId: widget.churchId,
                profileService: _profileService!,
                onProfileChanged: _loadData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
