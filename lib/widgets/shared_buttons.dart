import 'package:flutter/material.dart';

/// Reusable animated back button with press effect
class AnimatedBackButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color color;

  const AnimatedBackButton({
    required this.onTap,
    required this.color,
  });

  @override
  State<AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<AnimatedBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
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
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                color: widget.color.withValues(alpha: 0.8),
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Reusable nav arrow button (for month navigation in calendar/insights)
class NavArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const NavArrowButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  State<NavArrowButton> createState() => _NavArrowButtonState();
}

class _NavArrowButtonState extends State<NavArrowButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: _isPressed ? 0.2 : 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.icon,
          color: widget.color.withValues(alpha: 0.8),
          size: 22,
        ),
      ),
    );
  }
}

/// Reusable animated icon button with scale effect (for settings button)
class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const AnimatedIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
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
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.1),
              ),
              child: Icon(
                widget.icon,
                color: widget.color.withValues(alpha: 0.8),
                size: 22,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Reusable premium nav button with hover/press effects
class PremiumNavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const PremiumNavButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<PremiumNavButton> createState() => _PremiumNavButtonState();
}

class _PremiumNavButtonState extends State<PremiumNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
        _controller.forward();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        _controller.reverse();
        setState(() => _isPressed = false);
        widget.onTap();
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
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _isPressed
                    ? widget.color.withValues(alpha: 0.2)
                    : widget.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.color.withValues(alpha: 0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: widget.color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
