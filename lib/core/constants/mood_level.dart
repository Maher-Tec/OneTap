import 'package:flutter/material.dart';
import 'package:onetap/core/constants/app_colors.dart';

/// Mood levels for the journal entries
enum MoodLevel {
  great,    // 🤩 - Star eyes, amazing
  good,     // 😊 - Happy, content
  okay,     // 😐 - Neutral
  meh,      // 😔 - Sad, down
  bad,      // 😣 - Stressed, rough
  inLove,   // 😍 - In love, heart eyes
}

/// Extension to add useful properties to MoodLevel
extension MoodLevelExtension on MoodLevel {
  /// The emoji representation of this mood (fallback when Lottie not available)
  String get emoji {
    switch (this) {
      case MoodLevel.great:
        return '🤩';
      case MoodLevel.good:
        return '😊';
      case MoodLevel.okay:
        return '😐';
      case MoodLevel.meh:
        return '😔';
      case MoodLevel.bad:
        return '😣';
      case MoodLevel.inLove:
        return '😍';
    }
  }

  // ... (keeping existing code)

  /// Human readable label for this mood
  String get label {
    switch (this) {
      case MoodLevel.great:
        return 'Great';
      case MoodLevel.good:
        return 'Good';
      case MoodLevel.okay:
        return 'Okay';
      case MoodLevel.meh:
        return 'Meh';
      case MoodLevel.bad:
        return 'Rough';
      case MoodLevel.inLove:
        return 'In Love';
    }
  }

  /// Engaging prompt for the note screen
  String get prompt {
    switch (this) {
      case MoodLevel.great:
        return "What made today amazing? ✨";
      case MoodLevel.good:
        return "What went well today? 🌟";
      case MoodLevel.okay:
        return "How was your day? 🍃";
      case MoodLevel.meh:
        return "What's on your mind? 💭";
      case MoodLevel.bad:
        return "What happened today? 🌨️";
      case MoodLevel.inLove:
        return "Who/what is in your heart? 💖";
    }
  }

  /// The color associated with this mood (calm theme colors)
  Color get color {
    switch (this) {
      case MoodLevel.great:
        return AppColors.moodGreat;
      case MoodLevel.good:
        return AppColors.moodGood;
      case MoodLevel.okay:
        return AppColors.moodOkay;
      case MoodLevel.meh:
        return AppColors.moodMeh;
      case MoodLevel.bad:
        return AppColors.moodBad;
      case MoodLevel.inLove:
        return AppColors.moodInLove;
    }
  }

  /// Lottie animation asset path for this mood
  String get lottieAsset {
    switch (this) {
      case MoodLevel.great:
        return 'assets/animation/Mood 1/Star Strike Emoji.json';
      case MoodLevel.good:
        return 'assets/animation/Mood 2/smile emoji animated.json';
      case MoodLevel.okay:
        return 'assets/animation/Mood 3/neutral emoji.json';
      case MoodLevel.meh:
        return 'assets/animation/Mood 4/Sad Emoji.json';
      case MoodLevel.bad:
        return 'assets/animation/Mood 5/stressed emoji.json';
      case MoodLevel.inLove:
        return 'assets/animation/Mood 6/in love.json';
    }
  }

  /// Numeric score for statistics (0.0 to 4.0 scale)
  double get score {
    switch (this) {
      case MoodLevel.great:
      case MoodLevel.inLove:
        return 4.0;
      case MoodLevel.good:
        return 3.0;
      case MoodLevel.okay:
        return 2.0;
      case MoodLevel.meh:
        return 1.0;
      case MoodLevel.bad:
        return 0.0;
    }
  }

  /// Whether this mood is considered positive (great, good, or in love)
  bool get isPositive {
    return this == MoodLevel.great ||
        this == MoodLevel.good ||
        this == MoodLevel.inLove;
  }

  /// Haptic weight for this mood (used for haptic feedback intensity)
  /// Higher = heavier haptic
  int get hapticWeight {
    switch (this) {
      case MoodLevel.great:
        return 1; // Light, crisp
      case MoodLevel.good:
        return 2; // Soft tick
      case MoodLevel.okay:
        return 3; // Neutral tap
      case MoodLevel.meh:
        return 4; // Slightly heavier
      case MoodLevel.bad:
        return 5; // Heavier + longer
      case MoodLevel.inLove:
        return 1; // Light, happy
    }
  }
}
