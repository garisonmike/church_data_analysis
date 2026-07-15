import 'package:church_analytics/graph_modules/graph_modules.dart';
import 'package:church_analytics/services/weekly_records_provider.dart';
import 'package:church_analytics/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Charts the SDA discipleship and outreach metrics recorded on each weekly
/// record: baptisms, Holy Communion, Sabbath School, mission offering, and
/// visitors.
class SpiritualLifeScreen extends ConsumerStatefulWidget {
  final int churchId;
  const SpiritualLifeScreen({super.key, required this.churchId});

  @override
  ConsumerState<SpiritualLifeScreen> createState() =>
      SpiritualLifeScreenState();
}

class SpiritualLifeScreenState extends ConsumerState<SpiritualLifeScreen> {
  static final captureKey = GlobalKey(debugLabel: 'spiritual_life_capture');

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(
      weeklyRecordsForChurchProvider(widget.churchId),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiritual Life & Outreach'),
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
            : GraphListView(
                graphs: SpiritualLifeGraphsModule.build(records),
                captureKey: SpiritualLifeScreenState.captureKey,
              ),
      ),
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
          Icon(Icons.volunteer_activism_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No data yet', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Add weekly records to see baptisms, communion, Sabbath School,\n'
            'mission offering, and visitor trends.',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
