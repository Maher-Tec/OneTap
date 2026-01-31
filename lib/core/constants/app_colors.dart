import 'package:flutter/material.dart';
import 'package:onetap/core/constants/mood_level.dart';

/// App color palette
class AppColors {
  AppColors._();

  // Primary gradient colors (time-of-day)
  static const Color morningStart = Color(0xFFFFE0B2);  // Warm peach
  static const Color morningEnd = Color(0xFFFFAB91);    // Soft coral
  
  static const Color afternoonStart = Color(0xFF90CAF9); // Light blue
  static const Color afternoonEnd = Color(0xFF64B5F6);   // Sky blue
  
  static const Color eveningStart = Color(0xFF7E57C2);   // Purple
  static const Color eveningEnd = Color(0xFF5C6BC0);     // Indigo
  
  static const Color nightStart = Color(0xFF3949AB);     // Deep indigo
  static const Color nightEnd = Color(0xFF1A237E);       // Dark blue

  // Glass card colors
  static const Color glassLight = Color(0x40FFFFFF);
  static const Color glassDark = Color(0x20FFFFFF);
  static const Color glassBorder = Color(0x30FFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0x99FFFFFF);

  // Surface colors
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF1A1A2E);

  // Accent colors
  static const Color streakFire = Color(0xFFFF6B35);
  static const Color lockGold = Color(0xFFFFD700);
  static const Color successGreen = Color(0xFF10B981);

  // Mood colors (calm theme - also defined in mood_level.dart extension)
  static const Color moodGreat = Color(0xFF2E7D32);   // Darker green for visibility
  static const Color moodGood = Color(0xFF00897B);    // Teal green for visibility
  static const Color moodOkay = Color(0xFFFFD93D);    // Warm yellow
  static const Color moodMeh = Color(0xFF6B8DD6);     // Soft blue
  static const Color moodBad = Color(0xFF9B7DD6);     // Soft purple
  static const Color moodInLove = Color(0xFFFF6B9D);  // Soft pink

  /// Map of mood levels to colors for easy lookup
  static const Map<MoodLevel, Color> moodColors = {
    MoodLevel.great: moodGreat,
    MoodLevel.good: moodGood,
    MoodLevel.okay: moodOkay,
    MoodLevel.meh: moodMeh,
    MoodLevel.bad: moodBad,
    MoodLevel.inLove: moodInLove,
  };

  /// Get gradient colors based on hour of day
  static List<Color> getTimeGradient(int hour) {
    if (hour >= 5 && hour < 12) {
      // Morning: 5am - 11:59am
      return [morningStart, morningEnd];
    } else if (hour >= 12 && hour < 17) {
      // Afternoon: 12pm - 4:59pm
      return [afternoonStart, afternoonEnd];
    } else if (hour >= 17 && hour < 21) {
      // Evening: 5pm - 8:59pm
      return [eveningStart, eveningEnd];
    } else {
      // Night: 9pm - 4:59am
      return [nightStart, nightEnd];
    }
  }

  /// Get the text color that works best with the current time gradient
  static Color getTimeTextColor(int hour) {
    if (hour >= 5 && hour < 12) {
      return textPrimary;
    }
    return textLight;
  }
}
