import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onetap/core/constants/app_colors.dart';
import 'package:onetap/core/utils/haptic_utils.dart';
import 'package:onetap/data/models/achievement.dart';
import 'package:onetap/providers/achievement_providers.dart';
import 'package:onetap/widgets/animated_gradient_background.dart';
import 'package:onetap/widgets/floating_particles.dart';
import 'package:onetap/widgets/glassmorphic_card.dart';
import 'package:onetap/widgets/shared_buttons.dart';

/// Premium achievements screen
class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  AchievementTier? _filterTier;
  bool _showLockedOnly = false;

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
    final stats = ref.watch(achievementStatsProvider);
    var achievements = ref.watch(allAchievementsProvider);

    // Apply filters
    if (_filterTier != null) {
      achievements = achievements.where((a) => a.tier == _filterTier).toList();
    }
    if (_showLockedOnly) {
      achievements = achievements.where((a) => !a.isUnlocked).toList();
    }

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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Achievements',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  '${stats.progressString} unlocked',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textColor.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Stats card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _StatsCard(
                        stats: stats,
                        textColor: textColor,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Filters
                    _FilterRow(
                      textColor: textColor,
                      filterTier: _filterTier,
                      showLockedOnly: _showLockedOnly,
                      onTierChanged: (tier) {
                        setState(() => _filterTier = tier);
                        HapticUtils.gentle();
                      },
                      onLockedChanged: (value) {
                        setState(() => _showLockedOnly = value);
                        HapticUtils.gentle();
                      },
                    ),

                    const SizedBox(height: 16),

                    //  Achievements grid
                    Expanded(
                      child: achievements.isEmpty
                          ? _buildEmptyState(textColor)
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: achievements.length,
                              itemBuilder: (context, index) {
                                return _AchievementCard(
                                  achievement: achievements[index],
                                  textColor: textColor,
                                );
                              },
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

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🔍',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 20),
            Text(
              'No Achievements Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stats card
class _StatsCard extends StatelessWidget {
  final AchievementStats stats;
  final Color textColor;

  const _StatsCard({
    required this.stats,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      blur: 12,
      opacity: 0.15,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Progress circle
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation(
                    Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                CircularProgressIndicator(
                  value: stats.completionPercent / 100,
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation(
                    AppColors.successGreen,
                  ),
                ),
                Center(
                  child: Text(
                    '${stats.completionPercent.toInt()}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.totalUnlocked} Unlocked',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                if (stats.rarestUnlocked != null) ...[
                  Text(
                    'Rarest: ${stats.rarestUnlocked!.name}',
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  Text(
                    'Start your journey!',
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter row
class _FilterRow extends StatelessWidget {
  final Color textColor;
  final AchievementTier? filterTier;
  final bool showLockedOnly;
  final ValueChanged<AchievementTier?> onTierChanged;
  final ValueChanged<bool> onLockedChanged;

  const _FilterRow({
    required this.textColor,
    required this.filterTier,
    required this.showLockedOnly,
    required this.onTierChanged,
    required this.onLockedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: filterTier == null,
            textColor: textColor,
            onTap: () => onTierChanged(null),
          ),
          const SizedBox(width: 8),
          ...AchievementTier.values.map((tier) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: '${tier.emoji} ${tier.label}',
                isSelected: filterTier == tier,
                textColor: textColor,
                onTap: () => onTierChanged(tier),
              ),
            );
          }),
          const SizedBox(width: 8),
          _FilterChip(
            label: '🔒 Locked',
            isSelected: showLockedOnly,
            textColor: textColor,
            onTap: () => onLockedChanged(!showLockedOnly),
          ),
        ],
      ),
    );
  }
}

/// Filter chip
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color textColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? textColor
                : textColor.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

/// Achievement card
class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final Color textColor;

  const _AchievementCard({
    required this.achievement,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !achievement.isUnlocked;

    return GlassmorphicCard(
      blur: 12,
      opacity: isLocked ? 0.08 : 0.15,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Spacer(flex: 1),
          
          // Emoji/Icon
          Stack(
            children: [
              Text(
                achievement.emoji,
                style: TextStyle(
                  fontSize: 36,
                  color: isLocked ? Colors.grey : null,
                ),
              ),
              if (isLocked)
                const Positioned(
                  right: -4,
                  top: -4,
                  child: Icon(
                    Icons.lock,
                    size: 16,
                    color: Colors.white60,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Name
          Text(
            achievement.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isLocked
                  ? textColor.withValues(alpha: 0.4)
                  : textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Description
          Flexible(
            child: Text(
              achievement.description,
              style: TextStyle(
                fontSize: 10,
                color: isLocked
                    ? textColor.withValues(alpha: 0.3)
                    : textColor.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 6),

          // Tier badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _getTierColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _getTierColor().withValues(alpha: isLocked ? 0.2 : 0.4),
                width: 1,
              ),
            ),
            child: Text(
              achievement.tier.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isLocked
                    ? _getTierColor().withValues(alpha: 0.4)
                    : _getTierColor(),
              ),
            ),
          ),

          // Progress bar (if locked and has progress)
          if (isLocked && achievement.currentProgress > 0) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: achievement.progressPercent / 100,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(_getTierColor()),
                minHeight: 3,
              ),
            ),
          ],
          
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Color _getTierColor() {
    switch (achievement.tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
      case AchievementTier.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}
