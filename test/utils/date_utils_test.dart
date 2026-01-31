import 'package:flutter_test/flutter_test.dart';
import 'package:onetap/core/utils/date_utils.dart' as app_date;

void main() {
  group('DateUtils', () {
    test('todayKey returns today date in yyyy-MM-dd format', () {
      final today = DateTime.now();
      final key = app_date.DateUtils.todayKey();
      
      final expectedKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      expect(key, expectedKey);
    });

    test('toDateKey converts DateTime to yyyy-MM-dd format', () {
      final date = DateTime(2024, 1, 28);
      final key = app_date.DateUtils.toDateKey(date);
      
      expect(key, '2024-01-28');
    });

    test('toDateKey pads month and day with zeros', () {
      final date = DateTime(2024, 3, 5);
      final key = app_date.DateUtils.toDateKey(date);
      
      expect(key, '2024-03-05');
    });

    test('fromDateKey parses date from yyyy-MM-dd format', () {
      final date = app_date.DateUtils.fromDateKey('2024-01-28');
      
      expect(date.year, 2024);
      expect(date.month, 1);
      expect(date.day, 28);
    });

    test('fromDateKey and toDateKey are inverse operations', () {
      final original = DateTime(2024, 6, 15);
      final key = app_date.DateUtils.toDateKey(original);
      final parsed = app_date.DateUtils.fromDateKey(key);
      
      expect(parsed.year, original.year);
      expect(parsed.month, original.month);
      expect(parsed.day, original.day);
    });

    test('daysInMonth returns correct count for each month', () {
      const expectedDays = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]; // 2024 is leap year
      
      for (int month = 1; month <= 12; month++) {
        final days = app_date.DateUtils.daysInMonth(2024, month);
        expect(days, expectedDays[month - 1]);
      }
    });

    test('daysInMonth handles leap years correctly', () {
      final leapYear = app_date.DateUtils.daysInMonth(2024, 2);
      expect(leapYear, 29);
      
      final nonLeapYear = app_date.DateUtils.daysInMonth(2023, 2);
      expect(nonLeapYear, 28);
    });

    test('getLastNDays returns correct list length', () {
      final last7 = app_date.DateUtils.getLastNDays(7);
      expect(last7.length, 7);
      
      final last30 = app_date.DateUtils.getLastNDays(30);
      expect(last30.length, 30);
    });

    test('getLastNDays returns dates in reverse chronological order', () {
      final days = app_date.DateUtils.getLastNDays(3);
      
      expect(days[0].isAfter(days[1]), true);
      expect(days[1].isAfter(days[2]), true);
    });

    test('getLastNDays first element is approximately today', () {
      final days = app_date.DateUtils.getLastNDays(1);
      final today = DateTime.now();
      
      // Should be same day (comparing only year, month, day)
      expect(days[0].year, today.year);
      expect(days[0].month, today.month);
      expect(days[0].day, today.day);
    });

    test('formatMonthYear returns formatted string', () {
      final date = DateTime(2024, 1, 28);
      final formatted = app_date.DateUtils.formatMonthYear(date);
      
      expect(formatted, contains('2024'));
      expect(formatted.toLowerCase().contains('jan') || formatted.contains('1'), true);
    });

    test('isToday correctly identifies todays date', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final tomorrow = today.add(const Duration(days: 1));
      
      expect(app_date.DateUtils.isToday(today), true);
      expect(app_date.DateUtils.isToday(yesterday), false);
      expect(app_date.DateUtils.isToday(tomorrow), false);
    });

    test('isSameDay compares only date parts', () {
      final date1 = DateTime(2024, 1, 28, 10, 30);
      final date2 = DateTime(2024, 1, 28, 15, 45);
      final date3 = DateTime(2024, 1, 29, 10, 30);
      
      expect(app_date.DateUtils.isSameDay(date1, date2), true);
      expect(app_date.DateUtils.isSameDay(date1, date3), false);
    });
  });
}
