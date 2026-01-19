import 'package:flutter/material.dart';

/// Card with hover and tap effects for better interactivity
class HoverableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double hoverScale;
  final Duration animationDuration;
  final BorderRadius? borderRadius;

  const HoverableCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.hoverScale = 1.05,
    this.animationDuration = const Duration(milliseconds: 200),
    this.borderRadius,
  });

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;

  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.hoverScale,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _scaleController.forward();
    } else if (!_isPressed) {
      _scaleController.reverse();
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    if (!_isHovered) {
      _scaleController.reverse();
    }
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    if (!_isHovered) {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Material(
            color: Colors.transparent,
            borderRadius: widget.borderRadius,
            child: InkWell(
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              borderRadius: widget.borderRadius,
              splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
