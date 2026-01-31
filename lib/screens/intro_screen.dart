import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:onetap/screens/home_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/intro/intro.mp4');

    try {
      await _controller.initialize();
      _controller.setVolume(1.0); // Ensure sound is on if any
      _controller.play();
      
      // Listen for video end
      _controller.addListener(_checkVideoEnd);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing intro video: $e');
      _navigateToHome(); // Fallback if video fails
    }
  }

  void _checkVideoEnd() {
    if (_controller.value.position >= _controller.value.duration) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    _controller.removeListener(_checkVideoEnd);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black, // Cinematic background
        extendBody: true,
        body: Stack(
        children: [
          // Video Player
          SizedBox.expand(
            child: _isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const SizedBox.shrink(), // Black screen while loading
          ),

        ],
      ),
    ),
    );
  }
}
