import 'package:hive/hive.dart';
import 'package:onetap/core/constants/mood_level.dart';

part 'mood_goal.g.dart';

/// A mood improvement goal
@HiveType(typeId: 3)
class MoodGoal {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int targetDaysPerMonth;

  @HiveField(3)
  List<int> targetMoodIndices; // Indices of moods that count as success

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  DateTime? completedAt;

  @HiveField(6)
  bool isActive;

  MoodGoal({
    required this.id,
    required this.name,
    required this.targetDaysPerMonth,
    required this.targetMoodIndices,
    required this.createdAt,
    this.completedAt,
    this.isActive = true,
  });

  /// Factory to create a new goal
  factory MoodGoal.create({
    required String name,
    required int targetDaysPerMonth,
    required List<MoodLevel> targetMoods,
  }) {
    return MoodGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      targetDaysPerMonth: targetDaysPerMonth,
      targetMoodIndices: targetMoods.map((m) => m.index).toList(),
      createdAt: DateTime.now(),
      isActive: true,
    );
  }

  /// Get target moods as MoodLevel list
  List<MoodLevel> get targetMoods {
    return targetMoodIndices
        .where((i) => i >= 0 && i < MoodLevel.values.length)
        .map((i) => MoodLevel.values[i])
        .toList();
  }

  /// Check if a mood counts toward this goal
  bool moodCountsTowardGoal(MoodLevel mood) {
    return targetMoodIndices.contains(mood.index);
  }

  /// Mark goal as complete
  void markComplete() {
    completedAt = DateTime.now();
    isActive = false;
  }

  /// Goal is completed
  bool get isCompleted => completedAt != null;

  /// Get goal type label
  String get typeLabel {
    if (targetMoodIndices.contains(0) && targetMoodIndices.contains(1)) {
      return 'Positive Days';
    } else if (targetMoodIndices.length == 1 &&
        targetMoodIndices.first >= 0 &&
        targetMoodIndices.first < MoodLevel.values.length) {
      return MoodLevel.values[targetMoodIndices.first].label;
    }
    return 'Custom Goal';
  }

  /// Get emoji for goal
  String get emoji {
    if (targetMoodIndices.contains(0)) return '🌟';
    if (targetMoodIndices.contains(1)) return '😊';
    return '🎯';
  }

  @override
  String toString() => 'MoodGoal($name: $targetDaysPerMonth days of $typeLabel)';
}

/// Preset goal templates
class GoalTemplates {
  static MoodGoal positiveDaysGoal(int targetDays) {
    return MoodGoal.create(
      name: '$targetDays Positive Days',
      targetDaysPerMonth: targetDays,
      targetMoods: [MoodLevel.great, MoodLevel.good, MoodLevel.inLove],
    );
  }

  static MoodGoal greatDaysGoal(int targetDays) {
    return MoodGoal.create(
      name: '$targetDays Great Days',
      targetDaysPerMonth: targetDays,
      targetMoods: [MoodLevel.great, MoodLevel.inLove],
    );
  }

  static MoodGoal consistencyGoal(int targetDays) {
    return MoodGoal.create(
      name: 'Log $targetDays Days',
      targetDaysPerMonth: targetDays,
      targetMoods: MoodLevel.values, // Any mood counts
    );
  }
}
