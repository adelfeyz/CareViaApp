import 'package:hive/hive.dart';

part 'sleep_stage.g.dart';

@HiveType(typeId: 11)
enum StageType {
  @HiveField(0)
  wake,
  @HiveField(1)
  light,
  @HiveField(2)
  deep,
  @HiveField(3)
  rem
}

@HiveType(typeId: 12)
class SleepStage extends HiveObject {
  @HiveField(0)
  DateTime start;

  @HiveField(1)
  DateTime end;

  @HiveField(2)
  StageType stage;

  SleepStage({
    required this.start,
    required this.end,
    required this.stage,
  });
} 