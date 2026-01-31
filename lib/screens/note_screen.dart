import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:onetap/core/constants/app_colors.dart';
import 'package:onetap/core/constants/app_strings.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/core/utils/haptic_utils.dart';
import 'package:onetap/providers/journal_providers.dart';
import 'package:onetap/widgets/animated_gradient_background.dart';
import 'package:onetap/widgets/floating_particles.dart';
import 'package:onetap/widgets/glassmorphic_card.dart';
import 'package:onetap/widgets/premium_effects.dart';
import 'package:onetap/widgets/breathing_widget.dart';
import 'package:onetap/screens/confirmation_screen.dart';

/// Premium screen for adding an optional micro-note
class NoteScreen extends ConsumerStatefulWidget {
  final MoodLevel selectedMood;

  const NoteScreen({
    super.key,
    required this.selectedMood,
  });

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen>
    with TickerProviderStateMixin {
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  static const int _maxChars = 300;
  
  late AnimationController _emojiController;
  late Animation<double> _emojiScaleAnimation;
  late Animation<double> _emojiOpacityAnimation;
  
  late AnimationController _contentController;
  late Animation<double> _contentOpacityAnimation;
  late Animation<Offset> _contentSlideAnimation;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    
    // Emoji entry animation
    _emojiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _emojiScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _emojiController, curve: Curves.elasticOut),
    );
    _emojiOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _emojiController, curve: Curves.easeOut),
    );
    
    // Content slide-up animation
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentOpacityAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));
    
    // Subtle pulse for the emoji glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Start animations in sequence
    _emojiController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentController.forward();
    });
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _focusNode.dispose();
    _emojiController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final textColor = AppColors.getTimeTextColor(hour);
    final charCount = _noteController.text.length;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AnimatedGradientBackground(
        overlayColor: widget.selectedMood.color,
        overlayOpacity: 0.2,
        child: Stack(
          children: [
            // Soft vignette
            const Positioned.fill(
              child: VignetteOverlay(intensity: 0.25),
            ),

            // Glow orb behind emoji
            Positioned(
              top: size.height * 0.08,
              left: size.width / 2 - 100,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return GlowOrb(
                    color: widget.selectedMood.color,
                    size: 200 * _pulseAnimation.value,
                    intensity: 0.5,
                  );
                },
              ),
            ),

            // Background particles (mood-colored)
            Positioned.fill(
              child: FloatingParticles(
                particleCount: 15,
                color: widget.selectedMood.color.withValues(alpha: 0.5),
                maxSize: 4,
                minSize: 1,
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 48),

                    // Selected mood emoji (animated entry with glow)
                    AnimatedBuilder(
                      animation: _emojiController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _emojiOpacityAnimation.value,
                          child: Transform.scale(
                            scale: _emojiScaleAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.selectedMood.color.withValues(alpha: 0.5),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: BreathingWidget(
                                minScale: 0.98,
                                maxScale: 1.02,
                                duration: const Duration(milliseconds: 1500),
                                child: Lottie.asset(
                                  widget.selectedMood.lottieAsset,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    
                    // Mood label
                    AnimatedBuilder(
                      animation: _contentOpacityAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _contentOpacityAnimation.value,
                          child: Text(
                            'Feeling ${widget.selectedMood.label.toLowerCase()}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: widget.selectedMood.color,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    // Content with slide animation
                    SlideTransition(
                      position: _contentSlideAnimation,
                      child: FadeTransition(
                        opacity: _contentOpacityAnimation,
                        child: Column(
                          children: [
                            // Title
                            Text(
                              widget.selectedMood.prompt,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                                letterSpacing: -0.5,
                              ),
                            ),

                            const SizedBox(height: 8),
                            
                            Text(
                              'capture this moment',
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor.withValues(alpha: 0.6),
                                fontStyle: FontStyle.italic,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Input field with premium glass effect
                            GlassmorphicCard(
                              blur: 15,
                              opacity: 0.12,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: TextField(
                                controller: _noteController,
                                focusNode: _focusNode,
                                maxLength: _maxChars,
                                maxLines: null,
                                minLines: 3,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                  letterSpacing: 0.5,
                                ),
                                decoration: InputDecoration(
                                  hintText: AppStrings.notePlaceholder,
                                  hintStyle: TextStyle(
                                    color: textColor.withValues(alpha: 0.35),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(_maxChars),
                                ],
                                onChanged: (_) => setState(() {}),
                              ),
                            ),

                            // Character counter (always visible)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: textColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_noteController.text.length} / $_maxChars chars',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: charCount >= _maxChars - 50
                                            ? AppColors.moodColors[MoodLevel.bad]
                                            : charCount >= _maxChars - 100
                                                ? AppColors.moodColors[MoodLevel.meh]
                                                : textColor.withValues(alpha: 0.6),
                                      ),
                                    ),
                                    if (charCount > 0)
                                      GestureDetector(
                                        onTap: () {
                                          _noteController.clear();
                                          setState(() {});
                                        },
                                        child: Icon(
                                          Icons.clear_rounded,
                                          size: 16,
                                          color: textColor.withValues(alpha: 0.4),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Examples with stagger
                            ...List.generate(3, (index) {
                              final examples = [
                                AppStrings.noteExample1,
                                AppStrings.noteExample2,
                                AppStrings.noteExample3,
                              ];
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 800 + (index * 150)),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 10 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    '"${examples[index]}"',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: textColor.withValues(alpha: 0.45),
                                    ),
                                  ),
                                ),
                              );
                            }),

                            const SizedBox(height: 48),

                            // Action buttons with premium styling
                            Row(
                              children: [
                                // Skip button
                                Expanded(
                                  child: _PremiumButton(
                                    label: AppStrings.skipButton,
                                    onTap: () => _saveEntry(null),
                                    isPrimary: false,
                                    color: textColor,
                                    isLoading: _isSaving,
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Save button
                                Expanded(
                                  child: _PremiumButton(
                                    label: AppStrings.saveButton,
                                    onTap: () => _saveEntry(_noteController.text),
                                    isPrimary: true,
                                    color: widget.selectedMood.color,
                                    isLoading: _isSaving,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),
                          ],
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

  Future<void> _saveEntry(String? note) async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    HapticUtils.success();
    
    final trimmedNote = note?.trim();
    final finalNote = (trimmedNote?.isEmpty ?? true) ? null : trimmedNote;
    
    // Save entry
    await ref.read(todayEntryProvider.notifier).saveEntry(
      widget.selectedMood,
      note: finalNote,
    );

    if (mounted) {
      // Navigate to confirmation with smooth transition
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ConfirmationScreen(
            mood: widget.selectedMood,
            note: finalNote,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }
}

/// Premium button with press effects
class _PremiumButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final Color color;
  final bool isLoading;

  const _PremiumButton({
    required this.label,
    required this.onTap,
    required this.isPrimary,
    required this.color,
    this.isLoading = false,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isLoading) {
          _controller.forward();
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        _controller.reverse();
        setState(() => _isPressed = false);
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
        setState(() => _isPressed = false);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: widget.isPrimary
                    ? widget.color
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: widget.isPrimary
                    ? null
                    : Border.all(
                        color: widget.color.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                boxShadow: widget.isPrimary && !widget.isLoading
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(alpha: _isPressed ? 0.5 : 0.3),
                          blurRadius: _isPressed ? 20 : 15,
                          spreadRadius: _isPressed ? 2 : 0,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isPrimary ? Colors.white : widget.color,
                          ),
                        ),
                      )
                    : Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.isPrimary
                              ? Colors.white
                              : widget.color,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
