import 'package:flutter/material.dart';
import 'package:onetap/core/constants/app_colors.dart';

/// Streak badge with fire emoji
class StreakBadge extends StatelessWidget {
  final int streak;
  final bool compact;

  const StreakBadge({
    super.key,
    required this.streak,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (streak <= 0) {
      return const SizedBox.shrink();
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.streakFire.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              '$streak',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.streakFire,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.streakFire.withValues(alpha: 0.2),
            AppColors.streakFire.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.streakFire.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            '$streak day${streak != 1 ? 's' : ''} streak',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.streakFire,
            ),
          ),
        ],
      ),
    );
  }
}
