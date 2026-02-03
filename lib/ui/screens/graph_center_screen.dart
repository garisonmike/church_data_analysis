import 'package:church_analytics/ui/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ChartCategory { all, attendance, financial, analysis, advanced }

class ChartItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final ChartCategory category;
  final Widget Function(int churchId) screenBuilder;

  const ChartItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.screenBuilder,
  });
}

class GraphCenterScreen extends ConsumerStatefulWidget {
  final int churchId;

  const GraphCenterScreen({super.key, required this.churchId});

  @override
  ConsumerState<GraphCenterScreen> createState() => _GraphCenterScreenState();
}

class _GraphCenterScreenState extends ConsumerState<GraphCenterScreen> {
  ChartCategory _selectedCategory = ChartCategory.all;

  late final List<ChartItem> _allCharts;

  @override
  void initState() {
    super.initState();
    _allCharts = [
      ChartItem(
        title: 'Attendance Charts',
        description: 'Weekly trends, demographics, distribution, and growth',
        icon: Icons.bar_chart,
        color: Colors.blue,
        category: ChartCategory.attendance,
        screenBuilder: (churchId) => AttendanceChartsScreen(churchId: churchId),
      ),
      ChartItem(
        title: 'Financial Charts',
        description: 'Tithe, offerings, income breakdown, and distributions',
        icon: Icons.pie_chart,
        color: Colors.green,
        category: ChartCategory.financial,
        screenBuilder: (churchId) => FinancialChartsScreen(churchId: churchId),
      ),
      ChartItem(
        title: 'Correlation Charts',
        description: 'Attendance vs income, demographics, and scatter plots',
        icon: Icons.scatter_plot,
        color: Colors.purple,
        category: ChartCategory.analysis,
        screenBuilder: (churchId) =>
            CorrelationChartsScreen(churchId: churchId),
      ),
      ChartItem(
        title: 'Advanced Charts',
        description: 'Forecasts, moving averages, heatmaps, and outliers',
        icon: Icons.insights,
        color: Colors.deepOrange,
        category: ChartCategory.advanced,
        screenBuilder: (churchId) => AdvancedChartsScreen(churchId: churchId),
      ),
      ChartItem(
        title: 'Custom Graph Builder',
        description: 'Create dynamic charts with any two metrics',
        icon: Icons.auto_graph,
        color: Colors.teal,
        category: ChartCategory.advanced,
        screenBuilder: (churchId) =>
            CustomGraphBuilderScreen(churchId: churchId),
      ),
    ];
  }

  List<ChartItem> get _filteredCharts {
    if (_selectedCategory == ChartCategory.all) {
      return _allCharts;
    }
    return _allCharts
        .where((chart) => chart.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chart Center'), centerTitle: true),
      body: Column(
        children: [
          _buildCategoryFilters(),
          Expanded(child: _buildChartGrid()),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'All',
              category: ChartCategory.all,
              icon: Icons.apps,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Attendance',
              category: ChartCategory.attendance,
              icon: Icons.people,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Financial',
              category: ChartCategory.financial,
              icon: Icons.attach_money,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Analysis',
              category: ChartCategory.analysis,
              icon: Icons.analytics,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Advanced',
              category: ChartCategory.advanced,
              icon: Icons.trending_up,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required ChartCategory category,
    required IconData icon,
  }) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 4), Text(label)],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = category;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildChartGrid() {
    final filteredCharts = _filteredCharts;

    if (filteredCharts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No charts in this category',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: filteredCharts.length,
          itemBuilder: (context, index) {
            return _buildChartCard(filteredCharts[index]);
          },
        );
      },
    );
  }

  Widget _buildChartCard(ChartItem chart) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToChart(chart),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                chart.color.withValues(alpha: 0.1),
                chart.color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: chart.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(chart.icon, size: 32, color: chart.color),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward,
                    color: chart.color.withValues(alpha: 0.5),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chart.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: chart.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chart.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToChart(ChartItem chart) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => chart.screenBuilder(widget.churchId),
      ),
    );
  }
}
