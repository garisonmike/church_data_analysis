import 'package:flutter/material.dart';

import 'lazy_load_chart.dart';

/// A responsive chart container that adapts to screen size and available space.
/// Replaces fixed chart heights with responsive dimensions.
class ResponsiveChartContainer extends StatelessWidget {
  /// The chart widget to display
  final Widget child;

  /// Minimum height for the chart (default: 250)
  final double minHeight;

  /// Maximum height for the chart (default: 500)
  final double maxHeight;

  /// Aspect ratio for the chart (width/height, default: 16/9)
  final double aspectRatio;

  /// Whether to use available space instead of aspect ratio
  final bool useAvailableSpace;

  /// Padding around the chart content
  final EdgeInsetsGeometry? padding;

  /// Background decoration for the container
  final Decoration? decoration;

  /// Whether to enable pan/zoom interactivity (default: true)
  final bool enableInteractive;

  const ResponsiveChartContainer({
    super.key,
    required this.child,
    this.minHeight = 250,
    this.maxHeight = 500,
    this.aspectRatio = 16 / 9,
    this.useAvailableSpace = false,
    this.padding,
    this.decoration,
    this.enableInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive height
        double height;

        if (useAvailableSpace) {
          // Use available height with constraints
          height = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : maxHeight;
        } else {
          // Use aspect ratio to calculate height from width
          height = constraints.maxWidth / aspectRatio;
        }

        // Apply min/max constraints
        height = height.clamp(minHeight, maxHeight);

        // For mobile devices (width < 600), adjust height slightly
        if (constraints.maxWidth < 600) {
          height = (height * 0.85).clamp(minHeight * 0.8, maxHeight * 0.9);
        }

        Widget chartWidget = child;

        // Wrap in InteractiveViewer if interactivity is enabled
        if (enableInteractive) {
          chartWidget = InteractiveViewer(
            constrained: false,
            minScale: 0.5,
            maxScale: 4.0,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            child: SizedBox(
              height: height,
              width: constraints.maxWidth,
              child: child,
            ),
          );
        }

        return Container(
          decoration: decoration,
          height: height,
          width: double.infinity,
          padding: padding,
          child: chartWidget,
        );
      },
    );
  }
}

/// A responsive lazy-loading chart wrapper that combines ResponsiveChartContainer
/// with LazyLoadChart functionality
class ResponsiveLazyChart extends StatelessWidget {
  /// The chart widget to render when visible
  final Widget child;

  /// Minimum height for the chart (default: 250)
  final double minHeight;

  /// Maximum height for the chart (default: 500)
  final double maxHeight;

  /// Aspect ratio for the chart (width/height, default: 16/9)
  final double aspectRatio;

  /// Whether to use available space instead of aspect ratio
  final bool useAvailableSpace;

  /// Duration for the fade-in animation
  final Duration fadeInDuration;

  /// Optional callback when visibility changes
  final ValueChanged<bool>? onVisibilityChanged;

  /// Padding around the chart content
  final EdgeInsetsGeometry? padding;

  /// Whether to enable pan/zoom interactivity (default: true)
  final bool enableInteractive;

  const ResponsiveLazyChart({
    super.key,
    required this.child,
    this.minHeight = 250,
    this.maxHeight = 500,
    this.aspectRatio = 16 / 9,
    this.useAvailableSpace = false,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.onVisibilityChanged,
    this.padding,
    this.enableInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive height (same logic as ResponsiveChartContainer)
        double height;

        if (useAvailableSpace) {
          height = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : maxHeight;
        } else {
          height = constraints.maxWidth / aspectRatio;
        }

        height = height.clamp(minHeight, maxHeight);

        if (constraints.maxWidth < 600) {
          height = (height * 0.85).clamp(minHeight * 0.8, maxHeight * 0.9);
        }

        return LazyLoadChart(
          placeholderHeight: height,
          fadeInDuration: fadeInDuration,
          onVisibilityChanged: onVisibilityChanged,
          child: ResponsiveChartContainer(
            minHeight: minHeight,
            maxHeight: maxHeight,
            aspectRatio: aspectRatio,
            useAvailableSpace: useAvailableSpace,
            padding: padding,
            enableInteractive: enableInteractive,
            child: child,
          ),
        );
      },
    );
  }
}
