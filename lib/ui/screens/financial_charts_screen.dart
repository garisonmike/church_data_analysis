import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/models.dart' as models;
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/admin_profile_service.dart';
import 'package:church_analytics/services/settings_service.dart';
import 'package:church_analytics/ui/widgets/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinancialChartsScreen extends ConsumerStatefulWidget {
  final int churchId;

  const FinancialChartsScreen({super.key, required this.churchId});

  @override
  ConsumerState<FinancialChartsScreen> createState() =>
      _FinancialChartsScreenState();
}

class _FinancialChartsScreenState extends ConsumerState<FinancialChartsScreen> {
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
        title: const Text('Financial Charts'),
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
              'Add weekly records to see financial charts',
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
          _buildTitheVsOfferingsChart(sortedRecords),
          const SizedBox(height: 24),
          // Remaining charts lazy loaded
          LazyLoadChart(
            placeholderHeight: 380,
            child: _buildIncomeBreakdownChart(sortedRecords),
          ),
          const SizedBox(height: 24),
          LazyLoadChart(
            placeholderHeight: 380,
            child: _buildIncomeDistributionPieChart(sortedRecords),
          ),
          const SizedBox(height: 24),
          LazyLoadChart(
            placeholderHeight: 380,
            child: _buildFundsVsAttendanceChart(sortedRecords),
          ),
        ],
      ),
    );
  }

  Widget _buildTitheVsOfferingsChart(List<models.WeeklyRecord> records) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tithe vs Offerings',
              style: Theme.of(context).textTheme.titleLarge,
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
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                      axisNameWidget: const Text('Amount (\$)'),
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
                    // Tithe line
                    LineChartBarData(
                      spots: records
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.tithe))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Offerings line
                    LineChartBarData(
                      spots: records
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(e.key.toDouble(), e.value.offerings),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final record = records[spot.x.toInt()];
                          final date = DateFormat(
                            'MM/dd',
                          ).format(record.weekStartDate);
                          final value = spot.y;
                          final label = spot.barIndex == 0
                              ? 'Tithe'
                              : 'Offerings';
                          return LineTooltipItem(
                            '$label\n$date: ${_formatCurrency(value)}',
                            const TextStyle(color: Colors.white),
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
                _buildLegendItem('Tithe', Colors.blue),
                const SizedBox(width: 24),
                _buildLegendItem('Offerings', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeBreakdownChart(List<models.WeeklyRecord> records) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income Breakdown (Stacked)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final record = records[group.x.toInt()];
                        final date = DateFormat(
                          'MM/dd',
                        ).format(record.weekStartDate);
                        return BarTooltipItem(
                          '$date\nTotal: ${_formatCurrency(record.totalIncome)}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                      axisNameWidget: const Text('Amount (\$)'),
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
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  barGroups: records.asMap().entries.map((entry) {
                    final record = entry.value;
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: record.totalIncome,
                          width: 20,
                          rodStackItems: [
                            BarChartRodStackItem(0, record.tithe, Colors.blue),
                            BarChartRodStackItem(
                              record.tithe,
                              record.tithe + record.offerings,
                              Colors.green,
                            ),
                            BarChartRodStackItem(
                              record.tithe + record.offerings,
                              record.tithe +
                                  record.offerings +
                                  record.emergencyCollection,
                              Colors.orange,
                            ),
                            BarChartRodStackItem(
                              record.tithe +
                                  record.offerings +
                                  record.emergencyCollection,
                              record.totalIncome,
                              Colors.purple,
                            ),
                          ],
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem('Tithe', Colors.blue),
                _buildLegendItem('Offerings', Colors.green),
                _buildLegendItem('Emergency', Colors.orange),
                _buildLegendItem('Planned', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeDistributionPieChart(List<models.WeeklyRecord> records) {
    // Calculate totals across all records
    final totalTithe = records.fold(0.0, (sum, r) => sum + r.tithe);
    final totalOfferings = records.fold(0.0, (sum, r) => sum + r.offerings);
    final totalEmergency = records.fold(
      0.0,
      (sum, r) => sum + r.emergencyCollection,
    );
    final totalPlanned = records.fold(
      0.0,
      (sum, r) => sum + r.plannedCollection,
    );
    final grandTotal =
        totalTithe + totalOfferings + totalEmergency + totalPlanned;

    if (grandTotal == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Income Distribution',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Center(child: Text('No income data available')),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: totalTithe,
                      title:
                          '${((totalTithe / grandTotal) * 100).toStringAsFixed(1)}%',
                      color: Colors.blue,
                      radius: 120,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: totalOfferings,
                      title:
                          '${((totalOfferings / grandTotal) * 100).toStringAsFixed(1)}%',
                      color: Colors.green,
                      radius: 120,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: totalEmergency,
                      title:
                          '${((totalEmergency / grandTotal) * 100).toStringAsFixed(1)}%',
                      color: Colors.orange,
                      radius: 120,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: totalPlanned,
                      title:
                          '${((totalPlanned / grandTotal) * 100).toStringAsFixed(1)}%',
                      color: Colors.purple,
                      radius: 120,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {},
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem(
                  'Tithe: ${_formatCurrency(totalTithe)}',
                  Colors.blue,
                ),
                _buildLegendItem(
                  'Offerings: ${_formatCurrency(totalOfferings)}',
                  Colors.green,
                ),
                _buildLegendItem(
                  'Emergency: ${_formatCurrency(totalEmergency)}',
                  Colors.orange,
                ),
                _buildLegendItem(
                  'Planned: ${_formatCurrency(totalPlanned)}',
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundsVsAttendanceChart(List<models.WeeklyRecord> records) {
    // Calculate max values for scaling
    final maxIncome = records.fold(
      0.0,
      (max, r) => r.totalIncome > max ? r.totalIncome : max,
    );
    final maxAttendance = records.fold(
      0,
      (max, r) => r.totalAttendance > max ? r.totalAttendance : max,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Income vs Attendance',
              style: Theme.of(context).textTheme.titleLarge,
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
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                      axisNameWidget: const Text('Income (\$)'),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
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
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // Income line (primary axis)
                    LineChartBarData(
                      spots: records
                          .asMap()
                          .entries
                          .map(
                            (e) =>
                                FlSpot(e.key.toDouble(), e.value.totalIncome),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withValues(alpha: 0.2),
                      ),
                    ),
                    // Attendance line (scaled to income range for dual axis effect)
                    LineChartBarData(
                      spots: records
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              maxAttendance > 0
                                  ? (e.value.totalAttendance / maxAttendance) *
                                        maxIncome
                                  : 0,
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final record = records[spot.x.toInt()];
                          final date = DateFormat(
                            'MM/dd',
                          ).format(record.weekStartDate);
                          if (spot.barIndex == 0) {
                            return LineTooltipItem(
                              'Income\n$date: ${_formatCurrency(record.totalIncome)}',
                              const TextStyle(color: Colors.white),
                            );
                          } else {
                            return LineTooltipItem(
                              'Attendance\n$date: ${record.totalAttendance}',
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
                _buildLegendItem('Total Income', Colors.green),
                const SizedBox(width: 24),
                _buildLegendItem('Total Attendance', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    final settingsNotifier = ref.read(appSettingsProvider.notifier);
    return settingsNotifier.formatCurrencyPrecise(amount);
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
