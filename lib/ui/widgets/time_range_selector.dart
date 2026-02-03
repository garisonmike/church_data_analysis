import 'package:church_analytics/services/weekly_records_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget that allows users to select different time ranges for chart data
class TimeRangeSelector extends ConsumerWidget {
  /// Optional callback when time range changes
  final ValueChanged<ChartTimeRange>? onChanged;

  /// Whether to show as a compact button row instead of dropdown
  final bool compact;

  /// Custom styling for the selector
  final TextStyle? textStyle;

  const TimeRangeSelector({
    super.key,
    this.onChanged,
    this.compact = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTimeRange = ref.watch(chartTimeRangeProvider);
    final theme = Theme.of(context);

    if (compact) {
      return _buildCompactSelector(context, ref, currentTimeRange, theme);
    } else {
      return _buildDropdownSelector(context, ref, currentTimeRange, theme);
    }
  }

  Widget _buildDropdownSelector(
    BuildContext context,
    WidgetRef ref,
    ChartTimeRange currentTimeRange,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ChartTimeRange>(
          value: currentTimeRange,
          style: textStyle ?? theme.textTheme.bodyMedium,
          icon: Icon(
            Icons.expand_more,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
          items: ChartTimeRange.values.map((timeRange) {
            return DropdownMenuItem<ChartTimeRange>(
              value: timeRange,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIconForTimeRange(timeRange),
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(timeRange.displayName),
                ],
              ),
            );
          }).toList(),
          onChanged: (ChartTimeRange? newValue) {
            if (newValue != null) {
              ref.read(chartTimeRangeProvider.notifier).state = newValue;
              onChanged?.call(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCompactSelector(
    BuildContext context,
    WidgetRef ref,
    ChartTimeRange currentTimeRange,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ChartTimeRange.values.map((timeRange) {
          final isSelected = timeRange == currentTimeRange;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                timeRange.displayName,
                style:
                    textStyle?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurface,
                    ) ??
                    theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurface,
                    ),
              ),
              avatar: Icon(
                _getIconForTimeRange(timeRange),
                size: 16,
                color: isSelected
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              onSelected: (bool selected) {
                if (selected) {
                  ref.read(chartTimeRangeProvider.notifier).state = timeRange;
                  onChanged?.call(timeRange);
                }
              },
              selectedColor: theme.colorScheme.secondaryContainer,
              checkmarkColor: theme.colorScheme.onSecondaryContainer,
              backgroundColor: theme.colorScheme.surface,
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.outline.withOpacity(0.5),
                width: 1,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconForTimeRange(ChartTimeRange timeRange) {
    switch (timeRange) {
      case ChartTimeRange.fourWeeks:
        return Icons.today;
      case ChartTimeRange.twelveWeeks:
        return Icons.calendar_month;
      case ChartTimeRange.sixMonths:
        return Icons.date_range;
      case ChartTimeRange.oneYear:
        return Icons.calendar_today;
      case ChartTimeRange.all:
        return Icons.all_inclusive;
    }
  }
}

/// A convenient wrapper that shows time range selector with a label
class LabeledTimeRangeSelector extends StatelessWidget {
  /// Label text to display above the selector
  final String label;

  /// Optional callback when time range changes
  final ValueChanged<ChartTimeRange>? onChanged;

  /// Whether to show as a compact button row instead of dropdown
  final bool compact;

  /// Whether to show the label
  final bool showLabel;

  const LabeledTimeRangeSelector({
    super.key,
    this.label = 'Time Range:',
    this.onChanged,
    this.compact = false,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!showLabel) {
      return TimeRangeSelector(onChanged: onChanged, compact: compact);
    }

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          TimeRangeSelector(onChanged: onChanged, compact: compact),
        ],
      );
    } else {
      return Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          TimeRangeSelector(onChanged: onChanged, compact: compact),
        ],
      );
    }
  }
}
