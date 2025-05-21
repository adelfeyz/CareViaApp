import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppFooter extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppFooter({
    Key? key,
    this.selectedIndex = 0,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 9),
      color: const Color(0xFFF3F4F6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(
              icon: 'assets/images/home_icon.svg',
              label: 'Home',
              isSelected: selectedIndex == 0,
              onTap: () => onItemSelected(0),
            ),
            _buildNavItem(
              icon: 'assets/images/live_icon.svg',
              label: 'Live',
              isSelected: selectedIndex == 1,
              onTap: () => onItemSelected(1),
            ),
            _buildNavItem(
              icon: 'assets/images/sleep_icon.svg',
              label: 'Sleep',
              isSelected: selectedIndex == 2,
              onTap: () => onItemSelected(2),
            ),
            _buildNavItem(
              icon: 'assets/images/history_icon.svg',
              label: 'History',
              isSelected: selectedIndex == 3,
              onTap: () => onItemSelected(3),
            ),
            _buildNavItem(
              icon: 'assets/images/more_icon.svg',
              label: 'More',
              isSelected: selectedIndex == 4,
              onTap: () => onItemSelected(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            icon,
            width: _getIconWidth(icon),
            fit: BoxFit.contain,
            colorFilter: isSelected 
                ? const ColorFilter.mode(Colors.blue, BlendMode.srcIn)
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isSelected ? Colors.blue[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  double _getIconWidth(String icon) {
    switch (icon) {
      case 'assets/images/home_icon.svg':
        return 18;
      case 'assets/images/live_icon.svg':
        return 16;
      case 'assets/images/sleep_icon.svg':
        return 12;
      case 'assets/images/history_icon.svg':
        return 16;
      case 'assets/images/more_icon.svg':
        return 14;
      default:
        return 16;
    }
  }
} 