// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_cycle_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalCycleEntryAdapter extends TypeAdapter<LocalCycleEntry> {
  @override
  final int typeId = 3;

  @override
  LocalCycleEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalCycleEntry(
      id: fields[0] as String,
      userId: fields[1] as String,
      startDate: fields[2] as DateTime,
      endDate: fields[3] as DateTime?,
      flowLevel: fields[4] as String?,
      symptoms: fields[5] as String?,
      notes: fields[6] as String?,
      createdAt: fields[7] as DateTime,
      isSynced: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LocalCycleEntry obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.flowLevel)
      ..writeByte(5)
      ..write(obj.symptoms)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalCycleEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
