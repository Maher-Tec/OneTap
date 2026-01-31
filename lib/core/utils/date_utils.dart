import 'package:intl/intl.dart';

/// Date utility functions
class DateUtils {
  DateUtils._();

  /// Format date as yyyy-MM-dd for storage key
  static String toDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Parse date key back to DateTime
  static DateTime fromDateKey(String dateKey) {
    return DateFormat('yyyy-MM-dd').parse(dateKey);
  }

  /// Get today's date key
  static String todayKey() {
    return toDateKey(DateTime.now());
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Get the start of the week (Monday) for a given date
  static DateTime getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Check if two dates are in the same week
  static bool isSameWeek(DateTime a, DateTime b) {
    final weekStartA = getWeekStart(a);
    final weekStartB = getWeekStart(b);
    return isSameDay(weekStartA, weekStartB);
  }

  /// Get number of days in a month
  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Get the weekday of the first day of a month (1 = Monday, 7 = Sunday)
  static int firstWeekdayOfMonth(int year, int month) {
    return DateTime(year, month, 1).weekday;
  }

  /// Get a list of dates for the last N days
  static List<DateTime> getLastNDays(int n) {
    final now = DateTime.now();
    return List.generate(n, (i) => now.subtract(Duration(days: n - 1 - i)));
  }

  /// Format date for display (e.g., "Mon, Jan 28")
  static String formatDisplay(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }

  /// Format month for header (e.g., "January 2024")
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Format time for display (e.g., "8:00 PM")
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
}
