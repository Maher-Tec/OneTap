import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:onetap/core/utils/haptic_utils.dart';
import 'package:onetap/data/models/achievement.dart';

/// Full-screen achievement unlock celebration overlay
class AchievementUnlockOverlay extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementUnlockOverlay({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  /// Show the overlay
  static void show(BuildContext context, Achievement achievement) {
    HapticUtils.success();
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => AchievementUnlockOverlay(
        achievement: achievement,
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  @override
  State<AchievementUnlockOverlay> createState() =>
      _AchievementUnlockOverlayState();
}

class _AchievementUnlockOverlayState extends State<AchievementUnlockOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _confettiController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for badge
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Fade animation for content
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Confetti animation
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Start animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });
    _confettiController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Confetti
            const Positioned.fill(
              child: _ConfettiEffect(),
            ),

            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Achievement unlocked text
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        '🎉 ACHIEVEMENT UNLOCKED! 🎉',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Badge with scale animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _getTierColor().withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getTierColor().withValues(alpha: 0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.achievement.emoji,
                            style: const TextStyle(fontSize: 96),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Achievement name
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        widget.achievement.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Achievement description
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        widget.achievement.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tier badge
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _getTierColor().withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getTierColor().withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.achievement.tier.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.achievement.tier.label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _getTierColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Dismiss hint
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Tap anywhere to continue',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.6),
                          fontStyle: FontStyle.italic,
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

  Color _getTierColor() {
    switch (widget.achievement.tier) {
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
}

/// Confetti particle effect
class _ConfettiEffect extends StatefulWidget {
  const _ConfettiEffect();

  @override
  State<_ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<_ConfettiEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Generate random particles
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.3 - 0.3,
        color: Color.fromRGBO(
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
          1,
        ),
        size: random.nextDouble() * 6 + 4,
        rotation: random.nextDouble() * math.pi * 2,
        velocity: random.nextDouble() * 0.5 + 0.5,
      ));
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double y;
  final Color color;
  final double size;
  final double rotation;
  final double velocity;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.rotation,
    required this.velocity,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x = particle.x * size.width;
      final y = particle.y * size.height + (progress * size.height * particle.velocity);
      
      if (y > size.height) continue;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - progress * 0.5);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + progress * math.pi * 4);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}
