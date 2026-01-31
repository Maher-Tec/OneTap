import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Floating particle data
class _Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

/// Floating ambient particles for background atmosphere
class FloatingParticles extends StatefulWidget {
  final int particleCount;
  final Color color;
  final double maxSize;
  final double minSize;

  const FloatingParticles({
    super.key,
    this.particleCount = 20,
    this.color = Colors.white,
    this.maxSize = 6,
    this.minSize = 2,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initParticles();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  void _initParticles() {
    _particles = List.generate(widget.particleCount, (_) => _createParticle());
  }

  _Particle _createParticle({double? startY}) {
    return _Particle(
      x: _random.nextDouble(),
      y: startY ?? _random.nextDouble(),
      size: widget.minSize + _random.nextDouble() * (widget.maxSize - widget.minSize),
      speed: 0.0003 + _random.nextDouble() * 0.0007,
      opacity: 0.2 + _random.nextDouble() * 0.4,
    );
  }

  void _updateParticles() {
    for (int i = 0; i < _particles.length; i++) {
      _particles[i].y -= _particles[i].speed;

      // Reset particle when it goes off screen
      if (_particles[i].y < -0.05) {
        _particles[i] = _createParticle(startY: 1.05);
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        _updateParticles();
        return CustomPaint(
          painter: _ParticlesPainter(
            particles: _particles,
            color: widget.color,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;

  _ParticlesPainter({
    required this.particles,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
