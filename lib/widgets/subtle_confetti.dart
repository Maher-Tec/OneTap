import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Subtle confetti celebration effect
class SubtleConfetti extends StatefulWidget {
  final bool isPlaying;
  final Duration duration;
  final Color primaryColor;
  final Color secondaryColor;

  const SubtleConfetti({
    super.key,
    this.isPlaying = true,
    this.duration = const Duration(milliseconds: 2000),
    this.primaryColor = const Color(0xFF4CAF50),
    this.secondaryColor = const Color(0xFFFFC107),
  });

  @override
  State<SubtleConfetti> createState() => _SubtleConfettiState();
}

class _SubtleConfettiState extends State<SubtleConfetti>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiPiece> _pieces;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _pieces = List.generate(15, (_) => _createPiece());

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  _ConfettiPiece _createPiece() {
    return _ConfettiPiece(
      x: _random.nextDouble(),
      startY: 0.3 + _random.nextDouble() * 0.3,
      size: 4 + _random.nextDouble() * 6,
      speedY: 0.3 + _random.nextDouble() * 0.4,
      speedX: (_random.nextDouble() - 0.5) * 0.3,
      color: _random.nextBool() ? widget.primaryColor : widget.secondaryColor,
      rotation: _random.nextDouble() * math.pi * 2,
      rotationSpeed: (_random.nextDouble() - 0.5) * 4,
    );
  }

  @override
  void didUpdateWidget(covariant SubtleConfetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _pieces = List.generate(15, (_) => _createPiece());
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying && _controller.status != AnimationStatus.forward) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ConfettiPainter(
            pieces: _pieces,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ConfettiPiece {
  final double x;
  final double startY;
  final double size;
  final double speedY;
  final double speedX;
  final Color color;
  final double rotation;
  final double rotationSpeed;

  _ConfettiPiece({
    required this.x,
    required this.startY,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double progress;

  _ConfettiPainter({
    required this.pieces,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final x = (piece.x + piece.speedX * progress) * size.width;
      final y = (piece.startY + piece.speedY * progress) * size.height;
      final opacity = (1 - progress).clamp(0.0, 1.0);

      if (y > size.height || y < 0) continue;

      final paint = Paint()
        ..color = piece.color.withValues(alpha: opacity * 0.7)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(piece.rotation + piece.rotationSpeed * progress);

      // Draw as rounded rectangle (confetti shape)
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: piece.size, height: piece.size * 0.6),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
