import 'package:flutter/material.dart';
import '../hive/db/history_db.dart';
import '../hive/db/pressure_db.dart';
import '../hive/db/sleep_db.dart';
import '../hive/hive_manager.dart';
import '../hive/model/history_model.dart';
import '../hive/model/pressure_model.dart';
import '../hive/model/sleep_model.dart';
import 'package:smartring_plugin/smartring_plugin.dart' as smartring_plugin;

import '../util/commonUtil.dart';

class HealthModel {
  static HealthModel? _instance;
  final _hiveManager = HiveManager();
  late HistoryModel _historyModel;
  late SleepModel _sleepModel;
  late PressureModel _pressureModel;
  final int MINUTE = 60 * 1000;
  final int HOUR = 60 * 60 * 1000;
  factory HealthModel() {
    if (_instance == null) {
      _instance = HealthModel._internal();
      _instance!.init();
    }
    return _instance!;
  }

  HealthModel._internal();

  init() async {
    _historyModel = _hiveManager.getHistoryModel();
    _sleepModel = _hiveManager.getSleepModel();
    _pressureModel = _hiveManager.getPressureModel();
  }

  getHistoryModel() {
    return _historyModel;
  }

  getSleepModel() {
    return _sleepModel;
  }

  Future<void> storeSleepData() async {
    // await _sleepModel.deleteAllSleepData();
    await _sleepModel.deleteLastSleepData();
    final timeStamp = await _sleepModel.getLastSleepTime();
    // debugPrint("storeSleepData timeStamp=$timeStamp");
    var historyArr = <HistoryDb>[];
    if (timeStamp == null) {
      historyArr = await _historyModel.getAllHistoryData();
    } else {
      historyArr = await _historyModel.getTimeStampRangeData(timeStamp);
    }
    await addSleepData(historyArr);
  }

  Future<void> addSleepData(List<HistoryDb> historyData) async {
    if (historyData.isEmpty) {
      return;
    }
    final (sleepArray, hrArray) = await dealHistoryData(historyData);
    debugPrint(
        "数据库取出后计算的睡眠数据 length=${sleepArray.length} sleepArray=$sleepArray ");
    final sleepResult = smartring_plugin.sleepAlgorithm(sleepArray);
    debugPrint("addSleepData sleepResult=$sleepResult");
    final sleepTimeArray = [];
    final sleepTimePeriodArray = [];
    final sleepPeriodItemArray = [];
    for (var i = 0; i < sleepResult.length; i++) {
      var data = sleepResult[i];
      var lightTime = 0;
      var deepTime = 0;
      var remTime = 0;
      var wakeTime = 0;
      var napTime = 0;
      var lightArr = [];
      var deepArr = [];
      var napArr = [];
      var remArr = [];
      var wakeArr = [];
      var startTime = data["startTime"];
      var endTime = data["endTime"];
      var stagingList = data["stagingList"];
      for (var i = 0; i < stagingList.length; i++) {
        var staging = stagingList[i];
        switch (staging["type"]) {
          case smartring_plugin.SleepType.WAKE:
            wakeTime = staging["endTime"] - staging["startTime"] + wakeTime;
            wakeArr.add({
              "startTime": staging["startTime"],
              "endTime": staging["endTime"]
            });
            break;
          case smartring_plugin.SleepType.NREM1:
            lightTime = staging["endTime"] - staging["startTime"] + lightTime;
            lightArr.add({
              "startTime": staging["startTime"],
              "endTime": staging["endTime"]
            });
            break;
          case smartring_plugin.SleepType.NREM3:
            deepTime = staging["endTime"] - staging["startTime"] + deepTime;
            deepArr.add({
              "startTime": staging["startTime"],
              "endTime": staging["endTime"]
            });
            break;
          case smartring_plugin.SleepType.REM:
            remTime = staging["endTime"] - staging["startTime"] + remTime;
            remArr.add({
              "startTime": staging["startTime"],
              "endTime": staging["endTime"]
            });
            break;
          case smartring_plugin.SleepType.NAP:
            napTime = staging["endTime"] - staging["startTime"] + napTime;
            napArr.add({
              "startTime": staging["startTime"],
              "endTime": staging["endTime"]
            });
            break;
        }
      }
      sleepPeriodItemArray.add({
        "lightPeriod": lightArr,
        "remPeriod": remArr,
        "deepPeriod": deepArr,
        "napPeriod": napArr,
        "wakePeriod": wakeArr,
      });
      sleepTimeArray.add({
        "deepSleep":
            "deepTime= ${(deepTime ~/ HOUR)}h${((deepTime % HOUR) ~/ MINUTE)}m",
        "deepSleepTime": deepTime,
        "lightTime":
            "lightTime= ${(lightTime ~/ HOUR)}h${((lightTime % HOUR) ~/ MINUTE)}m",
        "lightSleepTime": lightTime,
        "remTime":
            "remTime= ${(remTime ~/ HOUR)}h${((remTime % HOUR) ~/ MINUTE)}m",
        "remSleepTime": remTime,
        "wakeTime":
            "wakeTime= ${(wakeTime ~/ HOUR)}h${((wakeTime % HOUR) ~/ MINUTE)}m",
        "wakeSleepTime": wakeTime,
        "napTime":
            "napTime= ${(napTime ~/ HOUR)}h${((napTime % HOUR) ~/ MINUTE)}m",
        "napSleepTime": napTime,
        "startTime": smartring_plugin.formatDateTime(startTime),
        "endTime": smartring_plugin.formatDateTime(endTime)
      });
      sleepTimePeriodArray.add({
        "sleepTimePeriod": {"startTime": startTime, "endTime": endTime}
      });
    }
    for (var i = 0; i < sleepTimePeriodArray.length; i++) {
      var sleepPeriodTime = sleepTimePeriodArray[i];
      var sleepPeriodItem = sleepPeriodItemArray[i];
      var sleepTime = sleepTimeArray[i];
      var wakeArr = sleepPeriodItem["wakePeriod"];
      num ftcAvg = 0;
      //睡眠开始时间
      int sleepStartTime = sleepPeriodTime["sleepTimePeriod"]["startTime"];
      //睡眠结束时间
      int sleepEndTime = sleepPeriodTime["sleepTimePeriod"]["endTime"];
      int duration = sleepEndTime - sleepStartTime;
      if (isMoreThanThreeHours(sleepStartTime, sleepEndTime)) {
        ftcAvg = await _historyModel.calFtcAvg(
            sleepStartTime, sleepEndTime, wakeArr);
        debugPrint("isMoreThanThreeHours ftcAvg=$ftcAvg");
      }

      var pressureBaseLine = await _sleepModel.findPressureBaseLine(
          DateTime.fromMillisecondsSinceEpoch(sleepEndTime));
      int hrvAvg = await _historyModel.calHrvAvg(sleepStartTime, sleepEndTime);
      bool isNap = sleepTime["napSleepTime"] > 0 ? true : false;
      double ftcBase = await _sleepModel.findFtcAvgGreaterThanZeroFor7Days(
              DateTime.fromMillisecondsSinceEpoch(sleepEndTime)) ??
          ftcAvg.toDouble();
      bool isFtcOutlier = _sleepModel.isFtcOutlier(ftcAvg, ftcBase);
      // debugPrint(
      //     "startTime=${smartring_plugin.formatDateTime(sleepStartTime)} endTime=${smartring_plugin.formatDateTime(sleepEndTime)} duration=$duration ftcAvg=$ftcAvg hrvAvg=$hrvAvg isNap=$isNap ftcBase=$ftcBase isFtcOutlier=$isFtcOutlier pressureBaseLine=$pressureBaseLine");
      await _sleepModel.addSleep(SleepDb(
          startTimeStamp: sleepStartTime,
          endTimeStamp: sleepEndTime,
          duration: duration,
          ftcAvg: ftcAvg.toDouble(),
          avgHrv: hrvAvg,
          startTime: sleepTime["startTime"],
          endTime: sleepTime["endTime"],
          deepSleep: sleepTime["deepSleep"],
          deepSleepTime: sleepTime["deepSleepTime"],
          lightSleep: sleepTime["lightTime"],
          lightSleepTime: sleepTime["lightSleepTime"],
          remSleep: sleepTime["remTime"],
          remSleepTime: sleepTime["remSleepTime"],
          wakeSleep: sleepTime["wakeTime"],
          wakeSleepTime: sleepTime["wakeSleepTime"],
          napSleep: sleepTime["napTime"],
          napSleepTime: sleepTime["napSleepTime"],
          ftcBase: ftcBase,
          nap: isNap,
          isFtcOutlier: isFtcOutlier,
          pressureBaseLine: pressureBaseLine));
    }
  }

  Future<Map<String, dynamic>?> getSleepTemperatureFluctuateData(
      DateTime date) async {
    final sleepData = await _sleepModel.getSleepDataByDate(date);
    if (sleepData.isEmpty) return null;

    final sleepDataWithoutNap = sleepData
        .where((element) => !element.nap && element.ftcAvg != 0)
        .toList();
    if (sleepDataWithoutNap.isEmpty) return null;
    final longestSleepRecord = sleepDataWithoutNap.reduce(
        (longestSoFar, current) =>
            longestSoFar.duration > current.duration ? longestSoFar : current);
    final historyData = await _historyModel.getTimeStampRangeData(
        longestSleepRecord.startTimeStamp, longestSleepRecord.endTimeStamp);
    final baseDate = longestSleepRecord.ftcBase == 0
        ? longestSleepRecord.ftcAvg
        : longestSleepRecord.ftcBase;
    final temperatureArray = historyData.map((data) {
      return {
        "timeStamp": data.timeStamp,
        "temp": data.temperature - baseDate,
      };
    }).toList();
    return {
      "temperatureArray": temperatureArray,
      "ftcW": longestSleepRecord.ftcAvg - baseDate,
      "ftcBase": baseDate,
    };
  }

  Future<Map<String, dynamic>> getPressureBaseLine(DateTime date) async {
    return await _sleepModel.findPressureBaseLine(date);
  }

  Future<void> storePressureZone() async {
    final timeStamp = await _pressureModel.getLastPressureTimeStamp();
    List<HistoryDb> historyArr = [];
    if (timeStamp == null) {
      historyArr = await _historyModel.getAllHistoryData();
    } else {
      historyArr = await _historyModel.getTimeStampRangeData(timeStamp);
    }
    if (historyArr.isEmpty) {
      return;
    }
    await _pressureModel.deleteLastPressureData();
    // 创建一个Map来存储按天分组的历史数据
    Map<DateTime, List<HistoryDb>> dailyDataMap = {};
    for (var data in historyArr) {
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(data.timeStamp).toLocal();
      DateTime startDateOfTheDay =
          DateTime(dateTime.year, dateTime.month, dateTime.day);
      // 检查Map中是否已经存在这一天的列表
      if (!dailyDataMap.containsKey(startDateOfTheDay)) {
        dailyDataMap[startDateOfTheDay] = [data];
      } else {
        dailyDataMap[startDateOfTheDay]!.add(data);
      }
    }
    Map<DateTime, List<Map<String, dynamic>>> classifiedDataMap = {};
    debugPrint("classifiedDataMap 开始初始化");
    final future = dailyDataMap.keys.map((date) async {
      int count = 0;
      double hrvaSum = 0.0;
      int motionSum = 0;
      int initialTimestamp = 0;
      bool isDirtyData = false;
      HistoryDb? previousData;
      int previousSteps = 0;
      final sleepDataForDate = await _sleepModel.getSleepDataByDate(date);
      debugPrint("storePressureZone 1 time=${dailyDataMap[date]!.length}");
      for (var data in dailyDataMap[date]!) {
        // debugPrint("storePressureZone 2 time=${DateTime.now().microsecondsSinceEpoch}");
        final pressureBaseLineMap = await getPressureBaseLine(date);
        final pressureBaseLine = pressureBaseLineMap["baseLine"];
        if (pressureBaseLine != 0) {
          if (data.wearStatus == 0 || data.chargeStatus == 1) {
            isDirtyData = true;
          }
          if (previousData != null) {
            final previousTimestamp = previousData.timeStamp;
            final timeDifference =
                Duration(milliseconds: data.timeStamp - previousTimestamp);

            if (timeDifference.inMinutes >= 4 &&
                timeDifference.inMinutes <= 8) {
              if ((data.step - previousSteps) > 500) {
                isDirtyData = true;
              }
            }
          }
          if (sleepDataForDate.isNotEmpty) {
            for (var sleep in sleepDataForDate) {
              final sleepStart = sleep.startTimeStamp;
              final sleepEnd = sleep.endTimeStamp;
              if (sleepStart <= data.timeStamp && sleepEnd >= data.timeStamp) {
                isDirtyData = true;
                break;
              }
            }
          }
          // 更新前一次数据
          previousData = data;
          previousSteps = data.step;
          if (count == 0) {
            motionSum = data.motionDetectionCount;
            hrvaSum = data.hrv.toDouble();
            initialTimestamp = data.timeStamp;
          } else {
            hrvaSum += data.hrv.toDouble();
            motionSum += data.motionDetectionCount;
          }
          count++;
          if (count == 3) {
            if (isDirtyData) {
              count = 0;
              hrvaSum = 0.0;
              motionSum = 0;
              // initialTimestamp = 0;
              isDirtyData = false;
              continue;
            }
            final lastTimestamp = data.timeStamp;
            final timeWindow =
                Duration(milliseconds: lastTimestamp - initialTimestamp);
            if (timeWindow.inMinutes <= 15) {
              final pressure = hrvaSum / count;
              final stressLevel =
                  classifyStressLevel(pressure, pressureBaseLine);
              classifiedDataMap[date] ??= [];
              classifiedDataMap[date]!.add({
                'timeStamp': data.timeStamp,
                'stressLevel': stressLevel,
                'baseLine': pressureBaseLine,
                'pressure': pressure,
                'motionSum': motionSum,
                'motionType': getMotionType(motionSum),
              });
            }
            count = 0;
            hrvaSum = 0.0;
            motionSum = 0;
            initialTimestamp = 0;
            isDirtyData = false;
          }
        } else {
          continue;
        }    
      }
      return Future.value(null);
    }).toList();
    await Future.wait(future);
    classifiedDataMap.forEach((date, dataList) async {
      PressureDb pressureRecord = PressureDb(
        timeStamp: 0, // 我们将在最后填充正确的最新时间戳
        stressZoneList: [],
        engagementZoneList: [],
        relaxationZoneList: [],
        recoveryZoneList: [],
        pressureBaseLine: 0.0,
        extremelyLowMotionList: [],
        lowMotionList: [],
        mediumMotionList: [],
        highMotionList: [],
        allMotionList: [],
        allZoneList: {},
      );
      if (dataList.isNotEmpty) {
        int timeZoneCounter = 1;
        Map<int, List<Map<String, dynamic>>> allZoneList = {};
        final timestampInMs = date.millisecondsSinceEpoch;
        pressureRecord.timeStamp = timestampInMs;
        pressureRecord.pressureBaseLine = dataList[0]['baseLine'];
        for (int i = 0; i < dataList.length; i++) {
          final Map<String, dynamic> item = dataList[i];
          final trainingZone = item['stressLevel'];
          final motionType = item['motionType'];
          final int currentTimestamp = item['timeStamp'];
          allZoneList[timeZoneCounter] ??= [];
          allZoneList[timeZoneCounter]!.add({
            "timeStamp": item['timeStamp'],
            "stressLevel": item['stressLevel'],
            "pressure": item['pressure'],
            "timeZone": timeZoneCounter,
            "dashedLine": false,
          });
          if (i < dataList.length - 1) {
            final nextItem = dataList[i + 1];
            final int nextTimestamp = nextItem['timeStamp'];
            final Duration difference =Duration(milliseconds: nextTimestamp - currentTimestamp);
            if (difference.inHours >= 2) {
              timeZoneCounter++;
            } else if (difference.inMinutes > 18) {
              allZoneList[timeZoneCounter]!.last['dashedLine'] = true;
            }
          }
          pressureRecord.allZoneList = allZoneList;
          pressureRecord.allMotionList.add({
            "timeStamp": item['timeStamp'],
            "motionType": item['motionType'],
            "motionSum": item['motionSum'],
          });
          switch (TrainingZoneInt.fromInt(trainingZone)) {
            case TrainingZone.StressZone:
              pressureRecord.stressZoneList.add({
                "timeStamp": item['timeStamp'],
                "stressLevel": item['stressLevel'],
                "pressure": item['pressure'],
              });
              break;
            case TrainingZone.EngagementZone:
              pressureRecord.engagementZoneList.add({
                "timeStamp": item['timeStamp'],
                "stressLevel": item['stressLevel'],
                "pressure": item['pressure'],
              });
              break;
            case TrainingZone.RelaxationZone:
              pressureRecord.relaxationZoneList.add({
                "timeStamp": item['timeStamp'],
                "stressLevel": item['stressLevel'],
                "pressure": item['pressure'],
              });
              break;
            case TrainingZone.RecoveryZone:
              pressureRecord.recoveryZoneList.add({
                "timeStamp": item['timeStamp'],
                "stressLevel": item['stressLevel'],
                "pressure": item['pressure'],
              });
              break;
            default:
              // 不应该发生，但可以在此处进行错误处理或者记录日志
              break;
          }
          switch (MotionTypeInt.fromInt(motionType)) {
            case MotionType.ExtremelyLow:
              pressureRecord.extremelyLowMotionList.add({
                "timeStamp": item['timeStamp'],
                "motionType": item['motionType'],
                "motionSum": item['motionSum'],
              });
              break;
            case MotionType.Low:
              pressureRecord.lowMotionList.add({
                "timeStamp": item['timeStamp'],
                "motionType": item['motionType'],
                "motionSum": item['motionSum'],
              });
              break;
            case MotionType.Medium:
              pressureRecord.mediumMotionList.add({
                "timeStamp": item['timeStamp'],
                "motionType": item['motionType'],
                "motionSum": item['motionSum'],
              });
              break;
            case MotionType.High:
              pressureRecord.highMotionList.add({
                "timeStamp": item['timeStamp'],
                "motionType": item['motionType'],
                "motionSum": item['motionSum'],
              });
              break;
            default:
            break;  
          }
        }
        await _pressureModel.addPressure(pressureRecord);
        pressureRecord = PressureDb(
          timeStamp: 0, // 我们将在最后填充正确的最新时间戳
          stressZoneList: [],
          engagementZoneList: [],
          relaxationZoneList: [],
          recoveryZoneList: [],
          pressureBaseLine: 0.0,
          extremelyLowMotionList: [],
          lowMotionList: [],
          mediumMotionList: [],
          highMotionList: [],
          allMotionList: [],
          allZoneList: {},
        );
      }
    });
  }

  // Future<void> storePressureZone1() async {
  //   final timeStamp = await _pressureModel.getLastPressureTimeStamp();
  //   List<HistoryDb> historyArr = [];
  //   if (timeStamp == null) {
  //     historyArr = await _historyModel.getAllHistoryData();
  //   } else {
  //     historyArr = await _historyModel.getTimeStampRangeData(timeStamp);
  //   }
  //   if (historyArr.isEmpty) {
  //     return;
  //   }
  //   await _pressureModel.deleteLastPressureData();
  //   // 创建一个Map来存储按天分组的历史数据
  //   Map<DateTime, List<HistoryDb>> dailyDataMap = {};

  //   for (var data in historyArr) {
  //     DateTime dateTime =
  //         DateTime.fromMillisecondsSinceEpoch(data.timeStamp).toLocal();
  //     DateTime startDateOfTheDay =
  //         DateTime(dateTime.year, dateTime.month, dateTime.day);

  //     final sleepDataForDate =
  //         await _sleepModel.getSleepDataByDate(startDateOfTheDay);
  //     bool shouldSkipCurrentData = false;
  //     if (sleepDataForDate.isNotEmpty) {
  //       for (var sleep in sleepDataForDate) {
  //         final sleepStart =
  //             DateTime.fromMillisecondsSinceEpoch(sleep.startTimeStamp);
  //         final sleepEnd =
  //             DateTime.fromMillisecondsSinceEpoch(sleep.endTimeStamp);
  //         if (sleepStart.compareTo(dateTime) <= 0 &&
  //             sleepEnd.compareTo(dateTime) >= 0) {
  //           shouldSkipCurrentData = true;
  //           break;
  //         }
  //       }
  //     }
  //     if (shouldSkipCurrentData) {
  //       continue;
  //     }
  //     // 检查Map中是否已经存在这一天的列表
  //     if (!dailyDataMap.containsKey(startDateOfTheDay)) {
  //       dailyDataMap[startDateOfTheDay] = [data];
  //     } else {
  //       dailyDataMap[startDateOfTheDay]!.add(data);
  //     }
  //   }
  //   HistoryDb? previousData;
  //   int? previousSteps;
  //   Map<DateTime, List<Map<String, dynamic>>> classifiedDataMap = {};
  //   debugPrint("classifiedDataMap 开始初始化");
  //   final future = dailyDataMap.keys.map((date) async {
  //     int count = 0;
  //     double hrvaSum = 0.0;
  //     int motionSum = 0;
  //     int initialTimestamp = 0;
  //     for (var data in dailyDataMap[date]!) {
  //       final pressureBaseLineMap = await getPressureBaseLine(date);
  //       final pressureBaseLine = pressureBaseLineMap["baseLine"];
  //       if (pressureBaseLine != 0 &&
  //           data.wearStatus == 1 &&
  //           data.chargeStatus == 0) {
  //         if (previousData == null) {
  //           previousData = data;
  //           previousSteps = data.step;
  //           continue;
  //         }

  //         final previousTimestamp = previousData!.timeStamp;
  //         final timeDifference =
  //             Duration(milliseconds: data.timeStamp - previousTimestamp);

  //         if (timeDifference.inMinutes >= 4 && timeDifference.inMinutes <= 6) {
  //           if ((data.step - previousSteps!) > 500) {
  //             continue;
  //           }
  //         }

  //         // 更新前一次数据
  //         previousData = data;
  //         previousSteps = data.step;
  //         if (count == 0) {
  //           motionSum = data.motionDetectionCount;
  //           hrvaSum = data.hrv.toDouble();
  //           initialTimestamp = data.timeStamp;
  //         } else {
  //           hrvaSum += data.hrv.toDouble();
  //           motionSum += data.motionDetectionCount;
  //         }
  //         count++;

  //         if (count == 3) {
  //           final lastTimestamp = data.timeStamp;
  //           final timeWindow =
  //               Duration(milliseconds: lastTimestamp - initialTimestamp);
  //           if (timeWindow.inMinutes <= 15) {
  //             final pressure = hrvaSum / count;
  //             final stressLevel =
  //                 classifyStressLevel(pressure, pressureBaseLine);
  //             classifiedDataMap[date] ??= [];
  //             classifiedDataMap[date]!.add({
  //               'timeStamp': data.timeStamp,
  //               'stressLevel': stressLevel,
  //               'baseLine': pressureBaseLine,
  //               'pressure': pressure,
  //               'motionSum': motionSum,
  //               'motionType': getMotionType(motionSum),
  //             });

  //             count = 0;
  //             hrvaSum = 0.0;
  //             motionSum = 0;
  //             initialTimestamp = 0;
  //           } else {
  //             count = 1;
  //             hrvaSum = data.hrv.toDouble();
  //             initialTimestamp = data.timeStamp;
  //           }
  //         }
  //       }
  //     }
  //     return Future.value(null);
  //   }).toList();
  //   await Future.wait(future);

  //   debugPrint("classifiedDataMap 计算完成");
  //   classifiedDataMap.forEach((date, dataList) async {
  //     PressureDb pressureRecord = PressureDb(
  //       timeStamp: 0, // 我们将在最后填充正确的最新时间戳
  //       stressZoneList: [],
  //       engagementZoneList: [],
  //       relaxationZoneList: [],
  //       recoveryZoneList: [],
  //       pressureBaseLine: 0.0,
  //       extremelyLowMotionList: [],
  //       lowMotionList: [],
  //       mediumMotionList: [],
  //       highMotionList: [],
  //       allMotionList: [],
  //       allZoneList: {},
  //     );
  //     debugPrint("date=$date dataList=$dataList");
  //     if (dataList.isNotEmpty) {
  //       int timeZoneCounter = 1;
  //       Map<int, List<Map<String, dynamic>>> allZoneList = {};
  //       final timestampInMs = date.millisecondsSinceEpoch;
  //       pressureRecord.timeStamp = timestampInMs;
  //       pressureRecord.pressureBaseLine = dataList[0]['baseLine'];
  //       for (int i = 0; i < dataList.length; i++) {
  //         final Map<String, dynamic> item = dataList[i];
  //         final trainingZone = item['stressLevel'];
  //         final motionType = item['motionType'];
  //         final int currentTimestamp = item['timeStamp'];
  //         allZoneList[timeZoneCounter] ??= [];
  //         allZoneList[timeZoneCounter]!.add({
  //           "timeStamp": item['timeStamp'],
  //           "stressLevel": item['stressLevel'],
  //           "pressure": item['pressure'],
  //           "timeZone": timeZoneCounter,
  //           "dashedLine": false,
  //         });

  //         if (i < dataList.length - 1) {
  //           final nextItem = dataList[i + 1];
  //           final int nextTimestamp = nextItem['timeStamp'];
  //           final Duration difference =
  //               Duration(milliseconds: nextTimestamp - currentTimestamp);

  //           if (difference.inHours >= 2) {
  //             timeZoneCounter++;
  //           } else if (difference.inMinutes > 18) {
  //             allZoneList[timeZoneCounter]!.last['dashedLine'] = true;
  //           }
  //         }
  //         pressureRecord.allZoneList = allZoneList;
  //         pressureRecord.allMotionList.add({
  //           "timeStamp": item['timeStamp'],
  //           "motionType": item['motionType'],
  //           "motionSum": item['motionSum'],
  //         });

  //         switch (TrainingZoneInt.fromInt(trainingZone)) {
  //           case TrainingZone.StressZone:
  //             pressureRecord.stressZoneList.add({
  //               "timeStamp": item['timeStamp'],
  //               "stressLevel": item['stressLevel'],
  //               "pressure": item['pressure'],
  //             });
  //             break;
  //           case TrainingZone.EngagementZone:
  //             pressureRecord.engagementZoneList.add({
  //               "timeStamp": item['timeStamp'],
  //               "stressLevel": item['stressLevel'],
  //               "pressure": item['pressure'],
  //             });
  //             break;
  //           case TrainingZone.RelaxationZone:
  //             pressureRecord.relaxationZoneList.add({
  //               "timeStamp": item['timeStamp'],
  //               "stressLevel": item['stressLevel'],
  //               "pressure": item['pressure'],
  //             });
  //             break;
  //           case TrainingZone.RecoveryZone:
  //             pressureRecord.recoveryZoneList.add({
  //               "timeStamp": item['timeStamp'],
  //               "stressLevel": item['stressLevel'],
  //               "pressure": item['pressure'],
  //             });
  //             break;
  //           default:
  //             // 不应该发生，但可以在此处进行错误处理或者记录日志
  //             break;
  //         }
  //         switch (MotionTypeInt.fromInt(motionType)) {
  //           case MotionType.ExtremelyLow:
  //             pressureRecord.extremelyLowMotionList.add({
  //               "timeStamp": item['timeStamp'],
  //               "motionType": item['motionType'],
  //               "motionSum": item['motionSum'],
  //             });
  //             break;
  //           case MotionType.Low:
  //             pressureRecord.lowMotionList.add({
  //               "timeStamp": item['timeStamp'],
  //               "motionType": item['motionType'],
  //               "motionSum": item['motionSum'],
  //             });
  //             break;
  //           case MotionType.Medium:
  //             pressureRecord.mediumMotionList.add({
  //               "timeStamp": item['timeStamp'],
  //               "motionType": item['motionType'],
  //               "motionSum": item['motionSum'],
  //             });
  //             break;
  //           case MotionType.High:
  //             pressureRecord.highMotionList.add({
  //               "timeStamp": item['timeStamp'],
  //               "motionType": item['motionType'],
  //               "motionSum": item['motionSum'],
  //             });
  //             break;
  //           default:
  //             // 不应该发生，但可以在此处进行错误处理或者记录日志
  //             break;
  //         }
  //       }
  //       await _pressureModel.addPressure(pressureRecord);
  //       pressureRecord = PressureDb(
  //         timeStamp: 0, // 我们将在最后填充正确的最新时间戳
  //         stressZoneList: [],
  //         engagementZoneList: [],
  //         relaxationZoneList: [],
  //         recoveryZoneList: [],
  //         pressureBaseLine: 0.0,
  //         extremelyLowMotionList: [],
  //         lowMotionList: [],
  //         mediumMotionList: [],
  //         highMotionList: [],
  //         allMotionList: [],
  //         allZoneList: {},
  //       );
  //     }
  //   });
  // }

  Future<List<PressureDb>> getPressureDataByDate(DateTime date) async {
    return await _pressureModel.getPressureDataByDate(date);
  }

  // 定义分类压力等级的方法
  int classifyStressLevel(double averageHRV, double pressureBaseLine) {
    // 这里仅为示例，实际需要根据您的区间规则进行准确分类
    if (10 < averageHRV && averageHRV <= pressureBaseLine * 0.6) {
      return TrainingZone.StressZone.value;
    } else if (pressureBaseLine * 0.6 < averageHRV &&
        averageHRV <= pressureBaseLine) {
      return TrainingZone.EngagementZone.value;
    } else if (pressureBaseLine > averageHRV &&
        averageHRV <= pressureBaseLine * 1.5) {
      return TrainingZone.RelaxationZone.value;
    } else if (averageHRV > pressureBaseLine * 1.5) {
      return TrainingZone.RecoveryZone.value;
    }
    return TrainingZone.Unknown.value;
  }

  //定义motionType的方法 根据motionSum的值来判断 0-100 为极低 101-500 为低 501-1000 为中 1001以上 为高
  int getMotionType(int motionSum) {
    if (0 <= motionSum && motionSum <= 100) {
      return MotionType.ExtremelyLow.value;
    } else if (101 <= motionSum && motionSum <= 500) {
      return MotionType.Low.value;
    } else if (501 <= motionSum && motionSum <= 1000) {
      return MotionType.Medium.value;
    } else if (motionSum >= 1001) {
      return MotionType.High.value;
    }
    return MotionType.Unknown.value;
  }

  Future<(List, List)> dealHistoryData(List<HistoryDb> historyArr) async {
    var sleepArray = [];
    var hrArray = [];
    historyArr.forEach((data) {
      var isBadData = false;
      if (data.rawHr == null) {
        isBadData = false;
      } else if (data.rawHr!.length == 3 &&
          data.rawHr![0] == 200 &&
          data.rawHr![1] == 200 &&
          data.rawHr![2] == 200) {
        isBadData = true;
      }
      // debugPrint("data[heartRate]=${data["heartRate"]}  data[wearStatus]=${data["wearStatus"]} data[chargeStatus]=${data["chargeStatus"]}");
      if (data.heartRate >= 50 &&
          data.heartRate <= 175 &&
          data.wearStatus == 1 &&
          data.chargeStatus == 0 &&
          !isBadData) {
        sleepArray.add({
          "ts": data.timeStamp,
          "hr": data.heartRate,
          "hrv": data.hrv,
          "motion": data.motionDetectionCount,
          "steps": data.step,
          "ox": data.ox
        });
      }
      if (data.heartRate >= 60 &&
          data.heartRate <= 175 &&
          data.wearStatus == 1 &&
          data.chargeStatus == 0 &&
          !isBadData) {
        hrArray.add({
          "ts": data.timeStamp,
          "hr": data.heartRate,
        });
      }
    });
    return (sleepArray, hrArray);
  }
}
