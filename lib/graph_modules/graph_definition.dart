import 'package:flutter/widgets.dart';

/// A single named chart contributed by a domain graph module.
///
/// Modules assemble the analytics data into fully configured chart widgets;
/// screens decide only layout concerns (lazy loading, capture keys for
/// image export).
class GraphDefinition {
  const GraphDefinition({
    required this.id,
    required this.title,
    required this.builder,
    this.minHeight = 220,
    this.maxHeight = 380,
    this.aspectRatio = 16 / 9,
  });

  /// Stable identifier, aligned with the Python reference implementation's
  /// graph IDs where an equivalent exists.
  final String id;

  /// Human-readable title; matches the title rendered inside the chart.
  final String title;

  /// Preferred constraints for the responsive chart container.
  final double minHeight;
  final double maxHeight;
  final double aspectRatio;

  /// Builds the fully configured chart widget.
  final WidgetBuilder builder;
}
