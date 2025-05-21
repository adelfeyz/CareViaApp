import 'package:hive/hive.dart';
part 'ring_settings.g.dart';

@HiveType(typeId: 0)
class RingSettings {
  @HiveField(0)
  String deviceId;
  @HiveField(1)
  String name;
  @HiveField(2)
  String color;
  @HiveField(3)
  int size;
  @HiveField(4)
  DateTime savedAt;

  RingSettings({
    required this.deviceId,
    required this.name,
    required this.color,
    required this.size,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();
} 