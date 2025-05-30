// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_episode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepEpisodeAdapter extends TypeAdapter<SleepEpisode> {
  @override
  final int typeId = 10;

  @override
  SleepEpisode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepEpisode(
      start: fields[0] as DateTime,
      end: fields[1] as DateTime,
      deepMin: fields[2] as int,
      lightMin: fields[3] as int,
      remMin: fields[4] as int,
      wakeMin: fields[5] as int,
      efficiency: fields[6] as double,
      avgRespRate: fields[7] as double,
      avgSpO2: fields[8] as double,
      timeline: (fields[9] as List).cast<SleepStage>(),
    );
  }

  @override
  void write(BinaryWriter writer, SleepEpisode obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end)
      ..writeByte(2)
      ..write(obj.deepMin)
      ..writeByte(3)
      ..write(obj.lightMin)
      ..writeByte(4)
      ..write(obj.remMin)
      ..writeByte(5)
      ..write(obj.wakeMin)
      ..writeByte(6)
      ..write(obj.efficiency)
      ..writeByte(7)
      ..write(obj.avgRespRate)
      ..writeByte(8)
      ..write(obj.avgSpO2)
      ..writeByte(9)
      ..write(obj.timeline);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepEpisodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
