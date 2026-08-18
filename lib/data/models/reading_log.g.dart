// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingLogAdapter extends TypeAdapter<ReadingLog> {
  @override
  final int typeId = 2;

  @override
  ReadingLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingLog(
      id: fields[0] as String,
      bookId: fields[1] as String,
      fromPage: fields[2] as int,
      toPage: fields[3] as int,
      timeStamp: fields[4] as DateTime,
      sessionDurationMinutes: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bookId)
      ..writeByte(2)
      ..write(obj.fromPage)
      ..writeByte(3)
      ..write(obj.toPage)
      ..writeByte(4)
      ..write(obj.timeStamp)
      ..writeByte(5)
      ..write(obj.sessionDurationMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
