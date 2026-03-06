import 'package:church_analytics/models/activity_log_entry.dart';
import 'package:church_analytics/services/activity_log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// ActivityLogCard
// ---------------------------------------------------------------------------

/// Settings card that displays the "Recent Activity" log.
///
/// Shows the 10 most-recent export, import, and installer-launch operations
/// with a green (success) or red (failure) icon, the filename, and a relative
/// timestamp.  The list is populated from [activityLogServiceProvider] on
/// every build — i.e. whenever the Settings screen is opened or rebuilt.
class ActivityLogCard extends ConsumerWidget {
  const ActivityLogCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read instead of watch: entries are only needed on build.
    // The list will be current each time the Settings screen is entered.
    final logService = ref.read(activityLogServiceProvider);
    final entries = logService.getRecentEntries(10);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Last 10 file operations',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              _EmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) =>
                    _ActivityEntryTile(entries[index]),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ActivityEntryTile
// ---------------------------------------------------------------------------

class _ActivityEntryTile extends StatelessWidget {
  final ActivityLogEntry entry;

  const _ActivityEntryTile(this.entry);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final successColor = Colors.green.shade600;
    final failureColor = colorScheme.error;

    final iconColor = entry.success ? successColor : failureColor;
    final icon = entry.success
        ? Icons.check_circle_outline
        : Icons.error_outline;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        entry.filename,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TypeBadge(entry.type),
              const SizedBox(width: 8),
              Text(
                _relativeTime(entry.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (entry.message != null) ...[
            const SizedBox(height: 2),
            Text(
              entry.message!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: entry.success
                    ? colorScheme.onSurfaceVariant
                    : failureColor,
              ),
            ),
          ],
        ],
      ),
      isThreeLine: entry.message != null,
    );
  }
}

// ---------------------------------------------------------------------------
// _TypeBadge
// ---------------------------------------------------------------------------

class _TypeBadge extends StatelessWidget {
  final ActivityLogEntryType type;

  const _TypeBadge(this.type);

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String label) = switch (type) {
      ActivityLogEntryType.export => (Icons.upload_file, 'Export'),
      ActivityLogEntryType.import => (Icons.download_for_offline, 'Import'),
      ActivityLogEntryType.installerLaunch => (Icons.install_mobile, 'Install'),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _EmptyState
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 36,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'No activity recorded yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Export or import data to see your history here.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Relative time helper
// ---------------------------------------------------------------------------

/// Returns a human-readable relative time string for [timestamp].
///
/// Examples: `'just now'`, `'3m ago'`, `'2h ago'`, `'5d ago'`,
/// `'Jan 15, 2026'` (for entries older than one week).
String _relativeTime(DateTime timestamp) {
  final now = DateTime.now();
  final diff = now.difference(timestamp);

  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('MMM d, y').format(timestamp);
}
