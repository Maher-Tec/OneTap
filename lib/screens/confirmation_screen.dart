import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:onetap/core/constants/app_colors.dart';
import 'package:onetap/core/constants/app_strings.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/core/utils/haptic_utils.dart';

import 'package:onetap/widgets/animated_gradient_background.dart';
import 'package:onetap/widgets/floating_particles.dart';
import 'package:onetap/widgets/premium_effects.dart';

import 'package:onetap/screens/home_screen.dart';
import 'package:onetap/screens/calendar_screen.dart';

/// Premium confirmation screen after saving an entry
class ConfirmationScreen extends ConsumerStatefulWidget {
  final MoodLevel mood;
  final String? note;

  const ConfirmationScreen({
    super.key,
    required this.mood,
    this.note,
  });

  @override
  ConsumerState<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends ConsumerState<ConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late Animation<double> _checkmarkScale;
  late Animation<double> _checkmarkRotation;
  
  late AnimationController _emojiController;
  late Animation<double> _emojiScale;
  late Animation<double> _emojiY;
  
  late AnimationController _lockController;
  late Animation<double> _lockScale;
  
  late AnimationController _contentController;
  late Animation<double> _contentOpacity;
  
  late AnimationController _confettiController;
  
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  bool _showConfetti = false;
  final List<_ConfettiParticle> _confettiParticles = [];

  @override
  void initState() {
    super.initState();

    // Checkmark animation with rotation
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkmarkScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkmarkController, curve: Curves.elasticOut),
    );
    _checkmarkRotation = Tween<double>(begin: -0.5, end: 0).animate(
      CurvedAnimation(parent: _checkmarkController, curve: Curves.easeOutBack),
    );

    // Emoji bounce animation
    _emojiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _emojiScale = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(parent: _emojiController, curve: Curves.elasticOut),
    );
    _emojiY = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _emojiController, curve: Curves.easeOutCubic),
    );

    // Lock animation
    _lockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _lockScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _lockController, curve: Curves.easeOutBack),
    );
    
    // Content fade
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentOpacity = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    
    // Confetti controller
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    
    // Glow pulse
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);

    // Start animation sequence
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    
    // Checkmark
    _checkmarkController.forward();
    HapticUtils.success();
    
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    
    // Emoji bounce
    _emojiController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    
    // Lock click
    _lockController.forward();
    HapticUtils.lockClick();
    
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    
    // Content
    _contentController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    
    // Confetti
    _generateConfetti();
    setState(() => _showConfetti = true);
    _confettiController.forward();
  }
  
  void _generateConfetti() {
    final random = math.Random();
    final colors = [
      widget.mood.color,
      AppColors.lockGold,
      Colors.white,
      widget.mood.color.withValues(alpha: 0.7),
    ];
    
    for (int i = 0; i < 30; i++) {
      _confettiParticles.add(_ConfettiParticle(
        x: random.nextDouble(),
        startY: -0.2 - random.nextDouble() * 0.3, // Start higher up
        speed: 0.8 + random.nextDouble() * 0.7,   // Faster speed
        size: 4 + random.nextDouble() * 6,
        rotation: random.nextDouble() * math.pi * 2,
        rotationSpeed: (random.nextDouble() - 0.5) * 4,
        color: colors[random.nextInt(colors.length)],
        swayAmount: 0.1 + random.nextDouble() * 0.15,
        swaySpeed: 2 + random.nextDouble() * 2,
      ));
    }
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _emojiController.dispose();
    _lockController.dispose();
    _contentController.dispose();
    _confettiController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final textColor = AppColors.getTimeTextColor(hour);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedGradientBackground(
        overlayColor: widget.mood.color,
        overlayOpacity: 0.25,
        child: Stack(
          children: [
            // Soft vignette
            const Positioned.fill(
              child: VignetteOverlay(intensity: 0.2),
            ),

            // Background glow orb
            Positioned(
              top: size.height * 0.25 - 150,
              left: size.width / 2 - 150,
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return GlowOrb(
                    color: widget.mood.color,
                    size: 300 * _glowAnimation.value,
                    intensity: 0.4,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Animated checkmark
                    AnimatedBuilder(
                      animation: _checkmarkController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _checkmarkScale.value,
                          child: Transform.rotate(
                            angle: _checkmarkRotation.value,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.successGreen,
                                    AppColors.successGreen.withValues(alpha: 0.8),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.successGreen.withValues(alpha: 0.5),
                                    blurRadius: 25,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Mood emoji (bounces in with glow)
                    AnimatedBuilder(
                      animation: _emojiController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _emojiY.value),
                          child: Transform.scale(
                            scale: _emojiScale.value,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.mood.color.withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Lottie.asset(
                                widget.mood.lottieAsset,
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Note (if provided)
                    FadeTransition(
                      opacity: _contentOpacity,
                      child: widget.note != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: textColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '"${widget.note}"',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                    color: textColor.withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 32),

                    // Saved message with lock
                    FadeTransition(
                      opacity: _contentOpacity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Saved for today.",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedBuilder(
                            animation: _lockScale,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _lockScale.value,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.lockGold.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    '🔒',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    FadeTransition(
                      opacity: _contentOpacity,
                      child: Text(
                        AppStrings.seeYouTomorrow,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Streak celebration removed as requested

                    const Spacer(flex: 2),

                    // Action buttons
                    FadeTransition(
                      opacity: _contentOpacity,
                      child: Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              label: AppStrings.viewCalendar,
                              icon: Icons.calendar_month_outlined,
                              onTap: () => _navigateToCalendar(context),
                              isPrimary: false,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ActionButton(
                              label: AppStrings.done,
                              icon: Icons.check_rounded,
                              onTap: () => _navigateToHome(context),
                              isPrimary: true,
                              color: widget.mood.color,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Confetti overlay (on top)
            if (_showConfetti)
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: size,
                      painter: _ConfettiPainter(
                        particles: _confettiParticles,
                        progress: _confettiController.value,
                      ),
                    );
                  },
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
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 240),
      ),
      (route) => false,
    );
  }

  void _navigateToCalendar(BuildContext context) {
    HapticUtils.gentle();
    Navigator.of(context).pushAndRemoveUntil(
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
        transitionDuration: const Duration(milliseconds: 240),
      ),
      (route) => false,
    );
  }
}

/// Confetti particle data
class _ConfettiParticle {
  final double x;
  final double startY;
  final double speed;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final Color color;
  final double swayAmount;
  final double swaySpeed;

  _ConfettiParticle({
    required this.x,
    required this.startY,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.swayAmount,
    required this.swaySpeed,
  });
}

/// Custom painter for confetti
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Multiplier increased to 2.0 to ensure they cross the screen
      final y = particle.startY + (progress * particle.speed * 2.0);
      if (y > 1.2) continue;
      
      final sway = math.sin(progress * math.pi * particle.swaySpeed) * particle.swayAmount;
      final x = particle.x + sway;
      
      final opacity = (1.0 - (y.clamp(0.8, 1.2) - 0.8) / 0.4).clamp(0.0, 1.0);
      
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      
      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(particle.rotation + progress * particle.rotationSpeed);
      
      // Draw rectangle confetti
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.6),
          const Radius.circular(1),
        ),
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Premium action button
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final Color color;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
    required this.color,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        _controller.reverse();
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
        setState(() => _isPressed = false);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: widget.isPrimary
                    ? widget.color
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: widget.isPrimary
                    ? null
                    : Border.all(
                        color: widget.color.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                boxShadow: widget.isPrimary
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(alpha: _isPressed ? 0.5 : 0.35),
                          blurRadius: _isPressed ? 20 : 15,
                          spreadRadius: _isPressed ? 2 : 0,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.isPrimary
                        ? Colors.white
                        : widget.color,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: widget.isPrimary
                          ? Colors.white
                          : widget.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
