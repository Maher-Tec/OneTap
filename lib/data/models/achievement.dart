import 'package:hive/hive.dart';

part 'achievement.g.dart';

/// Achievement tier/rarity levels
enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond;

  String get label => name[0].toUpperCase() + name.substring(1);

  String get emoji {
    switch (this) {
      case AchievementTier.bronze:
        return '🥉';
      case AchievementTier.silver:
        return '🥈';
      case AchievementTier.gold:
        return '🥇';
      case AchievementTier.platinum:
        return '💎';
      case AchievementTier.diamond:
        return '👑';
    }
  }
}

/// Achievement type categories
enum AchievementType {
  streak,
  totalEntries,
  mood,
  consistency,
  goal,
  special;

  String get label {
    switch (this) {
      case AchievementType.streak:
        return 'Streak';
      case AchievementType.totalEntries:
        return 'Total Entries';
      case AchievementType.mood:
        return 'Mood';
      case AchievementType.consistency:
        return 'Consistency';
      case AchievementType.goal:
        return 'Goals';
      case AchievementType.special:
        return 'Special';
    }
  }
}

/// Achievement badge model
@HiveType(typeId: 4)
class Achievement {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String emoji;

  @HiveField(4)
  final int tierIndex; // AchievementTier index

  @HiveField(5)
  final int typeIndex; // AchievementType index

  @HiveField(6)
  final int targetValue; // Criteria value to unlock

  @HiveField(7)
  DateTime? unlockedAt;

  @HiveField(8)
  bool isUnlocked;

  @HiveField(9)
  int currentProgress; // Current progress toward unlock

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.tierIndex,
    required this.typeIndex,
    required this.targetValue,
    this.unlockedAt,
    this.isUnlocked = false,
    this.currentProgress = 0,
  });

  /// Get achievement tier
  AchievementTier get tier => AchievementTier.values[tierIndex];

  /// Get achievement type
  AchievementType get type => AchievementType.values[typeIndex];

  /// Get progress percentage
  double get progressPercent {
    if (isUnlocked) return 100.0;
    if (targetValue <= 0) return 0.0;
    return (currentProgress / targetValue * 100).clamp(0.0, 100.0);
  }

  /// Get progress string (e.g., "5/10")
  String get progressString => '$currentProgress/$targetValue';

  /// Check if achievement is almost unlocked (>= 80% progress)
  bool get isAlmostUnlocked => progressPercent >= 80 && !isUnlocked;

  /// Unlock the achievement
  void unlock() {
    if (!isUnlocked) {
      isUnlocked = true;
      unlockedAt = DateTime.now();
      currentProgress = targetValue;
    }
  }

  /// Update progress
  void updateProgress(int value) {
    if (!isUnlocked) {
      currentProgress = value.clamp(0, targetValue);
      if (currentProgress >= targetValue) {
        unlock();
      }
    }
  }

  /// Create a copy with updated fields
  Achievement copyWith({
    DateTime? unlockedAt,
    bool clearUnlockedAt = false,
    bool? isUnlocked,
    int? currentProgress,
  }) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      tierIndex: tierIndex,
      typeIndex: typeIndex,
      targetValue: targetValue,
      unlockedAt: clearUnlockedAt ? null : unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  @override
  String toString() => 'Achievement($name, ${tier.label}, $progressString)';
}
