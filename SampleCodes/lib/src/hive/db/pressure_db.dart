import 'package:hive/hive.dart';

part 'pressure_db.g.dart';
part 'common/pressureCommon.dart';

@HiveType(typeId: 3)
class PressureDb extends HiveObject {
  @HiveField(0)
  int timeStamp;
  @HiveField(1)
  List<Map<String, dynamic>> stressZoneList;
  @HiveField(2)
  List<Map<String, dynamic>> engagementZoneList;
  @HiveField(3)
  List<Map<String, dynamic>> relaxationZoneList;
  @HiveField(4)
  List<Map<String, dynamic>> recoveryZoneList;
  @HiveField(5)
  double pressureBaseLine;
  @HiveField(6)
  List<Map<String, dynamic>> extremelyLowMotionList;
  @HiveField(7)
  List<Map<String, dynamic>> lowMotionList;
  @HiveField(8)
  List<Map<String, dynamic>> mediumMotionList;
  @HiveField(9)
  List<Map<String, dynamic>> highMotionList;
  @HiveField(10)
  Map<int, List<Map<String, dynamic>>> allZoneList;
  @HiveField(11)
  List<Map<String, dynamic>> allMotionList;

  PressureDb(
      {required this.timeStamp,
      required this.stressZoneList,
      required this.engagementZoneList,
      required this.relaxationZoneList,
      required this.recoveryZoneList,
      required this.pressureBaseLine,
      required this.extremelyLowMotionList,
      required this.lowMotionList,
      required this.mediumMotionList,
      required this.highMotionList,
      required this.allZoneList,
      required this.allMotionList});

  @override
  String toString() {
    return 'PressureDb{timeStamp: $timeStamp, stressZoneList: $stressZoneList, engagementZoneList: $engagementZoneList, relaxationZoneList: $relaxationZoneList, recoveryZoneList: $recoveryZoneList, pressureBaseLine: $pressureBaseLine, extremelyLowMotionList: $extremelyLowMotionList, lowMotionList: $lowMotionList, mediumMotionList: $mediumMotionList, highMotionList: $highMotionList, allZoneList: $allZoneList, allMotionList: $allMotionList}';
  }

  Map<String, dynamic> toJson() {
    return {
      'timeStamp': timeStamp,
      'stressZoneList': stressZoneList,
      'engagementZoneList': engagementZoneList,
      'relaxationZoneList': relaxationZoneList,
      'recoveryZoneList': recoveryZoneList,
      'pressureBaseLine': pressureBaseLine,
      'extremelyLowMotionList': extremelyLowMotionList,
      'lowMotionList': lowMotionList,
      'mediumMotionList': mediumMotionList,
      'highMotionList': highMotionList,
      'allZoneList': allZoneList,
      'allMotionList': allMotionList,
    };
  }
}
