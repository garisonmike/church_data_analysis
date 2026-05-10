import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

class _LogViewerScreenState extends State<LogViewerScreen> {
  LogLevel _filterLevel = LogLevel.debug;
  List<LogEntry> _entries = [];

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
    setState(() {
      _entries = LogService.getRecentEntries(minLevel: _filterLevel);
    });
  }

  Color _levelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:   return Colors.grey;
      case LogLevel.info:    return Colors.blue;
      case LogLevel.warning: return Colors.orange;
      case LogLevel.error:   return Colors.red;
      case LogLevel.crash:   return Colors.purple;
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
      if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
        // Use a temp path in documents when no file picker is integrated here.
        // In production this would call fileService.pickSaveLocation().
        final dir = await _getExportsDir();
        destPath = '${dir.path}/$suggestedName';
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
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
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
                  'Showing ${_entries.length} entries  ·  min level: ${_filterLevel.name.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // ── Log list ─────────────────────────────────────────────────────
          Expanded(
            child: _entries.isEmpty
                ? const Center(child: Text('No log entries yet.'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _entries.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final e = _entries[i];
                      return _LogEntryTile(
                        entry: e,
                        levelColor: _levelColor(e.level),
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
  final Color levelColor;
  final DateFormat timeFmt;

  const _LogEntryTile({
    required this.entry,
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
    builder: (ctx) => AlertDialog(
      title: const Text('App closed unexpectedly'),
      content: const Text(
        'The app crashed in the previous session. '
        'Would you like to view or export the logs to help diagnose the issue?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Dismiss'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LogViewerScreen(),
              ),
            );
          },
          child: const Text('View Logs'),
        ),
      ],
    ),
  );
}
