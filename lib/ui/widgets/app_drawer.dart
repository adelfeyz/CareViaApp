import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../pages/home_page.dart';
import '../../ring_live_page.dart';
import '../../retrieve_data_page.dart';
import '../../sample_data_page.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppDrawer({
    Key? key,
    this.selectedIndex = 0,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const Divider(),
            _buildTile(
              context,
              0,
              'Home',
              'assets/images/home_icon.svg',
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              ),
            ),
            _buildTile(
              context,
              1,
              'Live',
              'assets/images/live_icon.svg',
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RingLivePage()),
              ),
            ),
            _buildTile(
              context,
              2,
              'History',
              'assets/images/history_icon.svg',
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RetrieveDataPage()),
              ),
            ),
            _buildTile(
              context,
              3,
              'Sample Data',
              'assets/images/more_icon.svg',
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SampleDataPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Text(
            'CareVia',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    int index,
    String title,
    String iconPath,
    VoidCallback? onTap,
  ) {
    final bool isSelected = selectedIndex == index;
    return ListTile(
      leading: SvgPicture.asset(
        iconPath,
        width: 20,
        fit: BoxFit.contain,
        colorFilter: isSelected ? const ColorFilter.mode(Colors.blue, BlendMode.srcIn) : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.blue : Colors.grey[800],
        ),
      ),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context);
        if (onTap != null) {
          onTap();
        } else {
          onItemSelected(index);
        }
      },
    );
  }
} 