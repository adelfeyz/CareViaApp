import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'raw_frame.g.dart';

/// Category of incoming BLE packet. Adjust as needed when you add more [ReceiveType] handlers.
@HiveType(typeId: 1)
enum RawKind {
  @HiveField(0)
  history,
  @HiveField(1)
  ppgIrOrGreen,
  @HiveField(2)
  ppgRed,
  @HiveField(3)
  battery,
  @HiveField(4)
  unknown,
}

/// Low-level, loss-less snapshot of a BLE frame received from the ring.
/// Stores the original bytes so that heavier processing can be executed
/// later or replayed when algorithms evolve.
@HiveType(typeId: 2)
class RawFrame extends HiveObject {
  @HiveField(0)
  final int timeStamp;

  @HiveField(1)
  final int heartRate;

  @HiveField(2)
  final int motionDetectionCount;

  @HiveField(3)
  final int detectionMode;

  @HiveField(4)
  final String sportsMode;

  @HiveField(5)
  final int wearStatus;

  @HiveField(6)
  final int chargeStatus;

  @HiveField(7)
  final int uuid;

  @HiveField(8)
  final int? hrv;

  @HiveField(9)
  final double? temperature;

  @HiveField(10)
  final int step;

  @HiveField(11)
  final int reStep;

  @HiveField(12)
  final int ox;

  @HiveField(13)
  final int? rawHr;

  @HiveField(14)
  final int? respiratoryRate;

  @HiveField(15)
  final int batteryLevel;

  // Legacy fields for backward compatibility
  @HiveField(16)
  final RawKind? kind;

  @HiveField(17)
  final Uint8List? payload;

  RawFrame({
    required this.timeStamp,
    required this.heartRate,
    required this.motionDetectionCount,
    required this.detectionMode,
    required this.sportsMode,
    required this.wearStatus,
    required this.chargeStatus,
    required this.uuid,
    this.hrv,
    this.temperature,
    required this.step,
    required this.reStep,
    required this.ox,
    this.rawHr,
    this.respiratoryRate,
    required this.batteryLevel,
    this.kind,
    this.payload,
  });

  // Factory constructor from legacy format
  factory RawFrame.fromLegacy({
    required int uuid,
    required RawKind kind,
    required Uint8List payload,
  }) {
    return RawFrame(
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      heartRate: 0,
      motionDetectionCount: 0,
      detectionMode: 0,
      sportsMode: '',
      wearStatus: 0,
      chargeStatus: 0,
      uuid: uuid,
      step: 0,
      reStep: 0,
      ox: 0,
      batteryLevel: 0,
      kind: kind,
      payload: payload,
    );
  }

  // Factory constructor from JSON
  factory RawFrame.fromJson(Map<String, dynamic> json) {
    return RawFrame(
      timeStamp: json['timeStamp'] as int,
      heartRate: json['heartRate'] as int,
      motionDetectionCount: json['motionDetectionCount'] as int,
      detectionMode: json['detectionMode'] as int,
      sportsMode: json['sportsMode'] as String,
      wearStatus: json['wearStatus'] as int,
      chargeStatus: json['chargeStatus'] as int,
      uuid: json['uuid'] as int,
      hrv: json['hrv'] as int?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      step: json['step'] as int,
      reStep: json['reStep'] as int,
      ox: json['ox'] as int,
      rawHr: json['rawHr'] as int?,
      respiratoryRate: json['respiratoryRate'] as int?,
      batteryLevel: json['batteryLevel'] as int,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'timeStamp': timeStamp,
      'heartRate': heartRate,
      'motionDetectionCount': motionDetectionCount,
      'detectionMode': detectionMode,
      'sportsMode': sportsMode,
      'wearStatus': wearStatus,
      'chargeStatus': chargeStatus,
      'uuid': uuid,
      'hrv': hrv,
      'temperature': temperature,
      'step': step,
      'reStep': reStep,
      'ox': ox,
      'rawHr': rawHr,
      'respiratoryRate': respiratoryRate,
      'batteryLevel': batteryLevel,
    };
  }

  // Create a copy with optional updates
  RawFrame copyWith({
    int? timeStamp,
    int? heartRate,
    int? motionDetectionCount,
    int? detectionMode,
    String? sportsMode,
    int? wearStatus,
    int? chargeStatus,
    int? uuid,
    int? hrv,
    double? temperature,
    int? step,
    int? reStep,
    int? ox,
    int? rawHr,
    int? respiratoryRate,
    int? batteryLevel,
    RawKind? kind,
    Uint8List? payload,
  }) {
    return RawFrame(
      timeStamp: timeStamp ?? this.timeStamp,
      heartRate: heartRate ?? this.heartRate,
      motionDetectionCount: motionDetectionCount ?? this.motionDetectionCount,
      detectionMode: detectionMode ?? this.detectionMode,
      sportsMode: sportsMode ?? this.sportsMode,
      wearStatus: wearStatus ?? this.wearStatus,
      chargeStatus: chargeStatus ?? this.chargeStatus,
      uuid: uuid ?? this.uuid,
      hrv: hrv ?? this.hrv,
      temperature: temperature ?? this.temperature,
      step: step ?? this.step,
      reStep: reStep ?? this.reStep,
      ox: ox ?? this.ox,
      rawHr: rawHr ?? this.rawHr,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      kind: kind ?? this.kind,
      payload: payload ?? this.payload,
    );
  }

  // Validate required fields
  bool isValid() {
    return timeStamp > 0 &&
           uuid > 0 &&
           heartRate >= 0 &&
           motionDetectionCount >= 0 &&
           detectionMode >= 0 &&
           wearStatus >= 0 &&
           chargeStatus >= 0 &&
           step >= 0 &&
           reStep >= 0 &&
           ox >= 0 &&
           batteryLevel >= 0;
  }

  // Get safe values for algorithm processing
  Map<String, dynamic> getSafeValues() {
    return {
      'ts': timeStamp,
      'hr': heartRate,
      'motion': motionDetectionCount,
      'mode': detectionMode,
      'wear': wearStatus,
      'charge': chargeStatus,
      'uuid': uuid,
      'hrv': hrv ?? 0,
      'temp': temperature ?? 0.0,
      'step': step,
      'restep': reStep,
      'ox': ox,
      'rawhr': rawHr ?? 0,
      'resp': respiratoryRate ?? 0,
      'battery': batteryLevel,
    };
  }
} 