import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Status of a vital sign measurement
enum VitalStatus {
  /// Normal status (grey background)
  normal,
  /// Good status (green background)
  good,
  /// Warning status (yellow background)
  warning,
  /// Critical status (red background)
  critical,
}

/// A card widget that displays a vital sign with its value, unit, and status.
class VitalCard extends StatelessWidget {
  /// The title of the vital sign (e.g., "Heart Rate")
  final String title;
  /// The measured value (e.g., "72")
  final String value;
  /// The unit of measurement (e.g., "bpm")
  final String unit;
  /// The status of the vital sign
  final VitalStatus status;
  /// Text describing the status (e.g., "Resting", "Normal")
  final String statusText;
  /// Optional path to an icon image
  final String? iconPath;
  /// Optional custom header widget to replace the title
  final Widget? customHeader;

  /// Creates a vital card widget.
  const VitalCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    required this.statusText,
    this.iconPath,
    this.customHeader,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (customHeader != null)
            customHeader!
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
                if (iconPath != null)
                  SvgPicture.asset(
                    iconPath!,
                    width: 16,
                    height: 16,
                    fit: BoxFit.contain,
                  ),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                unit,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: _getStatusColor(),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: _getStatusTextColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case VitalStatus.normal:
        return Colors.grey[100]!;
      case VitalStatus.good:
        return const Color(0xFFD1FAE5); // Light green
      case VitalStatus.warning:
        return Colors.amber[100]!;
      case VitalStatus.critical:
        return Colors.red[100]!;
    }
  }

  Color _getStatusTextColor() {
    switch (status) {
      case VitalStatus.normal:
        return Colors.grey[600]!;
      case VitalStatus.good:
        return const Color(0xFF065F46); // Dark green
      case VitalStatus.warning:
        return Colors.amber[800]!;
      case VitalStatus.critical:
        return Colors.red[800]!;
    }
  }
} 