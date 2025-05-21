part of '../pressure_db.dart';

enum TrainingZone {
  // 压力区间
  StressZone,

  // 投入区间
  EngagementZone,

  // 放松区间
  RelaxationZone,

  // 恢复区间
  RecoveryZone,
  // 未知区间
  Unknown
}

enum MotionType {
  //极低
  ExtremelyLow,
  //低
  Low,
  //中
  Medium,
  //高
  High,
  //未知
  Unknown
}

extension TrainingZoneInt on TrainingZone {
  int get value {
    switch (this) {
      case TrainingZone.StressZone:
        return 0;
      case TrainingZone.EngagementZone:
        return 1;
      case TrainingZone.RelaxationZone:
        return 2;
      case TrainingZone.RecoveryZone:
        return 3;
      default:
        return -1;
    }
  }

  static TrainingZone fromInt(int value) {
    switch (value) {
      case 0:
        return TrainingZone.StressZone;
      case 1:
        return TrainingZone.EngagementZone;
      case 2:
        return TrainingZone.RelaxationZone;
      case 3:
        return TrainingZone.RecoveryZone;
    }
    return TrainingZone.Unknown;
  }
}

extension MotionTypeInt on MotionType {
  int get value {
    switch (this) {
      case MotionType.ExtremelyLow:
        return 0;
      case MotionType.Low:
        return 1;
      case MotionType.Medium:
        return 2;
      case MotionType.High:
        return 3;
      default:
        return -1;
    }
  }

  static MotionType fromInt(int value) {
    switch (value) {
      case 0:
        return MotionType.ExtremelyLow;
      case 1:
        return MotionType.Low;
      case 2:
        return MotionType.Medium;
      case 3:
        return MotionType.High;
    }
    return MotionType.Unknown;
  }
}
