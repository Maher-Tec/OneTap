import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onetap/core/constants/app_colors.dart';
import 'package:onetap/core/constants/app_strings.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/core/utils/haptic_utils.dart';

import 'package:onetap/providers/journal_providers.dart';
import 'package:onetap/providers/quote_provider.dart';

import 'package:onetap/screens/insights_screen.dart';
import 'package:onetap/screens/settings_screen.dart';
import 'package:onetap/widgets/animated_gradient_background.dart';
import 'package:onetap/widgets/floating_particles.dart';
import 'package:onetap/widgets/glassmorphic_card.dart';
import 'package:onetap/widgets/mood_calendar_day.dart';
import 'package:onetap/widgets/mood_emoji_button.dart';

import 'package:onetap/widgets/premium_effects.dart';
import 'package:onetap/widgets/shared_buttons.dart';
import 'package:onetap/screens/note_screen.dart';
import 'package:onetap/screens/calendar_screen.dart';
import 'package:onetap/widgets/mood_galaxy.dart';


/// Main home screen for mood selection - premium edition
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  MoodLevel? _selectedMood;
  MoodLevel? _previewMood; // For two-step selection: preview before confirm
  Color? _overlayColor;
  
  late AnimationController _fadeInController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideUpAnimation;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Entry fade-in animation
    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeOutCubic,
    );
    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeOutCubic,
    ));

    // Subtle pulse for ambient feel
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _fadeInController.forward();
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final textColor = AppColors.getTimeTextColor(hour);
    final todayEntry = ref.watch(todayEntryProvider);
    final hasEntryToday = todayEntry != null;
    final last7Days = ref.watch(last7DaysProvider);
    final validEntriesCount = last7Days.where((e) => e != null).length;
    // Only show Galaxy if we have a full week of data (7 days)
    final showGalaxy = validEntriesCount >= 7;
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: SizedBox.expand(
          child: AnimatedGradientBackground(
            overlayColor: _overlayColor,
            overlayOpacity: 0.2,
            child: Stack(
          children: [
            // Soft vignette for depth
            const Positioned.fill(
              child: VignetteOverlay(intensity: 0.25),
            ),

            // Background glow orb (follows mood or defaults)
            Positioned(
              top: size.height * 0.2,
              left: size.width / 2 - 150,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return GlowOrb(
                    color: _overlayColor ?? Colors.white,
                    size: 300 * _pulseAnimation.value,
                    intensity: 0.25,
                  );
                },
              ),
            ),

            // Background particles
            Positioned.fill(
              child: FloatingParticles(
                particleCount: 20,
                color: Colors.white.withValues(alpha: 0.6),
                maxSize: 3,
                minSize: 1,
              ),
            ),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: SlideTransition(
                  position: _slideUpAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Top bar with settings
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedIconButton(
                              icon: Icons.settings_outlined,
                              color: textColor,
                              onTap: () => _navigateToSettings(context),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Greeting with subtle animation
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            AppStrings.getGreeting(hour),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: textColor.withValues(alpha: 0.85),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Prompt
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 30 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                            child: hasEntryToday
                                ? Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      Text(
                                        showGalaxy ? 'Your Emotional Galaxy' : 'Today\'s Focus',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        showGalaxy 
                                          ? 'A visual reflection of your week'
                                          : _getEmpatheticMessage(todayEntry.mood),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: textColor.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  )
                              : Text(
                                  AppStrings.getPrompt(hour),
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    letterSpacing: -0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ),

                        const SizedBox(height: 48),

                        // Mood selection card - premium glass
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1400),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.scale(
                                scale: 0.9 + (0.1 * value),
                                child: child,
                              ),
                            );
                          },
                          child: GlassmorphicCard(
                            blur: 15,
                            opacity: 0.15,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 28,
                            ),
                            child: hasEntryToday
                                // Show Mood Galaxy and AI-generated daily quote when mood is already saved
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      showGalaxy
                                          ? MoodGalaxy(
                                              entries: last7Days,
                                              size: 200,
                                            )
                                          : _PremiumMoodDisplay(
                                              mood: todayEntry.mood,
                                              size: 200,
                                            ),
                                      const SizedBox(height: 24),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Consumer(
                                          builder: (context, ref, _) {
                                            final quoteAsync = ref.watch(aiQuoteProvider(todayEntry.mood));
                                            return quoteAsync.when(
                                              data: (quote) => Text(
                                                quote,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontStyle: FontStyle.italic,
                                                  color: textColor.withValues(alpha: 0.8),
                                                  height: 1.5,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              loading: () => Text(
                                                '✨ Generating your quote...',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontStyle: FontStyle.italic,
                                                  color: textColor.withValues(alpha: 0.5),
                                                ),
                                              ),
                                              error: (_, __) => Text(
                                                AppStrings.getDailyQuote(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontStyle: FontStyle.italic,
                                                  color: textColor.withValues(alpha: 0.8),
                                                  height: 1.5,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'See you tomorrow ✨',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textColor.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ],
                                  )
                                // Show emoji grid for mood selection
                                : Column(
                                    children: [
                                      // Mood emoji grid - 3x2 layout
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // First row - 3 emojis
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: MoodLevel.values.take(3).toList().asMap().entries.map((entry) {
                                              final index = entry.key;
                                              final mood = entry.value;
                                              final isPreview = _previewMood == mood;
                                              final isSelected = isPreview || _selectedMood == mood;

                                              return TweenAnimationBuilder<double>(
                                                tween: Tween(begin: 0.0, end: 1.0),
                                                duration: Duration(milliseconds: 1400 + (index * 100)),
                                                curve: Curves.elasticOut,
                                                builder: (context, value, child) {
                                                  return Transform.scale(
                                                    scale: value,
                                                    child: child,
                                                  );
                                                },
                                                child: MoodEmojiButton(
                                                  mood: mood,
                                                  isSelected: isSelected,
                                                  isDisabled: false,
                                                  showLabel: isSelected,
                                                  size: 52,
                                                  onTap: () => _previewMoodSelection(mood),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          
                                          const SizedBox(height: 16),
                                          
                                          // Second row - 3 emojis
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: MoodLevel.values.skip(3).toList().asMap().entries.map((entry) {
                                              final index = entry.key + 3;
                                              final mood = entry.value;
                                              final isPreview = _previewMood == mood;
                                              final isSelected = isPreview || _selectedMood == mood;

                                              return TweenAnimationBuilder<double>(
                                                tween: Tween(begin: 0.0, end: 1.0),
                                                duration: Duration(milliseconds: 1400 + (index * 100)),
                                                curve: Curves.elasticOut,
                                                builder: (context, value, child) {
                                                  return Transform.scale(
                                                    scale: value,
                                                    child: child,
                                                  );
                                                },
                                                child: MoodEmojiButton(
                                                  mood: mood,
                                                  isSelected: isSelected,
                                                  isDisabled: false,
                                                  showLabel: isSelected,
                                                  size: 52,
                                                  onTap: () => _previewMoodSelection(mood),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),

                                      // Confirm button - shown when a mood is previewed
                                      AnimatedSize(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOutCubic,
                                        child: _previewMood != null
                                            ? Padding(
                                                padding: const EdgeInsets.only(top: 20),
                                                child: TweenAnimationBuilder<double>(
                                                  tween: Tween(begin: 0.0, end: 1.0),
                                                  duration: const Duration(milliseconds: 400),
                                                  curve: Curves.elasticOut,
                                                  builder: (context, value, child) {
                                                    return Transform.scale(
                                                      scale: value,
                                                      child: Opacity(
                                                        opacity: value.clamp(0.0, 1.0),
                                                        child: child,
                                                      ),
                                                    );
                                                  },
                                                  child: GestureDetector(
                                                    onTap: () => _confirmMoodSelection(),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 32,
                                                        vertical: 14,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            _previewMood!.color,
                                                            _previewMood!.color.withValues(alpha: 0.8),
                                                          ],
                                                        ),
                                                        borderRadius: BorderRadius.circular(25),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: _previewMood!.color.withValues(alpha: 0.4),
                                                            blurRadius: 12,
                                                            spreadRadius: 2,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          const Icon(
                                                            Icons.check_rounded,
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            "I'm feeling ${_previewMood!.label}",
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),

                                      // First time hint with fade
                                      AnimatedSize(
                                        duration: const Duration(milliseconds: 300),
                                        child: _previewMood == null
                                            ? Padding(
                                                padding: const EdgeInsets.only(top: 20),
                                                child: Text(
                                                  AppStrings.hintFirstTime,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: textColor.withValues(alpha: 0.5),
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                          ),
                        ),


                        const SizedBox(height: 32),

                        // Mini calendar preview
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1800),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(opacity: value, child: child);
                          },
                          child: MiniCalendarPreview(
                            entries: last7Days,
                            onTap: () => _navigateToCalendar(context),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Bottom navigation with hover effects
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 2000),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(opacity: value, child: child);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PremiumNavButton(
                                    icon: Icons.calendar_month_outlined,
                                    label: 'Calendar',
                                    color: textColor,
                                    onTap: () => _navigateToCalendar(context),
                                  ),
                                  const SizedBox(width: 16),
                                  PremiumNavButton(
                                    icon: Icons.insights_rounded,
                                    label: 'Insights',
                                    color: textColor,
                                    onTap: () => _navigateToInsights(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
    ),
    );
  }

  // Step 1: Preview the mood
  void _previewMoodSelection(MoodLevel mood) {
    if (_previewMood == mood) return; // Already previewing this mood
    
    HapticUtils.selectionTick();
    setState(() {
      _previewMood = mood;
      // Don't set _selectedMood yet, wait for confirmation
      _selectedMood = null;
      _overlayColor = mood.color.withValues(alpha: 0.1);
    });
  }

  // Step 2: Confirm and save
  void _confirmMoodSelection() {
    if (_previewMood == null) return;
    _selectMood(_previewMood!);
  }

  void _selectMood(MoodLevel mood) {
    HapticUtils.forMood(mood);
    
    setState(() {
      _selectedMood = mood;
      _previewMood = null; // Clear preview
      _overlayColor = mood.color;
    });

    // Navigate to note screen after short delay for animation
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                NoteScreen(selectedMood: mood),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        ).then((_) {
          // Reset selection when returning
          if (mounted) {
            setState(() {
              _selectedMood = null;
              _previewMood = null;
              _overlayColor = null;
            });
          }
        });
      }
    });
  }

  void _showAlreadySavedToast(BuildContext context) {
    HapticUtils.gentle();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(AppStrings.alreadySavedToast),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _getEmpatheticMessage(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.great:
        return 'Radiating positive energy! ✨';
      case MoodLevel.good:
        return 'Building good momentum today.';
      case MoodLevel.okay:
        return 'Staying balanced and grounded.';
      case MoodLevel.meh:
        return 'Be gentle with yourself today.';
      case MoodLevel.bad:
        return 'Tough days pass. We\'re here for you.';
      case MoodLevel.inLove:
        return 'Embracing the love in your life. 💖';
    }
  }

  void _navigateToCalendar(BuildContext context) {
    HapticUtils.gentle();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CalendarScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _navigateToInsights(BuildContext context) {
    HapticUtils.gentle();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const InsightsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    HapticUtils.gentle();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }


}

class _PremiumMoodDisplay extends StatelessWidget {
  final MoodLevel mood;
  final double size;

  const _PremiumMoodDisplay({
    required this.mood,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GlowOrb(
            color: mood.color,
            size: size * 0.8,
            intensity: 0.2,
          ),
          MeditationRings(
            color: mood.color,
            maxSize: size * 0.9,
          ),
          Text(
            mood.emoji,
            style: TextStyle(
              fontSize: size * 0.4,
              shadows: [
                Shadow(
                  color: mood.color.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
