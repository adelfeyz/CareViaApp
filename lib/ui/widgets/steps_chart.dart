import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StepsChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels;
  final double maxValue;
  final double goal;

  const StepsChart({
    Key? key,
    required this.values,
    required this.labels,
    required this.goal,
    this.maxValue = 10000,
  }) : super(key: key);

  @override
  State<StepsChart> createState() => _StepsChartState();
}

class _StepsChartState extends State<StepsChart> {
  int? selectedBarIndex;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: widget.maxValue,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()} steps',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          handleBuiltInTouches: false,
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            if (event is FlTapUpEvent) {
              if (barTouchResponse?.spot != null) {
                setState(() {
                  selectedBarIndex = barTouchResponse?.spot?.touchedBarGroupIndex;
                });
              } else {
                setState(() {
                  selectedBarIndex = null;
                });
              }
            }
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
                      color: selectedBarIndex == value.toInt() 
                          ? Colors.blue 
                          : Colors.grey,
                      fontSize: 10,
                      fontWeight: selectedBarIndex == value.toInt()
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
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barGroups: List.generate(
          widget.values.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: widget.values[index],
                color: _getBarColor(widget.values[index]),
                width: 8,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                rodStackItems: [
                  BarChartRodStackItem(
                    0,
                    widget.values[index],
                    selectedBarIndex == index
                        ? Colors.blue.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBarColor(double value) {
    final percentage = value / widget.goal;
    if (percentage > 0.8) {
      return Colors.green[500]!;
    } else if (percentage > 0.5) {
      return Colors.green[300]!;
    } else if (percentage > 0.3) {
      return Colors.green[200]!;
    } else {
      return Colors.green[100]!;
    }
  }
} 