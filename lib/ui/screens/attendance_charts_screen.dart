import 'package:church_analytics/graph_modules/graph_modules.dart';
import 'package:church_analytics/models/weekly_record.dart';
import 'package:church_analytics/services/weekly_records_provider.dart';
import 'package:church_analytics/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceChartsScreen extends ConsumerStatefulWidget {
  final int churchId;
  const AttendanceChartsScreen({super.key, required this.churchId});

  @override
  ConsumerState<AttendanceChartsScreen> createState() =>
      AttendanceChartsScreenState();
}

class AttendanceChartsScreenState
    extends ConsumerState<AttendanceChartsScreen> {
  static final captureKey = GlobalKey(debugLabel: 'attendance_chart_capture');

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(
      weeklyRecordsForChurchProvider(widget.churchId),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Charts'),
        actions: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: TimeRangeSelector(compact: true),
            ),
          ),
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
            : _AttendanceContent(records: records),
      ),
    );
  }
}

class _AttendanceContent extends StatelessWidget {
  final List<WeeklyRecord> records;
  const _AttendanceContent({required this.records});

  @override
  Widget build(BuildContext context) {
    return GraphListView(
      graphs: AttendanceGraphsModule.build(records),
      captureKey: AttendanceChartsScreenState.captureKey,
    );
  }
}

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
          Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No data yet', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Add weekly records to see attendance charts.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
