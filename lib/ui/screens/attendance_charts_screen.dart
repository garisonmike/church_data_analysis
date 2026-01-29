import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart' as models;
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AttendanceChartsScreen extends ConsumerStatefulWidget {
  final int churchId;

  const AttendanceChartsScreen({super.key, required this.churchId});

  @override
  ConsumerState<AttendanceChartsScreen> createState() =>
      _AttendanceChartsScreenState();
}

class _AttendanceChartsScreenState
    extends ConsumerState<AttendanceChartsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<models.WeeklyRecord> _records = [];

  // GlobalKeys for RepaintBoundary to capture charts
  final GlobalKey _attendanceByCategoryKey = GlobalKey();
  final GlobalKey _totalTrendKey = GlobalKey();
  final GlobalKey _distributionKey = GlobalKey();
  final GlobalKey _growthRateKey = GlobalKey();

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

      // Get records for the last 12 weeks
      final records = await repository.getRecentRecords(widget.churchId, 12);

      if (mounted) {
        setState(() {
          _records = records;
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

  Future<void> _exportChart(GlobalKey key, String chartName) async {
    try {
      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 16),
              Text('Exporting chart...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Export the chart
      final filePath = await ChartExportService.exportChart(
        repaintBoundaryKey: key,
        churchName: 'Church', // In a real app, get from database
        chartType: chartName,
      );

      if (!mounted) return;

      if (filePath != null) {
        // Verify the export
        final isValid = await ChartExportService.verifyExport(filePath);

        if (!mounted) return;

        if (isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Chart exported successfully!'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        } else {
          throw Exception('Export verification failed');
        }
      } else {
        throw Exception('Failed to export chart');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting chart: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Charts'),
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
          : _records.isEmpty
          ? _buildEmptyView()
          : _buildChartsContent(),
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
            Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add weekly records to see attendance charts',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Attendance by Category Bar Chart
          _buildSectionTitle(
            'Attendance by Category',
            exportKey: _attendanceByCategoryKey,
          ),
          const SizedBox(height: 8),
          _buildAttendanceByCategoryChart(),
          const SizedBox(height: 32),

          // 2. Total Attendance Trend Line
          _buildSectionTitle(
            'Total Attendance Trend',
            exportKey: _totalTrendKey,
          ),
          const SizedBox(height: 8),
          _buildTotalAttendanceTrendChart(),
          const SizedBox(height: 32),

          // 3. Attendance Distribution Pie Chart
          _buildSectionTitle(
            'Attendance Distribution',
            exportKey: _distributionKey,
          ),
          const SizedBox(height: 8),
          _buildAttendanceDistributionChart(),
          const SizedBox(height: 32),

          // 4. Growth Rate Chart
          _buildSectionTitle(
            'Attendance Growth Rate',
            exportKey: _growthRateKey,
          ),
          const SizedBox(height: 8),
          _buildGrowthRateChart(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {GlobalKey? exportKey}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (exportKey != null)
          IconButton(
            icon: const Icon(Icons.download, size: 20),
            onPressed: () => _exportChart(exportKey, title),
            tooltip: 'Export chart',
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }

  // 1. Attendance by Category Bar Chart
  Widget _buildAttendanceByCategoryChart() {
    if (_records.isEmpty) return const SizedBox.shrink();

    // Calculate average attendance by category
    final totalMen = _records.fold<int>(0, (sum, r) => sum + r.men);
    final totalWomen = _records.fold<int>(0, (sum, r) => sum + r.women);
    final totalChildren = _records.fold<int>(0, (sum, r) => sum + r.children);

    final avgMen = totalMen / _records.length;
    final avgWomen = totalWomen / _records.length;
    final avgChildren = totalChildren / _records.length;

    final maxValue = [
      avgMen,
      avgWomen,
      avgChildren,
    ].reduce((a, b) => a > b ? a : b);

    return RepaintBoundary(
      key: _attendanceByCategoryKey,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final labels = ['Men', 'Women', 'Children'];
                      return BarTooltipItem(
                        '${labels[group.x]}\n${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Men', 'Women', 'Children'];
                        if (value.toInt() >= 0 &&
                            value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              labels[value.toInt()],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 5,
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: avgMen,
                        color: Colors.blue,
                        width: 40,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: avgWomen,
                        color: Colors.pink,
                        width: 40,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: avgChildren,
                        color: Colors.orange,
                        width: 40,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 2. Total Attendance Trend Line Chart
  Widget _buildTotalAttendanceTrendChart() {
    if (_records.isEmpty) return const SizedBox.shrink();

    // Sort records by date
    final sortedRecords = List<models.WeeklyRecord>.from(_records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    final spots = <FlSpot>[];
    for (var i = 0; i < sortedRecords.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), sortedRecords[i].totalAttendance.toDouble()),
      );
    }

    final minY = sortedRecords
        .map((r) => r.totalAttendance)
        .reduce((a, b) => a < b ? a : b)
        .toDouble();
    final maxY = sortedRecords
        .map((r) => r.totalAttendance)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return RepaintBoundary(
      key: _totalTrendKey,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final record = sortedRecords[spot.x.toInt()];
                        final dateFormat = DateFormat('MMM d');
                        return LineTooltipItem(
                          '${dateFormat.format(record.weekStartDate)}\n${spot.y.toInt()}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < sortedRecords.length) {
                          final record = sortedRecords[value.toInt()];
                          final dateFormat = DateFormat('M/d');
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dateFormat.format(record.weekStartDate),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                minY: minY * 0.9,
                maxY: maxY * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 3. Attendance Distribution Pie Chart
  Widget _buildAttendanceDistributionChart() {
    if (_records.isEmpty) return const SizedBox.shrink();

    // Calculate total attendance by category
    final totalMen = _records.fold<int>(0, (sum, r) => sum + r.men);
    final totalWomen = _records.fold<int>(0, (sum, r) => sum + r.women);
    final totalChildren = _records.fold<int>(0, (sum, r) => sum + r.children);

    final total = totalMen + totalWomen + totalChildren;
    if (total == 0) return const SizedBox.shrink();

    return RepaintBoundary(
      key: _distributionKey,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 300,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: totalMen.toDouble(),
                          title:
                              '${(totalMen / total * 100).toStringAsFixed(0)}%',
                          color: Colors.blue,
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: totalWomen.toDouble(),
                          title:
                              '${(totalWomen / total * 100).toStringAsFixed(0)}%',
                          color: Colors.pink,
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: totalChildren.toDouble(),
                          title:
                              '${(totalChildren / total * 100).toStringAsFixed(0)}%',
                          color: Colors.orange,
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {},
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Men', Colors.blue, totalMen),
                    const SizedBox(height: 8),
                    _buildLegendItem('Women', Colors.pink, totalWomen),
                    const SizedBox(height: 8),
                    _buildLegendItem('Children', Colors.orange, totalChildren),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // 4. Growth Rate Chart
  Widget _buildGrowthRateChart() {
    if (_records.length < 2) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Need at least 2 weeks of data to show growth rate',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    // Sort records by date
    final sortedRecords = List<models.WeeklyRecord>.from(_records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    // Calculate week-over-week growth rates
    final growthRates = <FlSpot>[];
    for (var i = 1; i < sortedRecords.length; i++) {
      final prev = sortedRecords[i - 1].totalAttendance;
      final curr = sortedRecords[i].totalAttendance;
      final growth = prev > 0 ? ((curr - prev) / prev * 100) : 0.0;
      growthRates.add(FlSpot(i.toDouble(), growth));
    }

    final minY = growthRates.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = growthRates.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return RepaintBoundary(
      key: _growthRateKey,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final record = sortedRecords[spot.x.toInt()];
                        final dateFormat = DateFormat('MMM d');
                        return LineTooltipItem(
                          '${dateFormat.format(record.weekStartDate)}\n${spot.y.toStringAsFixed(1)}%',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() > 0 &&
                            value.toInt() < sortedRecords.length) {
                          final record = sortedRecords[value.toInt()];
                          final dateFormat = DateFormat('M/d');
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dateFormat.format(record.weekStartDate),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                minY: minY < 0 ? minY * 1.2 : minY * 0.8,
                maxY: maxY > 0 ? maxY * 1.2 : maxY * 0.8,
                lineBarsData: [
                  LineChartBarData(
                    spots: growthRates,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final color = spot.y >= 0 ? Colors.green : Colors.red;
                        return FlDotCirclePainter(
                          radius: 4,
                          color: color,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 0,
                      color: Colors.grey,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
