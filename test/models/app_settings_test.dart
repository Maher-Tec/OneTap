import 'package:flutter_test/flutter_test.dart';
import 'package:onetap/data/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('AppSettings can be created with default values', () {
      final settings = AppSettings();

      expect(settings.reminderEnabled, false);
      expect(settings.reminderTime, '20:00');
      expect(settings.themeModeIndex, 0);
      expect(settings.biometricLockEnabled, false);
      expect(settings.graceEnabled, false);
      expect(settings.graceRemainingThisWeek, 0);
    });

    test('AppSettings.defaults() creates default instance', () {
      final settings = AppSettings.defaults();

      expect(settings.reminderEnabled, false);
      expect(settings.reminderTime, '20:00');
      expect(settings.themeModeIndex, 0);
      expect(settings.biometricLockEnabled, false);
      expect(settings.graceEnabled, false);
      expect(settings.graceRemainingThisWeek, 0);
    });

    test('AppSettings can be created with custom values', () {
      final settings = AppSettings(
        reminderEnabled: true,
        reminderTime: '19:30',
        themeModeIndex: 2,
        biometricLockEnabled: true,
        graceEnabled: true,
        graceRemainingThisWeek: 1,
      );

      expect(settings.reminderEnabled, true);
      expect(settings.reminderTime, '19:30');
      expect(settings.themeModeIndex, 2);
      expect(settings.biometricLockEnabled, true);
      expect(settings.graceEnabled, true);
      expect(settings.graceRemainingThisWeek, 1);
    });

    test('AppSettings can be modified', () {
      final settings = AppSettings();
      
      settings.reminderEnabled = true;
      settings.reminderTime = '08:00';
      settings.themeModeIndex = 1;
      
      expect(settings.reminderEnabled, true);
      expect(settings.reminderTime, '08:00');
      expect(settings.themeModeIndex, 1);
    });

    test('AppSettings.themeMode getter returns correct enum', () {
      final settings0 = AppSettings(themeModeIndex: 0);
      expect(settings0.themeMode, ThemeMode.system);

      final settings1 = AppSettings(themeModeIndex: 1);
      expect(settings1.themeMode, ThemeMode.light);

      final settings2 = AppSettings(themeModeIndex: 2);
      expect(settings2.themeMode, ThemeMode.dark);
    });

    test('AppSettings.themeMode setter updates themeModeIndex', () {
      final settings = AppSettings();
      
      settings.themeMode = ThemeMode.light;
      expect(settings.themeModeIndex, 1);
      
      settings.themeMode = ThemeMode.dark;
      expect(settings.themeModeIndex, 2);
      
      settings.themeMode = ThemeMode.system;
      expect(settings.themeModeIndex, 0);
    });

    test('AppSettings copyWith returns new updated instance', () {
      final settings = AppSettings();
      final updated = settings.copyWith(
        reminderEnabled: true,
        reminderTime: '07:30',
        themeModeIndex: 2,
      );

      expect(updated.reminderEnabled, true);
      expect(updated.reminderTime, '07:30');
      expect(updated.themeModeIndex, 2);
      expect(settings.reminderEnabled, false); // Original unchanged
    });

    test('AppSettings supports all valid reminder times', () {
      final times = ['07:00', '12:00', '19:00', '20:00', '21:00', '22:00'];
      
      for (final time in times) {
        final settings = AppSettings(reminderTime: time);
        expect(settings.reminderTime, time);
      }
    });
  });
}
