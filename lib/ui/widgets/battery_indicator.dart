import 'package:flutter/material.dart';

/// A widget that displays a battery level indicator with a progress bar.
class BatteryIndicator extends StatelessWidget {
  /// The battery level as a percentage (0.0 to 1.0)
  final double percentage;
  /// The height of the battery indicator
  final double height;
  /// The background color of the battery indicator
  final Color backgroundColor;
  /// The foreground color of the battery indicator
  final Color? foregroundColor;

  /// Creates a battery indicator widget.
  const BatteryIndicator({
    Key? key,
    required this.percentage,
    this.height = 24.0,
    this.backgroundColor = const Color(0xFFE5E7EB),
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Battery level ${(percentage * 100).toInt()} percent',
      value: '${(percentage * 100).toInt()}%',
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: backgroundColor,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            minHeight: height,
          ),
        ),
      ),
    );
  }
}

/// A more detailed battery indicator with icon and percentage text.
class DetailedBatteryIndicator extends StatelessWidget {
  /// The battery level as a percentage (0.0 to 1.0)
  final double percentage;
  /// The device name or description
  final String deviceName;
  /// Optional icon to display
  final Widget? icon;

  /// Creates a detailed battery indicator widget.
  const DetailedBatteryIndicator({
    Key? key,
    required this.percentage,
    required this.deviceName,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 12),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deviceName,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(percentage * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: BatteryIndicator(
              percentage: percentage,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.battery_full,
            size: 14,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }
} 