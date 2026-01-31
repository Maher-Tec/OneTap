import 'package:hive_flutter/hive_flutter.dart';
import 'package:onetap/data/models/mood_goal.dart';
import 'package:onetap/data/models/mood_entry.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/core/utils/date_utils.dart' as app_date;

/// Repository for managing mood goals
class GoalRepository {
  static const String _goalsBoxName = 'mood_goals';

  late Box<MoodGoal> _goalsBox;
  final Box<MoodEntry> _entriesBox;

  GoalRepository(this._entriesBox);

  /// Initialize the goal repository
  static Future<GoalRepository> initialize(Box<MoodEntry> entriesBox) async {
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(MoodGoalAdapter());
    }

    final repo = GoalRepository(entriesBox);
    repo._goalsBox = await Hive.openBox<MoodGoal>(_goalsBoxName);
    return repo;
  }

  /// Get the mood goals box (for other repositories)
  Box<MoodGoal> get goalsBox => _goalsBox;

  // ==================== CRUD ====================

  /// Get all goals
  List<MoodGoal> getAllGoals() {
    return _goalsBox.values.toList();
  }

  /// Get active goals
  List<MoodGoal> getActiveGoals() {
    return _goalsBox.values.where((g) => g.isActive).toList();
  }

  /// Get completed goals
  List<MoodGoal> getCompletedGoals() {
    return _goalsBox.values.where((g) => g.isCompleted).toList();
  }

  /// Get goal by ID
  MoodGoal? getGoal(String id) {
    return _goalsBox.get(id);
  }

  /// Create a new goal
  Future<void> createGoal(MoodGoal goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  /// Update a goal
  Future<void> updateGoal(MoodGoal goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  /// Delete a goal
  Future<void> deleteGoal(String id) async {
    await _goalsBox.delete(id);
  }

  // ==================== PROGRESS ====================

  /// Calculate progress for a goal (current month)
  GoalProgress calculateProgress(MoodGoal goal, {int? year, int? month}) {
    final now = DateTime.now();
    final targetYear = year ?? now.year;
    final targetMonth = month ?? now.month;

    // Get all entries for the month
    final daysInMonth = app_date.DateUtils.daysInMonth(targetYear, targetMonth);
    int qualifyingDays = 0;
    int totalLoggedDays = 0;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(targetYear, targetMonth, day);
      if (date.isAfter(now)) break; // Don't count future days

      final dateKey = app_date.DateUtils.toDateKey(date);
      final entry = _entriesBox.get(dateKey);

      if (entry != null) {
        totalLoggedDays++;
        if (goal.moodCountsTowardGoal(entry.mood)) {
          qualifyingDays++;
        }
      }
    }

    final progressPercent = goal.targetDaysPerMonth > 0
        ? (qualifyingDays / goal.targetDaysPerMonth * 100).clamp(0.0, 100.0)
        : 0.0;

    final isComplete = qualifyingDays >= goal.targetDaysPerMonth;

    // Calculate days remaining in month
    final lastDayOfMonth = DateTime(targetYear, targetMonth, daysInMonth);
    final daysRemaining = lastDayOfMonth.difference(now).inDays.clamp(0, daysInMonth);
    final daysNeeded = (goal.targetDaysPerMonth - qualifyingDays).clamp(0, goal.targetDaysPerMonth);

    return GoalProgress(
      goal: goal,
      qualifyingDays: qualifyingDays,
      totalLoggedDays: totalLoggedDays,
      targetDays: goal.targetDaysPerMonth,
      progressPercent: progressPercent,
      isComplete: isComplete,
      daysRemaining: daysRemaining,
      daysNeeded: daysNeeded,
    );
  }

  /// Get progress for all active goals
  List<GoalProgress> getAllActiveProgress() {
    return getActiveGoals().map((g) => calculateProgress(g)).toList();
  }

  /// Check and mark goals as complete
  Future<List<MoodGoal>> checkAndCompleteGoals() async {
    final completed = <MoodGoal>[];
    
    for (final goal in getActiveGoals()) {
      final progress = calculateProgress(goal);
      if (progress.isComplete && !goal.isCompleted) {
        goal.markComplete();
        await updateGoal(goal);
        completed.add(goal);
      }
    }
    
    return completed;
  }
}

/// Progress data for a goal
class GoalProgress {
  final MoodGoal goal;
  final int qualifyingDays;
  final int totalLoggedDays;
  final int targetDays;
  final double progressPercent;
  final bool isComplete;
  final int daysRemaining;
  final int daysNeeded;

  const GoalProgress({
    required this.goal,
    required this.qualifyingDays,
    required this.totalLoggedDays,
    required this.targetDays,
    required this.progressPercent,
    required this.isComplete,
    required this.daysRemaining,
    required this.daysNeeded,
  });

  /// Get status message
  String get statusMessage {
    if (isComplete) return 'Goal Complete! 🎉';
    if (daysNeeded > daysRemaining) return 'Almost there, keep going!';
    if (progressPercent >= 75) return 'Great progress!';
    if (progressPercent >= 50) return 'Halfway there!';
    if (progressPercent >= 25) return 'Good start!';
    return 'Just getting started';
  }

  /// Get progress as fraction string
  String get progressFraction => '$qualifyingDays/$targetDays days';
}
