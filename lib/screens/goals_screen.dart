import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onetap/core/constants/app_colors.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/core/utils/haptic_utils.dart';
import 'package:onetap/data/models/mood_goal.dart';
import 'package:onetap/data/repositories/goal_repository.dart';
import 'package:onetap/providers/goal_providers.dart';
import 'package:onetap/widgets/glassmorphic_card.dart';
import 'package:onetap/widgets/animated_gradient_background.dart';
import 'package:onetap/widgets/floating_particles.dart';
import 'package:onetap/widgets/premium_effects.dart';
import 'package:onetap/widgets/shared_buttons.dart';
import 'package:onetap/screens/home_screen.dart';

/// Premium Goals Screen
class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(goalNotifierProvider.notifier).checkAndCompleteGoals();
    });
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
    final activeProgress = ref.watch(activeGoalsProgressProvider);
    final completedGoals = ref.watch(completedGoalsProvider);

    return Scaffold(
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            const Positioned.fill(child: VignetteOverlay(intensity: 0.2)),
            Positioned.fill(
              child: FloatingParticles(
                particleCount: 8,
                color: Colors.white.withValues(alpha: 0.3),
                maxSize: 2,
                minSize: 1,
              ),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // App bar
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
                            'Goals',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const Spacer(),
                          _AddGoalButton(
                            textColor: textColor,
                            onTap: () => _showAddGoalSheet(context),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (activeProgress.isEmpty && completedGoals.isEmpty)
                              _EmptyState(textColor: textColor, onAddGoal: () => _showAddGoalSheet(context))
                            else ...[
                              // Active goals
                              if (activeProgress.isNotEmpty) ...[
                                Text(
                                  'Active Goals',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...activeProgress.map(
                                  (progress) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _GoalCard(
                                      progress: progress,
                                      textColor: textColor,
                                      onDelete: () => _deleteGoal(progress.goal.id),
                                    ),
                                  ),
                                ),
                              ],

                              // Completed goals
                              if (completedGoals.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...completedGoals.map(
                                  (goal) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _CompletedGoalCard(goal: goal, textColor: textColor),
                                  ),
                                ),
                              ],
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

  void _navigateToHome(BuildContext context) {
    HapticUtils.gentle();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 240),
      ),
      (route) => false,
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    HapticUtils.gentle();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddGoalSheet(
        onGoalCreated: (type, targetDays) {
          ref.read(goalNotifierProvider.notifier).createFromTemplate(
                type: type,
                targetDays: targetDays,
              );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteGoal(String id) {
    HapticUtils.gentle();
    ref.read(goalNotifierProvider.notifier).deleteGoal(id);
  }
}

/// Add goal button
class _AddGoalButton extends StatelessWidget {
  final Color textColor;
  final VoidCallback onTap;

  const _AddGoalButton({required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: textColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add_rounded, color: textColor, size: 24),
      ),
    );
  }
}

/// Goal card with progress ring
class _GoalCard extends StatelessWidget {
  final GoalProgress progress;
  final Color textColor;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.progress,
    required this.textColor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final goal = progress.goal;
    final color = _getGoalColor();

    return GlassmorphicCard(
      blur: 12,
      opacity: 0.12,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Progress ring
          SizedBox(
            width: 70,
            height: 70,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.progressPercent / 100),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CustomPaint(
                  painter: _ProgressRingPainter(
                    progress: value,
                    color: color,
                    backgroundColor: textColor.withValues(alpha: 0.1),
                  ),
                  child: child,
                );
              },
              child: Center(
                child: Text(
                  goal.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  progress.progressFraction,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  progress.statusMessage,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          // Delete button
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close_rounded,
                size: 20,
                color: textColor.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGoalColor() {
    if (progress.isComplete) return AppColors.moodColors[MoodLevel.great]!;
    if (progress.progressPercent >= 75) return AppColors.moodColors[MoodLevel.good]!;
    if (progress.progressPercent >= 50) return AppColors.moodColors[MoodLevel.okay]!;
    return AppColors.moodColors[MoodLevel.meh]!;
  }
}

/// Progress ring painter
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 6.0;

    // Background
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

/// Completed goal card
class _CompletedGoalCard extends StatelessWidget {
  final MoodGoal goal;
  final Color textColor;

  const _CompletedGoalCard({required this.goal, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.moodColors[MoodLevel.great]!.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.moodColors[MoodLevel.great]!.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              goal.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.moodColors[MoodLevel.great],
            size: 22,
          ),
        ],
      ),
    );
  }
}

/// Empty state
class _EmptyState extends StatelessWidget {
  final Color textColor;
  final VoidCallback onAddGoal;

  const _EmptyState({required this.textColor, required this.onAddGoal});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            Text(
              'No goals yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set a mood goal to stay motivated',
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onAddGoal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.moodColors[MoodLevel.good]!,
                      AppColors.moodColors[MoodLevel.great]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.moodColors[MoodLevel.good]!.withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Text(
                  'Create Your First Goal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Add goal bottom sheet
class _AddGoalSheet extends StatefulWidget {
  final Function(String type, int targetDays) onGoalCreated;

  const _AddGoalSheet({required this.onGoalCreated});

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  String _selectedType = 'positive';
  int _targetDays = 15;

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'New Goal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 24),

          // Goal type
          Text(
            'Goal Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _TypeChip(
                label: '😊 Positive Days',
                isSelected: _selectedType == 'positive',
                onTap: () => setState(() => _selectedType = 'positive'),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: '🌟 Great Days',
                isSelected: _selectedType == 'great',
                onTap: () => setState(() => _selectedType = 'great'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _TypeChip(
            label: '📝 Log Consistently',
            isSelected: _selectedType == 'consistency',
            onTap: () => setState(() => _selectedType = 'consistency'),
          ),
          const SizedBox(height: 24),

          // Target days
          Text(
            'Target: $_targetDays days per month',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Slider(
            value: _targetDays.toDouble(),
            min: 5,
            max: 30,
            divisions: 25,
            activeColor: AppColors.moodColors[MoodLevel.good],
            inactiveColor: Colors.white.withValues(alpha: 0.2),
            onChanged: (v) => setState(() => _targetDays = v.round()),
          ),
          const SizedBox(height: 32),

          // Create button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticUtils.gentle();
                widget.onGoalCreated(_selectedType, _targetDays);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.moodColors[MoodLevel.good],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Create Goal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Type selection chip
class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.moodColors[MoodLevel.good]!.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.moodColors[MoodLevel.good]!
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? AppColors.moodColors[MoodLevel.good]
                : Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
