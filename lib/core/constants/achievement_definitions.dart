import 'package:onetap/data/models/achievement.dart';

/// Predefined achievement catalog for the app
class AchievementDefinitions {
  /// Get all achievements (catalog)
  static List<Achievement> getAllAchievements() {
    return [
      // ==================== STREAK ACHIEVEMENTS ====================
      _createAchievement(
        id: 'streak_3',
        name: 'First Steps',
        description: 'Maintain a 3-day streak',
        emoji: '🌱',
        tier: AchievementTier.bronze,
        type: AchievementType.streak,
        targetValue: 3,
      ),
      _createAchievement(
        id: 'streak_7',
        name: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        emoji: '🔥',
        tier: AchievementTier.silver,
        type: AchievementType.streak,
        targetValue: 7,
      ),
      _createAchievement(
        id: 'streak_14',
        name: 'Two Week Champion',
        description: 'Maintain a 14-day streak',
        emoji: '⚡',
        tier: AchievementTier.silver,
        type: AchievementType.streak,
        targetValue: 14,
      ),
      _createAchievement(
        id: 'streak_30',
        name: 'Monthly Master',
        description: 'Maintain a 30-day streak',
        emoji: '🌟',
        tier: AchievementTier.gold,
        type: AchievementType.streak,
        targetValue: 30,
      ),
      _createAchievement(
        id: 'streak_60',
        name: 'Two Month Legend',
        description: 'Maintain a 60-day streak',
        emoji: '💫',
        tier: AchievementTier.gold,
        type: AchievementType.streak,
        targetValue: 60,
      ),
      _createAchievement(
        id: 'streak_100',
        name: 'Centurion',
        description: 'Maintain a 100-day streak',
        emoji: '🏆',
        tier: AchievementTier.platinum,
        type: AchievementType.streak,
        targetValue: 100,
      ),
      _createAchievement(
        id: 'streak_365',
        name: 'Year of Growth',
        description: 'Maintain a 365-day streak',
        emoji: '👑',
        tier: AchievementTier.diamond,
        type: AchievementType.streak,
        targetValue: 365,
      ),

      // ==================== TOTAL ENTRIES ACHIEVEMENTS ====================
      _createAchievement(
        id: 'entries_10',
        name: 'Getting Started',
        description: 'Log 10 mood entries',
        emoji: '📝',
        tier: AchievementTier.bronze,
        type: AchievementType.totalEntries,
        targetValue: 10,
      ),
      _createAchievement(
        id: 'entries_50',
        name: 'Committed',
        description: 'Log 50 mood entries',
        emoji: '📖',
        tier: AchievementTier.silver,
        type: AchievementType.totalEntries,
        targetValue: 50,
      ),
      _createAchievement(
        id: 'entries_100',
        name: 'Dedicated',
        description: 'Log 100 mood entries',
        emoji: '📚',
        tier: AchievementTier.gold,
        type: AchievementType.totalEntries,
        targetValue: 100,
      ),
      _createAchievement(
        id: 'entries_365',
        name: 'Year Complete',
        description: 'Log 365 mood entries',
        emoji: '🎯',
        tier: AchievementTier.platinum,
        type: AchievementType.totalEntries,
        targetValue: 365,
      ),
      _createAchievement(
        id: 'entries_1000',
        name: 'Millennium',
        description: 'Log 1000 mood entries',
        emoji: '🌌',
        tier: AchievementTier.diamond,
        type: AchievementType.totalEntries,
        targetValue: 1000,
      ),

      // ==================== MOOD ACHIEVEMENTS ====================
      _createAchievement(
        id: 'great_10',
        name: 'Great Day Starter',
        description: 'Log 10 great days',
        emoji: '😄',
        tier: AchievementTier.bronze,
        type: AchievementType.mood,
        targetValue: 10,
      ),
      _createAchievement(
        id: 'positive_30',
        name: 'Positivity Pro',
        description: 'Log 30 positive days',
        emoji: '😊',
        tier: AchievementTier.silver,
        type: AchievementType.mood,
        targetValue: 30,
      ),
      _createAchievement(
        id: 'great_100',
        name: 'Sunshine Soul',
        description: 'Log 100 great days',
        emoji: '🌞',
        tier: AchievementTier.gold,
        type: AchievementType.mood,
        targetValue: 100,
      ),

      // ==================== CONSISTENCY ACHIEVEMENTS ====================
      _createAchievement(
        id: 'perfect_week',
        name: 'Perfect Week',
        description: 'Log every day for a week',
        emoji: '📅',
        tier: AchievementTier.silver,
        type: AchievementType.consistency,
        targetValue: 7,
      ),
      _createAchievement(
        id: 'perfect_month',
        name: 'Flawless Month',
        description: 'Log every day for a month',
        emoji: '🗓️',
        tier: AchievementTier.platinum,
        type: AchievementType.consistency,
        targetValue: 30,
      ),

      // ==================== GOAL ACHIEVEMENTS ====================
      _createAchievement(
        id: 'goal_first',
        name: 'First Goal Complete',
        description: 'Complete your first goal',
        emoji: '🎖️',
        tier: AchievementTier.silver,
        type: AchievementType.goal,
        targetValue: 1,
      ),
      _createAchievement(
        id: 'goal_5',
        name: 'Goal Getter',
        description: 'Complete 5 goals',
        emoji: '🏅',
        tier: AchievementTier.gold,
        type: AchievementType.goal,
        targetValue: 5,
      ),
      _createAchievement(
        id: 'goal_10',
        name: 'Goal Master',
        description: 'Complete 10 goals',
        emoji: '🥇',
        tier: AchievementTier.platinum,
        type: AchievementType.goal,
        targetValue: 10,
      ),

      // ==================== SPECIAL ACHIEVEMENTS ====================
      _createAchievement(
        id: 'early_bird',
        name: 'Early Bird',
        description: 'Log 10 entries before 9 AM',
        emoji: '🌅',
        tier: AchievementTier.bronze,
        type: AchievementType.special,
        targetValue: 10,
      ),
      _createAchievement(
        id: 'night_owl',
        name: 'Night Owl',
        description: 'Log 10 entries after 9 PM',
        emoji: '🌙',
        tier: AchievementTier.bronze,
        type: AchievementType.special,
        targetValue: 10,
      ),
      _createAchievement(
        id: 'weekend_warrior',
        name: 'Weekend Warrior',
        description: 'Log 10 weekend entries',
        emoji: '🎉',
        tier: AchievementTier.bronze,
        type: AchievementType.special,
        targetValue: 10,
      ),
    ];
  }

  /// Helper to create achievement
  static Achievement _createAchievement({
    required String id,
    required String name,
    required String description,
    required String emoji,
    required AchievementTier tier,
    required AchievementType type,
    required int targetValue,
  }) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      tierIndex: tier.index,
      typeIndex: type.index,
      targetValue: targetValue,
    );
  }

  /// Get achievements by tier
  static List<Achievement> getAchievementsByTier(AchievementTier tier) {
    return getAllAchievements()
        .where((a) => a.tier == tier)
        .toList();
  }

  /// Get achievements by type
  static List<Achievement> getAchievementsByType(AchievementType type) {
    return getAllAchievements()
        .where((a) => a.type == type)
        .toList();
  }
}
