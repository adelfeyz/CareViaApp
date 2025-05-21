
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartring_flutter/src/hive/db/pressure_db.dart';

import 'db/history_db.dart';
import 'db/sleep_db.dart';
import 'model/history_model.dart';
import 'model/pressure_model.dart';
import 'model/sleep_model.dart';

class HiveManager {
  static final HiveManager _singleton = HiveManager._internal();
  late HistoryModel historyModel;
  late SleepModel sleepModel;
  late PressureModel pressureModel;

  factory HiveManager() {
    return _singleton;
  }

  HiveManager._internal();
  // 初始化 hive 数据库 在加载界面之前初始化
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(HistoryDbAdapter());
      Hive.registerAdapter(SleepDbAdapter());
      Hive.registerAdapter(PressureDbAdapter());
      historyModel = await HistoryModel.getInstance();
      sleepModel= await SleepModel.getInstance();
      pressureModel = await PressureModel.getInstance();
    } catch (e) {
      print('初始化 historyModel 时出现异常: $e');
    }
  }

  HistoryModel getHistoryModel() {
    return historyModel;
  }

  SleepModel getSleepModel() {
    return sleepModel;
  }

  PressureModel getPressureModel() {
    return pressureModel;
  }

  static Future<void> close() async {
    await Hive.close();
  }
}
