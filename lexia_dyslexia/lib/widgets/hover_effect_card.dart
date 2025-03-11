import 'package:flutter/material.dart';

class HoverEffectCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double hoverElevation;
  final double elevation;
  final double scale;
  final Duration duration;
  final Color? baseColor;
  final Color? hoverColor;

  const HoverEffectCard({
    super.key,
    required this.child,
    this.onTap,
    this.hoverElevation = 8.0,
    this.elevation = 2.0,
    this.scale = 1.05,
    this.duration = const Duration(milliseconds: 200),
    this.baseColor,
    this.hoverColor,
  });

  @override
  State<HoverEffectCard> createState() => _HoverEffectCardState();
}

class _HoverEffectCardState extends State<HoverEffectCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.hoverElevation,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _setupColorAnimation();
  }
  
  void _setupColorAnimation() {
    final defaultBaseColor = widget.baseColor ?? Colors.white;
    final defaultHoverColor = widget.hoverColor ?? Colors.blue.shade50;
    
    _colorAnimation = ColorTween(
      begin: defaultBaseColor,
      end: defaultHoverColor,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(HoverEffectCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.baseColor != widget.baseColor || 
        oldWidget.hoverColor != widget.hoverColor) {
      _setupColorAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _controller.forward();
      },
      onExit: (_) {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              elevation: _elevationAnimation.value,
              color: _colorAnimation.value,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(12),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
