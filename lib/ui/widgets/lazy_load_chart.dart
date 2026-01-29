import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A widget that lazily loads its child chart when it becomes visible
/// in the viewport. This improves performance by deferring expensive
/// chart rendering until the user scrolls to that section.
class LazyLoadChart extends StatefulWidget {
  /// The chart widget to render when visible
  final Widget child;

  /// Height of the placeholder shown before the chart loads
  final double placeholderHeight;

  /// Optional custom placeholder widget
  final Widget? placeholder;

  /// Duration for the fade-in animation
  final Duration fadeInDuration;

  /// Optional callback when visibility changes
  final ValueChanged<bool>? onVisibilityChanged;

  const LazyLoadChart({
    super.key,
    required this.child,
    this.placeholderHeight = 300,
    this.placeholder,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.onVisibilityChanged,
  });

  @override
  State<LazyLoadChart> createState() => _LazyLoadChartState();
}

class _LazyLoadChartState extends State<LazyLoadChart> {
  bool _hasBeenVisible = false;
  bool _isVisible = false;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Check visibility after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  void _checkVisibility() {
    if (!mounted || _hasBeenVisible) return;

    final RenderObject? renderObject = _key.currentContext?.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) return;

    final RenderAbstractViewport viewport = RenderAbstractViewport.of(
      renderObject,
    );

    final RevealedOffset offsetToReveal = viewport.getOffsetToReveal(
      renderObject,
      0.0,
    );

    // Get the viewport's visible height
    final viewportDimension =
        (viewport as RenderBox?)?.size.height ?? double.infinity;

    // Calculate if this widget is within the visible area
    // We check if any part of the widget is visible
    final widgetTop = offsetToReveal.offset;
    final widgetBottom = widgetTop + renderObject.size.height;

    // Get the current scroll position
    final scrollableState = Scrollable.maybeOf(context);
    if (scrollableState == null) {
      // Not in a scrollable, assume visible
      _setVisible(true);
      return;
    }

    final scrollPosition = scrollableState.position;
    final viewportTop = scrollPosition.pixels;
    final viewportBottom = viewportTop + viewportDimension;

    // Check if the widget overlaps with the visible viewport
    final isNowVisible =
        widgetBottom > viewportTop && widgetTop < viewportBottom;

    if (isNowVisible && !_hasBeenVisible) {
      _setVisible(true);
    }
  }

  void _setVisible(bool visible) {
    if (visible && !_hasBeenVisible) {
      setState(() {
        _isVisible = true;
        _hasBeenVisible = true;
      });
      widget.onVisibilityChanged?.call(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!_hasBeenVisible) {
          _checkVisibility();
        }
        return false;
      },
      child: SizedBox(
        key: _key,
        child: _hasBeenVisible
            ? AnimatedOpacity(
                duration: widget.fadeInDuration,
                opacity: _isVisible ? 1.0 : 0.0,
                child: widget.child,
              )
            : widget.placeholder ?? _buildDefaultPlaceholder(),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return SizedBox(
      height: widget.placeholderHeight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_chart_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Loading chart...',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

/// A simplified lazy chart wrapper that uses IntersectionObserver-like behavior
/// to detect when the chart enters the viewport.
class LazyChart extends StatefulWidget {
  /// The builder function that creates the chart
  final WidgetBuilder childBuilder;

  /// Height of the chart container
  final double height;

  /// Whether to keep the chart alive after first load
  final bool keepAlive;

  const LazyChart({
    super.key,
    required this.childBuilder,
    this.height = 300,
    this.keepAlive = true,
  });

  @override
  State<LazyChart> createState() => _LazyChartState();
}

class _LazyChartState extends State<LazyChart>
    with AutomaticKeepAliveClientMixin {
  bool _isLoaded = false;

  @override
  bool get wantKeepAlive => widget.keepAlive && _isLoaded;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Schedule visibility check after layout
          if (!_isLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkAndLoad();
            });
          }

          if (_isLoaded) {
            return widget.childBuilder(context);
          }

          return _buildPlaceholder();
        },
      ),
    );
  }

  void _checkAndLoad() {
    if (!mounted || _isLoaded) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    // Check if rendered in viewport
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) {
      // Not in a scrollable, load immediately
      _load();
      return;
    }

    final viewportSize = scrollable.position.viewportDimension;
    final scrollOffset = scrollable.position.pixels;

    // Get widget position relative to scroll view
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(
      renderBox,
    );

    final offsetToReveal = viewport.getOffsetToReveal(renderBox, 0.0);
    final widgetTop = offsetToReveal.offset;
    final widgetBottom = widgetTop + renderBox.size.height;

    // Check if in viewport with some buffer (preload slightly ahead)
    const preloadBuffer = 100.0;
    final viewportTop = scrollOffset - preloadBuffer;
    final viewportBottom = scrollOffset + viewportSize + preloadBuffer;

    if (widgetBottom >= viewportTop && widgetTop <= viewportBottom) {
      _load();
    }
  }

  void _load() {
    if (!mounted || _isLoaded) return;
    setState(() {
      _isLoaded = true;
    });
    updateKeepAlive();
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Chart loading...',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
