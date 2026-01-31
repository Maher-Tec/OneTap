import 'package:flutter/material.dart';
import 'package:onetap/core/constants/app_durations.dart';

/// A widget that applies a "breathing" scale animation to its child
class BreathingWidget extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;

  const BreathingWidget({
    super.key,
    required this.child,
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.duration = AppDurations.splashBreathing,
  });

  @override
  State<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

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
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
