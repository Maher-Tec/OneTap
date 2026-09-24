import 'package:flutter/services.dart';
import 'package:onetap/core/constants/mood_level.dart';

/// Haptic feedback utilities with mood-based patterns
class HapticUtils {
  HapticUtils._();

  /// Light tap feedback
  static Future<void> lightTap() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium tap feedback
  static Future<void> mediumTap() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy tap feedback
  static Future<void> heavyTap() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection tick feedback
  static Future<void> selectionTick() async {
    await HapticFeedback.selectionClick();
  }

  /// Gentle feedback for navigation and subtle interactions
  static Future<void> gentle() async {
    await HapticFeedback.selectionClick();
  }

  /// Alias for moodHaptic
  static Future<void> forMood(MoodLevel mood) async {
    await moodHaptic(mood);
  }

  /// Success feedback (used after saving)
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Mood-based haptic feedback
  /// Each mood has a different haptic weight/feel
  static Future<void> moodHaptic(MoodLevel mood) async {
    switch (mood) {
      case MoodLevel.great:
        // Light, crisp - two quick light taps
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();
        break;
      case MoodLevel.good:
        // Soft tick
        await HapticFeedback.selectionClick();
        break;
      case MoodLevel.okay:
        // Neutral tap
        await HapticFeedback.lightImpact();
        break;
      case MoodLevel.meh:
        // Slightly heavier
        await HapticFeedback.mediumImpact();
        break;
      case MoodLevel.bad:
        // Heavier + longer feel
        await HapticFeedback.heavyImpact();
        break;
      case MoodLevel.inLove:
        // Light, joyful - like great
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();
        break;
    }
  }

  /// Lock click feedback (satisfying confirmation)
  static Future<void> lockClick() async {
    await HapticFeedback.heavyImpact();
  }

  /// Error/disabled feedback
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }
}
