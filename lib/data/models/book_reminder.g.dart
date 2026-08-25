// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookReminderAdapter extends TypeAdapter<BookReminder> {
  @override
  final int typeId = 4;

  @override
  BookReminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookReminder(
      id: fields[0] as String,
      label: fields[1] as String,
      hour: fields[2] as int,
      minute: fields[3] as int,
      enabled: fields[4] as bool,
      bookID: fields[5] as int,
      daysOfWeek: (fields[6] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, BookReminder obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.hour)
      ..writeByte(3)
      ..write(obj.minute)
      ..writeByte(4)
      ..write(obj.enabled)
      ..writeByte(5)
      ..write(obj.bookID)
      ..writeByte(6)
      ..write(obj.daysOfWeek);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
