import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:onetap/core/constants/app_colors.dart';
import 'package:onetap/core/constants/app_strings.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/widgets/animated_gradient_background.dart';
import 'package:onetap/widgets/breathing_widget.dart';
import 'package:onetap/widgets/floating_particles.dart';
import 'package:onetap/widgets/premium_effects.dart';
import 'package:onetap/screens/home_screen.dart';

/// Premium splash screen with breathing emoji and meditation rings
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _titleController;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Main fade in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    // Title animation with slide
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _titleFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOut),
    );
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutCubic,
    ));

    // Glow pulse animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _glowController.repeat(reverse: true);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _titleController.forward();
    });

    // Auto-navigate to home with smooth transition
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _titleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final textColor = AppColors.getTimeTextColor(hour);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            // Soft vignette for depth
            const Positioned.fill(
              child: VignetteOverlay(intensity: 0.3),
            ),

            // Meditation rings behind emoji
            Positioned(
              top: size.height * 0.35 - 175,
              left: size.width / 2 - 175,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const MeditationRings(
                  color: Colors.white,
                  ringCount: 3,
                  maxSize: 350,
                ),
              ),
            ),

            // Glow orb behind emoji
            Positioned(
              top: size.height * 0.35 - 100,
              left: size.width / 2 - 100,
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return GlowOrb(
                    color: Colors.white,
                    size: 200,
                    intensity: 0.4 * _glowAnimation.value,
                  );
                },
              ),
            ),

            // Floating particles
            Positioned.fill(
              child: FloatingParticles(
                particleCount: 30,
                color: Colors.white.withValues(alpha: 0.8),
                maxSize: 4,
                minSize: 1,
              ),
            ),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Breathing emoji with glow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: BreathingWidget(
                        minScale: 0.92,
                        maxScale: 1.08,
                        duration: Duration(milliseconds: 2500),
                        child: Lottie.asset(
                          MoodLevel.good.lottieAsset,
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // App name with slide and fade
                    SlideTransition(
                      position: _titleSlideAnimation,
                      child: FadeTransition(
                        opacity: _titleFadeAnimation,
                        child: Column(
                          children: [
                            // Shimmer on title
                            ShimmerOverlay(
                              shimmerColor: Colors.white,
                              child: Text(
                                AppStrings.appName,
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Tagline
                            Text(
                              AppStrings.appTagline,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: textColor.withValues(alpha: 0.8),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom safe breathing indicator
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _titleFadeAnimation,
                child: Center(
                  child: BreathingWidget(
                    minScale: 0.8,
                    maxScale: 1.0,
                    duration: const Duration(milliseconds: 1500),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: textColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
