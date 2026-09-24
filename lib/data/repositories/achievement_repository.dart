import 'package:hive_flutter/hive_flutter.dart';
import 'package:onetap/data/models/achievement.dart';
import 'package:onetap/data/models/mood_entry.dart';
import 'package:onetap/data/models/mood_goal.dart';
import 'package:onetap/core/constants/achievement_definitions.dart';
import 'package:onetap/core/constants/mood_level.dart';

/// Repository for managing achievements
class AchievementRepository {
  static const String _achievementsBoxName = 'achievements';

  late Box<Achievement> _achievementsBox;
  final Box<MoodEntry> _entriesBox;
  final Box<MoodGoal> _goalsBox;

  AchievementRepository(this._entriesBox, this._goalsBox);

  /// Initialize the achievement repository
  static Future<AchievementRepository> initialize({
    required Box<MoodEntry> entriesBox,
    required Box<MoodGoal> goalsBox,
  }) async {
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AchievementAdapter());
    }

    final repo = AchievementRepository(entriesBox, goalsBox);
    repo._achievementsBox = await Hive.openBox<Achievement>(_achievementsBoxName);

    // Initialize achievements from catalog if first time
    if (repo._achievementsBox.isEmpty) {
      await repo._initializeAchievements();
    }

    return repo;
  }

  /// Initialize achievements from catalog
  Future<void> _initializeAchievements() async {
    final allAchievements = AchievementDefinitions.getAllAchievements();
    for (final achievement in allAchievements) {
      await _achievementsBox.put(achievement.id, achievement);
    }
  }

  /// Clear user progress while keeping the achievement catalog.
  Future<void> resetProgress() async {
    for (final achievement in _achievementsBox.values) {
      await updateAchievement(achievement.copyWith(
        isUnlocked: false,
        clearUnlockedAt: true,
        currentProgress: 0,
      ));
    }
  }

  // ==================== CRUD ====================

  /// Get all achievements
  List<Achievement> getAllAchievements() {
    return _achievementsBox.values.toList()
      ..sort((a, b) {
        // Sort by tier first, then by unlock status
        final tierCompare = a.tierIndex.compareTo(b.tierIndex);
        if (tierCompare != 0) return tierCompare;
        if (a.isUnlocked && !b.isUnlocked) return -1;
        if (!a.isUnlocked && b.isUnlocked) return 1;
        return 0;
      });
  }

  /// Get unlocked achievements
  List<Achievement> getUnlockedAchievements() {
    return _achievementsBox.values.where((a) => a.isUnlocked).toList()
      ..sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));
  }

  /// Get locked achievements
  List<Achievement> getLockedAchievements() {
    return _achievementsBox.values.where((a) => !a.isUnlocked).toList();
  }

  /// Get recently unlocked achievements (last 7 days)
  List<Achievement> getRecentlyUnlocked() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return getUnlockedAchievements()
        .where((a) => a.unlockedAt!.isAfter(weekAgo))
        .toList();
  }

  /// Get achievements by tier
  List<Achievement> getAchievementsByTier(AchievementTier tier) {
    return _achievementsBox.values
        .where((a) => a.tier == tier)
        .toList();
  }

  /// Get achievements by type
  List<Achievement> getAchievementsByType(AchievementType type) {
    return _achievementsBox.values
        .where((a) => a.type == type)
        .toList();
  }

  /// Get achievement by ID
  Achievement? getAchievement(String id) {
    return _achievementsBox.get(id);
  }

  /// Update achievement
  Future<void> updateAchievement(Achievement achievement) async {
    await _achievementsBox.put(achievement.id, achievement);
  }

  // ==================== PROGRESS TRACKING ====================

  /// Check and update all achievements based on current data
  Future<List<Achievement>> checkAndUnlockAchievements() async {
    final newlyUnlocked = <Achievement>[];

    // Calculate current stats
    final totalEntries = _entriesBox.length;
    final currentStreak = _calculateCurrentStreak();
    final completedGoals = _goalsBox.values.where((g) => g.isCompleted).length;
    
    // Count mood-specific entries
    final greatDays = _entriesBox.values
        .where((e) => e.mood == MoodLevel.great || e.mood == MoodLevel.inLove)
        .length;
    final positiveDays = _entriesBox.values
        .where((e) => e.mood.isPositive)
        .length;

    // Count special entries
    final earlyBirdEntries = _entriesBox.values
        .where((e) => e.createdAt.hour < 9)
        .length;
    final nightOwlEntries = _entriesBox.values
        .where((e) => e.createdAt.hour >= 21)
        .length;
    final weekendEntries = _entriesBox.values
        .where((e) => e.createdAt.weekday == DateTime.saturday || 
                      e.createdAt.weekday == DateTime.sunday)
        .length;

    // Check each achievement
    for (final achievement in _achievementsBox.values) {
      if (achievement.isUnlocked) continue;

      int currentProgress = 0;

      switch (achievement.type) {
        case AchievementType.streak:
          currentProgress = currentStreak;
          break;
        case AchievementType.totalEntries:
          currentProgress = totalEntries;
          break;
        case AchievementType.mood:
          if (achievement.id.contains('great')) {
            currentProgress = greatDays;
          } else if (achievement.id.contains('positive')) {
            currentProgress = positiveDays;
          }
          break;
        case AchievementType.consistency:
          currentProgress = currentStreak;
          break;
        case AchievementType.goal:
          currentProgress = completedGoals;
          break;
        case AchievementType.special:
          if (achievement.id.contains('early_bird')) {
            currentProgress = earlyBirdEntries;
          } else if (achievement.id.contains('night_owl')) {
            currentProgress = nightOwlEntries;
          } else if (achievement.id.contains('weekend')) {
            currentProgress = weekendEntries;
          }
          break;
      }

      // Update progress
      final updated = achievement.copyWith(currentProgress: currentProgress);
      
      // Check if unlocked
      if (updated.currentProgress >= updated.targetValue && !updated.isUnlocked) {
        updated.unlock();
        newlyUnlocked.add(updated);
      }

      await updateAchievement(updated);
    }

    return newlyUnlocked;
  }

  /// Calculate current streak
  int _calculateCurrentStreak() {
    if (_entriesBox.isEmpty) return 0;

    final now = DateTime.now();
    var currentDate = DateTime(now.year, now.month, now.day);
    var streak = 0;

    // Check if today has an entry
    final todayKey = _dateKey(currentDate);
    final todayEntry = _entriesBox.get(todayKey);
    
    if (todayEntry == null) {
      // If no entry today, start from yesterday
      currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day - 1);
    }

    // Count consecutive days
    while (true) {
      final key = _dateKey(currentDate);
      final entry = _entriesBox.get(key);
      
      if (entry == null) break;
      
      streak++;
      currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day - 1);
    }

    return streak;
  }

  /// Get date key for entry lookup
  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ==================== STATS ====================

  /// Get total unlocked count
  int get totalUnlocked => getUnlockedAchievements().length;

  /// Get total achievements count
  int get totalAchievements => _achievementsBox.length;

  /// Get completion percentage
  double get completionPercent {
    if (totalAchievements == 0) return 0.0;
    return (totalUnlocked / totalAchievements * 100);
  }

  /// Get rarest unlocked achievement
  Achievement? get rarestUnlocked {
    final unlocked = getUnlockedAchievements();
    if (unlocked.isEmpty) return null;
    
    unlocked.sort((a, b) => b.tierIndex.compareTo(a.tierIndex));
    return unlocked.first;
  }
}
