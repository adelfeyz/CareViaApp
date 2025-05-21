// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ring_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RingSettingsAdapter extends TypeAdapter<RingSettings> {
  @override
  final int typeId = 0;

  @override
  RingSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RingSettings(
      deviceId: fields[0] as String,
      name: fields[1] as String,
      color: fields[2] as String,
      size: fields[3] as int,
      savedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RingSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.deviceId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.color)
      ..writeByte(3)
      ..write(obj.size)
      ..writeByte(4)
      ..write(obj.savedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RingSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
