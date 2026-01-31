/// Animation duration constants
class AppDurations {
  AppDurations._();

  // Splash screen
  static const Duration splashFade = Duration(milliseconds: 800);
  static const Duration splashBreathing = Duration(milliseconds: 2000);
  static const Duration splashAutoNavigate = Duration(milliseconds: 1800);

  // Page transitions
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration sharedElement = Duration(milliseconds: 400);

  // Mood selection
  static const Duration moodScale = Duration(milliseconds: 200);
  static const Duration moodFadeOthers = Duration(milliseconds: 150);
  static const Duration moodRipple = Duration(milliseconds: 300);
  static const Duration moodTintTransition = Duration(milliseconds: 500);

  // Micro interactions
  static const Duration buttonPress = Duration(milliseconds: 100);
  static const Duration fadeIn = Duration(milliseconds: 200);
  static const Duration fadeOut = Duration(milliseconds: 150);
  static const Duration springBounce = Duration(milliseconds: 300);

  // Confirmation screen
  static const Duration checkmarkDraw = Duration(milliseconds: 400);
  static const Duration confettiDuration = Duration(milliseconds: 2000);
  static const Duration lockClick = Duration(milliseconds: 200);

  // Calendar
  static const Duration monthSwipe = Duration(milliseconds: 300);
  static const Duration bottomSheetOpen = Duration(milliseconds: 250);

  // Gradient animation
  static const Duration gradientLoop = Duration(seconds: 4);

  // Particles
  static const Duration particleDrift = Duration(seconds: 8);
}
