// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pressure_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PressureDbAdapter extends TypeAdapter<PressureDb> {
  @override
  final int typeId = 3;

  @override
  PressureDb read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PressureDb(
      timeStamp: fields[0] as int,
      stressZoneList: (fields[1] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      engagementZoneList: (fields[2] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      relaxationZoneList: (fields[3] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      recoveryZoneList: (fields[4] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      pressureBaseLine: fields[5] as double,
      extremelyLowMotionList: (fields[6] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      lowMotionList: (fields[7] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      mediumMotionList: (fields[8] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      highMotionList: (fields[9] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      allZoneList: (fields[10] as Map).map((dynamic k, dynamic v) => MapEntry(
          k as int,
          (v as List)
              .map((dynamic e) => (e as Map).cast<String, dynamic>())
              .toList())),
      allMotionList: (fields[11] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, PressureDb obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.timeStamp)
      ..writeByte(1)
      ..write(obj.stressZoneList)
      ..writeByte(2)
      ..write(obj.engagementZoneList)
      ..writeByte(3)
      ..write(obj.relaxationZoneList)
      ..writeByte(4)
      ..write(obj.recoveryZoneList)
      ..writeByte(5)
      ..write(obj.pressureBaseLine)
      ..writeByte(6)
      ..write(obj.extremelyLowMotionList)
      ..writeByte(7)
      ..write(obj.lowMotionList)
      ..writeByte(8)
      ..write(obj.mediumMotionList)
      ..writeByte(9)
      ..write(obj.highMotionList)
      ..writeByte(10)
      ..write(obj.allZoneList)
      ..writeByte(11)
      ..write(obj.allMotionList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PressureDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
