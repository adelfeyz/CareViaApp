import 'package:flutter/material.dart';

/// A customizable bar chart widget for displaying time-based data.
class ChartBar extends StatelessWidget {
  /// The label to display below the bar (typically a time)
  final String label;
  /// The height of the bar (will be scaled relative to the container)
  final double height;
  /// The color of the bar
  final Color color;
  /// The width of the bar
  final double width;
  /// Whether this bar is currently selected
  final bool isSelected;
  /// Callback when the bar is tapped
  final VoidCallback? onTap;

  /// Creates a chart bar widget.
  const ChartBar({
    Key? key,
    required this.label,
    required this.height,
    required this.color,
    this.width = 8.0,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label: '$label: ${height.toInt()} units',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                border: isSelected ? Border.all(color: Colors.black, width: 1) : null,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A horizontal chart that displays multiple bars with time labels.
class TimeBarChart extends StatelessWidget {
  /// List of data points to display
  final List<TimeBarData> data;
  /// Maximum height of the chart
  final double maxHeight;
  /// Optional title for the chart
  final String? title;
  /// Optional description for the chart
  final String? description;

  /// Creates a time bar chart widget.
  const TimeBarChart({
    Key? key,
    required this.data,
    this.maxHeight = 100,
    this.title,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              description!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey[500],
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          height: maxHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((item) {
              return ChartBar(
                label: item.label,
                height: item.value,
                color: item.color,
                width: item.width,
                isSelected: item.isSelected,
                onTap: item.onTap,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Data for a single bar in the time bar chart.
class TimeBarData {
  /// The label for this data point (typically a time)
  final String label;
  /// The value to display (determines bar height)
  final double value;
  /// The color of the bar
  final Color color;
  /// The width of the bar
  final double width;
  /// Whether this bar is selected
  final bool isSelected;
  /// Callback when the bar is tapped
  final VoidCallback? onTap;

  /// Creates a time bar data point.
  TimeBarData({
    required this.label,
    required this.value,
    required this.color,
    this.width = 8.0,
    this.isSelected = false,
    this.onTap,
  });
} 