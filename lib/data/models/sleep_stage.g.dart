// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_stage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepStageAdapter extends TypeAdapter<SleepStage> {
  @override
  final int typeId = 12;

  @override
  SleepStage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepStage(
      start: fields[0] as DateTime,
      end: fields[1] as DateTime,
      stage: fields[2] as StageType,
    );
  }

  @override
  void write(BinaryWriter writer, SleepStage obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end)
      ..writeByte(2)
      ..write(obj.stage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepStageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StageTypeAdapter extends TypeAdapter<StageType> {
  @override
  final int typeId = 11;

  @override
  StageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StageType.wake;
      case 1:
        return StageType.light;
      case 2:
        return StageType.deep;
      case 3:
        return StageType.rem;
      default:
        return StageType.wake;
    }
  }

  @override
  void write(BinaryWriter writer, StageType obj) {
    switch (obj) {
      case StageType.wake:
        writer.writeByte(0);
        break;
      case StageType.light:
        writer.writeByte(1);
        break;
      case StageType.deep:
        writer.writeByte(2);
        break;
      case StageType.rem:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
