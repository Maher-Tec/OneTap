import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onetap/core/constants/app_colors.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/core/utils/haptic_utils.dart';
import 'package:onetap/data/repositories/goal_repository.dart';
import 'package:onetap/providers/goal_providers.dart';
import 'package:onetap/widgets/animated_gradient_background.dart';
import 'package:onetap/widgets/floating_particles.dart';
import 'package:onetap/widgets/glassmorphic_card.dart';
import 'package:onetap/widgets/shared_buttons.dart';

/// Premium goal detail screen
class GoalDetailScreen extends ConsumerStatefulWidget {
  final GoalProgress progress;

  const GoalDetailScreen({
    super.key,
    required this.progress,
  });

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
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
    final goal = widget.progress.goal;
    final isComplete = widget.progress.isComplete;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            // Background particles
            Positioned.fill(
              child: FloatingParticles(
                particleCount: 15,
                color: Colors.white.withValues(alpha: 0.4),
                maxSize: 3,
                minSize: 1,
              ),
            ),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          AnimatedIconButton(
                            icon: Icons.arrow_back,
                            color: textColor,
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Goal Details',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          // Delete button
                          AnimatedIconButton(
                            icon: Icons.delete_outline,
                            color: textColor.withValues(alpha: 0.7),
                            onTap: () => _showDeleteConfirmation(context),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),

                            // Large progress circle
                            TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 0,
                                end: widget.progress.progressPercent / 100,
                              ),
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: Stack(
                                    children: [
                                      // Background circle
                                      CircularProgressIndicator(
                                        value: 1.0,
                                        strokeWidth: 12,
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.white.withValues(alpha: 0.1),
                                        ),
                                      ),
                                      // Progress circle
                                      CircularProgressIndicator(
                                        value: value,
                                        strokeWidth: 12,
                                        valueColor: AlwaysStoppedAnimation(
                                          isComplete
                                              ? AppColors.successGreen
                                              : Colors.white,
                                        ),
                                      ),
                                      // Center content
                                      Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              goal.emoji,
                                              style:
                                                  const TextStyle(fontSize: 48),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${(value * 100).toInt()}%',
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w800,
                                                color: textColor,
                                                letterSpacing: -1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 32),

                            // Goal name
                            Text(
                              goal.name,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 8),

                            // Goal type
                            Text(
                              goal.typeLabel,
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Stats cards
                            GlassmorphicCard(
                              blur: 12,
                              opacity: 0.15,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  _StatRow(
                                    label: 'Progress',
                                    value: widget.progress.progressFraction,
                                    textColor: textColor,
                                  ),
                                  const SizedBox(height: 16),
                                  _StatRow(
                                    label: 'Status',
                                    value: widget.progress.statusMessage,
                                    textColor: textColor,
                                  ),
                                  if (!isComplete) ...[
                                    const SizedBox(height: 16),
                                    _StatRow(
                                      label: 'Days Remaining',
                                      value:
                                          '${widget.progress.daysRemaining} days',
                                      textColor: textColor,
                                    ),
                                    const SizedBox(height: 16),
                                    _StatRow(
                                      label: 'Days Needed',
                                      value:
                                          '${widget.progress.daysNeeded} more',
                                      textColor: textColor,
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  _StatRow(
                                    label: 'Total Logged',
                                    value:
                                        '${widget.progress.totalLoggedDays} days',
                                    textColor: textColor,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Target moods
                            if (goal.targetMoods.isNotEmpty) ...[
                              GlassmorphicCard(
                                blur: 12,
                                opacity: 0.15,
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'MOODS THAT COUNT',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            textColor.withValues(alpha: 0.6),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: goal.targetMoods.map((mood) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: mood.color
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: mood.color
                                                  .withValues(alpha: 0.3),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                mood.emoji,
                                                style:
                                                    const TextStyle(fontSize: 20),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                mood.label,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Completion celebration
                            if (isComplete) ...[
                              GlassmorphicCard(
                                blur: 12,
                                opacity: 0.15,
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    const Text(
                                      '🎉',
                                      style: TextStyle(fontSize: 48),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Goal Complete!',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.successGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Congratulations on\nachieving your goal!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            textColor.withValues(alpha: 0.7),
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

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

  void _showDeleteConfirmation(BuildContext context) {
    HapticUtils.gentle();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Delete Goal?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this goal? This action cannot be undone.',
          style: TextStyle(
            color: Colors.white70,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(goalNotifierProvider.notifier)
                  .deleteGoal(widget.progress.goal.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat row widget
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;

  const _StatRow({
    required this.label,
    required this.value,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: textColor.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
