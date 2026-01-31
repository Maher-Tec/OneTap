// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 4;

  @override
  Achievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Achievement(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      emoji: fields[3] as String,
      tierIndex: fields[4] as int,
      typeIndex: fields[5] as int,
      targetValue: fields[6] as int,
      unlockedAt: fields[7] as DateTime?,
      isUnlocked: fields[8] as bool,
      currentProgress: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.emoji)
      ..writeByte(4)
      ..write(obj.tierIndex)
      ..writeByte(5)
      ..write(obj.typeIndex)
      ..writeByte(6)
      ..write(obj.targetValue)
      ..writeByte(7)
      ..write(obj.unlockedAt)
      ..writeByte(8)
      ..write(obj.isUnlocked)
      ..writeByte(9)
      ..write(obj.currentProgress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
