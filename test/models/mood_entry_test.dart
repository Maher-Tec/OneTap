import 'package:flutter_test/flutter_test.dart';
import 'package:onetap/data/models/mood_entry.dart';
import 'package:onetap/core/constants/mood_level.dart';

void main() {
  group('MoodEntry', () {
    test('MoodEntry can be created with all required fields', () {
      final entry = MoodEntry(
        dateKey: '2024-01-28',
        moodIndex: 0,
        createdAt: DateTime(2024, 1, 28),
      );

      expect(entry.dateKey, '2024-01-28');
      expect(entry.moodIndex, 0);
      expect(entry.note, null);
      expect(entry.createdAt, DateTime(2024, 1, 28));
    });

    test('MoodEntry.mood returns correct MoodLevel from index', () {
      final entry = MoodEntry(
        dateKey: '2024-01-28',
        moodIndex: 0,
        createdAt: DateTime.now(),
      );
      expect(entry.mood, MoodLevel.great);

      final entry2 = MoodEntry(
        dateKey: '2024-01-28',
        moodIndex: 4,
        createdAt: DateTime.now(),
      );
      expect(entry2.mood, MoodLevel.bad);
    });

    test('MoodEntry can be created with optional note', () {
      final entry = MoodEntry(
        dateKey: '2024-01-28',
        moodIndex: 1,
        note: 'Feeling great today',
        createdAt: DateTime.now(),
      );

      expect(entry.note, 'Feeling great today');
    });

    test('MoodEntry.create factory creates entry from MoodLevel', () {
      final entry = MoodEntry.create(
        dateKey: '2024-01-28',
        mood: MoodLevel.good,
        note: 'Productive day',
      );

      expect(entry.dateKey, '2024-01-28');
      expect(entry.mood, MoodLevel.good);
      expect(entry.moodIndex, 1);
      expect(entry.note, 'Productive day');
      expect(entry.createdAt.isAfter(DateTime.now().subtract(const Duration(seconds: 1))), true);
    });

    test('MoodEntry.create factory works without note', () {
      final entry = MoodEntry.create(
        dateKey: '2024-01-28',
        mood: MoodLevel.okay,
      );

      expect(entry.dateKey, '2024-01-28');
      expect(entry.mood, MoodLevel.okay);
      expect(entry.note, null);
    });

    test('MoodEntry.toString provides readable format', () {
      final entry = MoodEntry.create(
        dateKey: '2024-01-28',
        mood: MoodLevel.great,
        note: 'Amazing day',
      );

      final string = entry.toString();
      expect(string.contains('2024-01-28'), true);
      expect(string.contains('🤩'), true);
      expect(string.contains('Amazing day'), true);
    });

    test('MoodEntry with all moods creates correct entries', () {
      final moods = [
        (MoodLevel.great, 0, '🤩'),
        (MoodLevel.good, 1, '😊'),
        (MoodLevel.okay, 2, '😐'),
        (MoodLevel.meh, 3, '😔'),
        (MoodLevel.bad, 4, '😣'),
        (MoodLevel.inLove, 5, '😍'),
      ];

      for (final (mood, index, emoji) in moods) {
        final entry = MoodEntry.create(
          dateKey: '2024-01-28',
          mood: mood,
        );
        expect(entry.moodIndex, index);
        expect(entry.mood.emoji, emoji);
      }
    });
  });
}
