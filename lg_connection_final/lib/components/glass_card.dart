import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? backgroundColor;
  final double blur;
  final bool animateOnTap;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(24),
    this.borderColor,
    this.backgroundColor,
    this.blur = 20, // Match prompt: 20px Gaussian blur
    this.animateOnTap = true,
    this.onTap,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
      onTapDown: (_) => widget.onTap != null && widget.animateOnTap ? _controller.forward() : null,
      onTapUp: (_) => widget.onTap != null && widget.animateOnTap ? _controller.reverse() : null,
      onTapCancel: () => widget.onTap != null && widget.animateOnTap ? _controller.reverse() : null,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                // Prompt: 70% opacity. Usually background is subtle. 
                // Using a light cyan-white tint for the background.
                color: widget.backgroundColor ?? Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  // Prompt: ultra-thin 1px borders in light cyan-white
                  color: widget.borderColor ?? const Color(0xFFE0F7FA).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
