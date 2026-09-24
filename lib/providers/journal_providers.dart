import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:onetap/data/repositories/journal_repository.dart';
import 'package:onetap/data/models/mood_entry.dart';
import 'package:onetap/data/models/app_settings.dart';
import 'package:onetap/data/models/trend_models.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/core/services/notification_service.dart';

/// Provider for the journal repository
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  throw UnimplementedError('Repository must be initialized before use');
});

/// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('NotificationService must be initialized before use');
});

/// Provider for today's entry (null if not saved yet)
final todayEntryProvider = StateNotifierProvider<TodayEntryNotifier, MoodEntry?>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return TodayEntryNotifier(repo, notificationService);
});

class TodayEntryNotifier extends StateNotifier<MoodEntry?> {
  final JournalRepository _repo;
  final NotificationService _notificationService;

  TodayEntryNotifier(this._repo, this._notificationService) : super(_repo.getTodayEntry());

  /// Check if today has an entry
  bool get hasEntry => state != null;

  /// Save today's entry
  Future<void> saveEntry(MoodLevel mood, {String? note}) async {
    await _repo.saveTodayEntry(mood, note: note);
    state = _repo.getTodayEntry();
    
    // Check for streak milestone and show notification
    final streak = _repo.calculateStreak();
    try {
      await _notificationService.showStreakMilestone(streak);
    } catch (error) {
      // A notification failure must not make a successfully saved entry fail.
      debugPrint('Could not show streak notification: $error');
    }
  }

  /// Refresh from storage
  void refresh() {
    state = _repo.getTodayEntry();
  }
}

/// Provider for current streak
final currentStreakProvider = Provider<int>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  // Re-read when today's entry changes
  ref.watch(todayEntryProvider);
  return repo.calculateStreak();
});

/// Provider for longest streak
final longestStreakProvider = Provider<int>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  ref.watch(todayEntryProvider);
  return repo.calculateLongestStreak();
});

/// Provider for total entries count
final totalEntriesProvider = Provider<int>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  ref.watch(todayEntryProvider);
  return repo.totalEntries;
});

/// Provider for last 7 days entries (for mini calendar preview)
final last7DaysProvider = Provider<List<MoodEntry?>>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  ref.watch(todayEntryProvider);
  return repo.getLastNDays(7);
});

/// Provider for entries of a specific month
final monthEntriesProvider = Provider.family<List<MoodEntry>, DateTime>((ref, date) {
  final repo = ref.watch(journalRepositoryProvider);
  ref.watch(todayEntryProvider);
  return repo.getEntriesForMonth(date.year, date.month);
});

/// Provider for mood distribution
final moodDistributionProvider = Provider.family<Map<MoodLevel, int>, DateTime?>((ref, date) {
  final repo = ref.watch(journalRepositoryProvider);
  ref.watch(todayEntryProvider);
  if (date != null) {
    return repo.getMoodDistribution(year: date.year, month: date.month);
  }
  return repo.getMoodDistribution();
});

/// Provider for most common mood
final mostCommonMoodProvider = Provider.family<MoodLevel?, DateTime?>((ref, date) {
  final repo = ref.watch(journalRepositoryProvider);
  ref.watch(todayEntryProvider);
  if (date != null) {
    return repo.getMostCommonMood(year: date.year, month: date.month);
  }
  return repo.getMostCommonMood();
});

/// Provider for positive days count (great or good)
final positiveDaysProvider = Provider.family<int, DateTime?>((ref, date) {
  final repo = ref.watch(journalRepositoryProvider);
  ref.watch(todayEntryProvider);
  if (date != null) {
    return repo.countPositiveDays(year: date.year, month: date.month);
  }
  return repo.countPositiveDays();
});

/// Provider for app settings
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return SettingsNotifier(repo, notificationService);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final JournalRepository _repo;
  final NotificationService _notificationService;

  SettingsNotifier(this._repo, this._notificationService) : super(_repo.getSettings());

  /// Update reminder settings
  Future<void> setReminder({bool? enabled, String? time}) async {
    // Create a copy with updated values
    final newSettings = state.copyWith(
      reminderEnabled: enabled ?? state.reminderEnabled,
      reminderTime: time ?? state.reminderTime,
    );
    
    await _repo.updateSettings(newSettings);
    
    // Schedule or cancel notification based on setting
    if (newSettings.reminderEnabled) {
      await _notificationService.scheduleDailyReminder(newSettings.reminderTime);
    } else {
      await _notificationService.cancelDailyReminder();
    }
    
    // Set the new state to trigger rebuild
    state = newSettings;
  }

  /// Update theme mode
  Future<void> setThemeMode(int modeIndex) async {
    final newSettings = state.copyWith(themeModeIndex: modeIndex);
    await _repo.updateSettings(newSettings);
    state = newSettings;
  }



  /// Reset all entries
  Future<void> resetEntries() async {
    await _repo.resetEntries();
  }

  /// Reset everything
  Future<void> resetAll() async {
    await _repo.resetAll();
    state = _repo.getSettings();
    if (state.reminderEnabled) {
      await _notificationService.scheduleDailyReminder(state.reminderTime);
    } else {
      await _notificationService.cancelDailyReminder();
    }
  }

  /// Refresh from storage
  void refresh() {
    state = _repo.getSettings();
  }
}

// ==================== ANALYTICS PROVIDERS ====================

/// Provider for mood trend (last N days)
final moodTrendProvider = Provider.family<List<TrendDataPoint>, int>((ref, days) {
  final repo = ref.watch(journalRepositoryProvider);
  ref.watch(todayEntryProvider);
  return repo.getMoodTrend(days: days);
});

/// Provider for mood by day of week
final moodByDayOfWeekProvider = Provider.family<List<DayOfWeekStats>, DateTime?>((ref, date) {
  final repo = ref.watch(journalRepositoryProvider);
  ref.watch(todayEntryProvider);
  if (date != null) {
    return repo.getMoodByDayOfWeek(year: date.year, month: date.month);
  }
  return repo.getMoodByDayOfWeek();
});

/// Provider for mood by hour of day
final moodByHourProvider = Provider.family<Map<int, double>, DateTime?>((ref, date) {
  final repo = ref.watch(journalRepositoryProvider);
  ref.watch(todayEntryProvider);
  if (date != null) {
    return repo.getMoodByHour(year: date.year, month: date.month);
  }
  return repo.getMoodByHour();
});

/// Provider for weekly summary
final weeklySummaryProvider = Provider<WeeklySummary>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  ref.watch(todayEntryProvider);
  return repo.getWeeklySummary();
});

/// Provider for mood velocity
final moodVelocityProvider = Provider.family<double, int>((ref, days) {
  final repo = ref.watch(journalRepositoryProvider);
  ref.watch(todayEntryProvider);
  return repo.getMoodVelocity(days: days);
});

/// Provider for mood volatility
final moodVolatilityProvider = Provider.family<double, int>((ref, days) {
  final repo = ref.watch(journalRepositoryProvider);
  ref.watch(todayEntryProvider);
  return repo.getMoodVolatility(days: days);
});

/// Provider for keyword frequency
final keywordFrequencyProvider = Provider.family<Map<String, int>, int?>((ref, limit) {
  final repo = ref.watch(journalRepositoryProvider);
  ref.watch(todayEntryProvider);
  return repo.getKeywordFrequency(limit: limit);
});

/// Provider for monthly comparison (current vs previous month)
final monthlyComparisonProvider = Provider<MonthlyComparison>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  ref.watch(todayEntryProvider);
  final now = DateTime.now();
  final currentMonth = DateTime(now.year, now.month);
  final previousMonth = DateTime(now.year, now.month - 1);
  return repo.compareMonths(previousMonth, currentMonth);
});

