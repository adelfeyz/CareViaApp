import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';

import '../util/getxManager.dart'; // 引入日期/时间格式化包

class PressureLineChartController extends GetxController {
  RxMap<int, List<Map<String, dynamic>>> pressureData =
      <int, List<Map<String, dynamic>>>{}.obs;

  void updateData(Map<int, List<Map<String, dynamic>>> data) {
    pressureData.value = data;
  }
}

class PressureLineChart extends StatefulWidget {
  // 改为 StatefulWidget 因为需要处理外部数据流
  PressureLineChart({
    super.key,
    Color? line1Color,
    Color? line2Color,
    Color? betweenColor,
    required this.pressureBaseLine,
  })  : line1Color = line1Color ?? const Color.fromARGB(255, 0, 255, 42),
        line2Color = line2Color ?? const Color(0xff0077ff),
        betweenColor = betweenColor ?? const Color.fromARGB(255, 255, 60, 0);

  final Color line1Color;
  final Color line2Color;
  final Color betweenColor;
  final List<String> xTitles = [];
  final RxDouble pressureBaseLine;

  // ... 其他不变的成员变量和方法 ...
  List<double> pressureThresholds = [];
  final List<String> pressureLabels = ['恢复', '放松', '投入', '压力']; // 根据实际需求定义标签

  String getTimeFormat(int timeStamp, TitleMeta meta) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    final format = DateFormat('HH:mm');
    return format.format(date);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final timeStamp = value.toInt(); // 假设这里已经通过某种方式正确映射了小时数和分钟数到X轴
    final formattedTime = getTimeFormat(timeStamp, meta); // 将小时数转换为毫秒并格式化
    if (timeStamp == meta.min ||
        formattedTime == "06:00" ||
        formattedTime == "18:00" ||
        formattedTime == "00:00" ||
        formattedTime == "12:00") {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 4,
        child: Text(formattedTime,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      );
    } else {
      return Container();
    }
  }

  Widget rightTitleWidgets(
      double value, TitleMeta meta, List<String> rightTitles) {
    if (value == 0) {
      rightTitles.clear();
    }
    final index = findClosestIndex(value); // 查找最接近当前值的阈值索引
    if (index != -1 && !rightTitles.contains(pressureLabels[index])) {
      // 如果找到了匹配的阈值
      rightTitles.add(pressureLabels[index]);
      return Column(
        children: [
          Text(
            pressureLabels[index],
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 30,
          )
        ],
      );
    } else {
      return const SizedBox.shrink(); // 不是阈值的位置则不显示标签
    }
  }

  double epsilon = 0.5;
  int findClosestIndex(double value) {
    pressureThresholds = [
      pressureBaseLine * 1.5,
      pressureBaseLine * 1,
      pressureBaseLine * 0.6,
      10,
    ]; // 假设这里已经通过某种方式正确映射了阈值到Y轴
    int index = -1;
    double minDiff = double.infinity;
    for (int i = 0; i < pressureThresholds.length; i++) {
      double diff = (value - pressureThresholds[i]).abs();
      if (diff < minDiff) {
        minDiff = diff;
        index = i;
      }
    }
    return (minDiff <= epsilon) ? index : -1;
  }

  @override
  _LineChartSample7State createState() => _LineChartSample7State();
}

class _LineChartSample7State extends State<PressureLineChart> {
  final PressureLineChartController controller = GetXManager.instance
      .putController(PressureLineChartController(),
          tag: GetXManager.pressureChartControllerTag);
  List<LineChartBarData> listLineChartBarData = [];
  List<String> rightTitles = [];
  List<LineChartBarData> getLineChartBarData() {
    List<LineChartBarData> result = [];
    FlDotPainter _flDot() {
      return FlDotCirclePainter(
        radius: 2,
        color: Colors.white,
        strokeWidth: 1,
        strokeColor: widget.line2Color,
      );
    }

    controller.pressureData.values.forEach((item) {
      List<FlSpot> spots = [];
      bool isDash = false;
      // debugPrint("item: $item");
      for (var element in item) {
        var dashedLine = element["dashedLine"];
        if (dashedLine) {
          if (spots.isNotEmpty) {
            spots.add(FlSpot(element["timeStamp"].toDouble(),
                element["pressure"].toDouble()));
            result.add(LineChartBarData(
              spots: spots,
              isCurved: false,
              barWidth: 2,
              color: widget.line2Color,
              dotData: FlDotData(
                getDotPainter: (spot, percent, barData, index) {
                  return _flDot();
                },
              ),
              dashArray: null,
            ));
            List<FlSpot> copy = List<FlSpot>.from(spots);
            spots = [];
            spots.add(copy.last);
            isDash = true;
          } else {
            spots.add(FlSpot(element["timeStamp"].toDouble(),
                element["pressure"].toDouble()));
            isDash = true;
          }
        } else {
          if (isDash) {
            isDash = false;
            spots.add(FlSpot(element["timeStamp"].toDouble(),
                element["pressure"].toDouble()));
            result.add(LineChartBarData(
              spots: spots,
              isCurved: false,
              barWidth: 2,
              color: widget.line2Color,
              dotData: FlDotData(
                getDotPainter: (spot, percent, barData, index) {
                  return _flDot();
                },
              ),
              dashArray: [5, 5],
            ));
            List<FlSpot> copy = List<FlSpot>.from(spots);
            spots = [];
            spots.add(copy.removeAt(1));
          } else {
            spots.add(FlSpot(element["timeStamp"].toDouble(),
                element["pressure"].toDouble()));
            // isDash = true;
          }
        }
      }
      if (spots.isNotEmpty) {
        result.add(LineChartBarData(
          spots: spots,
          isCurved: false,
          barWidth: 2,
          color: widget.line2Color,
          dotData: FlDotData(
            getDotPainter: (spot, percent, barData, index) {
              return _flDot();
            },
          ),
          dashArray: null,
        ));
      }
      List<List<Map<String, dynamic>>> data =
          controller.pressureData.values.toList();
      if (data.isNotEmpty) {
        int startTimeStamp = data[0][0]["timeStamp"];
        DateTime startDateTime =
            DateTime.fromMillisecondsSinceEpoch(startTimeStamp);
        //根据DateTime获取晚上12点的毫秒数
        int endTimeStamp = DateTime(
                startDateTime.year, startDateTime.month, startDateTime.day, 24)
            .millisecondsSinceEpoch;
        // debugPrint("endTimeStamp: $endTimeStamp startTimeStamp: $startTimeStamp");
        result.add(LineChartBarData(
          spots: [FlSpot(endTimeStamp.toDouble(), 0)],
          isCurved: false,
          barWidth: 2,
          color: widget.line2Color,
          dotData: const FlDotData(
            show: false,
          ),
          dashArray: null,
        ));
      }
    });

    return result;
  }

  @override
  void initState() {
    super.initState();
  }

  void touchCallback(
      FlTouchEvent flTouchEvent, LineTouchResponse? lineTouchResponse) {}

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      listLineChartBarData = getLineChartBarData();
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
              lineTouchData: LineTouchData(
                enabled: true,
                touchCallback: touchCallback,
              ),
              lineBarsData: listLineChartBarData,
              minY: 0,
              borderData: FlBorderData(
                  show: true,
                  border: const Border(
                      top: BorderSide.none,
                      right: BorderSide.none,
                      bottom: BorderSide(),
                      left: BorderSide.none)),
              titlesData: FlTitlesData(
                // 标题
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 3600000 * 2, // 3600000 毫秒为 1 小时
                    getTitlesWidget: widget.bottomTitleWidgets,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) =>
                        widget.rightTitleWidgets(value, meta, rightTitles),
                    reservedSize: 36,
                    interval: 1,
                  ),
                ),
              ),
              gridData: FlGridData(
                // 网格线
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                checkToShowHorizontalLine: (double value) {
                  // debugPrint("checkToShowHorizontalLine: $value");
                  return value == 10 ||
                      value == (widget.pressureBaseLine * 0.6).toInt() ||
                      value == (widget.pressureBaseLine * 1).toInt() ||
                      value == (widget.pressureBaseLine * 1.5).toInt();
                },
              ),
            ),
          ),
        ),
      );
    });
  }
}
