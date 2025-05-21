import 'package:hive/hive.dart';
part 'sleep_db.g.dart';

@HiveType(typeId: 2)
class SleepDb extends HiveObject {
  @HiveField(0)
  int startTimeStamp;
  @HiveField(1)
  int endTimeStamp;
  @HiveField(2)
  double ftcAvg; //计算睡眠的平均值，睡眠时长大等于3小时才计算,苏醒温度不参与计算，否则为0
  @HiveField(3)
  int avgHrv;
  @HiveField(4)
  int duration;
  @HiveField(5)
  String startTime;
  @HiveField(6)
  String endTime;
  @HiveField(7)
  String deepSleep;
  @HiveField(8)
  int deepSleepTime;
  @HiveField(9)
  String lightSleep;
  @HiveField(10)
  int lightSleepTime;
  @HiveField(11)
  String remSleep;
  @HiveField(12)
  int remSleepTime;
  @HiveField(13)
  String wakeSleep;
  @HiveField(14)
  int wakeSleepTime;
  @HiveField(15)
  String napSleep;
  @HiveField(16)
  int napSleepTime;
  // @HiveField(17)
  // String sleepPeriodJSON;
  // @HiveField(18)
  // dynamic heartRateImmersion;
  // @HiveField(19)
  // dynamic restingHeartRate;
  // @HiveField(20)
  // dynamic respiratoryRate;
  // @HiveField(21)
  // dynamic oxygenSaturation;
  // @HiveField(22)
  // String account;
  // @HiveField(23)
  // double avgHr;
  // @HiveField(24)
  // int maxHrv;
  // @HiveField(25)
  // double avgBr;
  // @HiveField(26)
  // double avgSpo2;
  @HiveField(27)
  double ftcBase;
  // @HiveField(28)
  // double ftcMax;
  // @HiveField(29)
  // double ftcMin;
  // @HiveField(30)
  // double efficiency;
  @HiveField(31)
  bool nap;
  @HiveField(32, defaultValue: false)
  bool isFtcOutlier;
  @HiveField(33)
  Map<String, dynamic> pressureBaseLine;

  SleepDb(
      {required this.startTimeStamp,
      required this.endTimeStamp,
      required this.ftcAvg,
      required this.avgHrv,
      required this.duration,
      required this.startTime,
      required this.endTime,
      required this.deepSleep,
      required this.deepSleepTime,
      required this.lightSleep,
      required this.lightSleepTime,
      required this.remSleep,
      required this.remSleepTime,
      required this.wakeSleep,
      required this.wakeSleepTime,
      required this.napSleep,
      required this.napSleepTime,
      // required this.sleepPeriodJSON,
      // required this.heartRateImmersion,
      // required this.restingHeartRate,
      // required this.respiratoryRate,
      // required this.oxygenSaturation,
      // required this.account,
      // required this.avgHr,
      // required this.maxHrv,
      // required this.avgBr,
      // required this.avgSpo2,
      required this.ftcBase,
      // required this.ftcMax,
      // required this.ftcMin,
      // required this.efficiency,
      required this.nap,
      required this.isFtcOutlier,
      required this.pressureBaseLine});

  @override
  String toString() {
    return 'SleepDb(startTimeStamp: $startTimeStamp, endTimeStamp: $endTimeStamp, ftcAvg: $ftcAvg, avgHrv: $avgHrv,ftcBase=$ftcBase, duration: $duration, startTime: $startTime, endTime: $endTime, deepSleep: $deepSleep, deepSleepTime: $deepSleepTime, lightSleep: $lightSleep, lightSleepTime: $lightSleepTime, remSleep: $remSleep, remSleepTime: $remSleepTime, wakeSleep: $wakeSleep, wakeSleepTime: $wakeSleepTime, napSleep: $napSleep, napSleepTime: $napSleepTime, nap: $nap, isFtcOutlier: $isFtcOutlier, pressureBaseLine: $pressureBaseLine)';
  }

  Map<String, dynamic> toJson() {
    return {
      "startTimeStamp": startTimeStamp,
      "endTimeStamp": endTimeStamp, 
      "ftcAvg": ftcAvg,
      "avgHrv": avgHrv,
      "duration": duration,
      "startTime": startTime, 
      "endTime": endTime,
      "deepSleep": deepSleep,
      "deepSleepTime": deepSleepTime,
      "lightSleep": lightSleep,
      "lightSleepTime": lightSleepTime,
      "remSleep": remSleep,
      "remSleepTime": remSleepTime,
      "wakeSleep": wakeSleep,
      "wakeSleepTime": wakeSleepTime,
      "napSleep": napSleep,
      "napSleepTime": napSleepTime,
      "nap": nap,
      "isFtcOutlier": isFtcOutlier,
      "pressureBaseLine": pressureBaseLine
    };  
  }
}
