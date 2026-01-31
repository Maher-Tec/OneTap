import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onetap/core/constants/app_colors.dart';
import 'package:onetap/core/constants/app_strings.dart';
import 'package:onetap/core/utils/haptic_utils.dart';
import 'package:onetap/providers/journal_providers.dart';
import 'package:onetap/widgets/animated_gradient_background.dart';
import 'package:onetap/widgets/premium_effects.dart';
import 'package:onetap/widgets/floating_particles.dart';
import 'package:onetap/widgets/glassmorphic_card.dart';
import 'package:onetap/widgets/shared_buttons.dart';
import 'package:onetap/screens/home_screen.dart';

/// Premium settings screen
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
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
                particleCount: 8,
                color: Colors.white.withValues(alpha: 0.3),
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
                            onTap: () => _navigateBack(context),
                            color: textColor,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            AppStrings.settingsTitle,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Settings list
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          // Reminders section
                          _buildSectionHeader(AppStrings.reminders, textColor, index: 0),
                          _buildSettingsCard(
                            child: Column(
                              children: [
                                _SettingsTile(
                                  title: AppStrings.dailyReminder,
                                  icon: Icons.notifications_outlined,
                                  textColor: textColor,
                                  trailing: _PremiumSwitch(
                                    value: settings.reminderEnabled,
                                    onChanged: (value) {
                                      HapticUtils.gentle();
                                      ref.read(settingsProvider.notifier)
                                          .setReminder(enabled: value);
                                    },
                                  ),
                                ),
                                if (settings.reminderEnabled) ...[
                                  const _Divider(),
                                  _SettingsTile(
                                    title: AppStrings.reminderTime,
                                    icon: Icons.access_time_outlined,
                                    textColor: textColor,
                                    trailing: _TimeButton(
                                      time: settings.reminderTime,
                                      onTap: () => _showTimePicker(
                                        context,
                                        settings.reminderTime,
                                      ),
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            index: 0,
                          ),

                          const SizedBox(height: 24),


                          const SizedBox(height: 24),

                          // Data section
                          // Data section
                          _buildSectionHeader(AppStrings.data, textColor, index: 3),
                          _buildSettingsCard(
                            child: Column(
                              children: [
                                _SettingsTile(
                                  title: AppStrings.exportJournal,
                                  icon: Icons.download_outlined,
                                  textColor: textColor,
                                  onTap: () => _exportData(context),
                                  trailing: Icon(
                                    Icons.chevron_right_rounded,
                                    color: textColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                const _Divider(),
                                _SettingsTile(
                                  title: AppStrings.resetAll,
                                  icon: Icons.delete_outline,
                                  textColor: Colors.redAccent,
                                  onTap: () => _showResetConfirmation(context),
                                  trailing: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                            index: 3,
                          ),

                          const SizedBox(height: 40),

                          // Version
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: textColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'v1.0.0 • Made with 💜',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textColor.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
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

  Widget _buildSectionHeader(String title, Color textColor, {required int index}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child, required int index}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 700 + (index * 100)),
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
      child: GlassmorphicCard(
        blur: 10,
        opacity: 0.12,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: child,
      ),
    );
  }

  void _navigateBack(BuildContext context) {
    HapticUtils.gentle();
    Navigator.of(context).pop();
  }

  Future<void> _showTimePicker(BuildContext context, String currentTime) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final timeString =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      ref.read(settingsProvider.notifier).setReminder(time: timeString);
    }
  }

  Future<void> _exportData(BuildContext context) async {
    HapticUtils.gentle();
    final csv = ref.read(exportCsvProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ExportSheet(csv: csv),
    );
  }

  Future<void> _showResetConfirmation(BuildContext context) async {
    HapticUtils.gentle();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ResetConfirmSheet(),
    );

    if (confirmed == true) {
      await ref.read(settingsProvider.notifier).resetAll();
      ref.read(todayEntryProvider.notifier).refresh();
      
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
          (route) => false,
        );
      }
    }
  }
}

class _SettingsTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color textColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.textColor,
    this.trailing,
    this.onTap,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _isPressed ? widget.textColor.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                color: widget.textColor.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: widget.textColor,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.textColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
      ),
    );
  }
}

class _PremiumSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PremiumSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  State<_PremiumSwitch> createState() => _PremiumSwitchState();
}

class _PremiumSwitchState extends State<_PremiumSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    
    if (widget.value) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _PremiumSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: 52,
            height: 30,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  Color.lerp(Colors.grey.shade700, AppColors.successGreen, _animation.value)!,
                  Color.lerp(Colors.grey.shade600, AppColors.successGreen.withValues(alpha: 0.8), _animation.value)!,
                ],
              ),
              boxShadow: widget.value
                  ? [
                      BoxShadow(
                        color: AppColors.successGreen.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: widget.value ? 22 : 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
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
    );
  }
}



class _TimeButton extends StatelessWidget {
  final String time;
  final VoidCallback onTap;
  final Color color;

  const _TimeButton({
    required this.time,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}

class _ExportSheet extends StatelessWidget {
  final String csv;

  const _ExportSheet({required this.csv});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.download_outlined, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Export Data',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // CSV content
            Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    csv,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ResetConfirmSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                AppStrings.resetConfirmTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                AppStrings.resetConfirmMessage,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 28),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(AppStrings.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(AppStrings.reset),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
