import 'package:flutter/material.dart';

class TranslationShimmer extends StatefulWidget {
  const TranslationShimmer({super.key});

  @override
  State<TranslationShimmer> createState() => _TranslationShimmerState();
}

class _TranslationShimmerState extends State<TranslationShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6, // Show 6 shimmer items
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  height: 32,
                  constraints: const BoxConstraints(minWidth: 80, maxWidth: 120),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: _animation.value),
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[800]!.withValues(alpha: 0.8),
                        Colors.grey[700]!.withValues(alpha: 0.6),
                        Colors.grey[800]!.withValues(alpha: 0.8),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      transform: GradientRotation(_controller.value * 2 * 3.14159),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
