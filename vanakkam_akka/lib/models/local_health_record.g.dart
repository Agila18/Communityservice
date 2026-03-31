// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_health_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalHealthRecordAdapter extends TypeAdapter<LocalHealthRecord> {
  @override
  final int typeId = 2;

  @override
  LocalHealthRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalHealthRecord(
      id: fields[0] as String,
      userId: fields[1] as String,
      recordType: fields[2] as String,
      imagePath: fields[3] as String?,
      imageUrl: fields[4] as String?,
      ocrText: fields[5] as String?,
      aiExplanation: fields[6] as String?,
      title: fields[7] as String?,
      notes: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      isSynced: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LocalHealthRecord obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.recordType)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.ocrText)
      ..writeByte(6)
      ..write(obj.aiExplanation)
      ..writeByte(7)
      ..write(obj.title)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalHealthRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
