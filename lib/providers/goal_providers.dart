import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:onetap/data/repositories/goal_repository.dart';
import 'package:onetap/data/models/mood_goal.dart';
import 'package:onetap/providers/journal_providers.dart';

/// Provider for the goal repository
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  throw UnimplementedError('GoalRepository must be initialized before use');
});

/// Provider for all active goals
final activeGoalsProvider = Provider<List<MoodGoal>>((ref) {
  final repo = ref.watch(goalRepositoryProvider);
  // Refresh when entries or goals change
  ref.watch(todayEntryProvider);
  ref.watch(goalNotifierProvider); // Watch goal changes
  return repo.getActiveGoals();
});

/// Provider for completed goals
final completedGoalsProvider = Provider<List<MoodGoal>>((ref) {
  final repo = ref.watch(goalRepositoryProvider);
  ref.watch(goalNotifierProvider); // Watch goal changes
  return repo.getCompletedGoals();
});

/// Provider for progress of all active goals
final activeGoalsProgressProvider = Provider<List<GoalProgress>>((ref) {
  final repo = ref.watch(goalRepositoryProvider);
  // Refresh when entries or goals change
  ref.watch(todayEntryProvider);
  ref.watch(goalNotifierProvider); // Watch goal changes
  return repo.getAllActiveProgress();
});

/// Provider for a single goal's progress
final goalProgressProvider = Provider.family<GoalProgress?, String>((ref, goalId) {
  final repo = ref.watch(goalRepositoryProvider);
  // Refresh when entries change
  ref.watch(todayEntryProvider);
  final goal = repo.getGoal(goalId);
  if (goal == null) return null;
  return repo.calculateProgress(goal);
});

/// State notifier for managing goals
final goalNotifierProvider = StateNotifierProvider<GoalNotifier, List<MoodGoal>>((ref) {
  final repo = ref.watch(goalRepositoryProvider);
  return GoalNotifier(repo);
});

class GoalNotifier extends StateNotifier<List<MoodGoal>> {
  final GoalRepository _repo;

  GoalNotifier(this._repo) : super(_repo.getAllGoals());

  /// Create a new goal
  Future<void> createGoal(MoodGoal goal) async {
    await _repo.createGoal(goal);
    state = _repo.getAllGoals();
  }

  /// Create goal from template
  Future<void> createFromTemplate({
    required String type,
    required int targetDays,
  }) async {
    MoodGoal goal;
    switch (type) {
      case 'positive':
        goal = GoalTemplates.positiveDaysGoal(targetDays);
        break;
      case 'great':
        goal = GoalTemplates.greatDaysGoal(targetDays);
        break;
      case 'consistency':
        goal = GoalTemplates.consistencyGoal(targetDays);
        break;
      default:
        goal = GoalTemplates.positiveDaysGoal(targetDays);
    }
    await createGoal(goal);
  }

  /// Update a goal
  Future<void> updateGoal(MoodGoal goal) async {
    await _repo.updateGoal(goal);
    state = _repo.getAllGoals();
  }

  /// Delete a goal
  Future<void> deleteGoal(String id) async {
    await _repo.deleteGoal(id);
    state = _repo.getAllGoals();
  }

  /// Check and complete goals that have been achieved
  Future<List<MoodGoal>> checkAndCompleteGoals() async {
    final completed = await _repo.checkAndCompleteGoals();
    if (completed.isNotEmpty) {
      state = _repo.getAllGoals();
    }
    return completed;
  }

  /// Refresh from storage
  void refresh() {
    state = _repo.getAllGoals();
  }
}
