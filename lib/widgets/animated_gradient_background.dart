import 'package:flutter/material.dart';
import 'package:onetap/core/constants/app_colors.dart';
import 'package:onetap/core/constants/app_durations.dart';

/// Animated gradient background that shifts based on time of day
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final Color? overlayColor;
  final double overlayOpacity;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.overlayColor,
    this.overlayOpacity = 0.3,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.gradientLoop,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
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
    final hour = DateTime.now().hour;
    final colors = AppColors.getTimeGradient(hour);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Subtle animation - slightly shift the gradient alignment
        final alignmentValue = _animation.value * 0.3;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.5 - alignmentValue, -1),
              end: Alignment(0.5 + alignmentValue, 1),
              colors: [
                colors[0],
                Color.lerp(colors[0], colors[1], 0.5 + alignmentValue * 0.2)!,
                colors[1],
              ],
            ),
          ),
          child: widget.overlayColor != null
              ? Container(
                  color: widget.overlayColor!.withValues(alpha: widget.overlayOpacity),
                  child: child,
                )
              : child,
        );
      },
      child: widget.child,
    );
  }
}
