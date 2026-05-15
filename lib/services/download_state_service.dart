import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// DownloadStateRecord
// ---------------------------------------------------------------------------

/// Snapshot of an in-progress download, persisted to [SharedPreferences] by
/// [DownloadStateService] so that incomplete downloads can be detected on the
/// next app launch (FEAT-007).
///
/// A record is written when [UpdateDownloadService.download] begins streaming
/// chunks to disk and cleared when the download finishes (success, error, or
/// user cancel).  A voluntarily paused download (FEAT-006) keeps the record so
/// that an interrupted-resume is also recoverable on next launch.
class DownloadStateRecord {
  /// The full HTTPS URL of the installer asset being downloaded.
  final String url;

  /// Absolute path to the destination file on disk.
  ///
  /// Points to the partial file while the download is in progress, and to the
  /// complete file if the download finished but the installer was not yet
  /// launched before the app was closed.
  final String destPath;

  /// Expected SHA-256 hex digest of the completed installer (from the manifest).
  ///
  /// Used by [UpdateDownloadService.resumeFile] to verify the file is complete
  /// and uncorrupted after resuming.
  final String sha256;

  /// UTC timestamp when the download was first started.
  final DateTime startedAt;

  const DownloadStateRecord({
    required this.url,
    required this.destPath,
    required this.sha256,
    required this.startedAt,
  });

  // -------------------------------------------------------------------------
  // JSON serialisation
  // -------------------------------------------------------------------------

  Map<String, dynamic> toJson() => {
    'url': url,
    'dest_path': destPath,
    'sha256': sha256,
    'started_at': startedAt.toUtc().toIso8601String(),
  };

  factory DownloadStateRecord.fromJson(Map<String, dynamic> json) =>
      DownloadStateRecord(
        url: json['url'] as String,
        destPath: json['dest_path'] as String,
        sha256: json['sha256'] as String,
        startedAt: DateTime.parse(json['started_at'] as String).toUtc(),
      );
}

// ---------------------------------------------------------------------------
// DownloadStateService
// ---------------------------------------------------------------------------

/// Reads and writes the active-download record in [SharedPreferences].
///
/// All methods are static and fail-open: any [SharedPreferences] error is
/// swallowed silently so that persistence failures never block a download or
/// crash the app.
///
/// ## Lifecycle
///
/// | Event | Action |
/// |---|---|
/// | `UpdateDownloadService.download()` begins streaming | [persist] |
/// | Download completes (success, error, or cancel) | [clear] |
/// | Download paused (FEAT-006) | record **kept** for crash recovery |
/// | `UpdateDownloadService.resume()` completes non-paused | [clear] |
/// | App launches and detects partial file | [read], then [clear] after handling |
///
/// ## SharedPreferences key
/// The record is stored under [_prefKey] as a JSON string.
class DownloadStateService {
  DownloadStateService._();

  static const String _prefKey = 'active_download_state';

  // -------------------------------------------------------------------------
  // Write
  // -------------------------------------------------------------------------

  /// Persists a [DownloadStateRecord] so that an interrupted download can be
  /// detected on the next launch.
  ///
  /// Call this immediately before [UpdateDownloadService] begins writing chunks
  /// to disk — before the first byte is streamed, so that even an instant crash
  /// leaves a recoverable record.
  ///
  /// Fails silently if [SharedPreferences] is unavailable.
  static Future<void> persist({
    required String url,
    required String destPath,
    required String sha256,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final record = DownloadStateRecord(
        url: url,
        destPath: destPath,
        sha256: sha256,
        startedAt: DateTime.now().toUtc(),
      );
      await prefs.setString(_prefKey, jsonEncode(record.toJson()));
    } catch (_) {
      // Never block a download because persistence failed.
    }
  }

  // -------------------------------------------------------------------------
  // Read
  // -------------------------------------------------------------------------

  /// Returns the persisted [DownloadStateRecord], or `null` if none exists or
  /// the stored value cannot be decoded.
  ///
  /// Call this on startup to detect downloads that were interrupted by a
  /// crash, OS kill, or unexpected power loss.
  static Future<DownloadStateRecord?> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return DownloadStateRecord.fromJson(json);
    } catch (_) {
      // Corrupt or unreadable record — treat as absent.
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Clear
  // -------------------------------------------------------------------------

  /// Removes the active-download record from [SharedPreferences].
  ///
  /// Call this when a download finishes for any reason other than a voluntary
  /// pause.  Specifically:
  /// - Download succeeded (installer is ready).
  /// - Download failed with an unrecoverable error.
  /// - User cancelled the download.
  ///
  /// Do **not** call this on pause — the record must survive so that
  /// [StartupGateScreen] can detect the partial file on the next launch.
  ///
  /// Fails silently if [SharedPreferences] is unavailable.
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKey);
    } catch (_) {}
  }
}
