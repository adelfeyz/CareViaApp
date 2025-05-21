// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepDbAdapter extends TypeAdapter<SleepDb> {
  @override
  final int typeId = 2;

  @override
  SleepDb read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepDb(
      startTimeStamp: fields[0] as int,
      endTimeStamp: fields[1] as int,
      ftcAvg: fields[2] as double,
      avgHrv: fields[3] as int,
      duration: fields[4] as int,
      startTime: fields[5] as String,
      endTime: fields[6] as String,
      deepSleep: fields[7] as String,
      deepSleepTime: fields[8] as int,
      lightSleep: fields[9] as String,
      lightSleepTime: fields[10] as int,
      remSleep: fields[11] as String,
      remSleepTime: fields[12] as int,
      wakeSleep: fields[13] as String,
      wakeSleepTime: fields[14] as int,
      napSleep: fields[15] as String,
      napSleepTime: fields[16] as int,
      ftcBase: fields[27] as double,
      nap: fields[31] as bool,
      isFtcOutlier: fields[32] == null ? false : fields[32] as bool,
      pressureBaseLine: (fields[33] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, SleepDb obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.startTimeStamp)
      ..writeByte(1)
      ..write(obj.endTimeStamp)
      ..writeByte(2)
      ..write(obj.ftcAvg)
      ..writeByte(3)
      ..write(obj.avgHrv)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.startTime)
      ..writeByte(6)
      ..write(obj.endTime)
      ..writeByte(7)
      ..write(obj.deepSleep)
      ..writeByte(8)
      ..write(obj.deepSleepTime)
      ..writeByte(9)
      ..write(obj.lightSleep)
      ..writeByte(10)
      ..write(obj.lightSleepTime)
      ..writeByte(11)
      ..write(obj.remSleep)
      ..writeByte(12)
      ..write(obj.remSleepTime)
      ..writeByte(13)
      ..write(obj.wakeSleep)
      ..writeByte(14)
      ..write(obj.wakeSleepTime)
      ..writeByte(15)
      ..write(obj.napSleep)
      ..writeByte(16)
      ..write(obj.napSleepTime)
      ..writeByte(27)
      ..write(obj.ftcBase)
      ..writeByte(31)
      ..write(obj.nap)
      ..writeByte(32)
      ..write(obj.isFtcOutlier)
      ..writeByte(33)
      ..write(obj.pressureBaseLine);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
