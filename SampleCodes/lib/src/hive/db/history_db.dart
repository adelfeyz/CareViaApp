import 'package:hive_flutter/adapters.dart';
part 'history_db.g.dart';

@HiveType(typeId: 1)
class HistoryDb extends HiveObject {
  @HiveField(0)
  int timeStamp;
  @HiveField(1)
  int heartRate;
  @HiveField(2)
  int motionDetectionCount;
  @HiveField(3)
  int detectionMode;
  @HiveField(4)
  int wearStatus;
  @HiveField(5)
  int chargeStatus;
  @HiveField(6)
  int uuid;
  @HiveField(7)
  int hrv;
  @HiveField(8)
  double temperature;
  @HiveField(9)
  int step;
  @HiveField(10)
  int ox;
  @HiveField(11)
  List<int>? rawHr;
  @HiveField(12)
  String? sportsMode;
  @HiveField(13)
  int respiratoryRate;
  HistoryDb({
    required this.timeStamp,
    required this.heartRate,
    required this.motionDetectionCount,
    required this.detectionMode,
    required this.wearStatus,
    required this.chargeStatus,
    required this.uuid,
    required this.hrv,
    required this.temperature,
    required this.step,
    required this.ox,
    required this.rawHr,
    required this.sportsMode,
    required this.respiratoryRate,
  });

  @override
  String toString() {
    return 'HistoryDb(timeStamp: $timeStamp, heartRate: $heartRate, motionDetectionCount: $motionDetectionCount, detectionMode: $detectionMode, wearStatus: $wearStatus, chargeStatus: $chargeStatus, uuid: $uuid, hrv: $hrv, temperature: $temperature, step: $step, ox: $ox, rawHr: $rawHr, sportsMode: $sportsMode, respiratoryRate: $respiratoryRate)';
  }

  Map<String, dynamic> toJson() {
    return {
      "timeStamp": timeStamp,
      "heartRate": heartRate,
      "motionDetectionCount": motionDetectionCount,
      "detectionMode": detectionMode,
      "wearStatus": wearStatus,
      "chargeStatus": chargeStatus,
      "uuid": uuid,
      "hrv": hrv,
      "temperature": temperature,
      "step": step,
      "ox": ox,
      "rawHr": rawHr,
      "sportsMode": sportsMode,
      "respiratoryRate": respiratoryRate
    };
  }
}
