import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PremiumBackground extends StatelessWidget {
  const PremiumBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Stack(
      children: [
        // Base background color
        Container(color: const Color(0xFFF8F9FE)),

        // Soft blob 1 - Top Left
        _AnimatedBlob(
          alignment: Alignment.topLeft,
          color: primaryColor.withValues(alpha: 0.1),
          size: 400,
          duration: 15.seconds,
        ),

        // Soft blob 2 - Bottom Right
        _AnimatedBlob(
          alignment: Alignment.bottomRight,
          color: Colors.indigo.withValues(alpha: 0.08),
          size: 500,
          duration: 20.seconds,
        ),

        // Soft blob 3 - Center Left
        _AnimatedBlob(
          alignment: const Alignment(-1.5, 0.2),
          color: Colors.purple.withValues(alpha: 0.05),
          size: 350,
          duration: 12.seconds,
        ),

        // Overlay to soften everything
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}

class _AnimatedBlob extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double size;
  final Duration duration;

  const _AnimatedBlob({
    required this.alignment,
    required this.color,
    required this.size,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .move(
            begin: const Offset(-20, -20),
            end: const Offset(20, 20),
            duration: duration,
            curve: Curves.easeInOut,
          )
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.2, 1.2),
            duration: duration,
            curve: Curves.easeInOut,
          ),
    );
  }
}
