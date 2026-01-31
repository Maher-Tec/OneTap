import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

/// Service for managing local notifications
/// Handles daily reminders and streak milestone celebrations
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Notification IDs
  static const int _dailyReminderId = 1;
  static const int _streakMilestoneId = 100;

  // Channel details
  static const String _channelId = 'onetap_reminders';
  static const String _channelName = 'Daily Reminders';
  static const String _channelDescription =
      'Notifications to remind you to track your mood';

  /// Initialize the notification service
  /// Must be called before any other methods
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings (for future iOS support)
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // The app will open automatically when notification is tapped
    // We could add navigation logic here if needed
  }

  /// Request notification permissions (Android 13+)
  Future<bool> requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Schedule daily reminder at specified time
  /// [timeString] format: "HH:mm" (e.g., "20:00")
  Future<void> scheduleDailyReminder(String timeString) async {
    if (!_isInitialized) await initialize();

    // Cancel existing reminder first
    await cancelDailyReminder();

    // Parse time
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // Calculate next occurrence
    final scheduledTime = _nextInstanceOfTime(hour, minute);

    // Notification details
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        'Take a moment to check in with yourself. How are you feeling today?',
        contentTitle: 'Time to Journal 🌟',
        summaryText: 'OneTap',
      ),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      _dailyReminderId,
      'Time to Journal 🌟',
      'Take a moment to check in with yourself.',
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel scheduled daily reminder
  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_dailyReminderId);
  }

  /// Show streak milestone notification
  /// Called when user reaches 7, 14, 30, 50, 100, etc. days
  Future<void> showStreakMilestone(int streak) async {
    if (!_isInitialized) await initialize();

    // Only show for specific milestones
    if (!_isStreakMilestone(streak)) return;

    String title;
    String body;
    String emoji;

    if (streak >= 100) {
      emoji = '🏆';
      title = '$streak Day Streak! $emoji';
      body = 'Incredible dedication! You\'re a journaling master!';
    } else if (streak >= 50) {
      emoji = '💎';
      title = '$streak Day Streak! $emoji';
      body = 'Half way to 100! You\'re unstoppable!';
    } else if (streak >= 30) {
      emoji = '🔥';
      title = '$streak Day Streak! $emoji';
      body = 'A whole month of self-reflection! Amazing!';
    } else if (streak >= 14) {
      emoji = '⭐';
      title = '$streak Day Streak! $emoji';
      body = 'Two weeks strong! Keep it going!';
    } else {
      emoji = '✨';
      title = '$streak Day Streak! $emoji';
      body = 'You\'re building a great habit!';
    }

    const androidDetails = AndroidNotificationDetails(
      'onetap_achievements',
      'Achievements',
      channelDescription: 'Streak milestones and achievements',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      _streakMilestoneId + streak,
      title,
      body,
      notificationDetails,
    );
  }

  /// Check if streak is a milestone worth celebrating
  bool _isStreakMilestone(int streak) {
    const milestones = [7, 14, 21, 30, 50, 75, 100, 150, 200, 365];
    return milestones.contains(streak);
  }

  /// Calculate next occurrence of given time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      return await androidPlugin.areNotificationsEnabled() ?? false;
    }
    return false;
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }
}
