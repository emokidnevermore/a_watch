import 'package:flutter/material.dart';
import 'package:a_watch/presentation/components/index.dart';

class ClickableSectionHeader extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final bool isDesktop;

  const ClickableSectionHeader({
    super.key,
    required this.title,
    required this.onTap,
    required this.isDesktop,
  });

  @override
  State<ClickableSectionHeader> createState() => _ClickableSectionHeaderState();
}

class _ClickableSectionHeaderState extends State<ClickableSectionHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.blue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    _colorAnimation = ColorTween(
      begin: theme.textTheme.titleMedium?.color,
      end: theme.colorScheme.primary,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (!widget.isDesktop) return;

    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      cursor: widget.isDesktop ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return AppH2(
              widget.title,
              color: _colorAnimation.value,
            );
          },
        ),
      ),
    );
  }
}
