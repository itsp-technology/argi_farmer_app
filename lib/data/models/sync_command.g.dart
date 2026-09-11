// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_command.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncCommandAdapter extends TypeAdapter<SyncCommand> {
  @override
  final int typeId = 0;

  @override
  SyncCommand read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncCommand(
      commandId: fields[0] as String,
      entityId: fields[1] as String,
      attributeName: fields[2] as String,
      payloadValue: fields[3] as String,
      queuedAt: fields[4] as DateTime,
      retryCount: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SyncCommand obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.commandId)
      ..writeByte(1)
      ..write(obj.entityId)
      ..writeByte(2)
      ..write(obj.attributeName)
      ..writeByte(3)
      ..write(obj.payloadValue)
      ..writeByte(4)
      ..write(obj.queuedAt)
      ..writeByte(5)
      ..write(obj.retryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncCommandAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
