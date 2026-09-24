import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onetap/core/theme/app_theme.dart';
import 'package:onetap/core/services/notification_service.dart';
import 'package:onetap/data/repositories/journal_repository.dart';
import 'package:onetap/data/repositories/goal_repository.dart';
import 'package:onetap/data/repositories/achievement_repository.dart';
import 'package:onetap/data/demo/demo_data_seeder.dart';
import 'package:onetap/providers/journal_providers.dart';
import 'package:onetap/providers/goal_providers.dart';
import 'package:onetap/providers/achievement_providers.dart';
import 'package:onetap/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Enable edge-to-edge display and set transparent system bars
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Hive and repositories
  final journalRepo = await JournalRepository.initialize();
  const demoMode = bool.fromEnvironment('ONETAP_DEMO_MODE');
  if (demoMode) {
    await DemoDataSeeder.seedIfEmpty(journalRepo.entriesBox);
  }
  final goalRepo = await GoalRepository.initialize(journalRepo.entriesBox);
  final achievementRepo = await AchievementRepository.initialize(
    entriesBox: journalRepo.entriesBox,
    goalsBox: goalRepo.goalsBox,
  );
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Schedule reminder if enabled in settings
  final settings = journalRepo.getSettings();
  if (settings.reminderEnabled) {
    await notificationService.scheduleDailyReminder(settings.reminderTime);
  }
  
  runApp(
    ProviderScope(
      overrides: [
        journalRepositoryProvider.overrideWithValue(journalRepo),
        goalRepositoryProvider.overrideWithValue(goalRepo),
        achievementRepositoryProvider.overrideWithValue(achievementRepo),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const OneTapApp(),
    ),
  );
}

class OneTapApp extends ConsumerWidget {
  const OneTapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Forced Dark Mode

    return MaterialApp(
      title: 'OneTap Journal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark, // Always dark mode as requested
      home: const HomeScreen(),
    );
  }
}
