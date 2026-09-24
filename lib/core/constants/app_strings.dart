/// App string constants
class AppStrings {
  AppStrings._();

  // App info
  static const String appName = 'OneTap Journal';
  static const String appTagline = 'Track your mood in one tap.';

  // Greetings (based on time of day)
  static const String greetingMorning = '☀️ Good morning.';
  static const String greetingAfternoon = '🌤️ Good afternoon.';
  static const String greetingEvening = '🌙 Good evening.';

  // Prompts (based on time of day)
  static const String promptMorning = 'How did you sleep?';
  static const String promptAfternoon = 'How are you feeling?';
  static const String promptEvening = 'How was your day?';

  // Home screen
  static const String hintFirstTime = 'Tap one to save today';
  static const String savedForToday = 'Saved for today 🔒';
  static const String alreadySavedToast = 'Already saved today';
  static const String streakText = 'day streak';

  // Note screen
  static const String noteTitle = 'In 3 words (optional)';
  static const String notePlaceholder = 'Calm. Quiet. Okay.';
  static const String noteExample1 = '"Stressful but okay"';
  static const String noteExample2 = '"Calm. Quiet. Happy."';
  static const String noteExample3 = '"Better than yesterday"';
  static const String skipButton = 'Skip';
  static const String saveButton = 'Save';

  // Confirmation screen
  static const String savedTitle = 'Saved for today. 🔒';
  static const String seeYouTomorrow = 'See you tomorrow';
  static const String viewCalendar = 'View Calendar';
  static const String done = 'Done';

  // Calendar screen
  static const String calendarTitle = 'Your Journey';
  static const String tapToView = 'Tap a day to view entry';
  static const String noEntryForDay = 'No entry for this day';
  static const String locked = 'Locked';

  // Insights screen
  static const String insightsTitle = 'Your Insights';
  static const String thisMonth = 'This Month';
  static const String positiveDays = 'Positive Days';
  static const String orBetterOn = 'or better on';
  static const String days = 'days';
  static const String longestStreak = 'Longest streak';
  static const String currentStreak = 'Current streak';
  static const String totalEntries = 'Total entries';
  static const String moodDistribution = 'Mood Distribution';
  static const String mostCommonMood = 'Most common mood';

  // Settings screen
  static const String settingsTitle = 'Settings';
  static const String reminders = 'Reminders';
  static const String dailyReminder = 'Daily reminder';
  static const String reminderTime = 'Reminder time';
  static const String appearance = 'Appearance';
  static const String darkMode = 'Dark mode';
  static const String privacy = 'Privacy';
  static const String biometricLock = 'Biometric lock';
  static const String streak = 'Streak';
  static const String graceEnabled = 'Streak protection';
  static const String graceAvailable = 'Grace available';
  static const String graceHint = '1 free pass per week';
  static const String data = 'Data';
  static const String resetAll = 'Reset all data';
  static const String resetConfirmTitle = 'Reset Journal?';
  static const String resetConfirmMessage = 'This will delete all your entries and cannot be undone.';
  static const String cancel = 'Cancel';
  static const String reset = 'Reset';

  // Supportive messages for insights
  static String getPositiveDaysMessage(int positive, int total) {
    return 'You felt 🙂 or better on $positive of $total days.';
  }

  static String getStreakMessage(int streak) {
    if (streak == 0) return 'Start your streak today!';
    if (streak == 1) return '1 day! Great start.';
    if (streak < 7) return '$streak days! Keep it going.';
    if (streak < 30) return '$streak days! You\'re on fire 🔥';
    return '$streak days! Incredible consistency! 🌟';
  }

  /// Get greeting based on hour of day
  static String getGreeting(int hour) {
    if (hour >= 5 && hour < 12) {
      return greetingMorning;
    } else if (hour >= 12 && hour < 17) {
      return greetingAfternoon;
    } else {
      return greetingEvening;
    }
  }

  /// Get prompt based on hour of day
  static String getPrompt(int hour) {
    if (hour >= 5 && hour < 12) {
      return promptMorning;
    } else if (hour >= 12 && hour < 17) {
      return promptAfternoon;
    } else {
      return promptEvening;
    }
  }
  // Daily motivational quotes
  static const List<String> _dailyQuotes = [
    '"Be where you are, not where you think you should be." — Unknown',
    '"Every day is a fresh start." — Unknown',
    '"You are allowed to feel however you feel." — Unknown',
    '"Progress, not perfection." — Unknown',
    '"Small steps every day." — Unknown',
    '"Your feelings are valid." — Unknown',
    '"Breathe. You\'re doing great." — Unknown',
    '"One day at a time." — Unknown',
    '"The present moment is all we have." — Unknown',
    '"Be gentle with yourself." — Unknown',
    '"You showed up today. That matters." — Unknown',
    '"Your journey is unique." — Unknown',
    '"It\'s okay to just be okay." — Unknown',
    '"Tomorrow is another chance." — Unknown',
  ];

  static const Map<String, List<String>> _moodWords = {
    'great': ['You deserve to enjoy this moment.', 'Let yourself celebrate the good.', 'Keep a little of this joy with you.'],
    'good': ['Notice what is helping today.', 'Small good moments still count.', 'You are allowed to feel good.'],
    'okay': ['You do not have to feel amazing to be doing well.', 'Taking today as it comes is enough.', 'Steady is still progress.'],
    'meh': ['A hard feeling is not the whole story.', 'Be patient with yourself today.', 'You can take this one small step at a time.'],
    'bad': ['You deserve kindness, especially from yourself.', 'You do not have to solve everything right now.', 'Getting through this moment is enough.'],
    'inLove': ['Let yourself be present with the love you feel.', 'Hold on to what makes your heart feel full.', 'Love makes ordinary moments brighter.'],
  };

  /// Get a quote based on the day of year (consistent for the day)
  static String getDailyQuote() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return _dailyQuotes[dayOfYear % _dailyQuotes.length];
  }

  /// Get one locally stored supportive message for a mood, stable for the day.
  static String getMoodMessage(String moodName) {
    final messages = _moodWords[moodName] ?? _dailyQuotes;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return messages[dayOfYear % messages.length];
  }

  static String getBestDayMessage(String dayName, double averageMood) {
    if (averageMood >= 3.5) return '$dayName is often a bright spot in your week.';
    if (averageMood >= 2.5) return '$dayName tends to feel steady for you.';
    return 'You have been showing up for yourself on $dayName.';
  }
}
