import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/data/models/mood_entry.dart';
import 'package:onetap/widgets/premium_effects.dart';

/// A generative visualization of the week's emotional energy.
/// Each day is a star, colored by mood, forming a constellation.
class MoodGalaxy extends StatefulWidget {
  final List<MoodEntry?> entries;
  final double size;

  const MoodGalaxy({
    super.key,
    required this.entries,
    this.size = 320,
  });

  @override
  State<MoodGalaxy> createState() => _MoodGalaxyState();
}

class _MoodGalaxyState extends State<MoodGalaxy> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_StarData> _stars = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _generateGalaxy();
  }

  @override
  void didUpdateWidget(MoodGalaxy oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries || oldWidget.size != widget.size) {
      _generateGalaxy();
    }
  }

  void _generateGalaxy() {
    _stars.clear();
    if (widget.entries.isEmpty) return;

    final random = math.Random(42);
    
    // We want today (index 0) to be at the center or most prominent.
    // However, for a "galaxy" feel, we can spiral outwards as we go back in time.
    // The history is usually [today, yesterday, ..., -6 days]
    
    for (int i = 0; i < widget.entries.length; i++) {
      final entry = widget.entries[i];
      if (entry == null) continue;

      // Spiral logic: today is close to center, older days further out
      // radius should be within widget.size / 2 (allowing for star size)
      final maxRadius = (widget.size / 2) - 40; 
      final normalizedIndex = i / math.max(1, widget.entries.length - 1);
      
      final angle = (i * 0.8) + (random.nextDouble() * 0.5);
      final radius = 25.0 + (normalizedIndex * maxRadius);
      
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;

      _stars.add(_StarData(
        mood: entry.mood,
        offset: Offset(x, y),
        size: 14.0 - (i * 1.2), // Today is biggest
        pulseDelay: i * 0.4,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Constellation lines
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _ConstellationPainter(
              stars: _stars,
              animationValue: _controller.value,
            ),
          ),

          // Stars (GlowOrbs)
          ..._stars.asMap().entries.map((starEntry) {
            final star = starEntry.value;
            return _AnimatedStar(
              star: star,
              totalValue: _controller.value,
            );
          }),
          
          // Center glow for today if exists
          if (widget.entries.isNotEmpty && widget.entries[0] != null)
             GlowOrb(
              color: widget.entries[0]!.mood.color,
              size: 60,
              intensity: 0.15,
            ),
        ],
      ),
    );
  }
}

class _StarData {
  final MoodLevel mood;
  final Offset offset;
  final double size;
  final double pulseDelay;

  _StarData({
    required this.mood,
    required this.offset,
    required this.size,
    required this.pulseDelay,
  });
}

class _AnimatedStar extends StatelessWidget {
  final _StarData star;
  final double totalValue;

  const _AnimatedStar({
    required this.star,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    // Subtle floating animation
    final floatX = math.sin(totalValue * math.pi * 2 + star.pulseDelay) * 5;
    final floatY = math.cos(totalValue * math.pi * 2 + star.pulseDelay) * 5;

    return Transform.translate(
      offset: Offset(star.offset.dx + floatX, star.offset.dy + floatY),
      child: Container(
        width: star.size + 10,
        height: star.size + 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: star.mood.color.withValues(alpha: 0.6),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: star.size,
            height: star.size,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: star.mood.color.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  final List<_StarData> stars;
  final double animationValue;

  _ConstellationPainter({
    required this.stars,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (stars.length < 2) return;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < stars.length - 1; i++) {
      final p1 = center + stars[i].offset;
      final p2 = center + stars[i + 1].offset;

      // Draw faint connection line
      canvas.drawLine(p1, p2, paint);
      canvas.drawLine(p1, p2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) => true;
}
