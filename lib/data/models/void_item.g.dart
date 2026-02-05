// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'void_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VoidItemAdapter extends TypeAdapter<VoidItem> {
  @override
  final int typeId = 0;

  @override
  VoidItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VoidItem(
      id: fields[0] as String,
      type: fields[1] as String,
      content: fields[2] as String,
      title: fields[3] as String,
      summary: fields[4] as String,
      imageUrl: fields[5] as String?,
      createdAt: fields[6] as DateTime,
      tags: (fields[7] as List).cast<String>(),
      embedding: (fields[8] as List?)?.cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, VoidItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.summary)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.embedding);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoidItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
