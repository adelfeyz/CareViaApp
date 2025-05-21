import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:smartring_flutter/src/hive/db/sleep_db.dart';
import '../../util/commonUtil.dart';
import '../db/sleep_db.dart';

class SleepModel {
  static SleepModel? _instance; // 将其声明为nullable类型，并初始化为null
  late Box<SleepDb> _sleepBox;

  SleepModel._internal();

  static Future<SleepModel> getInstance() async {
    if (_instance == null) {
      _instance = SleepModel._internal();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _sleepBox = await Hive.openBox<SleepDb>('sleep');
  }

  Future<void> addSleep(SleepDb sleep) async {
    final keys = _sleepBox.keys;
    if (keys.isNotEmpty) {
      final lastKey = keys.last;
      final lastSleepData = _sleepBox.get(lastKey);
      if (lastSleepData!.startTimeStamp < sleep.startTimeStamp) {
        debugPrint('adding new sleep');
        await _sleepBox.add(sleep);
        return;
      }
    } else {
      debugPrint('adding new sleep');
      await _sleepBox.add(sleep);
      return;
    }
    debugPrint('sleep already exists');
  }

  // 根据时间戳获取睡眠数据
  Future<List<SleepDb>> getTimeStampRangeData(
      int startTimeStamp, int endTimeStamp) async {
    // 使用Hive查询方法，根据timeStamp范围筛选数据
    final rangeQueryResult = _sleepBox.values.where((sleep) {
      // debugPrint('${sleep.startTime} sleep.startTimeStamp: ${sleep.startTimeStamp} startTimeStamp=$startTimeStamp  ${sleep.endTime}  sleep.endTimeStamp: ${sleep.endTimeStamp}   endTimeStamp=$endTimeStamp');
      return (sleep.startTimeStamp >= startTimeStamp &&
              sleep.endTimeStamp <= endTimeStamp ||
          sleep.startTimeStamp <= startTimeStamp &&
              sleep.endTimeStamp >= startTimeStamp);
    }).toList();

    return rangeQueryResult.cast<SleepDb>();
  }

// 根据日期获取睡眠数据
  Future<List<SleepDb>> getSleepDataByDate(DateTime date) async {
    final startTimeStamp = DateTime(date.year, date.month, date.day, 00, 00, 00)
        .millisecondsSinceEpoch;
    final endTimeStamp = DateTime(date.year, date.month, date.day, 23, 59, 59)
        .millisecondsSinceEpoch;
    // debugPrint(
    //     'getSleepDataByDate startTimeStamp: $startTimeStamp, endTimeStamp: $endTimeStamp');
    // 使用Hive查询方法，根据timeStamp范围筛选数据
    final rangeQueryResult = _sleepBox.values
        .where((sleep) =>
            (sleep.startTimeStamp >= startTimeStamp &&
                sleep.endTimeStamp <= endTimeStamp) ||
            (sleep.startTimeStamp <= startTimeStamp &&
                sleep.endTimeStamp >= startTimeStamp))
        .toList();
    // debugPrint(
    //     'getSleepDataByDate rangeQueryResult: ${rangeQueryResult.length}  _sleepBox.values=${_sleepBox.values.length} _sleepBox.values.toList()=${_sleepBox.values.toList()}');
    return rangeQueryResult.cast<SleepDb>();
  }

  //计算温度的基线值
  Future<double?> findFtcAvgGreaterThanZeroFor7Days(DateTime startDate) async {
    var yesterday = startDate.subtract(const Duration(days: 1));
    var yesterdayStart =
        DateTime(yesterday.year, yesterday.month, yesterday.day, 00, 00, 00);
    var yesterdayEnd =
        DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
    final result = <double>[];
    final firstData = await getFirstData();
    debugPrint(
        '计算温度基线值 firstData: ${firstData.toString()} yesterday: $yesterday');
    if (firstData == null) {
      return null;
    }
    while (result.length < 7) {
      if (firstData.startTimeStamp > yesterdayEnd.millisecondsSinceEpoch) {
        break;
      }
      final dayRecords = await getTimeStampRangeData(
        yesterdayStart.millisecondsSinceEpoch,
        yesterdayEnd.millisecondsSinceEpoch,
      );
      var maxDuration = 0;
      var maxFtcAvg = 0.0;
      for(int i = 0; i < dayRecords.length; i++){
        final record = dayRecords[i];
        if(record.duration > maxDuration&&record.ftcAvg > 0&&!record.isFtcOutlier){
          maxDuration = record.duration;
          maxFtcAvg = record.ftcAvg;
        }
        if(i==dayRecords.length-1&&maxFtcAvg!=0.0){
          result.add(maxFtcAvg);
        }
      }
      // for (final record in dayRecords) {
      //   if(maxDuration){

      //   }
      // record.duration
      //   debugPrint('计算温度基线值 进入循环遍历 record: $record');
      //   if (record.ftcAvg > 0 && !record.isFtcOutlier) {
      //     result.add(record.ftcAvg);
      //     break;
      //   }
      // }
      yesterday = yesterday.subtract(const Duration(days: 1));
      yesterdayStart =
          DateTime(yesterday.year, yesterday.month, yesterday.day, 00, 00, 00);
      yesterdayEnd =
          DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
    }
    if (result.isEmpty) {
      return null;
    }
    final avg =
        result.reduce((value, element) => value + element) / result.length;
    return roundToOneDecimalWithRounding(avg);
  }

  //计算压力的基线值
  Future<Map<String, dynamic>> findPressureBaseLine(DateTime startDate) async {
    var yesterday = startDate.subtract(const Duration(days: 1));
    var fourteenday = startDate.subtract(const Duration(days: 13));
    var fourteendayStart = DateTime(
        fourteenday.year, fourteenday.month, fourteenday.day, 00, 00, 00);
    var yesterdayStart =
        DateTime(yesterday.year, yesterday.month, yesterday.day, 00, 00, 00);
    var yesterdayEnd =
        DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
    final result = <double>[];
    final firstData = await getFirstData();
    // debugPrint(
    //     'findPressureBaseLine firstData: ${firstData.toString()} yesterday: $yesterday fourteenday: $fourteenday');
    if (firstData == null) {
      return {'baseLine': 0, 'downCount': 5};
    }
    while (result.length <= 14) {
      // debugPrint(
      //     'findPressureBaseLine firstData.startTimeStamp: ${firstData.startTimeStamp} yesterdayEnd.millisecondsSinceEpoch: ${yesterdayEnd.millisecondsSinceEpoch} fourteendayStart.millisecondsSinceEpoch: ${fourteendayStart.millisecondsSinceEpoch}');
      // debugPrint(
      //     'firstData.startTimeStamp > yesterdayEnd.millisecondsSinceEpoch: ${firstData.startTimeStamp < yesterdayEnd.millisecondsSinceEpoch} fourteendayStart.millisecondsSinceEpoch >yesterdayEnd.millisecondsSinceEpoch: ${fourteendayStart.millisecondsSinceEpoch > yesterdayEnd.millisecondsSinceEpoch}');
      if (firstData.startTimeStamp > yesterdayEnd.millisecondsSinceEpoch ||
          fourteendayStart.millisecondsSinceEpoch >
              yesterdayEnd.millisecondsSinceEpoch) {
        break;
      }
      final dayRecords = await getTimeStampRangeData(
        yesterdayStart.millisecondsSinceEpoch,
        yesterdayEnd.millisecondsSinceEpoch,
      );
      // debugPrint('findPressureBaseLine dayRecords: $dayRecords');
      List<int> hrvList = [];
      for (final record in dayRecords) {
        // debugPrint(
        //     'record.avgHrv = ${record.avgHrv} record.duration = ${record.duration}');
        if (record.avgHrv > 0 &&
            record.duration >= const Duration(hours: 3).inMilliseconds) {
          // debugPrint('添加压力数据');
          // result.add(record.avgHrv);
          hrvList.add(record.avgHrv);
          break;
        }
      }
      if(hrvList.isNotEmpty){
       final avgHrv =  hrvList.reduce((value, element) => value + element)/hrvList.length;
       result.add(avgHrv);
      }
      yesterday = yesterday.subtract(const Duration(days: 1));
      yesterdayStart =
          DateTime(yesterday.year, yesterday.month, yesterday.day, 00, 00, 00);
      yesterdayEnd =
          DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
    }
    if (result.length < 5) {
      return {'baseLine': 0, 'downCount': 5 - result.length};
    }
    final baseLine =
        result.reduce((value, element) => value + element) / result.length;
    return {
      'baseLine': roundToOneDecimalWithRounding(baseLine),
      'downCount': 0
    };
  }

  bool isFtcOutlier(num ftcAvg, num ftcBase) {
    return (ftcAvg - ftcBase).abs() > 1;
  }

  // 异步函数，获取所有睡眠数据
  Future<List<SleepDb>> getAllSleepData() async {
    // 使用Hive查询方法，获取所有数据
    final allData = _sleepBox.values.toList();
    return allData.cast<SleepDb>();
  }

  // 获取第一条数据
  Future<SleepDb?> getFirstData() async {
    final keys = _sleepBox.keys.toList();
    // debugPrint('getFirstData keys: $keys');
    if (keys.isNotEmpty) {
      final firstKey = keys.first;
      return await _sleepBox.get(firstKey);
    }
    return null;
  }

  // 删除最后一条sleep数据
  Future<void> deleteLastSleepData() async {
    // 获取Box中的所有键
    final keys = _sleepBox.keys.toList();
    // 确保Box中有至少一条数据
    if (keys.isNotEmpty) {
      // 获取最后一个键
      final lastKey = keys.last;
      // 删除最后一条数据
      await _sleepBox.delete(lastKey);
      debugPrint('成功删除最后一条睡眠记录');
    } else {
      debugPrint('睡眠记录为空，无可删除数据');
    }
  }

  //删除所有sleep数据
  Future<void> deleteAllSleepData() async {
    // 获取Box中的所有键
    final keys = _sleepBox.keys.toList();
    // 确保Box中有至少一条数据
    if (keys.isNotEmpty) {
      // 删除所有数据
      await _sleepBox.clear();
      debugPrint('成功删除所有睡眠记录');
    } else {
      debugPrint('睡眠记录为空，无可删除数据');
    }
  }

  Future<String> getAllSleepDataToJson() async {
    final allData = _sleepBox.values.toList();
    List<Map<String, dynamic>> jsonData =
        allData.map((item) => item.toJson()).toList();
    String jsonDataStr = jsonData.fold("", (previousValue, element) {
      return previousValue + json.encode(element) + "\n";
    });

    return jsonDataStr;
  }

  // 异步函数，获取最后一次睡眠时间
  Future<int?> getLastSleepTime() async {
    final keys = _sleepBox.keys.toList();
    if (keys.isNotEmpty) {
      final lastKey = keys.last;
      final lastData = await _sleepBox.get(lastKey); // 获取最后一次睡眠数据
      final lastTime = lastData!.endTimeStamp; // 获取最后一次睡眠结束时间戳
      return lastTime; // 返回最后一次睡眠时间
    } else {
      debugPrint('睡眠记录为空，无睡眠时间'); // 打印历史记录为空
    }
    return null; // 返回空值
  }

  Future<void> calFtcAvg() async {}

  Future<void> closeBox() async {
    // 关闭box
    await _sleepBox.close();
  }
}
