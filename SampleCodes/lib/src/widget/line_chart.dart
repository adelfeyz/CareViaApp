import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';

import '../util/getxManager.dart'; // 引入日期/时间格式化包
class TempLineChartController extends GetxController {
  RxList<Map<String, dynamic>> dataPoints = <Map<String, dynamic>>[].obs;
  
  // 可以添加用于更新数据的方法
  void updateData(List<Map<String, dynamic>> newData) {
    debugPrint("updateData: $newData");
    dataPoints.value = newData;
  }
}
class TempLineChart extends StatefulWidget {
  // 改为 StatefulWidget 因为需要处理外部数据流
  TempLineChart({
    super.key,
    // required this.dataPoints, // 添加外部数据点列表
    Color? line1Color,
    Color? line2Color,
    Color? betweenColor,
  })  : line1Color = line1Color ?? const Color.fromARGB(255, 0, 255, 42),
        line2Color = line2Color ?? const Color(0xff0077ff),
        betweenColor = betweenColor ?? const Color.fromARGB(255, 255, 60, 0);

  // final List<Map<String, dynamic>>
  //     dataPoints; // 数据点列表 [{timeStamp: timestamp, temp: double}]
  final Color line1Color;
  final Color line2Color;
  final Color betweenColor;
  final List<String> xTitles = [];

  // ... 其他不变的成员变量和方法 ...

  String getTimeFormat(int timeStamp, TitleMeta meta) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    final format = DateFormat('hh:mm');
    return format.format(date);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final timeStamp = value.toInt(); // 假设这里已经通过某种方式正确映射了小时数和分钟数到X轴
    final formattedTime = getTimeFormat(timeStamp, meta); // 将小时数转换为毫秒并格式化
    // debugPrint("formattedTime: $formattedTime meta.min=${meta.min}");
    if (0 < timeStamp - meta.min && timeStamp - meta.min < 1800000 ||
        0 < meta.max - timeStamp && meta.max - timeStamp < 1800000) {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(formattedTime,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        meta.formattedValue,
        style: style,
      ),
    );
  }

  @override
  _LineChartSample7State createState() => _LineChartSample7State();
}

class _LineChartSample7State extends State<TempLineChart> {
  late final TempLineChartController controller = GetXManager.instance.putController(TempLineChartController(),tag:GetXManager.tempLineChartControllerTag);

  @override
  Widget build(BuildContext context) {
    
    return Obx(() {
      final spots = controller.dataPoints.map((data) => FlSpot(data["timeStamp"].toDouble(), data['temp'].toDouble())).toList();
    return AspectRatio(
      // 宽高比
      aspectRatio: 2,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 18,
          top: 10,
          bottom: 4,
        ),
        child: LineChart(
          // 线图
          LineChartData(
            lineTouchData: const LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots:spots,
                isCurved: false,
                barWidth: 2,
                color: widget.line2Color,
                dotData: const FlDotData(
                  show: false,
                ),
              ),
            ],
            // betweenBarsData: [
            //   BetweenBarsData(
            //     fromIndex: 0,
            //     toIndex: 1,
            //     color: betweenColor,
            //   )
            // ],
            minY: -3,
            maxY: 3,
            borderData: FlBorderData(
                show: true,
                border: const Border(
                    top: BorderSide.none,
                    right: BorderSide.none,
                    bottom: BorderSide(),
                    left: BorderSide())),
            titlesData: FlTitlesData(
              // 标题
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 3600000, // 3600000 毫秒为 1 小时
                  getTitlesWidget: widget.bottomTitleWidgets,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: widget.leftTitleWidgets,
                  interval: 0.5,
                  reservedSize: 36,
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              // 网格线
              show: false,
              drawVerticalLine: false,
              horizontalInterval: 1,
              checkToShowHorizontalLine: (double value) {
                return value == 1 || value == 6 || value == 4 || value == 5;
              },
            ),
          ),
        ),
      ),
    );
    });
  }
}
