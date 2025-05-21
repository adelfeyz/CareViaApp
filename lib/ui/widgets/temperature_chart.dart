import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TemperatureChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels;
  final double maxValue;

  const TemperatureChart({
    Key? key,
    required this.values,
    required this.labels,
    this.maxValue = 1.0,
  }) : super(key: key);

  @override
  State<TemperatureChart> createState() => _TemperatureChartState();
}

class _TemperatureChartState extends State<TemperatureChart> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)}°C',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: false,
          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
            if (event is FlTapUpEvent) {
              if (response?.lineBarSpots != null && response!.lineBarSpots!.isNotEmpty) {
                setState(() {
                  selectedIndex = response.lineBarSpots!.first.x.toInt();
                });
              } else {
                setState(() {
                  selectedIndex = null;
                });
              }
            }
          },
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: value == 0 ? Colors.orange : Colors.grey.withOpacity(0.2),
              strokeWidth: value == 0 ? 1 : 0.5,
              dashArray: value == 0 ? null : [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    widget.labels[value.toInt()],
                    style: TextStyle(
                      color: selectedIndex == value.toInt() 
                          ? Colors.orange 
                          : Colors.grey,
                      fontSize: 10,
                      fontWeight: selectedIndex == value.toInt()
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value == 0 ? '37°C' : '${value > 0 ? '+' : ''}${value.toStringAsFixed(1)}°C',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              widget.values.length,
              (index) => FlSpot(index.toDouble(), widget.values[index]),
            ),
            isCurved: true,
            color: Colors.orange,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: selectedIndex == index ? 4 : 3,
                  color: Colors.orange,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.1),
            ),
          ),
        ],
        minY: -widget.maxValue,
        maxY: widget.maxValue,
      ),
    );
  }
} 