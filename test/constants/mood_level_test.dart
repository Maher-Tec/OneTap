import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetap/core/constants/mood_level.dart';

void main() {
  group('MoodLevelExtension', () {
    test('emoji returns correct emoji for each mood', () {
      expect(MoodLevel.great.emoji, '😄');
      expect(MoodLevel.good.emoji, '🙂');
      expect(MoodLevel.okay.emoji, '😐');
      expect(MoodLevel.meh.emoji, '😕');
      expect(MoodLevel.bad.emoji, '😡');
    });

    test('label returns correct label for each mood', () {
      expect(MoodLevel.great.label, 'Great');
      expect(MoodLevel.good.label, 'Good');
      expect(MoodLevel.okay.label, 'Okay');
      expect(MoodLevel.meh.label, 'Meh');
      expect(MoodLevel.bad.label, 'Bad');
    });

    test('color returns valid color for each mood', () {
      final moods = [
        MoodLevel.great,
        MoodLevel.good,
        MoodLevel.okay,
        MoodLevel.meh,
        MoodLevel.bad,
      ];

      for (final mood in moods) {
        final color = mood.color;
        expect(color is Color, true);
        expect(color.alpha > 0, true); // Color has alpha > 0
      }
    });

    test('color values are distinct for each mood', () {
      final colors = <Color>{
        MoodLevel.great.color,
        MoodLevel.good.color,
        MoodLevel.okay.color,
        MoodLevel.meh.color,
        MoodLevel.bad.color,
      };

      // Should have 5 distinct colors
      expect(colors.length, 5);
    });

    test('color green is for great mood', () {
      final greatColor = MoodLevel.great.color;
      // Green: value should be high in green channel
      expect(greatColor.green > 150, true);
    });

    test('color red is for bad mood', () {
      final badColor = MoodLevel.bad.color;
      // Red: value should be high in red channel
      expect(badColor.red > 150, true);
    });

    test('hapticWeight returns increasing value per mood', () {
      expect(MoodLevel.great.hapticWeight, 1);
      expect(MoodLevel.good.hapticWeight, 2);
      expect(MoodLevel.okay.hapticWeight, 3);
      expect(MoodLevel.meh.hapticWeight, 4);
      expect(MoodLevel.bad.hapticWeight, 5);
    });

    test('hapticWeight is in valid range', () {
      for (final mood in MoodLevel.values) {
        expect(mood.hapticWeight >= 1 && mood.hapticWeight <= 5, true);
      }
    });

    test('all moods have emoji', () {
      for (final mood in MoodLevel.values) {
        expect(mood.emoji.isNotEmpty, true);
      }
    });

    test('all moods have labels', () {
      for (final mood in MoodLevel.values) {
        expect(mood.label.isNotEmpty, true);
      }
    });

    test('mood progression goes from happy to sad', () {
      final moods = MoodLevel.values;
      // Great > Good > Okay > Meh > Bad (in terms of positivity)
      expect(moods[0], MoodLevel.great);
      expect(moods[4], MoodLevel.bad);
    });
  });
}
