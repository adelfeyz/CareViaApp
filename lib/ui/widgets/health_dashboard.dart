import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'vital_card.dart';
import 'chart_bar.dart';
import 'battery_indicator.dart';
import 'heart_rate_chart.dart';
import 'steps_chart.dart';
import 'temperature_chart.dart';
import 'app_footer.dart';
import 'app_drawer.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A comprehensive health dashboard widget that displays various health metrics
/// including vitals, trends, and activity data.
class HealthDashboard extends StatefulWidget {
  final bool embedded;
  const HealthDashboard({Key? key, this.embedded = false}) : super(key: key);

  @override
  State<HealthDashboard> createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard> {
  int _selectedNavIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _handleNavItemSelected(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      // Use only the main content; hosting Scaffold (RingHome) provides app bar & drawer.
      return Semantics(
        label: 'Health Dashboard',
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.only(bottom: 32),
            child: _buildMainContent(),
          ),
        ),
      );
    }

    return Semantics(
      label: 'Health Dashboard',
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey[50],
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                _buildMainContent(),
              ],
            ),
          ),
        ),
        drawer: AppDrawer(
          selectedIndex: _selectedNavIndex,
          onItemSelected: _handleNavItemSelected,
        ),
        bottomNavigationBar: AppFooter(
          selectedIndex: _selectedNavIndex,
          onItemSelected: _handleNavItemSelected,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              const SizedBox(width: 8),
              Text(
                'CareVia',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[500],
                ),
                semanticsLabel: 'CareVia Health Dashboard',
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: Implement notifications action
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  // TODO: Implement settings action
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateAndSync(),
          _buildBatteryStatus(),
          const SizedBox(height: 18),
          _buildSectionTitle('Current Vitals'),
          const SizedBox(height: 21),
          _buildVitalsGrid(),
          const SizedBox(height: 15),
          _buildSectionTitle('24h Trends'),
          const SizedBox(height: 22),
          _buildHeartRateTrend(),
          const SizedBox(height: 16),
          _buildStepsBox(),
          const SizedBox(height: 16),
          _buildTemperatureVariation(),
        ],
      ),
    );
  }

  Widget _buildDateAndSync() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('sync_state').listenable(keys: ['lastProcessed']),
      builder: (context, box, _) {
        final millis = box.get('lastProcessed');
        DateTime? ts;
        if (millis is int) ts = DateTime.fromMillisecondsSinceEpoch(millis).toLocal();
        String label = ts != null ? _formatTime(ts) : 'Never';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Text('Today',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                    )),
            const SizedBox(height: 9),
            Text(
                  _formatDate(DateTime.now()),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
                'Last sync: $label',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF065F46),
            ),
          ),
        ),
      ],
    );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Widget _buildBatteryStatus() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: SvgPicture.asset(
                  'assets/images/ring_icon.svg',
                  width: 34,
                  height: 34,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ring Battery',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '85%',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    semanticsLabel: 'Battery level 85 percent',
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BatteryIndicator(
                percentage: 0.85,
                height: 24,
              ),
            ),
          ),
          SvgPicture.asset(
            'assets/images/battery_icon.svg',
            width: 14,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
      semanticsLabel: title,
    );
  }

  Widget _buildVitalsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: VitalCard(
                title: 'Heart Rate',
                value: '72',
                unit: 'bpm',
                status: VitalStatus.normal,
                statusText: 'Resting',
                iconPath: 'assets/images/heart_icon.svg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: VitalCard(
                title: 'SpO₂',
                value: '98',
                unit: '%',
                status: VitalStatus.good,
                statusText: 'Normal',
                iconPath: 'assets/images/oxygen_icon.svg',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: VitalCard(
                title: 'HRV',
                value: '45',
                unit: 'ms',
                status: VitalStatus.normal,
                statusText: 'Average',
                iconPath: 'assets/images/hrv_icon.svg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: VitalCard(
                title: 'Temperature',
                value: '0.2',
                unit: '°C',
                status: VitalStatus.normal,
                statusText: 'From baseline',
                iconPath: 'assets/images/temperature_icon.svg',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeartRateTrend() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heart Rate',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      _buildMetricPill('Min: 58'),
                      const SizedBox(width: 8),
                      _buildMetricPill('Avg: 72'),
                      const SizedBox(width: 8),
                      _buildMetricPill('Max: 115'),
                    ],
                  ),
                ],
              ),
              SvgPicture.asset(
                'assets/images/heart_icon.svg',
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: HeartRateChart(
              values: [72, 65, 68, 85, 75, 80, 95, 82, 78, 70, 65, 68],
              labels: ['12A', '2A', '4A', '6A', '8A', '10A', '12P', '2P', '4P', '6P', '8P', '10P'],
              maxValue: 120,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsBox() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Steps',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      _buildMetricPill('Goal: 10,000'),
                      const SizedBox(width: 8),
                      _buildMetricPill('Current: 8,546'),
                    ],
                  ),
                ],
              ),
              SvgPicture.asset(
                'assets/images/step_icon.svg',
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: StepsChart(
              values: [2500, 1800, 2200, 3000, 2800, 3200, 3500, 4000, 3800, 4200, 4500, 4800],
              labels: ['12A', '2A', '4A', '6A', '8A', '10A', '12P', '2P', '4P', '6P', '8P', '10P'],
              maxValue: 10000,
              goal: 10000,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureVariation() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temperature Variation',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '-0.1°C to +0.2°C',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    semanticsLabel: 'Temperature variation from negative 0.1 degrees to positive 0.2 degrees Celsius',
                  ),
                ],
              ),
              SvgPicture.asset(
                'assets/images/temperature_icon.svg',
                width: 10,
                height: 16,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: TemperatureChart(
              values: [-0.1, -0.2, -0.1, 0.0, 0.1, 0.2, 0.1, 0.0, -0.1, -0.2, -0.1, 0.0],
              labels: ['12A', '2A', '4A', '6A', '8A', '10A', '12P', '2P', '4P', '6P', '8P', '10P'],
              maxValue: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.grey[800],
        ),
      ),
    );
  }
} 