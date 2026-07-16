import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/app_secrets.dart';
import '../../services/log_service.dart';

/// Shows recent in-memory log entries and allows exporting logs for a
/// chosen date range to a file the user picks.
///
/// Access via the app-settings screen or any debug menu.
class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

/// A run of consecutive identical log entries, collapsed for display (U6).
/// [entry] is the most recent occurrence; [count] is how many identical
/// entries were folded into it.
class _LogGroup {
  final LogEntry entry;
  final int count;
  const _LogGroup(this.entry, this.count);
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  LogLevel _filterLevel = LogLevel.debug;
  List<_LogGroup> _groups = [];
  int _totalCount = 0;

  // Export range
  DateTime _exportFrom = DateTime.now().subtract(const Duration(days: 6));
  DateTime _exportTo = DateTime.now();
  bool _exporting = false;

  static final _dateFmt = DateFormat('yyyy-MM-dd');
  static final _timeFmt = DateFormat('HH:mm:ss');

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final entries = LogService.getRecentEntries(minLevel: _filterLevel);
    setState(() {
      _totalCount = entries.length;
      _groups = _collapseConsecutive(entries);
    });
  }

  /// Folds runs of identical consecutive entries (same level, tag, message,
  /// and error — timestamp ignored) into one [_LogGroup] with a count, so
  /// four back-to-back copies of the same exception read as one row ×4
  /// instead of four near-duplicate rows (U6).
  static List<_LogGroup> _collapseConsecutive(List<LogEntry> entries) {
    final groups = <_LogGroup>[];
    for (final e in entries) {
      final last = groups.isEmpty ? null : groups.last;
      if (last != null &&
          last.entry.level == e.level &&
          last.entry.tag == e.tag &&
          last.entry.message == e.message &&
          last.entry.error == e.error) {
        groups[groups.length - 1] = _LogGroup(last.entry, last.count + 1);
      } else {
        groups.add(_LogGroup(e, 1));
      }
    }
    return groups;
  }

  Color _levelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.crash:
        return Colors.purple;
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: DateTimeRange(start: _exportFrom, end: _exportTo),
    );
    if (picked != null) {
      setState(() {
        _exportFrom = picked.start;
        _exportTo = picked.end;
      });
    }
  }

  Future<void> _exportLogs() async {
    setState(() => _exporting = true);
    try {
      // Build a suggested filename.
      final from = _dateFmt.format(_exportFrom);
      final to = _dateFmt.format(_exportTo);
      final suggestedName = 'church_analytics_logs_${from}_to_$to.log';

      // Ask user where to save.
      String? destPath;
      if (!kIsWeb) {
        if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
          // Use a temp path in documents when no file picker is integrated here.
          // In production this would call fileService.pickSaveLocation().
          final dir = await _getExportsDir();
          destPath = '${dir.path}/$suggestedName';
        } else if (Platform.isAndroid) {
          // Resolve an Android-specific exports directory.
          // path_provider is already a dependency (^2.1.5 in pubspec.yaml).
          final dir = await _getAndroidExportsDir();
          if (dir != null) destPath = '${dir.path}/$suggestedName';
        }
      }

      if (destPath == null) {
        _showSnack('Could not determine save location.');
        return;
      }

      final lines = await LogService.exportLogs(
        from: _exportFrom,
        to: _exportTo.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
        destPath: destPath,
      );

      if (lines >= 0) {
        _showSnack('Exported $lines lines → $destPath', success: true);
      } else {
        _showSnack('Export failed. Check log directory permissions.');
      }
    } finally {
      setState(() => _exporting = false);
    }
  }

  Future<Directory> _getExportsDir() async {
    // Reuse the app's Documents folder.
    if (Platform.isLinux || Platform.isMacOS) {
      final home = Platform.environment['HOME'] ?? '/tmp';
      final dir = Directory('$home/Documents/church_analytics_exports');
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    }
    return Directory.systemTemp;
  }

  // Android-specific export directory resolver.
  // Uses the app-scoped external storage directory (no manifest permission
  // required on Android 10+) with a fallback to internal documents storage
  // which is always accessible on all Android versions.
  Future<Directory?> _getAndroidExportsDir() async {
    try {
      final external = await getExternalStorageDirectory();
      if (external != null) {
        final dir = Directory('${external.path}/church_analytics_exports');
        if (!await dir.exists()) await dir.create(recursive: true);
        return dir;
      }
    } catch (e) {
      LogService.warning('LogViewer', 'External storage unavailable: $e');
    }
    // Fallback: app-internal documents directory (always accessible).
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/church_analytics_exports');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  void _showSnack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Logs'),
        actions: [
          // Level filter
          PopupMenuButton<LogLevel>(
            tooltip: 'Filter level',
            icon: const Icon(Icons.filter_list),
            onSelected: (level) {
              setState(() => _filterLevel = level);
              _refresh();
            },
            itemBuilder: (_) => LogLevel.values
                .map(
                  (l) => PopupMenuItem(
                    value: l,
                    child: Text(l.name.toUpperCase()),
                  ),
                )
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Export card ──────────────────────────────────────────────────
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export logs',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: _pickDateRange,
                          child: Text(
                            '${_dateFmt.format(_exportFrom)}  →  ${_dateFmt.format(_exportTo)}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _exporting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : FilledButton.icon(
                          onPressed: _exportLogs,
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Export'),
                        ),
                ],
              ),
            ),
          ),

          // ── Level badge strip ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  'Showing $_totalCount entries  ·  min level: ${_filterLevel.name.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // ── Log list ─────────────────────────────────────────────────────
          Expanded(
            child: _groups.isEmpty
                ? const Center(child: Text('No log entries yet.'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _groups.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final g = _groups[i];
                      return _LogEntryTile(
                        entry: g.entry,
                        count: g.count,
                        levelColor: _levelColor(g.entry.level),
                        timeFmt: _timeFmt,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LogEntryTile extends StatelessWidget {
  final LogEntry entry;
  final int count;
  final Color levelColor;
  final DateFormat timeFmt;

  const _LogEntryTile({
    required this.entry,
    this.count = 1,
    required this.levelColor,
    required this.timeFmt,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level badge
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: levelColor.withAlpha(30),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: levelColor.withAlpha(80)),
            ),
            child: Text(
              entry.levelLabel.trim(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: levelColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          // Timestamp + tag + message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      timeFmt.format(entry.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '[${entry.tag}]',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (count > 1) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: levelColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: levelColor.withAlpha(90)),
                        ),
                        child: Text(
                          '×$count',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: levelColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  entry.message,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (entry.error != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.error!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
                if (entry.stackTrace != null) ...[
                  const SizedBox(height: 4),
                  // Stack traces make crashes like B3 diagnosable from the log
                  // alone. Kept in a bounded, scrollable monospace box so a
                  // long trace doesn't dominate the list.
                  Container(
                    constraints: const BoxConstraints(maxHeight: 140),
                    width: double.infinity,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        entry.stackTrace!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Call this early in [StartupGateScreen] or [DashboardScreen] to check
/// for a previous crash and offer to share logs.
Future<void> showCrashRecoveryDialogIfNeeded(BuildContext context) async {
  final crashed = await LogService.didCrashLastSession();
  if (!crashed) return;
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const _CrashRecoveryDialog(),
  );
}

class _CrashRecoveryDialog extends StatefulWidget {
  const _CrashRecoveryDialog();

  @override
  State<_CrashRecoveryDialog> createState() => _CrashRecoveryDialogState();
}

class _CrashRecoveryDialogState extends State<_CrashRecoveryDialog> {
  bool _sending = false;

  Future<void> _sendReport() async {
    setState(() => _sending = true);

    try {
      final tempDir = await getTemporaryDirectory();
      final destPath =
          '${tempDir.path}/crash_report_${DateTime.now().millisecondsSinceEpoch}.log';
      final now = DateTime.now();
      await LogService.exportLogs(
        from: now.subtract(const Duration(days: 7)),
        to: now,
        destPath: destPath,
      );

      await Share.shareXFiles(
        [XFile(destPath)],
        subject: 'Church Analytics Crash Report',
        text: 'Crash log from Church Analytics. Please send to: $kCrashEmail',
      );
    } catch (e, stack) {
      LogService.error('CrashDialog', 'Failed to send crash report',
          error: e, stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not share logs. You can export them manually from App Settings → View Logs.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('App closed unexpectedly'),
      content: _sending
          ? const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            )
          : const Text(
              'The app crashed in the previous session. '
              'Would you like to view the logs or send a report?',
            ),
      actions: _sending
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Dismiss'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LogViewerScreen()),
                  );
                },
                child: const Text('View Logs'),
              ),
              if (kCrashEmail.isNotEmpty)
                FilledButton(
                  onPressed: _sendReport,
                  child: const Text('Send Report'),
                ),
            ],
    );
  }
}
