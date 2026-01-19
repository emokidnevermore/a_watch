import 'package:flutter/material.dart';

class VideoPlayerShimmer extends StatefulWidget {
  const VideoPlayerShimmer({super.key});

  @override
  State<VideoPlayerShimmer> createState() => _VideoPlayerShimmerState();
}

class _VideoPlayerShimmerState extends State<VideoPlayerShimmer>
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
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: _animation.value),
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[900]!,
                  Colors.grey[850]!,
                  Colors.grey[900]!,
                ],
                stops: const [0.0, 0.5, 1.0],
                transform: GradientRotation(_controller.value * 2 * 3.14159),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white70,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Подготовка видео...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
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
