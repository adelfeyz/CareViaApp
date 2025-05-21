// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryDbAdapter extends TypeAdapter<HistoryDb> {
  @override
  final int typeId = 1;

  @override
  HistoryDb read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryDb(
      timeStamp: fields[0] as int,
      heartRate: fields[1] as int,
      motionDetectionCount: fields[2] as int,
      detectionMode: fields[3] as int,
      wearStatus: fields[4] as int,
      chargeStatus: fields[5] as int,
      uuid: fields[6] as int,
      hrv: fields[7] as int,
      temperature: fields[8] as double,
      step: fields[9] as int,
      ox: fields[10] as int,
      rawHr: (fields[11] as List?)?.cast<int>(),
      sportsMode: fields[12] as String?,
      respiratoryRate: fields[13] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryDb obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.timeStamp)
      ..writeByte(1)
      ..write(obj.heartRate)
      ..writeByte(2)
      ..write(obj.motionDetectionCount)
      ..writeByte(3)
      ..write(obj.detectionMode)
      ..writeByte(4)
      ..write(obj.wearStatus)
      ..writeByte(5)
      ..write(obj.chargeStatus)
      ..writeByte(6)
      ..write(obj.uuid)
      ..writeByte(7)
      ..write(obj.hrv)
      ..writeByte(8)
      ..write(obj.temperature)
      ..writeByte(9)
      ..write(obj.step)
      ..writeByte(10)
      ..write(obj.ox)
      ..writeByte(11)
      ..write(obj.rawHr)
      ..writeByte(12)
      ..write(obj.sportsMode)
      ..writeByte(13)
      ..write(obj.respiratoryRate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
