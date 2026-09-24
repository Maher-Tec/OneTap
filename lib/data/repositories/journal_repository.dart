import 'dart:math' as math;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:onetap/data/models/mood_entry.dart';
import 'package:onetap/data/models/app_settings.dart';
import 'package:onetap/data/models/trend_models.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/core/utils/date_utils.dart' as app_date;

/// Repository for managing mood journal entries
class JournalRepository {
  static const String _moodEntriesBoxName = 'mood_entries';
  static const String _settingsBoxName = 'settings';
  static const String _settingsKey = 'app_settings';

  late Box<MoodEntry> _moodEntriesBox;
  late Box<AppSettings> _settingsBox;

  /// Initialize Hive and open boxes
  static Future<JournalRepository> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MoodEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }

    final repo = JournalRepository();
    repo._moodEntriesBox = await Hive.openBox<MoodEntry>(_moodEntriesBoxName);
    repo._settingsBox = await Hive.openBox<AppSettings>(_settingsBoxName);
    
    // Ensure settings exist
    if (!repo._settingsBox.containsKey(_settingsKey)) {
      await repo._settingsBox.put(_settingsKey, AppSettings.defaults());
    }
    
    return repo;
  }

  /// Get the mood entries box (for other repositories)
  Box<MoodEntry> get entriesBox => _moodEntriesBox;

  // ==================== ENTRIES ====================

  /// Save a mood entry for today
  Future<void> saveTodayEntry(MoodLevel mood, {String? note}) async {
    final dateKey = app_date.DateUtils.todayKey();
    final entry = MoodEntry.create(
      dateKey: dateKey,
      mood: mood,
      note: note,
    );
    await _moodEntriesBox.put(dateKey, entry);
  }

  /// Get entry for a specific date
  MoodEntry? getEntry(DateTime date) {
    final dateKey = app_date.DateUtils.toDateKey(date);
    return _moodEntriesBox.get(dateKey);
  }

  /// Get today's entry (null if not yet saved)
  MoodEntry? getTodayEntry() {
    return getEntry(DateTime.now());
  }

  /// Check if today already has an entry
  bool hasTodayEntry() {
    return getTodayEntry() != null;
  }

  /// Get all entries for a specific month
  List<MoodEntry> getEntriesForMonth(int year, int month) {
    final allEntries = getAllEntries();
    return allEntries.where((entry) {
      final date = app_date.DateUtils.fromDateKey(entry.dateKey);
      return date.year == year && date.month == month;
    }).toList();
  }

  /// Get entries for the last N days
  List<MoodEntry?> getLastNDays(int n) {
    final dates = app_date.DateUtils.getLastNDays(n);
    return dates.map((date) => getEntry(date)).toList();
  }

  /// Get all entries
  List<MoodEntry> getAllEntries() {
    return _moodEntriesBox.values.toList();
  }

  /// Get total entry count
  int get totalEntries => _moodEntriesBox.length;

  // ==================== STREAK ====================

  /// Calculate current streak
  int calculateStreak() {
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    // Check if today has entry
    if (hasTodayEntry()) {
      streak = 1;
      checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
    } else {
      // If no entry today yet, check starting from yesterday so streak is not lost
      checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
    }
    
    // Go backwards checking each day
    while (true) {
      final entry = getEntry(checkDate);
      if (entry != null) {
        streak++;
        checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
      } else {
        // Streak broken
        break;
      }
    }
    
    return streak;
  }

  /// Calculate the longest streak ever (DST safe)
  int calculateLongestStreak() {
    final allEntries = getAllEntries();
    if (allEntries.isEmpty) return 0;
    
    // Sort by date
    allEntries.sort((a, b) => a.dateKey.compareTo(b.dateKey));
    
    int longestStreak = 1;
    int currentStreak = 1;
    
    for (int i = 1; i < allEntries.length; i++) {
      final prevDate = app_date.DateUtils.fromDateKey(allEntries[i - 1].dateKey);
      final currDate = app_date.DateUtils.fromDateKey(allEntries[i].dateKey);
      final diff = DateTime.utc(currDate.year, currDate.month, currDate.day)
          .difference(DateTime.utc(prevDate.year, prevDate.month, prevDate.day))
          .inDays;
      
      if (diff == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else if (diff > 1) {
        currentStreak = 1;
      }
    }
    
    return longestStreak;
  }

  // ==================== STATISTICS ====================

  /// Get mood distribution as a map of MoodLevel -> count
  Map<MoodLevel, int> getMoodDistribution({int? year, int? month}) {
    List<MoodEntry> entries;
    
    if (year != null && month != null) {
      entries = getEntriesForMonth(year, month);
    } else {
      entries = getAllEntries();
    }
    
    final distribution = <MoodLevel, int>{};
    for (final mood in MoodLevel.values) {
      distribution[mood] = 0;
    }
    
    for (final entry in entries) {
      distribution[entry.mood] = (distribution[entry.mood] ?? 0) + 1;
    }
    
    return distribution;
  }

  /// Get the most common mood
  MoodLevel? getMostCommonMood({int? year, int? month}) {
    final distribution = getMoodDistribution(year: year, month: month);
    if (distribution.values.every((v) => v == 0)) return null;
    
    MoodLevel? mostCommon;
    int maxCount = 0;
    
    for (final entry in distribution.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostCommon = entry.key;
      }
    }
    
    return mostCommon;
  }

  /// Count days with positive mood (great, good, or inLove)
  int countPositiveDays({int? year, int? month}) {
    List<MoodEntry> entries;
    
    if (year != null && month != null) {
      entries = getEntriesForMonth(year, month);
    } else {
      entries = getAllEntries();
    }
    
    return entries.where((e) => e.mood.isPositive).length;
  }

  // ==================== ADVANCED ANALYTICS ====================

  /// Get mood trend data points for the last N days
  /// Returns a list of TrendDataPoint for charting
  List<TrendDataPoint> getMoodTrend({int days = 30}) {
    final result = <TrendDataPoint>[];
    final now = DateTime.now();
    
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final entry = getEntry(date);
      if (entry != null) {
        result.add(TrendDataPoint.fromMood(date, entry.mood));
      }
    }
    
    return result;
  }

  /// Get average mood by day of week
  /// Returns map of day index (1=Mon, 7=Sun) to DayOfWeekStats
  List<DayOfWeekStats> getMoodByDayOfWeek({int? year, int? month}) {
    List<MoodEntry> entries;
    
    if (year != null && month != null) {
      entries = getEntriesForMonth(year, month);
    } else {
      entries = getAllEntries();
    }
    
    // Group entries by day of week
    final dayGroups = <int, List<double>>{};
    for (int i = 1; i <= 7; i++) {
      dayGroups[i] = [];
    }
    
    for (final entry in entries) {
      final date = app_date.DateUtils.fromDateKey(entry.dateKey);
      final dayOfWeek = date.weekday; // 1=Mon, 7=Sun
      dayGroups[dayOfWeek]!.add(entry.mood.score);
    }
    
    // Calculate averages
    final result = <DayOfWeekStats>[];
    for (int day = 1; day <= 7; day++) {
      final moods = dayGroups[day]!;
      final avg = moods.isEmpty ? 0.0 : moods.reduce((a, b) => a + b) / moods.length;
      result.add(DayOfWeekStats(
        dayIndex: day,
        averageMood: avg,
        entryCount: moods.length,
      ));
    }
    
    return result;
  }

  /// Get mood by hour of day (based on createdAt)
  Map<int, double> getMoodByHour({int? year, int? month}) {
    List<MoodEntry> entries;
    
    if (year != null && month != null) {
      entries = getEntriesForMonth(year, month);
    } else {
      entries = getAllEntries();
    }
    
    // Group by hour
    final hourGroups = <int, List<double>>{};
    for (int i = 0; i < 24; i++) {
      hourGroups[i] = [];
    }
    
    for (final entry in entries) {
      final hour = entry.createdAt.hour;
      hourGroups[hour]!.add(entry.mood.score);
    }
    
    // Calculate averages (0.0 to 4.0 scale where 4=great)
    final result = <int, double>{};
    for (int hour = 0; hour < 24; hour++) {
      final moods = hourGroups[hour]!;
      if (moods.isEmpty) {
        result[hour] = 0.0;
      } else {
        final avg = moods.reduce((a, b) => a + b) / moods.length;
        result[hour] = avg;
      }
    }
    
    return result;
  }

  /// Get weekly summary
  WeeklySummary getWeeklySummary() {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    
    // This week's entries
    final thisWeekEntries = <MoodEntry>[];
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      if (date.isAfter(now)) break;
      final entry = getEntry(date);
      if (entry != null) {
        thisWeekEntries.add(entry);
      }
    }
    
    // Last week's entries for comparison
    final lastWeekStart = weekStart.subtract(const Duration(days: 7));
    final lastWeekEntries = <MoodEntry>[];
    for (int i = 0; i < 7; i++) {
      final date = lastWeekStart.add(Duration(days: i));
      final entry = getEntry(date);
      if (entry != null) {
        lastWeekEntries.add(entry);
      }
    }
    
    // Calculate averages
    double thisWeekAvg = 0.0;
    if (thisWeekEntries.isNotEmpty) {
      final sum = thisWeekEntries.fold<double>(0.0, (sum, e) => sum + e.mood.score);
      thisWeekAvg = sum / thisWeekEntries.length;
    }
    
    double lastWeekAvg = 0.0;
    if (lastWeekEntries.isNotEmpty) {
      final sum = lastWeekEntries.fold<double>(0.0, (sum, e) => sum + e.mood.score);
      lastWeekAvg = sum / lastWeekEntries.length;
    }
    
    // Calculate week over week change
    double weekOverWeekChange = 0.0;
    if (lastWeekAvg > 0) {
      weekOverWeekChange = ((thisWeekAvg - lastWeekAvg) / lastWeekAvg) * 100;
    }
    
    // Count positive days
    final positiveDays = thisWeekEntries.where((e) => e.mood.isPositive).length;
    
    // Dominant mood for this week
    MoodLevel? dominantMood;
    if (thisWeekEntries.isNotEmpty) {
      final moodCounts = <MoodLevel, int>{};
      for (final e in thisWeekEntries) {
        moodCounts[e.mood] = (moodCounts[e.mood] ?? 0) + 1;
      }
      int maxCount = 0;
      for (final entry in moodCounts.entries) {
        if (entry.value > maxCount) {
          maxCount = entry.value;
          dominantMood = entry.key;
        }
      }
    }
    
    return WeeklySummary(
      totalEntries: thisWeekEntries.length,
      averageMood: thisWeekAvg,
      dominantMood: dominantMood,
      streakDays: calculateStreak(),
      positiveDays: positiveDays,
      weekOverWeekChange: weekOverWeekChange,
    );
  }

  /// Compare two months
  MonthlyComparison compareMonths(DateTime month1, DateTime month2) {
    final entries1 = getEntriesForMonth(month1.year, month1.month);
    final entries2 = getEntriesForMonth(month2.year, month2.month);
    
    double avg1 = 0.0;
    if (entries1.isNotEmpty) {
      final sum = entries1.fold<double>(0.0, (sum, e) => sum + e.mood.score);
      avg1 = sum / entries1.length;
    }
    
    double avg2 = 0.0;
    if (entries2.isNotEmpty) {
      final sum = entries2.fold<double>(0.0, (sum, e) => sum + e.mood.score);
      avg2 = sum / entries2.length;
    }
    
    return MonthlyComparison(
      previousAvg: avg1,
      currentAvg: avg2,
      previousEntryCount: entries1.length,
      currentEntryCount: entries2.length,
    );
  }

  /// Calculate mood velocity (rate of change over recent days)
  /// Positive = improving, negative = declining
  double getMoodVelocity({int days = 7}) {
    final trend = getMoodTrend(days: days);
    if (trend.length < 2) return 0.0;
    
    // Simple linear regression slope
    final n = trend.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    
    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += trend[i].value;
      sumXY += i * trend[i].value;
      sumX2 += i * i;
    }
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    return slope;
  }

  /// Calculate mood volatility (standard deviation)
  /// Higher = more variable moods
  double getMoodVolatility({int days = 7}) {
    final trend = getMoodTrend(days: days);
    if (trend.length < 2) return 0.0;
    
    final avg = trend.fold<double>(0.0, (sum, p) => sum + p.value) / trend.length;
    final variance = trend.fold<double>(0.0, (sum, p) {
      final diff = p.value - avg;
      return sum + (diff * diff);
    }) / trend.length;
    
    return variance > 0 ? math.sqrt(variance) : 0.0;
  }

  /// Get keyword frequency from notes
  /// Returns top keywords sorted by frequency
  Map<String, int> getKeywordFrequency({int? limit}) {
    final entries = getAllEntries();
    final wordCount = <String, int>{};
    
    // Common words to ignore
    const stopWords = {'the', 'a', 'an', 'is', 'it', 'to', 'and', 'of', 'in', 'for', 'on', 'at', 'i', 'my', 'me', 'was', 'had', 'have', 'been', 'but', 'so', 'just', 'with', 'this', 'that'};
    
    for (final entry in entries) {
      if (entry.note == null || entry.note!.isEmpty) continue;
      
      final words = entry.note!
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .split(RegExp(r'\s+'))
          .where((w) => w.length > 2 && !stopWords.contains(w));
      
      for (final word in words) {
        wordCount[word] = (wordCount[word] ?? 0) + 1;
      }
    }
    
    // Sort by frequency
    final sorted = wordCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topN = limit != null ? sorted.take(limit) : sorted;
    return Map.fromEntries(topN);
  }

  // ==================== SETTINGS ====================

  /// Get app settings
  AppSettings getSettings() {
    return _settingsBox.get(_settingsKey) ?? AppSettings.defaults();
  }

  /// Update settings
  Future<void> updateSettings(AppSettings settings) async {
    await _settingsBox.put(_settingsKey, settings);
  }

  /// Reset all data (entries only, keeps settings)
  Future<void> resetEntries() async {
    await _moodEntriesBox.clear();
  }

  /// Reset everything including settings
  Future<void> resetAll() async {
    await _moodEntriesBox.clear();
    await _settingsBox.put(_settingsKey, AppSettings.defaults());
  }

}
