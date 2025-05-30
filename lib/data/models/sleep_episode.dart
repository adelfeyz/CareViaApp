import 'package:hive/hive.dart';
import 'sleep_stage.dart';

part 'sleep_episode.g.dart';

@HiveType(typeId: 10)
class SleepEpisode extends HiveObject {
  @HiveField(0)
  DateTime start;

  @HiveField(1)
  DateTime end;

  @HiveField(2)
  int deepMin;

  @HiveField(3)
  int lightMin;

  @HiveField(4)
  int remMin;

  @HiveField(5)
  int wakeMin;

  @HiveField(6)
  double efficiency;

  @HiveField(7)
  double avgRespRate;

  @HiveField(8)
  double avgSpO2;

  @HiveField(9)
  List<SleepStage> timeline;

  SleepEpisode({
    required this.start,
    required this.end,
    required this.deepMin,
    required this.lightMin,
    required this.remMin,
    required this.wakeMin,
    required this.efficiency,
    required this.avgRespRate,
    required this.avgSpO2,
    this.timeline = const [],
  });
} 