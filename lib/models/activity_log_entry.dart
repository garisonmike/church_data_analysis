/// Classifies the class of operation that generated an [ActivityLogEntry].
enum ActivityLogEntryType {
  /// A file export (CSV, PDF, or backup bytes) to the filesystem.
  export,

  /// A file import (CSV or backup) from the filesystem.
  import,

  /// An attempt to launch a downloaded installer binary (UPDATE-011).
  installerLaunch;

  /// Short human-readable label shown in the Settings "Recent Activity" list.
  String get displayName => switch (this) {
    ActivityLogEntryType.export => 'Export',
    ActivityLogEntryType.import => 'Import',
    ActivityLogEntryType.installerLaunch => 'Install',
  };

  String _toJson() => name;

  static ActivityLogEntryType _fromJson(String value) =>
      ActivityLogEntryType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ActivityLogEntryType.export,
      );
}

// ---------------------------------------------------------------------------
// ActivityLogEntry
// ---------------------------------------------------------------------------

/// A single timestamped record of an export, import, or installer-launch
/// operation.
///
/// Instances are produced by [ActivityLogService] methods and stored in
/// [SharedPreferences] as a JSON-encoded list (max 50 entries, FIFO).
class ActivityLogEntry {
  /// Unique identifier — composed of the microsecond epoch and the operation
  /// type name, giving natural sort order without requiring a uuid package.
  final String id;

  /// The class of operation that was performed.
  final ActivityLogEntryType type;

  /// The filename that was exported / imported / launched.
  ///
  /// For [ActivityLogEntryType.installerLaunch] this holds the platform
  /// identifier (e.g. `'android'`) or `'installer'` when unavailable.
  final String filename;

  /// Absolute filesystem path for export operations; `null` for Web blob
  /// exports, cancelled imports, or installer-launch entries.
  final String? path;

  /// `true` when the operation completed successfully.
  final bool success;

  /// Human-readable error or info message; non-null only when the operation
  /// encountered a noteworthy condition (success or failure).
  final String? message;

  /// Wall-clock time when the operation completed.
  final DateTime timestamp;

  const ActivityLogEntry({
    required this.id,
    required this.type,
    required this.filename,
    this.path,
    required this.success,
    this.message,
    required this.timestamp,
  });

  // -------------------------------------------------------------------------
  // Factory constructors
  // -------------------------------------------------------------------------

  /// Creates a new entry timestamped to [DateTime.now].
  ///
  /// The [id] is derived from the microsecond epoch, so entries created in
  /// rapid succession remain uniquely ordered.
  factory ActivityLogEntry.now({
    required ActivityLogEntryType type,
    required String filename,
    String? path,
    required bool success,
    String? message,
  }) {
    final ts = DateTime.now();
    return ActivityLogEntry(
      id: '${ts.microsecondsSinceEpoch}_${type.name}',
      type: type,
      filename: filename,
      path: path,
      success: success,
      message: message,
      timestamp: ts,
    );
  }

  // -------------------------------------------------------------------------
  // JSON serialization
  // -------------------------------------------------------------------------

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type._toJson(),
    'filename': filename,
    if (path != null) 'path': path,
    'success': success,
    if (message != null) 'message': message,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) {
    return ActivityLogEntry(
      id: json['id'] as String,
      type: ActivityLogEntryType._fromJson(json['type'] as String),
      filename: json['filename'] as String,
      path: json['path'] as String?,
      success: json['success'] as bool,
      message: json['message'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  // -------------------------------------------------------------------------
  // Convenience
  // -------------------------------------------------------------------------

  @override
  String toString() =>
      'ActivityLogEntry(type=${type.name}, filename=$filename, '
      'success=$success, timestamp=$timestamp)';
}
