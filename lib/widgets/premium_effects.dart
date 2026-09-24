import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Premium glow orb widget that creates a soft, pulsating glow effect
class GlowOrb extends StatefulWidget {
  final Color color;
  final double size;
  final double intensity;

  const GlowOrb({
    super.key,
    this.color = Colors.white,
    this.size = 200,
    this.intensity = 0.6,
  });

  @override
  State<GlowOrb> createState() => _GlowOrbState();
}

class _GlowOrbState extends State<GlowOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size * _pulseAnimation.value,
          height: widget.size * _pulseAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.color.withValues(alpha: widget.intensity * _pulseAnimation.value),
                widget.color.withValues(alpha: widget.intensity * 0.3 * _pulseAnimation.value),
                widget.color.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Animated ring that expands outward with fade
class ExpandingRing extends StatefulWidget {
  final Color color;
  final double maxSize;
  final Duration duration;
  final double strokeWidth;

  const ExpandingRing({
    super.key,
    this.color = Colors.white,
    this.maxSize = 300,
    this.duration = const Duration(milliseconds: 2500),
    this.strokeWidth = 2,
  });

  @override
  State<ExpandingRing> createState() => _ExpandingRingState();
}

class _ExpandingRingState extends State<ExpandingRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _controller.repeat();
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
        final size = widget.maxSize * _controller.value;
        final opacity = (1 - _controller.value).clamp(0.0, 0.6);

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withValues(alpha: opacity),
              width: widget.strokeWidth,
            ),
          ),
        );
      },
    );
  }
}

/// Staggered expanding rings for meditation-like effect
class MeditationRings extends StatelessWidget {
  final Color color;
  final int ringCount;
  final double maxSize;

  const MeditationRings({
    super.key,
    this.color = Colors.white,
    this.ringCount = 3,
    this.maxSize = 350,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(ringCount, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 800 + (index * 200)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return ExpandingRing(
              color: color,
              maxSize: maxSize,
              duration: Duration(milliseconds: 2500 + (index * 500)),
              strokeWidth: 1.5,
            );
          },
        );
      }),
    );
  }
}

/// Shimmer effect overlay
class ShimmerOverlay extends StatefulWidget {
  final Widget child;
  final Color shimmerColor;
  
  const ShimmerOverlay({
    super.key,
    required this.child,
    this.shimmerColor = Colors.white,
  });

  @override
  State<ShimmerOverlay> createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<ShimmerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _controller.repeat();
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                widget.shimmerColor.withValues(alpha: 0.15),
                Colors.transparent,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
              transform: GradientRotation(_controller.value * math.pi * 2),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Soft vignette overlay for depth
class VignetteOverlay extends StatelessWidget {
  final double intensity;
  final Color color;

  const VignetteOverlay({
    super.key,
    this.intensity = 0.4,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Colors.transparent,
              color.withValues(alpha: intensity * 0.3),
              color.withValues(alpha: intensity),
            ],
            stops: const [0.4, 0.8, 1.0],
          ),
        ),
      ),
    );
  }
}
