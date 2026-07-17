import 'package:church_analytics/graph_modules/graph_modules.dart';
import 'package:church_analytics/models/weekly_record.dart';
import 'package:church_analytics/services/weekly_records_provider.dart';
import 'package:church_analytics/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdvancedChartsScreen extends ConsumerStatefulWidget {
  final int churchId;
  const AdvancedChartsScreen({super.key, required this.churchId});

  @override
  ConsumerState<AdvancedChartsScreen> createState() =>
      AdvancedChartsScreenState();
}

class AdvancedChartsScreenState extends ConsumerState<AdvancedChartsScreen> {
  static final captureKey = GlobalKey(debugLabel: 'advanced_chart_capture');

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(
      weeklyRecordsForChurchProvider(widget.churchId),
    );
    return Scaffold(
      appBar: AppBar(
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(52),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TimeRangeSelector(compact: true),
            ),
          ),
        ),
        title: const Text('Advanced Charts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.invalidate(weeklyRecordsForChurchProvider(widget.churchId)),
          ),
        ],
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: error.toString(),
          onRetry: () =>
              ref.invalidate(weeklyRecordsForChurchProvider(widget.churchId)),
        ),
        data: (records) => records.isEmpty
            ? const _EmptyView()
            : _AdvancedContent(records: records),
      ),
    );
  }
}

// ─── Content ─────────────────────────────────────────────────────────────────

class _AdvancedContent extends StatelessWidget {
  final List<WeeklyRecord> records;
  const _AdvancedContent({required this.records});

  @override
  Widget build(BuildContext context) {
    return GraphListView(
      graphs: ForecastGraphsModule.build(records),
      captureKey: AdvancedChartsScreenState.captureKey,
    );
  }
}

// ─── Error / Empty ────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No data yet', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Add weekly records to see advanced charts.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
