import 'package:flutter/material.dart';

class EpisodeShimmer extends StatefulWidget {
  const EpisodeShimmer({super.key});

  @override
  State<EpisodeShimmer> createState() => _EpisodeShimmerState();
}

class _EpisodeShimmerState extends State<EpisodeShimmer>
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
      height: 55,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 8, // Show 8 shimmer items
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: _animation.value),
                    borderRadius: BorderRadius.circular(8),
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
