import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:smartring_plugin/sdk/common/ble_protocol_constant.dart';
import '../../util/commonUtil.dart';
import '../db/history_db.dart';

class HistoryModel {
  static HistoryModel? _instance; // 将其声明为nullable类型，并初始化为null
  late Box<HistoryDb> _historyBox;

  HistoryModel._internal();

  static Future<HistoryModel> getInstance() async {
    if (_instance == null) {
      _instance = HistoryModel._internal();
      await _instance!._init(); // 添加非空断言（!），因为我们知道在此时肯定会被初始化
    }
    return _instance!;
  }

  Future<void> _init() async {
    _historyBox = await Hive.openBox<HistoryDb>('history');
  }

// 在数据库中添加历史记录
  Future<void> addHistory(HistoryDb history) async {
    final keys = _historyBox.keys.toList();
    // debugPrint('getFirstData keys: $keys');
    if (keys.isNotEmpty) {
      final lastKey = keys.last;
      final lastData = _historyBox.get(lastKey);
      // debugPrint('lastData!.timeStamp: ${lastData!.timeStamp}');
      if(history.timeStamp>lastData!.timeStamp){
      await _historyBox.add(history);
      return;
      }
      debugPrint('History already exists');
    }else{
      debugPrint('[keys is empty]');
      await _historyBox.add(history);
      return;
    }
    debugPrint('History already exists');
  }

  Future<void> addAllHistory(List<HistoryDb> historyList) async {    
    for (var history in historyList) {
      await addHistory(history);
    }
    
  }

// 删除历史记录
  Future<void> deleteHistory() async {
    // 删除所有历史记录
    await _historyBox.clear();
    // 输出调试信息
    debugPrint('All history records deleted');
  }

  /// 获取时间戳范围内的数据
  Future<List<HistoryDb>> getTimeStampRangeData(int startTimeStamp,
      [int? endTimeStamp]) async {
    int endTime = endTimeStamp ?? DateTime.now().millisecondsSinceEpoch;
    // 使用Hive查询方法，根据timeStamp范围筛选数据
    final rangeQueryResult = _historyBox.values
        .where((history) =>
            history.timeStamp >= startTimeStamp && history.timeStamp <= endTime)
        .toList();
    return rangeQueryResult.cast<HistoryDb>();
  }

// 获取所有历史数据的方法
// 该方法使用异步操作
// 从 _historyBox 中获取所有数据并转换为列表
// 最后将数据强制类型转换为 HistoryDb 类型并返回
  Future<List<HistoryDb>> getAllHistoryData() async {
    final allData = _historyBox.values.toList();
    return allData.cast<HistoryDb>(); // 强制类型转换
  }

  Future<String> getAllHistoryDataToJson() async {
    final allData = _historyBox.values.toList();
    List<Map<String, dynamic>> jsonData = allData.map((item) => item.toJson()).toList();
    String jsonDataStr = jsonData.fold("", (previousValue, element) {
      return previousValue + json.encode(element) + "\n";
    });

    return jsonDataStr;
  }

  //计算睡眠期间的平均温度
  Future<double> calFtcAvg(
      int startTimeStamp, int endTimeStamp, List wakeArr) async {
    // 获取睡眠时间段内的所有数据，但排除wakeArr中的唤醒时间段
    final sleepRecords =
        await getTimeStampRangeData(startTimeStamp, endTimeStamp);

    // 过滤掉wakeArr中时间段的记录
    final filteredRecords = sleepRecords.where((history) {
      for (var wake in wakeArr) {
        final wakeStartTimeStamp = wake["startTime"];
        final wakeEndTimeStamp = wake["endTime"];
        if (history.timeStamp >= wakeStartTimeStamp &&
            history.timeStamp <= wakeEndTimeStamp) {
          return false;
        }
      }
      return true;
    }).toList();

    // 计算剩余时间段的temperature总和
    double temperatureSum = 0;
    for (final record in filteredRecords) {
      temperatureSum += record.temperature;
    }

    // 计算平均值，注意过滤后可能没有记录，此时应避免除以零异常
    double ftcAvg = 0;
    if (filteredRecords.isNotEmpty) {
      ftcAvg = temperatureSum / filteredRecords.length;
    }
    // 输出结果或者做进一步处理
    print('FTC Avg Temperature: $ftcAvg');
    return ftcAvg;
  }

  // 计算HRV平均值
  Future<int> calHrvAvg(int startTimeStamp, int endTimeStamp) async {
    var sleepRecords =
        await getTimeStampRangeData(startTimeStamp, endTimeStamp);
    sleepRecords = sleepRecords
        .where(
            (history) => history.wearStatus == 1 && history.chargeStatus == 0)
        .where((history) {
      if (history.rawHr != null &&
              history.rawHr?.length == 3 &&
              history.rawHr?[0] == 200 &&
              history.rawHr?[1] == 200 &&
              history.rawHr?[2] == 200 ||
          history.hrv == 0) {
        return false;
      }
      return true;
    }).toList();

    // 计算HRV平均值
    double hrvAvg = 0;
    if (sleepRecords.isNotEmpty) {
      hrvAvg =
          sleepRecords.map((history) => history.hrv).reduce((a, b) => a + b) /
              sleepRecords.length;
    }
    // 输出结果或者做进一步处理
    print('HRV Avg: $hrvAvg');
    return hrvAvg.toInt();
  }
}
