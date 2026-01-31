import 'package:hive/hive.dart';

part 'app_settings.g.dart';

/// Theme mode options
enum ThemeMode {
  system,
  light,
  dark,
}

/// App settings stored in Hive
@HiveType(typeId: 1)
class AppSettings extends HiveObject {
  /// Whether daily reminder is enabled
  @HiveField(0)
  bool reminderEnabled;

  /// Reminder time in HH:mm format
  @HiveField(1)
  String reminderTime;

  /// Theme mode (0 = system, 1 = light, 2 = dark)
  @HiveField(2)
  int themeModeIndex;

  /// Whether biometric lock is enabled
  @HiveField(3)
  bool biometricLockEnabled;

  /// Whether streak grace/protection is enabled
  @HiveField(4)
  bool graceEnabled;

  /// Grace passes remaining this week (0 or 1)
  @HiveField(5)
  int graceRemainingThisWeek;

  /// The Monday of the current grace week (for reset logic)
  @HiveField(6)
  DateTime weekAnchor;

  AppSettings({
    this.reminderEnabled = false,
    this.reminderTime = '20:00',
    this.themeModeIndex = 0,
    this.biometricLockEnabled = false,
    this.graceEnabled = false,
    this.graceRemainingThisWeek = 0,
    DateTime? weekAnchor,
  }) : weekAnchor = weekAnchor ?? DateTime.now();

  /// Get the theme mode enum
  ThemeMode get themeMode => ThemeMode.values[themeModeIndex];

  /// Set theme mode from enum
  set themeMode(ThemeMode mode) => themeModeIndex = mode.index;

  /// Default settings
  factory AppSettings.defaults() {
    return AppSettings(
      reminderEnabled: false,
      reminderTime: '20:00',
      themeModeIndex: 0,
      biometricLockEnabled: false,
      graceEnabled: false,
      graceRemainingThisWeek: 0,
      weekAnchor: DateTime.now(),
    );
  }

  /// Create a copy with updated values (for immutable state management)
  AppSettings copyWith({
    bool? reminderEnabled,
    String? reminderTime,
    int? themeModeIndex,
    bool? biometricLockEnabled,
    bool? graceEnabled,
    int? graceRemainingThisWeek,
    DateTime? weekAnchor,
  }) {
    return AppSettings(
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      themeModeIndex: themeModeIndex ?? this.themeModeIndex,
      biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
      graceEnabled: graceEnabled ?? this.graceEnabled,
      graceRemainingThisWeek: graceRemainingThisWeek ?? this.graceRemainingThisWeek,
      weekAnchor: weekAnchor ?? this.weekAnchor,
    );
  }
}
