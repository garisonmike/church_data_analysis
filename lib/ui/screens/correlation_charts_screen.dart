import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart' as models;
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/admin_profile_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CorrelationChartsScreen extends ConsumerStatefulWidget {
  final int churchId;

  const CorrelationChartsScreen({super.key, required this.churchId});

  @override
  ConsumerState<CorrelationChartsScreen> createState() =>
      _CorrelationChartsScreenState();
}

class _CorrelationChartsScreenState
    extends ConsumerState<CorrelationChartsScreen> {
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

    AppDatabase? database;
    try {
      database = AppDatabase();
      final repository = WeeklyRecordRepository(database);

      // Get current admin ID to filter records
      final prefs = await SharedPreferences.getInstance();
      final adminDb = AppDatabase();
      final adminRepo = AdminUserRepository(adminDb);
      final profileService = AdminProfileService(adminRepo, prefs);
      final currentAdminId = profileService.getCurrentProfileId();
      await adminDb.close();

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
    } finally {
      await database?.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Correlation Charts'),
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
              'Add weekly records to see correlation charts',
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
          _buildAttendanceVsIncomeChart(sortedRecords),
          const SizedBox(height: 24),
          _buildDemographicsVsFundsChart(sortedRecords),
          const SizedBox(height: 24),
          _buildScatterCorrelationChart(sortedRecords),
          const SizedBox(height: 24),
          _buildGroupsVsFundsChart(sortedRecords),
        ],
      ),
    );
  }

  Widget _buildAttendanceVsIncomeChart(List<models.WeeklyRecord> records) {
    // Calculate max values for scaling
    final maxAttendance = records.fold(
      0,
      (max, r) => r.totalAttendance > max ? r.totalAttendance : max,
    );
    final maxIncome = records.fold(
      0.0,
      (max, r) => r.totalIncome > max ? r.totalIncome : max,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance vs Income (Dual-Axis)',
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
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          // Scale back from attendance range to income range
                          final incomeValue = maxAttendance > 0
                              ? (value / maxAttendance) * maxIncome
                              : 0;
                          return Text(
                            '\$${incomeValue.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                      axisNameWidget: const Text('Income (\$)'),
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
                    // Attendance line (primary axis)
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
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Income line (scaled to attendance range for dual axis)
                    LineChartBarData(
                      spots: records
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              maxIncome > 0
                                  ? (e.value.totalIncome / maxIncome) *
                                        maxAttendance
                                  : 0,
                            ),
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
                          if (spot.barIndex == 0) {
                            return LineTooltipItem(
                              'Attendance\n$date: ${record.totalAttendance}',
                              const TextStyle(color: Colors.white),
                            );
                          } else {
                            return LineTooltipItem(
                              'Income\n$date: \$${record.totalIncome.toStringAsFixed(2)}',
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
                _buildLegendItem('Total Attendance', Colors.blue),
                const SizedBox(width: 24),
                _buildLegendItem('Total Income', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemographicsVsFundsChart(List<models.WeeklyRecord> records) {
    // Calculate average demographics and total income
    final avgMen = records.fold(0, (sum, r) => sum + r.men) / records.length;
    final avgWomen =
        records.fold(0, (sum, r) => sum + r.women) / records.length;
    final avgYouth =
        records.fold(0, (sum, r) => sum + r.youth) / records.length;
    final avgChildren =
        records.fold(0, (sum, r) => sum + r.children) / records.length;

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Demographics vs Funds',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Average attendance by group and total income breakdown',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Demographics bar chart
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Avg Attendance',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final labels = [
                                    'Men',
                                    'Women',
                                    'Youth',
                                    'Children',
                                  ];
                                  return BarTooltipItem(
                                    '${labels[group.x.toInt()]}\n${rod.toY.toStringAsFixed(1)}',
                                    const TextStyle(color: Colors.white),
                                  );
                                },
                              ),
                            ),
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
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const labels = [
                                      'Men',
                                      'Women',
                                      'Youth',
                                      'Child',
                                    ];
                                    final index = value.toInt();
                                    if (index >= 0 && index < labels.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          labels[index],
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
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
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: avgMen,
                                    color: Colors.blue,
                                    width: 20,
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: avgWomen,
                                    color: Colors.pink,
                                    width: 20,
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 2,
                                barRods: [
                                  BarChartRodData(
                                    toY: avgYouth,
                                    color: Colors.orange,
                                    width: 20,
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 3,
                                barRods: [
                                  BarChartRodData(
                                    toY: avgChildren,
                                    color: Colors.purple,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Funds bar chart
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Income',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  const labels = [
                                    'Tithe',
                                    'Offerings',
                                    'Emergency',
                                    'Planned',
                                  ];
                                  return BarTooltipItem(
                                    '${labels[group.x.toInt()]}\n\$${rod.toY.toStringAsFixed(2)}',
                                    const TextStyle(color: Colors.white),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '\$${(value / 1000).toStringAsFixed(0)}k',
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const labels = [
                                      'Tithe',
                                      'Offer',
                                      'Emerg',
                                      'Plan',
                                    ];
                                    final index = value.toInt();
                                    if (index >= 0 && index < labels.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          labels[index],
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
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
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: totalTithe,
                                    color: Colors.blue,
                                    width: 20,
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: totalOfferings,
                                    color: Colors.green,
                                    width: 20,
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 2,
                                barRods: [
                                  BarChartRodData(
                                    toY: totalEmergency,
                                    color: Colors.orange,
                                    width: 20,
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 3,
                                barRods: [
                                  BarChartRodData(
                                    toY: totalPlanned,
                                    color: Colors.purple,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScatterCorrelationChart(List<models.WeeklyRecord> records) {
    // Create scatter plot of attendance vs income
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance vs Income Scatter Plot',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Correlation between total attendance and total income',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ScatterChart(
                ScatterChartData(
                  gridData: FlGridData(show: true),
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
                      axisNameWidget: const Text('Total Income (\$)'),
                    ),
                    bottomTitles: AxisTitles(
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
                      axisNameWidget: const Text('Total Attendance'),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  scatterSpots: records
                      .map(
                        (record) => ScatterSpot(
                          record.totalAttendance.toDouble(),
                          record.totalIncome,
                        ),
                      )
                      .toList(),
                  scatterTouchData: ScatterTouchData(
                    touchTooltipData: ScatterTouchTooltipData(
                      getTooltipItems: (spot) {
                        final record = records.firstWhere(
                          (r) =>
                              r.totalAttendance.toDouble() == spot.x &&
                              r.totalIncome == spot.y,
                        );
                        return ScatterTooltipItem(
                          DateFormat('MM/dd').format(record.weekStartDate),
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          bottomMargin: 8,
                          children: [
                            TextSpan(
                              text:
                                  '\nAttendance: ${record.totalAttendance}\nIncome: \$${record.totalIncome.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsVsFundsChart(List<models.WeeklyRecord> records) {
    // Show correlation between different groups and specific fund sources
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Groups vs Funds Correlation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Comparing adult attendance (men + women) with tithes and offerings',
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
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                      axisNameWidget: const Text('Count'),
                    ),
                    rightTitles: AxisTitles(
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
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // Adults (men + women) line
                    LineChartBarData(
                      spots: records
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              (e.value.men + e.value.women).toDouble(),
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Tithe + Offerings (scaled to match adult range)
                    LineChartBarData(
                      spots: records
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              e.value.tithe + e.value.offerings,
                            ),
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
                          if (spot.barIndex == 0) {
                            return LineTooltipItem(
                              'Adults\n$date: ${record.men + record.women}',
                              const TextStyle(color: Colors.white),
                            );
                          } else {
                            return LineTooltipItem(
                              'Tithe+Offerings\n$date: \$${(record.tithe + record.offerings).toStringAsFixed(2)}',
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
                _buildLegendItem('Adults (Men+Women)', Colors.blue),
                const SizedBox(width: 24),
                _buildLegendItem('Tithe + Offerings (\$)', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
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
