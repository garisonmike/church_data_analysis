import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps a Syncfusion chart so that mouse-wheel scroll only zooms when the
/// Ctrl key is held.  Without Ctrl the scroll event is NOT consumed, allowing
/// the parent [ScrollView] to scroll normally.
///
/// Usage: wrap your chart widget with this class and set
/// `enableMouseWheelZooming: ctrlHeld` on [ZoomPanBehavior].
///
/// ```dart
/// CtrlScrollZoomWrapper(
///   builder: (ctrlHeld) => SfCartesianChart(
///     zoomPanBehavior: ZoomPanBehavior(
///       enableMouseWheelZooming: ctrlHeld,
///     ),
///     ...
///   ),
/// )
/// ```
class CtrlScrollZoomWrapper extends StatefulWidget {
  final Widget Function(bool ctrlHeld) builder;

  const CtrlScrollZoomWrapper({super.key, required this.builder});

  @override
  State<CtrlScrollZoomWrapper> createState() => _CtrlScrollZoomWrapperState();
}

class _CtrlScrollZoomWrapperState extends State<CtrlScrollZoomWrapper> {
  bool _ctrlHeld = false;

  /// True only on desktop platforms where Ctrl+scroll zoom makes sense.
  static bool get _isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
       defaultTargetPlatform == TargetPlatform.linux ||
       defaultTargetPlatform == TargetPlatform.macOS);

  @override
  void initState() {
    super.initState();
    if (_isDesktop) {
      HardwareKeyboard.instance.addHandler(_onKey);
    }
  }

  @override
  void dispose() {
    if (_isDesktop) {
      HardwareKeyboard.instance.removeHandler(_onKey);
    }
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    final ctrl = HardwareKeyboard.instance.isControlPressed;
    if (ctrl != _ctrlHeld) {
      setState(() => _ctrlHeld = ctrl);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // On mobile/web, never enable mouse-wheel zooming (no mouse).
    // On desktop, gate it behind Ctrl key.
    if (!_isDesktop) return widget.builder(false);
    return widget.builder(_ctrlHeld);
  }
}
