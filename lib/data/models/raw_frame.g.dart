// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_frame.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RawFrameAdapter extends TypeAdapter<RawFrame> {
  @override
  final int typeId = 2;

  @override
  RawFrame read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RawFrame(
      timeStamp: fields[0] as int,
      heartRate: fields[1] as int,
      motionDetectionCount: fields[2] as int,
      detectionMode: fields[3] as int,
      sportsMode: fields[4] as String,
      wearStatus: fields[5] as int,
      chargeStatus: fields[6] as int,
      uuid: fields[7] as int,
      hrv: fields[8] as int?,
      temperature: fields[9] as double?,
      step: fields[10] as int,
      reStep: fields[11] as int,
      ox: fields[12] as int,
      rawHr: fields[13] as int?,
      respiratoryRate: fields[14] as int?,
      batteryLevel: fields[15] as int,
      kind: fields[16] as RawKind?,
      payload: fields[17] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, RawFrame obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.timeStamp)
      ..writeByte(1)
      ..write(obj.heartRate)
      ..writeByte(2)
      ..write(obj.motionDetectionCount)
      ..writeByte(3)
      ..write(obj.detectionMode)
      ..writeByte(4)
      ..write(obj.sportsMode)
      ..writeByte(5)
      ..write(obj.wearStatus)
      ..writeByte(6)
      ..write(obj.chargeStatus)
      ..writeByte(7)
      ..write(obj.uuid)
      ..writeByte(8)
      ..write(obj.hrv)
      ..writeByte(9)
      ..write(obj.temperature)
      ..writeByte(10)
      ..write(obj.step)
      ..writeByte(11)
      ..write(obj.reStep)
      ..writeByte(12)
      ..write(obj.ox)
      ..writeByte(13)
      ..write(obj.rawHr)
      ..writeByte(14)
      ..write(obj.respiratoryRate)
      ..writeByte(15)
      ..write(obj.batteryLevel)
      ..writeByte(16)
      ..write(obj.kind)
      ..writeByte(17)
      ..write(obj.payload);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RawFrameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RawKindAdapter extends TypeAdapter<RawKind> {
  @override
  final int typeId = 1;

  @override
  RawKind read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RawKind.history;
      case 1:
        return RawKind.ppgIrOrGreen;
      case 2:
        return RawKind.ppgRed;
      case 3:
        return RawKind.battery;
      case 4:
        return RawKind.unknown;
      default:
        return RawKind.history;
    }
  }

  @override
  void write(BinaryWriter writer, RawKind obj) {
    switch (obj) {
      case RawKind.history:
        writer.writeByte(0);
        break;
      case RawKind.ppgIrOrGreen:
        writer.writeByte(1);
        break;
      case RawKind.ppgRed:
        writer.writeByte(2);
        break;
      case RawKind.battery:
        writer.writeByte(3);
        break;
      case RawKind.unknown:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RawKindAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
