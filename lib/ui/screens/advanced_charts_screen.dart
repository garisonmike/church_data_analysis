import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/models.dart' as models;
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/admin_profile_service.dart';
import 'package:church_analytics/ui/widgets/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedChartsScreen extends ConsumerStatefulWidget {
  final int churchId;

  const AdvancedChartsScreen({super.key, required this.churchId});

  @override
  ConsumerState<AdvancedChartsScreen> createState() =>
      _AdvancedChartsScreenState();
}

class _AdvancedChartsScreenState extends ConsumerState<AdvancedChartsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<models.WeeklyRecord> _records = [];

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

    try {
      final database = ref.read(db.databaseProvider);
      final repository = WeeklyRecordRepository(database);

      // Get current admin ID to filter records
      final prefs = await SharedPreferences.getInstance();
      final adminRepo = AdminUserRepository(database);
      final profileService = AdminProfileService(adminRepo, prefs);
      final currentAdminId = profileService.getCurrentProfileId();

      // Get records for the last 12 weeks - filtered by admin if ID exists
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Charts'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
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
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No data available'),
            const SizedBox(height: 8),
            Text(
              'Add weekly records to see advanced charts',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    // Sort records by date
    final sortedRecords = List<models.WeeklyRecord>.from(_records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First chart loads immediately (above fold)
          _buildForecastChart(sortedRecords),
          const SizedBox(height: 24),
          // Remaining charts lazy loaded
          LazyLoadChart(
            placeholderHeight: 380,
            child: _buildMovingAverageChart(sortedRecords),
          ),
          const SizedBox(height: 24),
          LazyLoadChart(
            placeholderHeight: 380,
            child: _buildHeatmapChart(sortedRecords),
          ),
          const SizedBox(height: 24),
          _buildOutliersChart(sortedRecords),
        ],
      ),
    );
  }

  Widget _buildForecastChart(List<models.WeeklyRecord> records) {
    // Calculate simple linear regression for forecast
    final attendanceData = records
        .asMap()
        .entries
        .map(
          (e) => MapEntry(e.key.toDouble(), e.value.totalAttendance.toDouble()),
        )
        .toList();

    final forecast = _calculateForecast(attendanceData, 4); // Forecast 4 weeks

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Forecast Projection',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Historical data with 4-week forecast based on linear regression',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
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
                      axisNameWidget: const Text('Attendance'),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < records.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat(
                                  'MM/dd',
                                ).format(records[index].weekStartDate),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          } else if (index >= records.length &&
                              index < records.length + 4) {
                            // Forecast labels
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'F${index - records.length + 1}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                      axisNameWidget: const Text('Week'),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // Historical data
                    LineChartBarData(
                      spots: records
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              e.value.totalAttendance.toDouble(),
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                    ),
                    // Forecast line
                    LineChartBarData(
                      spots: forecast,
                      isCurved: false,
                      color: Colors.orange,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                      dashArray: [5, 5],
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.orange.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index < records.length) {
                            final record = records[index];
                            return LineTooltipItem(
                              'Actual\n${DateFormat('MM/dd').format(record.weekStartDate)}: ${record.totalAttendance}',
                              const TextStyle(color: Colors.white),
                            );
                          } else {
                            return LineTooltipItem(
                              'Forecast\nWeek ${index - records.length + 1}: ${spot.y.toInt()}',
                              const TextStyle(color: Colors.white),
                            );
                          }
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Historical', Colors.blue),
                const SizedBox(width: 24),
                _buildLegendItem('Forecast', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _calculateForecast(
    List<MapEntry<double, double>> data,
    int periods,
  ) {
    if (data.length < 2) return [];

    // Simple linear regression: y = mx + b
    final n = data.length;
    final sumX = data.fold(0.0, (sum, e) => sum + e.key);
    final sumY = data.fold(0.0, (sum, e) => sum + e.value);
    final sumXY = data.fold(0.0, (sum, e) => sum + (e.key * e.value));
    final sumX2 = data.fold(0.0, (sum, e) => sum + (e.key * e.key));

    final m = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final b = (sumY - m * sumX) / n;

    // Generate forecast points
    final lastIndex = data.last.key;
    final forecast = <FlSpot>[];

    // Connect to last actual data point
    forecast.add(FlSpot(lastIndex, m * lastIndex + b));

    // Add forecast points
    for (int i = 1; i <= periods; i++) {
      final x = lastIndex + i;
      final y = m * x + b;
      forecast.add(FlSpot(x, y > 0 ? y : 0)); // Ensure non-negative
    }

    return forecast;
  }

  Widget _buildMovingAverageChart(List<models.WeeklyRecord> records) {
    // Calculate 3-week moving average for attendance
    final movingAvg = _calculateMovingAverage(
      records.map((r) => r.totalAttendance.toDouble()).toList(),
      3,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance with Moving Average Overlay',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '3-week moving average smooths weekly fluctuations',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
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
                      axisNameWidget: const Text('Attendance'),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < records.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat(
                                  'MM/dd',
                                ).format(records[index].weekStartDate),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                      axisNameWidget: const Text('Week Starting'),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // Actual attendance
                    LineChartBarData(
                      spots: records
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              e.value.totalAttendance.toDouble(),
                            ),
                          )
                          .toList(),
                      isCurved: false,
                      color: Colors.blue.withValues(alpha: 0.5),
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Moving average
                    LineChartBarData(
                      spots: movingAvg,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          final record = records[index];
                          final date = DateFormat(
                            'MM/dd',
                          ).format(record.weekStartDate);

                          if (spot.barIndex == 0) {
                            return LineTooltipItem(
                              'Actual\n$date: ${record.totalAttendance}',
                              const TextStyle(color: Colors.white),
                            );
                          } else {
                            return LineTooltipItem(
                              'Avg\n$date: ${spot.y.toInt()}',
                              const TextStyle(color: Colors.white),
                            );
                          }
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  'Weekly Attendance',
                  Colors.blue.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 24),
                _buildLegendItem('3-Week Moving Avg', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _calculateMovingAverage(List<double> data, int window) {
    if (data.length < window) return [];

    final result = <FlSpot>[];
    for (int i = window - 1; i < data.length; i++) {
      double sum = 0;
      for (int j = 0; j < window; j++) {
        sum += data[i - j];
      }
      result.add(FlSpot(i.toDouble(), sum / window));
    }
    return result;
  }

  Widget _buildHeatmapChart(List<models.WeeklyRecord> records) {
    // Create a simplified heatmap showing attendance vs income intensity
    // We'll use a grid showing the relationship strength
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance vs Funds Heatmap',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Color intensity shows the relationship between attendance and income',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(height: 300, child: _buildHeatmapGrid(records)),
            const SizedBox(height: 16),
            _buildHeatmapLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapGrid(List<models.WeeklyRecord> records) {
    // Divide attendance and income into buckets
    final maxAttendance = records.fold(
      0,
      (max, r) => r.totalAttendance > max ? r.totalAttendance : max,
    );
    final maxIncome = records.fold(
      0.0,
      (max, r) => r.totalIncome > max ? r.totalIncome : max,
    );

    // Create 5x5 grid
    const gridSize = 5;
    final attendanceBucket = maxAttendance / gridSize;
    final incomeBucket = maxIncome / gridSize;

    // Count records in each cell
    final grid = List.generate(gridSize, (_) => List<int>.filled(gridSize, 0));

    for (final record in records) {
      final attendanceIndex =
          ((record.totalAttendance / attendanceBucket).floor()).clamp(
            0,
            gridSize - 1,
          );
      final incomeIndex = ((record.totalIncome / incomeBucket).floor()).clamp(
        0,
        gridSize - 1,
      );
      grid[gridSize - 1 - incomeIndex][attendanceIndex]++;
    }

    final maxCount = grid.fold(
      0,
      (max, row) => row.fold(max, (m, v) => v > m ? v : m),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Y-axis label
        Row(
          children: [
            const SizedBox(width: 40),
            Expanded(
              child: Center(
                child: Text(
                  'Attendance Range',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Row(
            children: [
              // Y-axis
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'Income Range',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Grid
              Expanded(
                child: Column(
                  children: List.generate(gridSize, (row) {
                    return Expanded(
                      child: Row(
                        children: List.generate(gridSize, (col) {
                          final count = grid[row][col];
                          final intensity = maxCount > 0
                              ? count / maxCount
                              : 0.0;
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: _getHeatmapColor(intensity),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Center(
                                child: count > 0
                                    ? Text(
                                        count.toString(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: intensity > 0.5
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getHeatmapColor(double intensity) {
    if (intensity == 0) return Colors.grey.shade100;
    // Gradient from light blue to dark blue
    return Color.lerp(Colors.blue.shade100, Colors.blue.shade900, intensity)!;
  }

  Widget _buildHeatmapLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        const Text('Low', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 16),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.blue.shade400,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        const Text('Medium', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 16),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.blue.shade900,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        const Text('High', style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildOutliersChart(List<models.WeeklyRecord> records) {
    // Detect outliers using IQR method for attendance
    final attendanceValues =
        records.map((r) => r.totalAttendance.toDouble()).toList()..sort();

    final outliers = _detectOutliers(attendanceValues);
    final outlierIndices = <int>{};

    for (int i = 0; i < records.length; i++) {
      if (outliers.contains(records[i].totalAttendance.toDouble())) {
        outlierIndices.add(i);
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance with Outlier Detection',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Outliers detected using IQR method (values beyond 1.5 × IQR)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
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
                      axisNameWidget: const Text('Attendance'),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < records.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat(
                                  'MM/dd',
                                ).format(records[index].weekStartDate),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                      axisNameWidget: const Text('Week Starting'),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // Normal data points
                    LineChartBarData(
                      spots: records
                          .asMap()
                          .entries
                          .where((e) => !outlierIndices.contains(e.key))
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              e.value.totalAttendance.toDouble(),
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                    ),
                    // Outlier points
                    LineChartBarData(
                      spots: records
                          .asMap()
                          .entries
                          .where((e) => outlierIndices.contains(e.key))
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              e.value.totalAttendance.toDouble(),
                            ),
                          )
                          .toList(),
                      isCurved: false,
                      color: Colors.red,
                      barWidth: 0,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: Colors.red,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          final record = records[index];
                          final date = DateFormat(
                            'MM/dd',
                          ).format(record.weekStartDate);
                          final isOutlier = outlierIndices.contains(index);

                          return LineTooltipItem(
                            isOutlier
                                ? 'OUTLIER\n$date: ${record.totalAttendance}'
                                : 'Normal\n$date: ${record.totalAttendance}',
                            TextStyle(
                              color: Colors.white,
                              fontWeight: isOutlier
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Normal', Colors.blue),
                const SizedBox(width: 24),
                _buildLegendItem('Outlier', Colors.red),
              ],
            ),
            if (outlierIndices.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${outlierIndices.length} outlier${outlierIndices.length > 1 ? 's' : ''} detected. These weeks had unusually high or low attendance.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Set<double> _detectOutliers(List<double> sortedValues) {
    if (sortedValues.length < 4) return {};

    // Calculate Q1, Q3, and IQR
    final q1Index = (sortedValues.length * 0.25).floor();
    final q3Index = (sortedValues.length * 0.75).floor();

    final q1 = sortedValues[q1Index];
    final q3 = sortedValues[q3Index];
    final iqr = q3 - q1;

    // Outliers are values beyond 1.5 * IQR from Q1 or Q3
    final lowerBound = q1 - 1.5 * iqr;
    final upperBound = q3 + 1.5 * iqr;

    return sortedValues
        .where((value) => value < lowerBound || value > upperBound)
        .toSet();
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
