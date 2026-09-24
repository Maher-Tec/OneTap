import 'package:flutter_test/flutter_test.dart';
import 'package:onetap/core/constants/mood_level.dart';

void main() {
  group('MoodLevelExtension', () {
    test('emoji returns correct emoji for each mood', () {
      expect(MoodLevel.great.emoji, '🤩');
      expect(MoodLevel.good.emoji, '😊');
      expect(MoodLevel.okay.emoji, '😐');
      expect(MoodLevel.meh.emoji, '😔');
      expect(MoodLevel.bad.emoji, '😣');
      expect(MoodLevel.inLove.emoji, '😍');
    });

    test('label returns correct label for each mood', () {
      expect(MoodLevel.great.label, 'Great');
      expect(MoodLevel.good.label, 'Good');
      expect(MoodLevel.okay.label, 'Okay');
      expect(MoodLevel.meh.label, 'Meh');
      expect(MoodLevel.bad.label, 'Rough');
      expect(MoodLevel.inLove.label, 'In Love');
    });

    test('color returns valid color for each mood', () {
      for (final mood in MoodLevel.values) {
        final color = mood.color;
        expect(color.a > 0, true);
      }
    });

    test('color values are distinct for each mood', () {
      final colors = MoodLevel.values.map((m) => m.color).toSet();
      expect(colors.length, MoodLevel.values.length);
    });

    test('score returns correct values for each mood', () {
      expect(MoodLevel.great.score, 4.0);
      expect(MoodLevel.inLove.score, 4.0);
      expect(MoodLevel.good.score, 3.0);
      expect(MoodLevel.okay.score, 2.0);
      expect(MoodLevel.meh.score, 1.0);
      expect(MoodLevel.bad.score, 0.0);
    });

    test('isPositive returns true for positive moods', () {
      expect(MoodLevel.great.isPositive, true);
      expect(MoodLevel.good.isPositive, true);
      expect(MoodLevel.inLove.isPositive, true);
      expect(MoodLevel.okay.isPositive, false);
      expect(MoodLevel.meh.isPositive, false);
      expect(MoodLevel.bad.isPositive, false);
    });

    test('hapticWeight returns valid range for all moods', () {
      for (final mood in MoodLevel.values) {
        expect(mood.hapticWeight >= 1 && mood.hapticWeight <= 5, true);
      }
    });

    test('all moods have non-empty emoji and label', () {
      for (final mood in MoodLevel.values) {
        expect(mood.emoji.isNotEmpty, true);
        expect(mood.label.isNotEmpty, true);
      }
    });
  });
}
