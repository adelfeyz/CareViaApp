import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartring_flutter/src/util/getxManager.dart';

import '../hive/db/pressure_db.dart';

class MotionChartController extends GetxController {
  RxList<Map<String, dynamic>> motionData = <Map<String, dynamic>>[].obs;

  void updateData(List<Map<String, dynamic>> data) {
    motionData.value = data;
  }
}

class MotionChart extends StatefulWidget {
  MotionChart({super.key});
  // final List<Map<String, dynamic>> motionData;
  final Color dark = Color(Colors.grey[800]!.value);
  final Color extremelyLowColor = const Color(0xff8a8a8a);
  final Color lowColor = const Color(0xff02679e);
  final Color mediumColor = const Color(0xff7dcbf5);
  final Color highColor = const Color.fromARGB(255, 223, 219, 219);

  @override
  State<StatefulWidget> createState() => MotionChartState();
}

class MotionChartState extends State<MotionChart> {
  final MotionChartController controller = GetXManager.instance.putController(
      MotionChartController(),
      tag: GetXManager.motionChartControllerTag);
  List<Map<String, dynamic>> processedData = [];
  int interval = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  dealData() {
    List<Map<String, dynamic>> data = controller.motionData.value;
    if (data.isEmpty) {
      return;
    }
    List timeStampArray = data.map((item) => item['timeStamp']).toList();

    int startTimeStamp = timeStampArray[0];
    DateTime startDateTime =
        DateTime.fromMillisecondsSinceEpoch(startTimeStamp);
    //根据DateTime获取晚上12点的毫秒数
    int endTimeStamp =
        DateTime(startDateTime.year, startDateTime.month, startDateTime.day, 24)
            .millisecondsSinceEpoch;
    //根据开始时间和结束时间计算有多少个15分钟的间隔
    interval = (endTimeStamp - startTimeStamp) ~/ 900000;
    //通过date数组中的timeStamp计算从开始时间开始是第几个15分钟
    processedData = data.map((entry) {
      int index = (entry['timeStamp'] - startTimeStamp) ~/ 900000;
      return {...entry, 'index': index};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      dealData();
      return AspectRatio(
        aspectRatio: 2,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 10,
            right: 18,
            top: 10,
            bottom: 4,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const barsSpace = 0.0;
              final barsWidth = constraints.maxWidth / interval;
              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  barTouchData: BarTouchData(
                    enabled: false,
                  ),
                  titlesData: const FlTitlesData(
                    show: false,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
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
                  gridData: FlGridData(
                    show: false,
                    checkToShowHorizontalLine: (value) => value % 10 == 0,
                    getDrawingHorizontalLine: (value) => const FlLine(
                      color: Colors.black12,
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  groupsSpace: barsSpace,
                  barGroups: getData(barsWidth, barsSpace),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Color getColor(MotionType motionType) {
    switch (motionType) {
      case MotionType.ExtremelyLow:
        return widget.extremelyLowColor;
      case MotionType.Low:
        return widget.lowColor;
      case MotionType.Medium:
        return widget.mediumColor;
      case MotionType.High:
        return widget.highColor;
      default:
        return widget.dark; // 或者抛出异常，视具体情况而定
    }
  }

  void addBarGroup(List<BarChartGroupData> barGroups, int i,
      MotionType motionType, double motionSum, double barsWidth) {
    barGroups.add(
      BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: motionSum.toDouble(),
            width: barsWidth,
            color: getColor(motionType),
            borderRadius: BorderRadius.zero,
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> getData(double barsWidth, double barsSpace) {
    debugPrint('interval: $interval processedData: ${processedData.length}');
    List<BarChartGroupData> barGroups =
        processedData.fold<List<BarChartGroupData>>(
      [],
      (groups, element) {
        if (element['index'] < interval) {
          addBarGroup(
              groups,
              element['index'],
              MotionTypeInt.fromInt(element['motionType']),
              element['motionSum'].toDouble(),
              barsWidth);
        }
        return groups;
      },
    );

    // 添加未命中的空白条形组
    for (int i = 0; i < interval; i++) {
      if (barGroups.indexWhere((group) => group.x == i) == -1) {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: 100,
                width: barsWidth,
                color: widget.dark,
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
        );
      }
    }
    barGroups.sort((a, b) => a.x.compareTo(b.x));
    return barGroups;
  }
}
