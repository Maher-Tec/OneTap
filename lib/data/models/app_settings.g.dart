// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 1;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      reminderEnabled: fields[0] as bool,
      reminderTime: fields[1] as String,
      themeModeIndex: fields[2] as int,
    )
      ..biometricLockEnabled = fields[3] as bool
      ..graceEnabled = fields[4] as bool
      ..graceRemainingThisWeek = fields[5] as int
      ..weekAnchor = fields[6] as DateTime;
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.reminderEnabled)
      ..writeByte(1)
      ..write(obj.reminderTime)
      ..writeByte(2)
      ..write(obj.themeModeIndex)
      ..writeByte(3)
      ..write(obj.biometricLockEnabled)
      ..writeByte(4)
      ..write(obj.graceEnabled)
      ..writeByte(5)
      ..write(obj.graceRemainingThisWeek)
      ..writeByte(6)
      ..write(obj.weekAnchor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
