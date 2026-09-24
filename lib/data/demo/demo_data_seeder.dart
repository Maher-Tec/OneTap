import 'package:hive/hive.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/core/utils/date_utils.dart' as app_date;
import 'package:onetap/data/models/mood_entry.dart';

/// Seeds local sample history for screenshots and demo recordings.
/// Normal app builds never call this seeder.
class DemoDataSeeder {
  DemoDataSeeder._();

  static Future<void> seedIfEmpty(Box<MoodEntry> entriesBox) async {
    final today = DateTime.now();
    const moods = [
      MoodLevel.good,
      MoodLevel.great,
      MoodLevel.okay,
      MoodLevel.inLove,
      MoodLevel.meh,
      MoodLevel.good,
      MoodLevel.great,
      MoodLevel.bad,
    ];
    const notes = [
      'A calm start and a good walk.',
      'Finished a task I had delayed.',
      'Taking today one step at a time.',
      'Had a lovely moment with family.',
      'A slow day, but I checked in.',
      'Good conversation with a friend.',
      'Proud of the progress I made.',
      'A difficult day; giving myself rest.',
    ];

    // Leave today empty so a demo can still show the mood logging flow.
    for (var daysAgo = 1; daysAgo <= 35; daysAgo++) {
      // Leave a few gaps so the calendar looks like realistic history.
      if (daysAgo > 7 && daysAgo % 9 == 0) continue;

      final date = DateTime(today.year, today.month, today.day - daysAgo);
      final dateKey = app_date.DateUtils.toDateKey(date);
      // Preserve anything the user already logged on this date.
      if (entriesBox.containsKey(dateKey)) continue;

      final sampleIndex = daysAgo % moods.length;
      final entry = MoodEntry(
        dateKey: dateKey,
        moodIndex: moods[sampleIndex].index,
        note: notes[sampleIndex],
        createdAt: DateTime(date.year, date.month, date.day, 8 + (daysAgo % 14)),
      );
      await entriesBox.put(entry.dateKey, entry);
    }
  }
}
