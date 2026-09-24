import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:onetap/core/constants/app_colors.dart';
import 'package:onetap/core/constants/app_strings.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/core/utils/date_utils.dart' as app_date;
import 'package:onetap/core/utils/haptic_utils.dart';
import 'package:onetap/data/models/mood_entry.dart';
import 'package:onetap/providers/journal_providers.dart';
import 'package:onetap/widgets/mood_calendar_day.dart';
import 'package:onetap/widgets/premium_effects.dart';
import 'package:onetap/widgets/floating_particles.dart';
import 'package:onetap/widgets/animated_gradient_background.dart';
import 'package:onetap/widgets/shared_buttons.dart';
import 'package:onetap/screens/home_screen.dart';

/// Premium calendar screen showing mood history
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with TickerProviderStateMixin {
  late DateTime _currentMonth;
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _pageController = PageController(initialPage: 1000);
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  DateTime _getMonthForIndex(int index) {
    final now = DateTime.now();
    final offset = index - 1000;
    return DateTime(now.year, now.month + offset, 1);
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final textColor = AppColors.getTimeTextColor(hour);

    return Scaffold(
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            // Soft vignette
            const Positioned.fill(
              child: VignetteOverlay(intensity: 0.2),
            ),

            // Subtle particles
            Positioned.fill(
              child: FloatingParticles(
                particleCount: 10,
                color: Colors.white.withValues(alpha: 0.4),
                maxSize: 2,
                minSize: 1,
              ),
            ),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Custom app bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          AnimatedBackButton(
                            onTap: () => _navigateToHome(context),
                            color: textColor,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            AppStrings.calendarTitle,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Month navigation with visual polish
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            NavArrowButton(
                              icon: Icons.chevron_left_rounded,
                              onTap: () {
                                HapticUtils.gentle();
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                              color: textColor,
                            ),
                            TweenAnimationBuilder<double>(
                              key: ValueKey(_currentMonth),
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.scale(
                                    scale: 0.95 + (0.05 * value),
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                app_date.DateUtils.formatMonthYear(_currentMonth),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ),
                            NavArrowButton(
                              icon: Icons.chevron_right_rounded,
                              onTap: () {
                                HapticUtils.gentle();
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                              color: textColor,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Weekday headers with glass effect
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                              .map((day) => Expanded(
                                    child: Center(
                                      child: Text(
                                        day,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: textColor.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Calendar grid with smooth transitions
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          HapticUtils.gentle();
                          setState(() {
                            _currentMonth = _getMonthForIndex(index);
                          });
                        },
                        itemBuilder: (context, index) {
                          final month = _getMonthForIndex(index);
                          return _MonthGrid(
                            month: month,
                            onDayTapped: _showEntryDetails,
                          );
                        },
                      ),
                    ),

                    // Legend
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: MoodLevel.values.map((mood) {
                            return Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: mood.color,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: mood.color.withValues(alpha: 0.4),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  mood.emoji,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    HapticUtils.gentle();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 240),
      ),
      (route) => false,
    );
  }

  void _showEntryDetails(MoodEntry entry) {
    HapticUtils.gentle();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _EntryDetailsSheet(entry: entry),
    );
  }
}

class _MonthGrid extends ConsumerWidget {
  final DateTime month;
  final Function(MoodEntry) onDayTapped;

  const _MonthGrid({
    required this.month,
    required this.onDayTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(monthEntriesProvider(month));
    final entryMap = {for (var e in entries) e.dateKey: e};
    
    final daysInMonth = app_date.DateUtils.daysInMonth(month.year, month.month);
    final firstWeekday = app_date.DateUtils.firstWeekdayOfMonth(month.year, month.month);
    final now = DateTime.now();

    // Calculate grid
    final leadingEmptyDays = firstWeekday - 1;
    final totalCells = leadingEmptyDays + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(rows, (rowIndex) {
          return Expanded(
            child: Row(
              children: List.generate(7, (colIndex) {
                final cellIndex = rowIndex * 7 + colIndex;
                final dayNumber = cellIndex - leadingEmptyDays + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox());
                }

                final date = DateTime(month.year, month.month, dayNumber);
                final dateKey = app_date.DateUtils.toDateKey(date);
                final entry = entryMap[dateKey];
                final isToday = app_date.DateUtils.isSameDay(date, now);

                return Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 200 + (cellIndex * 20)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: child,
                        ),
                      );
                    },
                    child: MoodCalendarDay(
                      date: date,
                      entry: entry,
                      isToday: isToday,
                      onTap: entry != null ? () => onDayTapped(entry) : null,
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}

class _EntryDetailsSheet extends StatelessWidget {
  final MoodEntry entry;

  const _EntryDetailsSheet({required this.entry});

  @override
  Widget build(BuildContext context) {
    final date = app_date.DateUtils.fromDateKey(entry.dateKey);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  entry.mood.color.withValues(alpha: 0.15),
                  entry.mood.color.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 24),

                // Date
                Text(
                  app_date.DateUtils.formatDisplay(date),
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
                ),

                const SizedBox(height: 20),

                // Emoji with glow
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: entry.mood.color.withValues(alpha: 0.4),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Lottie.asset(
                    entry.mood.lottieAsset,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 16),

                // Mood label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: entry.mood.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry.mood.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: entry.mood.color,
                    ),
                  ),
                ),

                // Note
                if (entry.note != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '"${entry.note}"',
                      style: TextStyle(
                        fontSize: 17,
                        fontStyle: FontStyle.italic,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Locked indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.locked,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


