import 'dart:math' as math;
import 'package:flutter/material.dart';

class MergeParticles extends StatefulWidget {
  final int value;
  final Color color;
  final double size;

  const MergeParticles({
    super.key,
    required this.value,
    required this.color,
    required this.size,
  });

  @override
  State<MergeParticles> createState() => _MergeParticlesState();
}

class _MergeParticlesState extends State<MergeParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> particles;
  final random = math.Random();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Create more particles for higher values
    final particleCount = widget.value >= 1024 ? 24 : 16;

    particles = List.generate(particleCount, (index) {
      final angle =
          index * (math.pi * 2 / particleCount) + random.nextDouble() * 0.2;
      final speed =
          2.0 + random.nextDouble() * (widget.value >= 1024 ? 4.0 : 2.0);
      final size = widget.size * (0.08 + random.nextDouble() * 0.12);
      final isSpecial = widget.value >= 512 && random.nextBool();

      return Particle(
        angle: angle,
        speed: speed,
        size: size,
        color: isSpecial
            ? _getSpecialColor(widget.color)
            : widget.color.withValues(
                red: widget.color.r.toDouble(),
                green: widget.color.g.toDouble(),
                blue: widget.color.b.toDouble(),
                alpha: 0.8,
              ),
        shape: _getRandomShape(),
        rotationSpeed: (random.nextDouble() * 2 - 1) * math.pi * 2,
      );
    });

    // Start the animation
    _controller.forward().then((_) {
      if (!_isDisposed && mounted) {
        setState(() {
          // Animation completed
        });
      }
    });
  }

  ParticleShape _getRandomShape() {
    if (widget.value >= 1024) {
      // More special shapes for higher values
      return ParticleShape.values[random.nextInt(ParticleShape.values.length)];
    } else {
      // Mostly circles for lower values
      return random.nextDouble() < 0.7
          ? ParticleShape.circle
          : ParticleShape.values[random.nextInt(ParticleShape.values.length)];
    }
  }

  Color _getSpecialColor(Color baseColor) {
    final hslColor = HSLColor.fromColor(baseColor);
    return hslColor
        .withLightness((hslColor.lightness + 0.2).clamp(0.0, 1.0))
        .withSaturation((hslColor.saturation + 0.2).clamp(0.0, 1.0))
        .toColor()
        .withValues(
          red: hslColor.toColor().r.toDouble(),
          green: hslColor.toColor().g.toDouble(),
          blue: hslColor.toColor().b.toDouble(),
          alpha: 0.9,
        );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return RepaintBoundary(
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: ParticlePainter(
              particles: particles,
              progress: _controller.value,
              isSpecialMerge: widget.value >= 1024,
            ),
          ),
        );
      },
    );
  }
}

enum ParticleShape { circle, square, triangle, star }

class Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final ParticleShape shape;
  final double rotationSpeed;
  double rotation = 0.0;

  Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.shape,
    required this.rotationSpeed,
  });

  Offset getPosition(double progress) {
    final curve = Curves.easeOutQuart.transform(progress);
    final distance = speed * 50 * curve;
    final dx = math.cos(angle) * distance;
    final dy = math.sin(angle) * distance;
    rotation = rotationSpeed * progress * 2 * math.pi;
    return Offset(dx, dy);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final bool isSpecialMerge;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.isSpecialMerge,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      final position = particle.getPosition(progress);
      final opacity = (1 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = particle.color.withValues(
          red: particle.color.r.toDouble(),
          green: particle.color.g.toDouble(),
          blue: particle.color.b.toDouble(),
          alpha: opacity,
        )
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(center.dx + position.dx, center.dy + position.dy);
      canvas.rotate(particle.rotation);

      switch (particle.shape) {
        case ParticleShape.circle:
          canvas.drawCircle(
            Offset.zero,
            particle.size * (1 - progress * 0.5),
            paint,
          );
          break;
        case ParticleShape.square:
          canvas.drawRect(
            Rect.fromCircle(
              center: Offset.zero,
              radius: particle.size * (1 - progress * 0.5) * 0.8,
            ),
            paint,
          );
          break;
        case ParticleShape.triangle:
          final path = Path();
          final radius = particle.size * (1 - progress * 0.5);
          const startAngle = -math.pi / 2;
          for (var i = 0; i < 3; i++) {
            final angle = startAngle + i * (2 * math.pi / 3);
            final point = Offset(
              math.cos(angle) * radius,
              math.sin(angle) * radius,
            );
            if (i == 0) {
              path.moveTo(point.dx, point.dy);
            } else {
              path.lineTo(point.dx, point.dy);
            }
          }
          path.close();
          canvas.drawPath(path, paint);
          break;
        case ParticleShape.star:
          final path = Path();
          final outerRadius = particle.size * (1 - progress * 0.5);
          final innerRadius = outerRadius * 0.4;
          const startAngle = -math.pi / 2;
          for (var i = 0; i < 10; i++) {
            final angle = startAngle + i * math.pi / 5;
            final radius = i.isEven ? outerRadius : innerRadius;
            final point = Offset(
              math.cos(angle) * radius,
              math.sin(angle) * radius,
            );
            if (i == 0) {
              path.moveTo(point.dx, point.dy);
            } else {
              path.lineTo(point.dx, point.dy);
            }
          }
          path.close();
          canvas.drawPath(path, paint);
          break;
      }
      canvas.restore();

      // Add glow effect for special merges
      if (isSpecialMerge) {
        final glowPaint = Paint()
          ..color = particle.color.withValues(
            red: particle.color.r.toDouble(),
            green: particle.color.g.toDouble(),
            blue: particle.color.b.toDouble(),
            alpha: opacity * 0.3,
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(
          center + position,
          particle.size * 1.5 * (1 - progress * 0.5),
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) =>
      progress != oldDelegate.progress;
}
