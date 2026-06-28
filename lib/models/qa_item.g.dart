// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qa_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QAItemAdapter extends TypeAdapter<QAItem> {
  @override
  final int typeId = 0;

  @override
  QAItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QAItem(
      question: fields[0] as String,
      answer: fields[1] as String?,
      isAnswered: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, QAItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.question)
      ..writeByte(1)
      ..write(obj.answer)
      ..writeByte(2)
      ..write(obj.isAnswered);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QAItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
