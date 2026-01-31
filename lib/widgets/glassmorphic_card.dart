import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:onetap/core/constants/app_colors.dart';

/// A glassmorphic card with frosted glass effect
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final double opacity;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 24,
    this.blur = 10,
    this.backgroundColor,
    this.opacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? 
        (isDark ? Colors.white.withValues(alpha: opacity) : Colors.white.withValues(alpha:opacity + 0.3));

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
