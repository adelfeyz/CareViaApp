import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:smartring_flutter/src/hive/db/pressure_db.dart';
import '../../util/commonUtil.dart';
import '../db/sleep_db.dart';

class PressureModel {
  static PressureModel? _instance; // 将其声明为nullable类型，并初始化为null
  late Box<PressureDb> _pressureBox;

  PressureModel._internal();

  static Future<PressureModel> getInstance() async {
    if (_instance == null) {
      _instance = PressureModel._internal();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _pressureBox = await Hive.openBox<PressureDb>('pressure');
  }

  Future<void> addPressure(PressureDb pressureDb) async {
    final keys = _pressureBox.keys;
    if (keys.isNotEmpty) {
      final lastKey = keys.last;
      final lastPressureData = _pressureBox.get(lastKey);
      if (lastPressureData!.timeStamp < pressureDb.timeStamp) {
        debugPrint('adding new pressure');
        await _pressureBox.add(pressureDb);
        return;
      }
    }else{
      debugPrint('adding new pressure');
      await _pressureBox.add(pressureDb);
      return;
    }
    debugPrint('pressure already exists');
  }

  // 删除最后一条Pressure数据
  Future<void> deleteLastPressureData() async {
    // 获取Box中的所有键
    final keys = _pressureBox.keys.toList();
    // 确保Box中有至少一条数据
    if (keys.isNotEmpty) {
      // 获取最后一个键
      final lastKey = keys.last;
      // 删除最后一条数据
      await _pressureBox.delete(lastKey);
      debugPrint('成功删除最后一条Pressure记录');
    } else {
      debugPrint('Pressure记录为空，无可删除数据');
    }
  }

  // 获取最后一条Pressure数据的timeStamp
  Future<int?> getLastPressureTimeStamp() async {
    // 获取Box中的所有键
    final keys = _pressureBox.keys.toList();
    // 确保Box中有至少一条数据
    if (keys.isNotEmpty) {
      // 获取最后一个键
      final lastKey = keys.last;
      // 获取最后一条数据
      final lastPressureData = _pressureBox.get(lastKey);
      // 返回最后一条数据的timeStamp
      return lastPressureData?.timeStamp;
    } else {
      debugPrint('历史记录为空，无可获取数据');
      return null;
    }
  }

  // 获取所有Pressure数据
  Future<List<PressureDb>> getPressureDataByDate(DateTime date) async {
    final startTimeStamp = DateTime(date.year, date.month, date.day, 00, 00, 00)
        .millisecondsSinceEpoch;
    final endTimeStamp = DateTime(date.year, date.month, date.day, 23, 59, 59)
        .millisecondsSinceEpoch;
    final rangeQueryResult = _pressureBox.values
        .where((element) => (element.timeStamp >= startTimeStamp &&
            element.timeStamp <= endTimeStamp))
        .toList();
    return rangeQueryResult.cast<PressureDb>();
  }

  Future<String> getDataByPressureToJson(DateTime date) async {
    final allData = await getPressureDataByDate(date);
    List<Map<String, dynamic>> jsonData =
        allData.map((item) => item.toJson()).toList();
    debugPrint("jsonData.length: ${jsonData.length}");
    String jsonDataStr = jsonData.fold("", (previousValue, element) {
      return previousValue + json.encode(element) + "\n";
    });
    return jsonDataStr;
  }

  Future<void> closeBox() async {
    // 关闭box
    await _pressureBox.close();
  }
}
