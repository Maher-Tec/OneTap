import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:onetap/data/repositories/achievement_repository.dart';
import 'package:onetap/data/models/achievement.dart';

import 'package:onetap/providers/journal_providers.dart';

/// Provider for the achievement repository
final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  throw UnimplementedError('AchievementRepository must be initialized before use');
});

/// Provider for all achievements
final allAchievementsProvider = Provider<List<Achievement>>((ref) {
  final repo = ref.watch(achievementRepositoryProvider);
  ref.watch(todayEntryProvider);
  ref.watch(achievementNotifierProvider);
  return repo.getAllAchievements();
});

/// Provider for unlocked achievements
final unlockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  final repo = ref.watch(achievementRepositoryProvider);
  ref.watch(todayEntryProvider);
  ref.watch(achievementNotifierProvider);
  return repo.getUnlockedAchievements();
});

/// Provider for locked achievements  
final lockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  final repo = ref.watch(achievementRepositoryProvider);
  ref.watch(todayEntryProvider);
  ref.watch(achievementNotifierProvider);
  return repo.getLockedAchievements();
});

/// Provider for recently unlocked achievements (last 7 days)
final recentlyUnlockedProvider = Provider<List<Achievement>>((ref) {
  final repo = ref.watch(achievementRepositoryProvider);
  ref.watch(todayEntryProvider);
  ref.watch(achievementNotifierProvider);
  return repo.getRecentlyUnlocked();
});

/// Provider for achievements by tier
final achievementsByTierProvider = Provider.family<List<Achievement>, AchievementTier>((ref, tier) {
  final repo = ref.watch(achievementRepositoryProvider);
  ref.watch(todayEntryProvider);
  ref.watch(achievementNotifierProvider);
  return repo.getAchievementsByTier(tier);
});

/// Provider for achievements by type
final achievementsByTypeProvider = Provider.family<List<Achievement>, AchievementType>((ref, type) {
  final repo = ref.watch(achievementRepositoryProvider);
  ref.watch(todayEntryProvider);
  ref.watch(achievementNotifierProvider);
  return repo.getAchievementsByType(type);
});

/// Provider for achievement stats
final achievementStatsProvider = Provider<AchievementStats>((ref) {
  final repo = ref.watch(achievementRepositoryProvider);
  ref.watch(todayEntryProvider);
  ref.watch(achievementNotifierProvider);
  return AchievementStats(
    totalUnlocked: repo.totalUnlocked,
    totalAchievements: repo.totalAchievements,
    completionPercent: repo.completionPercent,
    rarestUnlocked: repo.rarestUnlocked,
  );
});

/// Achievement statistics data class
class AchievementStats {
  final int totalUnlocked;
  final int totalAchievements;
  final double completionPercent;
  final Achievement? rarestUnlocked;

  const AchievementStats({
    required this.totalUnlocked,
    required this.totalAchievements,
    required this.completionPercent,
    this.rarestUnlocked,
  });

  String get progressString => '$totalUnlocked/$totalAchievements';
}

/// State notifier for managing achievements
final achievementNotifierProvider = StateNotifierProvider<AchievementNotifier, List<Achievement>>((ref) {
  final repo = ref.watch(achievementRepositoryProvider);
  return AchievementNotifier(repo);
});

class AchievementNotifier extends StateNotifier<List<Achievement>> {
  final AchievementRepository _repo;

  AchievementNotifier(this._repo) : super(_repo.getAllAchievements());

  /// Check and unlock achievements
  Future<List<Achievement>> checkAndUnlock() async {
    final newlyUnlocked = await _repo.checkAndUnlockAchievements();
    state = _repo.getAllAchievements();
    return newlyUnlocked;
  }

  /// Manually unlock achievement (for testing)
  Future<void> unlockAchievement(String id) async {
    final achievement = _repo.getAchievement(id);
    if (achievement != null && !achievement.isUnlocked) {
      achievement.unlock();
      await _repo.updateAchievement(achievement);
      state = _repo.getAllAchievements();
    }
  }

  /// Refresh achievements list
  void refresh() {
    state = _repo.getAllAchievements();
  }

  Future<void> resetProgress() async {
    await _repo.resetProgress();
    state = _repo.getAllAchievements();
  }
}
