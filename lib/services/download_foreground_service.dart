import 'dart:io' show Platform;

import 'package:church_analytics/services/update_download_service.dart'
    show CancelToken;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Thrown by [DownloadForegroundService.start] when the Android Foreground
/// Service fails to start.
///
/// In flutter_foreground_task v8, [FlutterForegroundTask.startService] returns
/// a [ServiceRequestFailure] instead of throwing.  This exception wraps that
/// failure so callers can use normal try/catch semantics.  The download must
/// not proceed when this is thrown — there is no process anchor and Android
/// will kill the process when the app is backgrounded.
class ForegroundServiceStartException implements Exception {
  const ForegroundServiceStartException(this.cause);
  final Object? cause;

  @override
  String toString() =>
      'ForegroundServiceStartException: failed to start foreground service'
      '${cause != null ? ' — $cause' : ''}';
}

// ---------------------------------------------------------------------------
// Entry-point required by flutter_foreground_task v8
// ---------------------------------------------------------------------------
//
// flutter_foreground_task v8 still requires a top-level entry-point annotated
// with @pragma('vm:entry-point') and a corresponding setTaskHandler() call
// before startService() succeeds.  Because the download runs in the main
// isolate (the service is a process anchor only), the handler is a deliberate
// no-op — it never receives work or sends data.
//
// Do NOT remove the @pragma annotation.  Without it the Dart AOT compiler
// strips the symbol and the Android plugin cannot find the entry-point,
// causing startService() to return silently without starting the service.

@pragma('vm:entry-point')
void _downloadServiceEntryPoint() {
  FlutterForegroundTask.setTaskHandler(_DownloadAnchorHandler());
}

/// No-op TaskHandler.  The download runs in the main isolate; this handler
/// exists solely because flutter_foreground_task v8 requires one.
///
/// IMPORTANT — isolate boundary: this handler runs in the plugin's own task
/// isolate, NOT in the main Dart isolate.  Any static fields accessed here
/// (such as [DownloadForegroundService._activeCancelToken]) are independent
/// copies of those objects and mutations have no effect on the main isolate.
/// Cancel-on-notification-dismiss is handled via [FlutterForegroundTask
/// .addTaskDataCallback] in [DownloadForegroundService.init], which fires on
/// the main isolate where the real [CancelToken] lives.
class _DownloadAnchorHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {
    // No periodic work needed — progress updates are driven by the download
    // stream in the main isolate via [DownloadForegroundService.updateProgress].
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // The service was stopped (normally, by the user swiping the notification,
    // or by the OS).  Send 'stop' to the main isolate so the
    // addTaskDataCallback registered in DownloadForegroundService.init() can
    // cancel the active download.
    //
    // We cannot reach the main-isolate CancelToken directly — this handler
    // runs in the plugin's task isolate and any static fields here are
    // independent copies.  sendDataToMain crosses the isolate boundary and
    // delivers the string to the registered callback on the main isolate,
    // where the real CancelToken lives.
    FlutterForegroundTask.sendDataToMain('stop');
  }
}

// ---------------------------------------------------------------------------
// DownloadForegroundService
// ---------------------------------------------------------------------------

/// Manages the Android Foreground Service lifecycle for the duration of an
/// update download.  On non-Android platforms every method is a no-op.
///
/// ### Architecture
/// The download continues to run in the **main Dart isolate**, exactly as it
/// does today.  The Foreground Service has two jobs only:
///   1. Post the mandatory persistent notification (required by Android OS).
///   2. Prevent Android from killing the process when the app is backgrounded.
///
/// No isolate boundary is crossed.  [CancelToken] and [PauseToken] mutations
/// from the UI remain effective because everything is in the same heap.
///
/// ### Usage
/// ```dart
/// DownloadForegroundService.init(); // once, e.g. in AboutUpdatesCard.initState
///
/// await DownloadForegroundService.start(cancelToken: cancelToken);
/// try {
///   result = await downloadService.download(..., onProgress: (p) {
///     progressNotifier.value = p;
///     DownloadForegroundService.updateProgress(p); // throttled internally
///   });
/// } finally {
///   await DownloadForegroundService.stop();
/// }
/// ```
class DownloadForegroundService {
  DownloadForegroundService._();

  // -------------------------------------------------------------------------
  // Internal state
  // -------------------------------------------------------------------------

  static bool _initialised = false;

  /// The [CancelToken] for the active download.  Stored by [start] and read
  /// by the [addTaskDataCallback] registered in [init].  When [onDestroy]
  /// fires in the task isolate it calls [FlutterForegroundTask.sendDataToMain]
  /// with the string `'stop'`; the callback on the main isolate then calls
  /// [CancelToken.cancel] here, cancelling the download if Android kills the
  /// service (e.g. the user swipes away the notification).
  static CancelToken? _activeCancelToken;

  // Notification throttle state — reset by [start] so each download begins
  // with a clean slate.
  static DateTime? _lastNotificationTime;
  static int _lastNotifiedPct = 0;

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Initialise the foreground service configuration.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.  Call once
  /// before the first [start], typically in [AboutUpdatesCard.initState] or
  /// at app startup.
  static void init() {
    if (_initialised || !Platform.isAndroid) return;
    _initialised = true;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'church_analytics_update_download',
        channelName: 'Update Download',
        channelDescription:
            'Shown while a Church Analytics update is downloading.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        // LOW importance: no sound, no heads-up banner — unobtrusive.
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        // The package's built-in repeat loop is not needed — progress updates
        // are driven by the download stream via [updateProgress].
        autoRunOnBoot: false,
      ),
    );

    // Register the main-isolate callback that cancels the active download when
    // the foreground service is destroyed (user swipes the notification, OS
    // kills the process, etc.).
    //
    // Cancellation path: onDestroy (task isolate) calls
    // FlutterForegroundTask.sendDataToMain('stop') → crosses the isolate
    // boundary → this callback fires on the main isolate → cancels the real
    // CancelToken that lives here.  Direct field access from onDestroy is not
    // possible because the task isolate has its own independent copy of any
    // static state.
    FlutterForegroundTask.addTaskDataCallback((data) {
      if (data == 'stop') {
        _activeCancelToken?.cancel();
      }
    });
  }

  /// Start the Android Foreground Service and post the initial notification.
  ///
  /// [cancelToken] is stored so the download is cancelled if the OS kills the
  /// service.  Pass the same token used in the download call.
  ///
  /// Must be called from the main isolate (has access to UI context if the
  /// POST_NOTIFICATIONS dialog is needed on Android 13+; that permission
  /// request is handled separately in [AboutUpdatesCard._onDownloadUpdate]).
  ///
  /// Throws a [ForegroundServiceStartException] if the service fails to start.
  /// In flutter_foreground_task v8, [FlutterForegroundTask.startService]
  /// returns a [ServiceRequestResult] rather than throwing — callers must
  /// inspect it.  Possible failure reasons: not initialised, already running,
  /// or Android start-timeout.  The caller's try/finally still runs on throw,
  /// so [stop] is always reached.
  static Future<void> start({CancelToken? cancelToken}) async {
    if (!Platform.isAndroid) return;

    // Store the cancel token before starting so the task-data callback can
    // cancel the download if the OS kills the service.
    _activeCancelToken = cancelToken;

    // Reset throttle state so the very first update fires immediately.
    _lastNotificationTime = null;
    _lastNotifiedPct = 0;

    final result = await FlutterForegroundTask.startService(
      notificationTitle: 'Downloading update…',
      notificationText: 'Church Analytics update is downloading',
      callback: _downloadServiceEntryPoint,
    );

    if (result is ServiceRequestFailure) {
      // Clear the token — the download must not proceed without an anchor.
      _activeCancelToken = null;
      throw ForegroundServiceStartException(result.error);
    }
  }

  /// Update the notification text to reflect current download progress.
  ///
  /// **Throttled** — the notification is only updated when at least 2 seconds
  /// have elapsed since the last update **or** the displayed percentage has
  /// moved by ≥ 5 points.  Both conditions are checked independently so that:
  /// - On fast connections (5% ticks in < 1 s) the 5-point gate fires first.
  /// - On slow connections (< 5% in 2 s) the timer gate fires first.
  ///
  /// Calling [FlutterForegroundTask.updateService] on every downloaded chunk
  /// (hundreds of times per second on a fast link) would flood the Android
  /// notification manager, cause visible flicker in the shade, and generate
  /// unnecessary binder IPC traffic.  The throttle keeps the notification
  /// feeling live without any of those side-effects.
  static Future<void> updateProgress(double fraction) async {
    if (!Platform.isAndroid) return;

    final now = DateTime.now();
    final pct = (fraction * 100).round().clamp(0, 100);

    final elapsedEnough = _lastNotificationTime == null ||
        now.difference(_lastNotificationTime!).inMilliseconds >= 2000;
    final deltaEnough = (pct - _lastNotifiedPct).abs() >= 5;

    if (!elapsedEnough && !deltaEnough) return; // skip this tick

    _lastNotificationTime = now;
    _lastNotifiedPct = pct;

    await FlutterForegroundTask.updateService(
      notificationTitle: 'Downloading update… $pct%',
      notificationText: 'Church Analytics update is downloading',
    );
  }

  /// Stop the Android Foreground Service.
  ///
  /// Call this in the `finally` block of the download try/catch to guarantee
  /// the service is stopped regardless of outcome (success, cancel, error,
  /// pause).
  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    _activeCancelToken = null;
    await FlutterForegroundTask.stopService();
  }
}
