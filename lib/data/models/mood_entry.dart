import 'package:hive/hive.dart';
import 'package:onetap/core/constants/mood_level.dart';

part 'mood_entry.g.dart';

/// A single mood journal entry
@HiveType(typeId: 0)
class MoodEntry extends HiveObject {
  /// The date key in yyyy-MM-dd format (also used as box key)
  @HiveField(0)
  final String dateKey;

  /// The mood level for this entry
  @HiveField(1)
  final int moodIndex;

  /// Optional note (max 25 chars)
  @HiveField(2)
  final String? note;

  /// When this entry was created
  @HiveField(3)
  final DateTime createdAt;

  MoodEntry({
    required this.dateKey,
    required this.moodIndex,
    this.note,
    required this.createdAt,
  });

  /// Get the MoodLevel enum from the stored index
  MoodLevel get mood => moodIndex >= 0 && moodIndex < MoodLevel.values.length
      ? MoodLevel.values[moodIndex]
      : MoodLevel.okay;

  /// Create a MoodEntry with a MoodLevel
  factory MoodEntry.create({
    required String dateKey,
    required MoodLevel mood,
    String? note,
  }) {
    return MoodEntry(
      dateKey: dateKey,
      moodIndex: mood.index,
      note: note,
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'MoodEntry(date: $dateKey, mood: ${mood.emoji}, note: $note)';
  }
}
