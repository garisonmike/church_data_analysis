import 'package:church_analytics/analytics/metrics_calculator.dart';
import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart' as models;
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/ui/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final int churchId;

  const DashboardScreen({super.key, required this.churchId});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<models.WeeklyRecord> _recentRecords = [];
  Map<String, dynamic>? _summaryMetrics;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AppDatabase? database;
    try {
      database = AppDatabase();
      final repository = WeeklyRecordRepository(database);

      // Get recent records (last 12 weeks)
      final records = await repository.getRecentRecords(widget.churchId, 12);

      // Calculate summary metrics if we have data
      Map<String, dynamic>? metrics;
      if (records.isNotEmpty) {
        final calculator = MetricsCalculator();
        metrics = calculator.calculateSummaryMetrics(records);
      }

      if (mounted) {
        setState(() {
          _recentRecords = records;
          _summaryMetrics = metrics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading data: ${e.toString()}';
          _isLoading = false;
        });
      }
    } finally {
      await database?.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Church Analytics Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
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
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Cards
            _buildKpiCards(),
            const SizedBox(height: 24),

            // Quick Actions / Graph Buttons
            _buildQuickActions(),
            const SizedBox(height: 24),

            // Recent Weeks List
            _buildRecentWeeksList(),
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
              return Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
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
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      'Financial Charts',
                      Icons.pie_chart,
                      Colors.green,
                      () => _showComingSoon('Financial Charts'),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                    () => _showComingSoon('Financial Charts'),
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
    return NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(amount);
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
