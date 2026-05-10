import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Log level for filtering.
enum LogLevel { debug, info, warning, error, crash }

/// A single structured log entry.
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final String? error;
  final String? stackTrace;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
  });

  String get levelLabel {
    switch (level) {
      case LogLevel.debug:   return 'DEBUG';
      case LogLevel.info:    return 'INFO ';
      case LogLevel.warning: return 'WARN ';
      case LogLevel.error:   return 'ERROR';
      case LogLevel.crash:   return 'CRASH';
    }
  }

  String toLogLine() {
    final ts = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(timestamp);
    final base = '[$ts] [$levelLabel] [$tag] $message';
    if (error != null && stackTrace != null) {
      return '$base\n  ERROR: $error\n  STACK:\n$stackTrace';
    }
    if (error != null) return '$base\n  ERROR: $error';
    return base;
  }

  static LogEntry? fromLogLine(String line) {
    try {
      // Basic parse: [2024-01-01 12:00:00.000] [INFO ] [tag] message
      final tsMatch = RegExp(r'\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3})\]').firstMatch(line);
      final lvlMatch = RegExp(r'\[(DEBUG|INFO |WARN |ERROR|CRASH)\]').firstMatch(line);
      if (tsMatch == null || lvlMatch == null) return null;
      final ts = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').parse(tsMatch.group(1)!);
      final lvlStr = lvlMatch.group(1)!.trim();
      final level = LogLevel.values.firstWhere(
        (l) => l.name.toUpperCase() == lvlStr,
        orElse: () => LogLevel.info,
      );
      return LogEntry(timestamp: ts, level: level, tag: 'log', message: line);
    } catch (_) {
      return null;
    }
  }
}

/// Application-wide logging service for church_analytics.
///
/// Writes structured log lines to a daily rotating file in the app's
/// documents directory. Supports:
/// - Levelled logging (debug / info / warning / error / crash)
/// - Crash detection: sets a flag in SharedPreferences that main.dart checks
///   on next launch to ask the user if they want to share logs.
/// - Log export: copies the merged log of a date range to a user-chosen path.
///
/// Usage:
/// ```dart
/// await LogService.init();
/// LogService.info('Dashboard', 'Loaded ${records.length} records');
/// LogService.error('Sync', 'Failed', error: e, stackTrace: st);
/// ```
class LogService {
  LogService._();

  static const _kCrashedKey = 'log_crashed_last_session';
  static const _kLogDir = 'church_analytics_logs';
  static const _kMaxAgeDays = 30;

  static Directory? _logDir;
  static IOSink? _sink;
  static File? _currentFile;
  static String? _currentDateStr;

  // In-memory recent entries for quick access (last 500).
  static final List<LogEntry> _recent = [];
  static const _kRecentMax = 500;

  // Whether init() has been called successfully.
  static bool _ready = false;

  /// Must be called once before any logging, typically in main() or app startup.
  static Future<void> init() async {
    if (kIsWeb) return; // File I/O not supported on web.
    try {
      final docs = await getApplicationDocumentsDirectory();
      _logDir = Directory('${docs.path}/$_kLogDir');
      if (!await _logDir!.exists()) await _logDir!.create(recursive: true);
      await _rotateTo(DateTime.now());
      _ready = true;
      _pruneOldLogs(); // fire-and-forget cleanup
      info('LogService', 'Logging initialised. Log dir: ${_logDir!.path}');
    } catch (e) {
      debugPrint('[LogService] init failed: $e');
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  static void debug(String tag, String message) =>
      _write(LogLevel.debug, tag, message);

  static void info(String tag, String message) =>
      _write(LogLevel.info, tag, message);

  static void warning(String tag, String message) =>
      _write(LogLevel.warning, tag, message);

  static void error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _write(
        LogLevel.error,
        tag,
        message,
        error: error?.toString(),
        stackTrace: stackTrace?.toString(),
      );

  /// Records a crash and sets the SharedPreferences flag so the next launch
  /// can offer to share logs.
  static Future<void> crash(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) async {
    _write(
      LogLevel.crash,
      tag,
      message,
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
    );
    await _flush();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kCrashedKey, true);
    } catch (_) {}
  }

  /// Returns true if the previous session ended with a crash.
  /// Clears the flag after reading.
  static Future<bool> didCrashLastSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final crashed = prefs.getBool(_kCrashedKey) ?? false;
      if (crashed) await prefs.setBool(_kCrashedKey, false);
      return crashed;
    } catch (_) {
      return false;
    }
  }

  /// Copies merged logs for [from]…[to] into [destPath].
  /// Returns the number of lines written, or -1 on failure.
  static Future<int> exportLogs({
    required DateTime from,
    required DateTime to,
    required String destPath,
  }) async {
    if (!_ready || _logDir == null) return -1;
    try {
      await _flush();
      final dest = File(destPath);
      final sink = dest.openWrite();
      int lines = 0;

      DateTime cursor = DateTime(from.year, from.month, from.day);
      while (!cursor.isAfter(DateTime(to.year, to.month, to.day))) {
        final f = _fileFor(cursor);
        if (await f.exists()) {
          final content = await f.readAsString();
          for (final line in content.split('\n')) {
            if (line.trim().isEmpty) continue;
            final entry = LogEntry.fromLogLine(line);
            if (entry == null ||
                (entry.timestamp.isAfter(from.subtract(const Duration(seconds: 1))) &&
                 entry.timestamp.isBefore(to.add(const Duration(days: 1))))) {
              sink.writeln(line);
              lines++;
            }
          }
        }
        cursor = cursor.add(const Duration(days: 1));
      }

      await sink.flush();
      await sink.close();
      info('LogService', 'Exported $lines log lines to $destPath');
      return lines;
    } catch (e) {
      debugPrint('[LogService] exportLogs failed: $e');
      return -1;
    }
  }

  /// Returns recent in-memory log entries, newest first.
  static List<LogEntry> getRecentEntries({LogLevel? minLevel}) {
    final all = List<LogEntry>.from(_recent.reversed);
    if (minLevel == null) return all;
    final idx = LogLevel.values.indexOf(minLevel);
    return all.where((e) => LogLevel.values.indexOf(e.level) >= idx).toList();
  }

  /// Returns a list of [File]s for each daily log file present on disk.
  static Future<List<File>> listLogFiles() async {
    if (_logDir == null || !await _logDir!.exists()) return [];
    final files = await _logDir!
        .list()
        .where((e) => e is File && e.path.endsWith('.log'))
        .map((e) => e as File)
        .toList();
    files.sort((a, b) => a.path.compareTo(b.path));
    return files;
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  static void _write(
    LogLevel level,
    String tag,
    String message, {
    String? error,
    String? stackTrace,
  }) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );

    // Always print in debug mode.
    if (kDebugMode) debugPrint(entry.toLogLine());

    // Add to recent ring buffer.
    _recent.add(entry);
    if (_recent.length > _kRecentMax) _recent.removeAt(0);

    // Write to file if available.
    if (!_ready || kIsWeb) return;
    _ensureFileForToday();
    _sink?.writeln(entry.toLogLine());
  }

  static void _ensureFileForToday() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (_currentDateStr != today) {
      _rotateTo(DateTime.now());
    }
  }

  static Future<void> _rotateTo(DateTime date) async {
    try {
      await _flush();
      _currentDateStr = DateFormat('yyyy-MM-dd').format(date);
      _currentFile = _fileFor(date);
      _sink = _currentFile!.openWrite(mode: FileMode.append);
    } catch (e) {
      debugPrint('[LogService] rotate failed: $e');
    }
  }

  static File _fileFor(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return File('${_logDir!.path}/church_analytics_$dateStr.log');
  }

  static Future<void> _flush() async {
    try {
      await _sink?.flush();
    } catch (_) {}
  }

  static Future<void> _pruneOldLogs() async {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: _kMaxAgeDays));
      final files = await listLogFiles();
      for (final f in files) {
        final name = f.uri.pathSegments.last;
        final match = RegExp(r'(\d{4}-\d{2}-\d{2})\.log$').firstMatch(name);
        if (match != null) {
          final date = DateTime.tryParse(match.group(1)!);
          if (date != null && date.isBefore(cutoff)) {
            await f.delete();
          }
        }
      }
    } catch (_) {}
  }
}
