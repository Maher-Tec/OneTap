import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:onetap/core/constants/app_colors.dart';
import 'package:onetap/core/constants/app_strings.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/core/utils/date_utils.dart' as app_date;
import 'package:onetap/core/utils/haptic_utils.dart';
import 'package:onetap/data/models/trend_models.dart';
import 'package:onetap/providers/journal_providers.dart';
import 'package:onetap/widgets/glassmorphic_card.dart';
import 'package:onetap/widgets/premium_effects.dart';
import 'package:onetap/widgets/floating_particles.dart';
import 'package:onetap/widgets/animated_gradient_background.dart';
import 'package:onetap/widgets/shared_buttons.dart';
import 'package:onetap/screens/home_screen.dart';
import 'package:onetap/services/ai_service.dart';

/// Premium insights screen with mood statistics
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _currentMonth;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final textColor = AppColors.getTimeTextColor(hour);
    final totalEntries = ref.watch(totalEntriesProvider);
    final distribution = ref.watch(moodDistributionProvider(_currentMonth));
    final mostCommon = ref.watch(mostCommonMoodProvider(_currentMonth));
    final positiveDays = ref.watch(positiveDaysProvider(null));
    final daysInMonth = app_date.DateUtils.daysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );

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
                            AppStrings.insightsTitle,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // This Month card with progress
                            _ThisMonthCard(
                              month: _currentMonth,
                              positiveDays: positiveDays,
                              totalDays: daysInMonth,
                              textColor: textColor,
                              onPreviousMonth: () {
                                HapticUtils.gentle();
                                setState(() {
                                  _currentMonth = DateTime(
                                    _currentMonth.year,
                                    _currentMonth.month - 1,
                                  );
                                });
                              },
                              onNextMonth: () {
                                final now = DateTime.now();
                                final nextMonth = DateTime(
                                  _currentMonth.year,
                                  _currentMonth.month + 1,
                                );
                                if (nextMonth.isBefore(now) ||
                                    (nextMonth.year == now.year && nextMonth.month == now.month)) {
                                  HapticUtils.gentle();
                                  setState(() {
                                    _currentMonth = nextMonth;
                                  });
                                }
                              },
                            ),

                            const SizedBox(height: 24),

                            // Stats row with stagger animation
                            Row(
                              children: [
                                Expanded(
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) {
                                      return Opacity(
                                        opacity: value,
                                        child: Transform.translate(
                                          offset: Offset(0, 20 * (1 - value)),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: _StatCard(
                                      label: AppStrings.totalEntries,
                                      value: '$totalEntries',
                                      icon: '📝',
                                      color: textColor,
                                      textColor: textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 900),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) {
                                      return Opacity(
                                        opacity: value,
                                        child: Transform.translate(
                                          offset: Offset(0, 20 * (1 - value)),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: _StatCard(
                                      label: AppStrings.positiveDays,
                                      value: '$positiveDays',
                                      icon: '❤️',
                                      color: AppColors.moodColors[MoodLevel.good]!,
                                      textColor: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // Most common mood
                            if (mostCommon != null) ...[
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 1100),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Opacity(opacity: value, child: child);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.mostCommonMood,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textColor.withValues(alpha: 0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            mostCommon.color.withValues(alpha: 0.2),
                                            mostCommon.color.withValues(alpha: 0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: mostCommon.color.withValues(alpha: 0.3),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: mostCommon.color.withValues(alpha: 0.2),
                                            blurRadius: 15,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: mostCommon.color.withValues(alpha: 0.4),
                                                  blurRadius: 12,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              mostCommon.emoji,
                                              style: const TextStyle(fontSize: 36),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                mostCommon.label,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: mostCommon.color,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Your top mood this month',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: textColor.withValues(alpha: 0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 28),

                            // Mood distribution chart
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(opacity: value, child: child);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.moodDistribution,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textColor.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  GlassmorphicCard(
                                    blur: 10,
                                    opacity: 0.1,
                                    padding: const EdgeInsets.all(20),
                                    child: _MoodDistributionChart(
                                      distribution: distribution,
                                      textColor: textColor,
                                      touchedIndex: _touchedIndex,
                                      onTouched: (index) {
                                        if (index != _touchedIndex) {
                                          HapticUtils.gentle();
                                          setState(() => _touchedIndex = index);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Weekly Summary Card (NEW)
                            _WeeklySummaryCard(
                              textColor: textColor,
                            ),

                            const SizedBox(height: 28),

                            // Mood Trend Chart (NEW)
                            _MoodTrendSection(
                              textColor: textColor,
                            ),

                            const SizedBox(height: 28),

                            // Day of Week Patterns (NEW)
                            _DayOfWeekSection(
                              textColor: textColor,
                              month: _currentMonth,
                            ),

                            const SizedBox(height: 28),

                            // Supportive message
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 1300),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(opacity: value, child: child);
                              },
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: textColor.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    AppStrings.getDailyQuote(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: textColor.withValues(alpha: 0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
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
        transitionDuration: const Duration(milliseconds: 350),
      ),
      (route) => false,
    );
  }
}

class _ThisMonthCard extends StatelessWidget {
  final DateTime month;
  final int positiveDays;
  final int totalDays;
  final Color textColor;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const _ThisMonthCard({
    required this.month,
    required this.positiveDays,
    required this.totalDays,
    required this.textColor,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalDays > 0 ? positiveDays / totalDays : 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.95 + (0.05 * value),
            child: child,
          ),
        );
      },
      child: GlassmorphicCard(
        blur: 15,
        opacity: 0.12,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NavArrowButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: onPreviousMonth,
                  color: textColor,
                ),
                TweenAnimationBuilder<double>(
                  key: ValueKey(month),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: Text(
                    app_date.DateUtils.formatMonthYear(month),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                NavArrowButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: onNextMonth,
                  color: textColor,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Animated progress bar
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: percentage),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: textColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.moodColors[MoodLevel.good]!,
                                AppColors.moodColors[MoodLevel.great]!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.moodColors[MoodLevel.good]!.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Message
            Row(
              children: [
                const Text(
                  '😊',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.getPositiveDaysMessage(positiveDays, totalDays),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;
  final Color textColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MoodDistributionChart extends StatelessWidget {
  final Map<MoodLevel, int> distribution;
  final Color textColor;
  final int touchedIndex;
  final Function(int) onTouched;

  const _MoodDistributionChart({
    required this.distribution,
    required this.textColor,
    required this.touchedIndex,
    required this.onTouched,
  });

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold(0, (sum, v) => sum + v);
    
    if (total == 0) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '📊',
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 12),
            Text(
              'No data yet this month',
              style: TextStyle(
                fontSize: 15,
                color: textColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: Row(
        children: [
          // Pie chart with touch
          Expanded(
            flex: 2,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (event.isInterestedForInteractions &&
                            response != null &&
                            response.touchedSection != null) {
                          onTouched(response.touchedSection!.touchedSectionIndex);
                        } else {
                          onTouched(-1);
                        }
                      },
                    ),
                    sections: MoodLevel.values.asMap().entries.map((entry) {
                      final index = entry.key;
                      final mood = entry.value;
                      final count = distribution[mood] ?? 0;
                      final percentage = count / total * 100;
                      final isTouched = index == touchedIndex;
                      
                      if (count == 0) {
                        return PieChartSectionData(
                          color: Colors.transparent,
                          value: 0,
                          showTitle: false,
                        );
                      }

                      return PieChartSectionData(
                        color: mood.color,
                        value: count.toDouble() * value,
                        title: percentage >= 10 ? '${percentage.round()}%' : '',
                        titleStyle: TextStyle(
                          fontSize: isTouched ? 14 : 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        radius: isTouched ? 70 : 55,
                        badgePositionPercentageOffset: 0.98,
                      );
                    }).toList(),
                    sectionsSpace: 3,
                    centerSpaceRadius: 25,
                  ),
                );
              },
            ),
          ),

          // Legend
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: MoodLevel.values.asMap().entries.map((entry) {
                final index = entry.key;
                final mood = entry.value;
                final count = distribution[mood] ?? 0;
                if (count == 0) return const SizedBox.shrink();

                final isTouched = index == touchedIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isTouched ? 14 : 10,
                        height: isTouched ? 14 : 10,
                        decoration: BoxDecoration(
                          color: mood.color,
                          shape: BoxShape.circle,
                          boxShadow: isTouched
                              ? [
                                  BoxShadow(
                                    color: mood.color.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: isTouched ? 14 : 12,
                          fontWeight: isTouched ? FontWeight.w700 : FontWeight.w500,
                          color: textColor.withValues(alpha: isTouched ? 1.0 : 0.7),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        mood.emoji,
                        style: TextStyle(fontSize: isTouched ? 16 : 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Weekly Summary Card - Shows this week's mood overview
class _WeeklySummaryCard extends ConsumerWidget {
  final Color textColor;

  const _WeeklySummaryCard({required this.textColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(weeklySummaryProvider);
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          GlassmorphicCard(
            blur: 12,
            opacity: 0.1,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: summary.isPositiveWeek
                            ? AppColors.moodColors[MoodLevel.good]!.withValues(alpha: 0.2)
                            : AppColors.moodColors[MoodLevel.meh]!.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        summary.trendLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: summary.isPositiveWeek
                              ? AppColors.moodColors[MoodLevel.good]
                              : AppColors.moodColors[MoodLevel.meh],
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (summary.dominantMood != null)
                      Text(summary.dominantMood!.emoji, style: const TextStyle(fontSize: 32)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _MiniStat(label: 'Entries', value: '${summary.totalEntries}', icon: '📝', textColor: textColor),
                    _MiniStat(label: 'Streak', value: '${summary.streakDays}', icon: '🔥', textColor: textColor),
                    _MiniStat(label: 'Good Days', value: '${summary.positiveDays}', icon: '😊', textColor: textColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color textColor;

  const _MiniStat({required this.label, required this.value, required this.icon, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor)),
          Text(label, style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}

/// Mood Trend Section - Line chart of recent mood
class _MoodTrendSection extends ConsumerWidget {
  final Color textColor;

  const _MoodTrendSection({required this.textColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendData = ref.watch(moodTrendProvider(14));
    final velocity = ref.watch(moodVelocityProvider(7));
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Mood Trend', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.6))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: velocity > 0 
                      ? AppColors.moodColors[MoodLevel.good]!.withValues(alpha: 0.2)
                      : velocity < 0 ? AppColors.moodColors[MoodLevel.bad]!.withValues(alpha: 0.2) : textColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  velocity > 0 ? '↗️ Improving' : velocity < 0 ? '↘️ Declining' : '→ Stable',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: velocity > 0 ? AppColors.moodColors[MoodLevel.good] : velocity < 0 ? AppColors.moodColors[MoodLevel.bad] : textColor.withValues(alpha: 0.7)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GlassmorphicCard(
            blur: 10,
            opacity: 0.1,
            padding: const EdgeInsets.all(16),
            child: trendData.isEmpty
                ? Container(height: 120, alignment: Alignment.center, child: Text('Start logging to see trends', style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.5))))
                : SizedBox(
                    height: 120,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineTouchData: LineTouchData(enabled: false),
                        minY: 0, maxY: 4,
                        lineBarsData: [
                          LineChartBarData(
                            spots: trendData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                            isCurved: true,
                            curveSmoothness: 0.3,
                            gradient: LinearGradient(colors: [AppColors.moodColors[MoodLevel.meh]!, AppColors.moodColors[MoodLevel.good]!, AppColors.moodColors[MoodLevel.great]!]),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) {
                                final mood = trendData[index].mood;
                                return FlDotCirclePainter(radius: 4, color: mood?.color ?? Colors.white, strokeWidth: 1, strokeColor: Colors.white.withValues(alpha: 0.5));
                              },
                            ),
                            belowBarData: BarAreaData(show: true, gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [AppColors.moodColors[MoodLevel.good]!.withValues(alpha: 0.3), AppColors.moodColors[MoodLevel.good]!.withValues(alpha: 0.0)])),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Center(child: Text('Last 14 days', style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.4)))),
        ],
      ),
    );
  }
}

/// Day of Week Section - Bar chart showing patterns
class _DayOfWeekSection extends ConsumerWidget {
  final Color textColor;
  final DateTime month;

  const _DayOfWeekSection({required this.textColor, required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayStats = ref.watch(moodByDayOfWeekProvider(null));
    final hasData = dayStats.any((s) => s.entryCount > 0);
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Best Days', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.6))),
          const SizedBox(height: 12),
          GlassmorphicCard(
            blur: 10,
            opacity: 0.1,
            padding: const EdgeInsets.all(16),
            child: !hasData
                ? Container(height: 100, alignment: Alignment.center, child: Text('Log more moods to see patterns', style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.5))))
                : Column(
                    children: [
                      SizedBox(
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: dayStats.map((stat) {
                            final height = stat.averageMood / 4.0 * 70;
                            final barColor = _getMoodColor(stat.averageMood);
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: height.clamp(4.0, 70.0)),
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) => Container(
                                    width: 28,
                                    height: stat.entryCount > 0 ? value : 4,
                                    decoration: BoxDecoration(
                                      color: stat.entryCount > 0 ? barColor : textColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: stat.entryCount > 0 ? [BoxShadow(color: barColor.withValues(alpha: 0.3), blurRadius: 8)] : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(stat.dayName, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: textColor.withValues(alpha: 0.6))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBestDayInsight(dayStats),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
  
  Color _getMoodColor(double avg) {
    if (avg >= 3.5) return AppColors.moodColors[MoodLevel.great]!;
    if (avg >= 2.5) return AppColors.moodColors[MoodLevel.good]!;
    if (avg >= 1.5) return AppColors.moodColors[MoodLevel.okay]!;
    if (avg >= 0.5) return AppColors.moodColors[MoodLevel.meh]!;
    return AppColors.moodColors[MoodLevel.bad]!;
  }
  
  Widget _buildBestDayInsight(List<DayOfWeekStats> stats) {
    final validStats = stats.where((s) => s.entryCount > 0).toList();
    if (validStats.isEmpty) return const SizedBox.shrink();
    validStats.sort((a, b) => b.averageMood.compareTo(a.averageMood));
    final best = validStats.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: textColor.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✨', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Flexible(
            child: FutureBuilder<String>(
              future: AiService().generateDayInsight(best.fullDayName, best.averageMood),
              builder: (context, snapshot) {
                // Default static fallback while loading or if error
                final fallbackText = '${best.fullDayName}s are your happiest days!';
                
                if (snapshot.hasData) {
                  return AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      snapshot.data!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                }
                
                // Show fallback/loading text
                return Text(
                  snapshot.connectionState == ConnectionState.waiting 
                      ? 'Analyzing ${best.fullDayName}s...' 
                      : fallbackText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor.withValues(alpha: 0.7),
                    fontStyle: snapshot.connectionState == ConnectionState.waiting ? FontStyle.italic : FontStyle.normal,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

