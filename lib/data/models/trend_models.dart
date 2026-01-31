import 'package:onetap/core/constants/mood_level.dart';

/// A single data point for mood trend charts
class TrendDataPoint {
  final DateTime date;
  final double value; // 0.0 (awful) to 4.0 (great)
  final MoodLevel? mood;

  const TrendDataPoint({
    required this.date,
    required this.value,
    this.mood,
  });

  /// Create from a MoodLevel
  factory TrendDataPoint.fromMood(DateTime date, MoodLevel mood) {
    return TrendDataPoint(
      date: date,
      value: _moodToValue(mood),
      mood: mood,
    );
  }

  static double _moodToValue(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.great:
        return 4.0;
      case MoodLevel.good:
        return 3.0;
      case MoodLevel.okay:
        return 2.0;
      case MoodLevel.meh:
        return 1.0;
      case MoodLevel.bad:
        return 0.0;
      case MoodLevel.inLove:
        return 4.0; // Same as great - positive mood
    }
  }
}

/// Summary of a week's mood data
class WeeklySummary {
  final int totalEntries;
  final double averageMood; // 0.0 to 4.0
  final MoodLevel? dominantMood;
  final int streakDays;
  final int positiveDays; // great or good
  final double weekOverWeekChange; // % change from previous week

  const WeeklySummary({
    required this.totalEntries,
    required this.averageMood,
    this.dominantMood,
    required this.streakDays,
    required this.positiveDays,
    this.weekOverWeekChange = 0.0,
  });

  /// Get a label describing the trend
  String get trendLabel {
    if (weekOverWeekChange > 10) return 'Improving 📈';
    if (weekOverWeekChange < -10) return 'Declining 📉';
    return 'Stable ➡️';
  }
  
  /// Check if this was a good week
  bool get isPositiveWeek => averageMood >= 2.5;
}

/// Comparison between two months
class MonthlyComparison {
  final double previousAvg;
  final double currentAvg;
  final int previousEntryCount;
  final int currentEntryCount;

  const MonthlyComparison({
    required this.previousAvg,
    required this.currentAvg,
    required this.previousEntryCount,
    required this.currentEntryCount,
  });

  /// Calculate percent change
  double get percentChange {
    if (previousAvg == 0) return currentAvg > 0 ? 100.0 : 0.0;
    return ((currentAvg - previousAvg) / previousAvg) * 100;
  }

  /// Check if mood improved
  bool get isImproved => currentAvg > previousAvg;

  /// Get trend emoji
  String get trendEmoji {
    final diff = currentAvg - previousAvg;
    if (diff > 0.3) return '🚀';
    if (diff > 0) return '📈';
    if (diff < -0.3) return '😔';
    if (diff < 0) return '📉';
    return '➡️';
  }
}

/// Data for mood by day of week
class DayOfWeekStats {
  /// Day index (1 = Monday, 7 = Sunday)
  final int dayIndex;
  
  /// Average mood for this day (0.0 to 4.0)
  final double averageMood;
  
  /// Number of entries for this day
  final int entryCount;

  const DayOfWeekStats({
    required this.dayIndex,
    required this.averageMood,
    required this.entryCount,
  });

  /// Get day name
  String get dayName {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dayIndex - 1];
  }

  /// Get full day name
  String get fullDayName {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayIndex - 1];
  }
}
