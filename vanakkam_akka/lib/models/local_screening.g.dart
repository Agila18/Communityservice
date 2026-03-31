// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_screening.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalScreeningAdapter extends TypeAdapter<LocalScreening> {
  @override
  final int typeId = 1;

  @override
  LocalScreening read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalScreening(
      id: fields[0] as String,
      userId: fields[1] as String,
      timestamp: fields[2] as DateTime,
      module: fields[3] as String,
      symptomsReported: fields[4] as String?,
      aiResponse: fields[5] as String?,
      riskLevel: fields[6] as String,
      recommendation: fields[7] as String?,
      referralNeeded: fields[8] as bool,
      isSynced: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LocalScreening obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.module)
      ..writeByte(4)
      ..write(obj.symptomsReported)
      ..writeByte(5)
      ..write(obj.aiResponse)
      ..writeByte(6)
      ..write(obj.riskLevel)
      ..writeByte(7)
      ..write(obj.recommendation)
      ..writeByte(8)
      ..write(obj.referralNeeded)
      ..writeByte(9)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalScreeningAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
