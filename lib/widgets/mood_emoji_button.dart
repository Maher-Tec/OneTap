import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/core/constants/app_durations.dart';
import 'package:onetap/core/utils/haptic_utils.dart';

/// Interactive mood emoji button
/// Shows static text emoji by default, Lottie animation on hover/selection
class MoodEmojiButton extends StatefulWidget {
  final MoodLevel mood;
  final bool isSelected;
  final bool isDisabled;
  final bool showLabel;
  final VoidCallback? onTap;
  final double size;

  const MoodEmojiButton({
    super.key,
    required this.mood,
    this.isSelected = false,
    this.isDisabled = false,
    this.showLabel = false,
    this.onTap,
    this.size = 52,
  });

  @override
  State<MoodEmojiButton> createState() => _MoodEmojiButtonState();
}

class _MoodEmojiButtonState extends State<MoodEmojiButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  late AnimationController _lottieController;
  
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    // Lottie animation controller
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    // Scale animation for selection
    _scaleController = AnimationController(
      vsync: this,
      duration: AppDurations.moodScale,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    // Glow pulse animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    // Bounce animation for tap
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    
    if (widget.isSelected) {
      _scaleController.forward();
      _glowController.repeat(reverse: true);
      _lottieController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant MoodEmojiButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _scaleController.forward();
      _glowController.repeat(reverse: true);
      _lottieController.repeat();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _scaleController.reverse();
      _glowController.stop();
      _glowController.reset();
      _lottieController.stop();
      _lottieController.reset();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _bounceController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isDisabled) return;
    _bounceController.forward();
    // Start animation on press
    if (!widget.isSelected) {
      _lottieController.repeat();
    }
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    _bounceController.reverse();
    // Stop animation on release if not selected
    if (!widget.isSelected) {
      _lottieController.stop();
      _lottieController.reset();
    }
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    _bounceController.reverse();
    // Stop animation if not selected
    if (!widget.isSelected) {
      _lottieController.stop();
      _lottieController.reset();
    }
    setState(() => _isPressed = false);
  }

  void _handleHoverEnter(PointerEvent event) {
    if (widget.isDisabled) return;
    // Start animation on hover
    if (!widget.isSelected) {
      _lottieController.repeat();
    }
    setState(() => _isHovered = true);
  }

  void _handleHoverExit(PointerEvent event) {
    // Stop animation on hover exit if not selected
    if (!widget.isSelected) {
      _lottieController.stop();
      _lottieController.reset();
    }
    setState(() => _isHovered = false);
  }

  void _handleTap() {
    if (widget.isDisabled) {
      HapticUtils.error();
      return;
    }
    HapticUtils.moodHaptic(widget.mood);
    widget.onTap?.call();
  }

  // Check if should show Lottie animation (selected, hovered, or pressed)
  bool get _showLottie => widget.isSelected || _isHovered || _isPressed;

  @override
  Widget build(BuildContext context) {
    // Calculate opacity based on state
    double opacity = 1.0;
    if (widget.isDisabled) {
      opacity = 0.5;
    } else if (!widget.isSelected && _scaleController.status != AnimationStatus.dismissed) {
      opacity = 0.4;
    }

    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _bounceAnimation, _glowAnimation]),
          builder: (context, child) {
            // Combine scale effects
            double scale = widget.isSelected
                ? _scaleAnimation.value
                : _bounceAnimation.value;

            return AnimatedOpacity(
              duration: AppDurations.moodFadeOthers,
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Emoji container with animated glow
                    Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: widget.isSelected
                            ? [
                                BoxShadow(
                                  color: widget.mood.color.withValues(
                                    alpha: _glowAnimation.value,
                                  ),
                                  blurRadius: 20 * _glowAnimation.value,
                                  spreadRadius: 4 * _glowAnimation.value,
                                ),
                              ]
                            : _isHovered
                                ? [
                                    BoxShadow(
                                      color: widget.mood.color.withValues(alpha: 0.25),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Selection ring
                          if (widget.isSelected)
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Container(
                                  width: widget.size + 6,
                                  height: widget.size + 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: widget.mood.color.withValues(alpha: 0.5 * value),
                                      width: 2,
                                    ),
                                  ),
                                );
                              },
                            ),
                          
                          // Show Lottie animation OR static text emoji
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _showLottie
                                ? Lottie.asset(
                                    widget.mood.lottieAsset,
                                    key: const ValueKey('lottie'),
                                    width: widget.size * 0.9,
                                    height: widget.size * 0.9,
                                    fit: BoxFit.contain,
                                    controller: _lottieController,
                                    repeat: true,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback to text emoji if Lottie fails
                                      return Text(
                                        widget.mood.emoji,
                                        style: TextStyle(
                                          fontSize: widget.size * 0.7,
                                        ),
                                      );
                                    },
                                  )
                                : Text(
                                    widget.mood.emoji,
                                    key: const ValueKey('emoji'),
                                    style: TextStyle(
                                      fontSize: widget.size * 0.7,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Label with animated reveal
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: widget.showLabel && widget.isSelected
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 5 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.mood.color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.mood.label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: widget.mood.color,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(height: 0),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
