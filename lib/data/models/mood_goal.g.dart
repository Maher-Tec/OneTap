// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MoodGoalAdapter extends TypeAdapter<MoodGoal> {
  @override
  final int typeId = 3;

  @override
  MoodGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodGoal(
      id: fields[0] as String,
      name: fields[1] as String,
      targetDaysPerMonth: fields[2] as int,
      targetMoodIndices: (fields[3] as List).cast<int>(),
      createdAt: fields[4] as DateTime,
      completedAt: fields[5] as DateTime?,
      isActive: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MoodGoal obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.targetDaysPerMonth)
      ..writeByte(3)
      ..write(obj.targetMoodIndices)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.completedAt)
      ..writeByte(6)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
