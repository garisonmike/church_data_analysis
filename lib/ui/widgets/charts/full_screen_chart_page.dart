import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-screen viewer for any chart widget.
///
/// Push this page when the user taps the expand icon on a chart card.
/// It forces landscape + portrait orientations to be allowed, wraps the
/// chart in an [OrientationBuilder] so it fills the available space in
/// both orientations, and provides a close button.
///
/// Usage:
/// ```dart
/// Navigator.of(context).push(
///   FullScreenChartPage.route(title: 'My Chart', chart: MyChartWidget()),
/// );
/// ```
class FullScreenChartPage extends StatefulWidget {
  final String title;
  final Widget chart;

  const FullScreenChartPage({
    super.key,
    required this.title,
    required this.chart,
  });

  /// Convenience constructor for a [MaterialPageRoute].
  static Route<void> route({required String title, required Widget chart}) {
    return MaterialPageRoute<void>(
      builder: (_) => FullScreenChartPage(title: title, chart: chart),
      fullscreenDialog: true,
    );
  }

  @override
  State<FullScreenChartPage> createState() => _FullScreenChartPageState();
}

class _FullScreenChartPageState extends State<FullScreenChartPage> {
  @override
  void initState() {
    super.initState();
    // Allow both orientations so the user can rotate for a wider view.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore portrait-only preference when leaving full-screen.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            // In landscape the available width is larger, giving the chart
            // more horizontal space automatically via its internal LayoutBuilder.
            return Padding(
              padding: const EdgeInsets.all(12),
              child: widget.chart,
            );
          },
        ),
      ),
    );
  }
}
