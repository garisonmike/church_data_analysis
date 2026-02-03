import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/dashboard_config.dart';
import '../../services/dashboard_config_service.dart';

class DashboardLayoutEditorScreen extends ConsumerWidget {
  const DashboardLayoutEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(dashboardConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Layout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to default',
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customize dashboard widgets',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Toggle visibility and drag to reorder sections.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: config.order.length,
                onReorder: (oldIndex, newIndex) {
                  final updated = List<DashboardSection>.from(config.order);
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final section = updated.removeAt(oldIndex);
                  updated.insert(newIndex, section);
                  ref
                      .read(dashboardConfigProvider.notifier)
                      .setSectionOrder(updated);
                },
                itemBuilder: (context, index) {
                  final section = config.order[index];
                  final isVisible = config.isVisible(section);
                  return ListTile(
                    key: ValueKey(section.name),
                    leading: Icon(_iconForSection(section)),
                    title: Text(_labelForSection(section)),
                    subtitle: Text(
                      isVisible ? 'Visible' : 'Hidden',
                      style: TextStyle(
                        color: isVisible
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    trailing: Switch(
                      value: isVisible,
                      onChanged: (value) {
                        ref
                            .read(dashboardConfigProvider.notifier)
                            .setSectionVisibility(section, value);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelForSection(DashboardSection section) {
    switch (section) {
      case DashboardSection.kpiCards:
        return 'KPI Cards';
      case DashboardSection.quickActions:
        return 'Quick Actions';
      case DashboardSection.recentWeeks:
        return 'Recent Weeks';
    }
  }

  IconData _iconForSection(DashboardSection section) {
    switch (section) {
      case DashboardSection.kpiCards:
        return Icons.dashboard_customize;
      case DashboardSection.quickActions:
        return Icons.flash_on;
      case DashboardSection.recentWeeks:
        return Icons.history;
    }
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset layout?'),
        content: const Text(
          'This will restore the default widget order and visibility.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (result == true) {
      await ref.read(dashboardConfigProvider.notifier).resetToDefaults();
    }
  }
}
