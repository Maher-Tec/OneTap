import 'package:flutter/material.dart';
import 'package:onetap/core/constants/app_colors.dart';

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

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground> {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final colors = AppColors.getTimeGradient(hour);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(-0.5, -1),
          end: const Alignment(0.5, 1),
          colors: [
            colors[0],
            Color.lerp(colors[0], colors[1], 0.56)!,
            colors[1],
          ],
        ),
      ),
      child: widget.overlayColor == null
          ? widget.child
          : ColoredBox(
              color: widget.overlayColor!.withValues(alpha: widget.overlayOpacity),
              child: widget.child,
            ),
    );
  }
}
