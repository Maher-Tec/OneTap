import 'package:flutter/material.dart';
import 'package:onetap/core/constants/app_colors.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/data/repositories/goal_repository.dart';
import 'package:onetap/widgets/glassmorphic_card.dart';

/// Premium goal card with glassmorphic design
class GoalCard extends StatelessWidget {
  final GoalProgress progress;
  final VoidCallback onTap;

  const GoalCard({
    super.key,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final goal = progress.goal;
    final isComplete = progress.isComplete;

    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicCard(
        blur: 15,
        opacity: 0.15,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with emoji and name
            Row(
              children: [
                // Goal emoji with glow
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    goal.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 16),
                // Goal name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.typeLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status indicator
                if (isComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.successGreen.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.successGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress indicator
            Row(
              children: [
                // Circular progress
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    children: [
                      // Background circle
                      CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation(
                          Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      // Progress circle
                      CircularProgressIndicator(
                        value: progress.progressPercent / 100,
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation(
                          isComplete
                              ? AppColors.successGreen
                              : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      // Percentage text
                      Center(
                        child: Text(
                          '${progress.progressPercent.toInt()}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // Progress details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress fraction
                      Text(
                        progress.progressFraction,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Status message
                      Text(
                        progress.statusMessage,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!isComplete && progress.daysRemaining > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${progress.daysNeeded} more needed • ${progress.daysRemaining} days left',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Target moods indicator (optional, subtle)
            if (goal.targetMoods.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                children: goal.targetMoods.take(3).map((mood) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: mood.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: mood.color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mood.emoji,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mood.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
