/// Model representing one historical record coming from ReceiveType.HistoricalData.
class HistorySample {
  final int uuid;
  final DateTime timestamp;
  final int heartRate;
  final int hrv;
  final int oxygen;
  final int step;
  final int motion;
  final double temperature;
  final bool wear;
  final bool charging;
  final bool sportsMode;
  final int respiratoryRate;
  final int battery;

  HistorySample({
    required this.uuid,
    required this.timestamp,
    required this.heartRate,
    required this.hrv,
    required this.oxygen,
    required this.step,
    required this.motion,
    required this.temperature,
    required this.wear,
    required this.charging,
    required this.sportsMode,
    required this.respiratoryRate,
    required this.battery,
  });

  factory HistorySample.fromMap(Map data) {
    int tsRaw = data['timeStamp'] ?? data['timestamp'] ?? 0;
    return HistorySample(
      uuid: data['uuid'] ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          tsRaw > 1000000000000 ? tsRaw : tsRaw * 1000,
          isUtc: true).toLocal(),
      heartRate: data['heartRate'] ?? data['HeartRate'] ?? -1,
      hrv: data['hrv'] ?? 0,
      oxygen: data['ox'] ?? 0,
      step: data['step'] ?? 0,
      motion: data['motionDetectionCount'] ?? 0,
      temperature: (data['temperature'] ?? 0).toDouble(),
      wear: (data['wearStatus'] ?? 0) == 1,
      charging: (data['chargeStatus'] ?? 0) == 1,
      sportsMode: (() {
        final v = data['sportsMode'];
        if (v is bool) return v;
        if (v is int) return v == 1;
        if (v is String) return v.toLowerCase() == 'open';
        return false;
      })(),
      respiratoryRate: data['respiratoryRate'] ?? 0,
      battery: data['batteryLevel'] ?? -1,
    );
  }
} 