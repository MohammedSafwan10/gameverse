import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_types.dart';

class HitEffect extends StatefulWidget {
  final MoleType? moleType;
  final bool isActive;
  final VoidCallback onComplete;

  const HitEffect({
    super.key,
    required this.moleType,
    required this.isActive,
    required this.onComplete,
  });

  @override
  State<HitEffect> createState() => _HitEffectState();
}

class _HitEffectState extends State<HitEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  late List<Star> _stars;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _particles = List.generate(30, (index) => _createParticle());
    _stars = List.generate(8, (index) => _createStar());

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Particle _createParticle() {
    final angle = _random.nextDouble() * 2 * pi;
    final speed = _random.nextDouble() * 200 + 100;
    final size = _random.nextDouble() * 8 + 4;
    final rotationSpeed = _random.nextDouble() * 10 - 5;
    final initialRotation = _random.nextDouble() * 2 * pi;

    Color color;
    if (widget.isActive && widget.moleType != null) {
      color = switch (widget.moleType!) {
        MoleType.golden => Colors.amber.withValues(
            red: Colors.amber.r.toDouble(),
            green: Colors.amber.g.toDouble(),
            blue: Colors.amber.b.toDouble(),
            alpha: 0.8,
          ),
        MoleType.bomb => Colors.red.shade400.withValues(
            red: Colors.red.shade400.r.toDouble(),
            green: Colors.red.shade400.g.toDouble(),
            blue: Colors.red.shade400.b.toDouble(),
            alpha: 0.8,
          ),
        MoleType.normal => Colors.brown.shade300.withValues(
            red: Colors.brown.shade300.r.toDouble(),
            green: Colors.brown.shade300.g.toDouble(),
            blue: Colors.brown.shade300.b.toDouble(),
            alpha: 0.8,
          ),
      };
    } else {
      color = Colors.grey.withValues(
        red: Colors.grey.r.toDouble(),
        green: Colors.grey.g.toDouble(),
        blue: Colors.grey.b.toDouble(),
        alpha: 0.8,
      );
    }

    return Particle(
      angle: angle,
      speed: speed,
      size: size,
      color: color,
      rotationSpeed: rotationSpeed,
      initialRotation: initialRotation,
    );
  }

  Star _createStar() {
    final angle = _random.nextDouble() * 2 * pi;
    final distance = _random.nextDouble() * 100 + 50;
    final size = _random.nextDouble() * 15 + 10;
    final rotationSpeed = _random.nextDouble() * 8 - 4;

    Color color;
    if (widget.isActive && widget.moleType != null) {
      color = switch (widget.moleType!) {
        MoleType.golden => Colors.yellow.shade300,
        MoleType.bomb => Colors.orange.shade300,
        MoleType.normal => Colors.white.withValues(
            red: Colors.white.r.toDouble(),
            green: Colors.white.g.toDouble(),
            blue: Colors.white.b.toDouble(),
            alpha: 0.8,
          ),
      };
    } else {
      color = Colors.white.withValues(
        red: Colors.white.r.toDouble(),
        green: Colors.white.g.toDouble(),
        blue: Colors.white.b.toDouble(),
        alpha: 0.6,
      );
    }

    return Star(
      angle: angle,
      distance: distance,
      size: size,
      color: color,
      rotationSpeed: rotationSpeed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Particles
            CustomPaint(
              painter: ParticlePainter(
                particles: _particles,
                progress: _controller.value,
              ),
            ),
            // Stars
            CustomPaint(
              painter: StarPainter(
                stars: _stars,
                progress: _controller.value,
              ),
            ),
            // Impact ripple
            CustomPaint(
              painter: RipplePainter(
                progress: _controller.value,
                color: widget.moleType == MoleType.golden
                    ? Colors.amber
                    : (widget.moleType == MoleType.bomb
                        ? Colors.red
                        : Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double rotationSpeed;
  final double initialRotation;

  Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotationSpeed,
    required this.initialRotation,
  });

  Offset getPosition(double progress) {
    final distance = speed * progress;
    final gravity = 500.0 * progress * progress;
    final dx = cos(angle) * distance;
    final dy = sin(angle) * distance + gravity;

    // Ensure we don't return NaN values
    if (dx.isNaN || dy.isNaN) return Offset.zero;
    return Offset(dx, dy);
  }

  double getRotation(double progress) {
    final rotation = initialRotation + rotationSpeed * progress * 2 * pi;
    if (rotation.isNaN) return 0.0;
    return rotation;
  }
}

class Star {
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final double rotationSpeed;

  Star({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.rotationSpeed,
  });

  Offset getPosition(double progress) {
    final currentDistance = distance * (1 - (1 - progress) * (1 - progress));
    final dx = cos(angle) * currentDistance;
    final dy = sin(angle) * currentDistance;
    return Offset(dx, dy);
  }

  double getRotation(double progress) {
    return rotationSpeed * progress * 2 * pi;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    if (center.dx.isNaN || center.dy.isNaN) return;

    for (final particle in particles) {
      final position = particle.getPosition(progress);
      if (position.dx.isNaN || position.dy.isNaN) continue;

      final rotation = particle.getRotation(progress);
      if (rotation.isNaN) continue;

      final paint = Paint()
        ..color = particle.color.withValues(
          red: particle.color.r.toDouble(),
          green: particle.color.g.toDouble(),
          blue: particle.color.b.toDouble(),
          alpha: (1 - progress).clamp(0.0, 1.0),
        )
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(
          (center.dx + position.dx).clamp(-size.width, size.width * 2),
          (center.dy + position.dy).clamp(-size.height, size.height * 2));
      canvas.rotate(rotation);

      // Draw a more interesting particle shape
      final path = Path();
      if (particle.size > 6) {
        // Star shape for larger particles
        for (var i = 0; i < 5; i++) {
          final angle = i * 2 * pi / 5;
          final point =
              Offset(cos(angle) * particle.size, sin(angle) * particle.size);
          if (i == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
          final innerAngle = angle + pi / 5;
          final innerPoint = Offset(cos(innerAngle) * particle.size * 0.4,
              sin(innerAngle) * particle.size * 0.4);
          path.lineTo(innerPoint.dx, innerPoint.dy);
        }
      } else {
        // Circle shape for smaller particles
        path.addOval(Rect.fromCircle(
          center: Offset.zero,
          radius: particle.size / 2,
        ));
      }
      path.close();

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double progress;

  StarPainter({
    required this.stars,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final star in stars) {
      final paint = Paint()
        ..color = star.color.withValues(
          red: star.color.r.toDouble(),
          green: star.color.g.toDouble(),
          blue: star.color.b.toDouble(),
          alpha: (1 - progress) * 0.8,
        )
        ..style = PaintingStyle.fill;

      final position = star.getPosition(progress);
      final rotation = star.getRotation(progress);

      canvas.save();
      canvas.translate(center.dx + position.dx, center.dy + position.dy);
      canvas.rotate(rotation);

      // Draw a star shape
      final path = Path();
      const points = 5;
      final outerRadius = star.size;
      final innerRadius = star.size * 0.4;

      for (var i = 0; i < points * 2; i++) {
        final radius = i.isEven ? outerRadius : innerRadius;
        final angle = i * pi / points;
        final x = cos(angle) * radius;
        final y = sin(angle) * radius;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  RipplePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final ripplePaint = Paint()
      ..color = color.withValues(
        red: color.r.toDouble(),
        green: color.g.toDouble(),
        blue: color.b.toDouble(),
        alpha: (1 - progress) * 0.3,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 * (1 - progress);

    canvas.drawCircle(
      center,
      maxRadius * progress,
      ripplePaint,
    );

    // Second ripple with different timing
    final secondProgress = (progress * 1.5).clamp(0.0, 1.0);
    final secondPaint = Paint()
      ..color = color.withValues(
        red: color.r.toDouble(),
        green: color.g.toDouble(),
        blue: color.b.toDouble(),
        alpha: (1 - secondProgress) * 0.2,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 * (1 - secondProgress);

    canvas.drawCircle(
      center,
      maxRadius * secondProgress * 0.8,
      secondPaint,
    );
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
