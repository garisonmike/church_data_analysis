import 'package:church_analytics/graph_modules/graph_definition.dart';
import 'package:church_analytics/ui/widgets/responsive_chart_container.dart';
import 'package:flutter/widgets.dart';

/// Renders a graph module's definitions as the standard chart list used by
/// every charts screen: the first chart loads eagerly (it is above the fold),
/// the rest lazy-load as they scroll into view, and one chart may carry a
/// repaint-boundary key for PNG export.
class GraphListView extends StatelessWidget {
  const GraphListView({
    super.key,
    required this.graphs,
    this.captureKey,
    this.captureGraphIndex = 1,
  });

  final List<GraphDefinition> graphs;

  /// Repaint-boundary key attached to [captureGraphIndex] for image export.
  final GlobalKey? captureKey;
  final int captureGraphIndex;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var i = 0; i < graphs.length; i++) ...[
          if (i == 0)
            ResponsiveChartContainer(
              minHeight: graphs[i].minHeight,
              maxHeight: graphs[i].maxHeight,
              aspectRatio: graphs[i].aspectRatio,
              child: Builder(builder: graphs[i].builder),
            )
          else
            ResponsiveLazyChart(
              minHeight: graphs[i].minHeight,
              maxHeight: graphs[i].maxHeight,
              aspectRatio: graphs[i].aspectRatio,
              captureKey: i == captureGraphIndex ? captureKey : null,
              child: Builder(builder: graphs[i].builder),
            ),
          SizedBox(height: i == graphs.length - 1 ? 32 : 16),
        ],
      ],
    );
  }
}
