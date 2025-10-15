import 'package:flutter/material.dart';
import '../models/game_types.dart';
import 'dart:math';

class MoleHole extends StatefulWidget {
  final MoleType? moleType;
  final bool isActive;
  final double progress;
  final VoidCallback onTap;
  final VoidCallback onMiss;

  const MoleHole({
    super.key,
    required this.moleType,
    required this.isActive,
    required this.progress,
    required this.onTap,
    required this.onMiss,
  });

  @override
  State<MoleHole> createState() => _MoleHoleState();
}

class _MoleHoleState extends State<MoleHole>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isActive) {
      _controller.forward().then((_) => _controller.reverse());
      widget.onTap();
    } else {
      widget.onMiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _handleTap(),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.brown.shade800,
            borderRadius: BorderRadius.circular(75),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  red: Colors.black.r.toDouble(),
                  green: Colors.black.g.toDouble(),
                  blue: Colors.black.b.toDouble(),
                  alpha: 0.3,
                ),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Hole
              _buildHole(),
              // Mole
              if (widget.isActive) _buildMole(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHole() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(75),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.brown.shade900,
            Colors.brown.shade800,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              red: Colors.black.r.toDouble(),
              green: Colors.black.g.toDouble(),
              blue: Colors.black.b.toDouble(),
              alpha: 0.3,
            ),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(
              red: Colors.black.r.toDouble(),
              green: Colors.black.g.toDouble(),
              blue: Colors.black.b.toDouble(),
              alpha: 0.2,
            ),
            blurRadius: 5,
            spreadRadius: -1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: HolePainter(),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildMole() {
    final moleColor = switch (widget.moleType!) {
      MoleType.golden => Colors.amber.shade700,
      MoleType.bomb => Colors.red.shade700,
      MoleType.normal => Colors.brown.shade600,
    };

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = widget.progress;
          final verticalOffset = (1 - _getMoleOffset(progress)) * 200;

          return Transform.translate(
            offset: Offset(0, verticalOffset),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Hands (appear first)
                if (progress > 0.1 && progress < 0.9)
                  Positioned(
                    top: -20,
                    left: 0,
                    right: 0,
                    child: _buildMoleHands(moleColor),
                  ),
                // Body
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: CustomPaint(
                      painter: MolePainter(
                        color: moleColor,
                        progress: progress,
                        type: widget.moleType!,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoleHands(Color color) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.rotate(
            angle: -0.4,
            child: _buildHand(color, true),
          ),
          Transform.rotate(
            angle: 0.4,
            child: _buildHand(color, false),
          ),
        ],
      ),
    );
  }

  Widget _buildHand(Color color, bool isLeft) {
    return Container(
      width: 30,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              red: Colors.black.r.toDouble(),
              green: Colors.black.g.toDouble(),
              blue: Colors.black.b.toDouble(),
              alpha: 0.3,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: MoleHandDetailsPainter(isLeft: isLeft),
      ),
    );
  }

  double _getMoleOffset(double progress) {
    // More realistic movement curve
    if (progress < 0.3) {
      // Coming up slowly from inside the hole
      return Curves.easeInOut.transform(progress * 3.33);
    } else if (progress > 0.7) {
      // Going down smoothly
      return 1.0 - Curves.easeIn.transform((progress - 0.7) * 3.33);
    }
    // Stay up
    return 1.0;
  }
}

class HolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw dirt texture
    final dirtPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF3E2723),
          const Color(0xFF3E2723).withValues(
            red: Colors.black.r.toDouble(),
            green: Colors.black.g.toDouble(),
            blue: Colors.black.b.toDouble(),
            alpha: 0.5,
          ),
        ],
        stops: const [0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, dirtPaint);

    // Draw hole shadow
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(
            red: Colors.black.r.toDouble(),
            green: Colors.black.g.toDouble(),
            blue: Colors.black.b.toDouble(),
            alpha: 0.4,
          ),
          Colors.black.withValues(
            red: Colors.black.r.toDouble(),
            green: Colors.black.g.toDouble(),
            blue: Colors.black.b.toDouble(),
            alpha: 0.0,
          ),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius * 0.8, shadowPaint);
  }

  @override
  bool shouldRepaint(HolePainter oldDelegate) => false;
}

class MolePainter extends CustomPainter {
  final Color color;
  final double progress;
  final MoleType type;

  MolePainter({
    required this.color,
    required this.progress,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Body
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color,
          color.darken(0.2),
        ],
        stops: const [0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, bodyPaint);

    // Eyes
    final eyeOffset = radius * 0.3;
    final eyeRadius = radius * 0.15;
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;

    // Left eye
    canvas.drawCircle(
      center + Offset(-eyeOffset, -eyeOffset * 0.5),
      eyeRadius,
      eyePaint,
    );
    canvas.drawCircle(
      center + Offset(-eyeOffset, -eyeOffset * 0.5),
      eyeRadius * 0.5,
      pupilPaint,
    );

    // Right eye
    canvas.drawCircle(
      center + Offset(eyeOffset, -eyeOffset * 0.5),
      eyeRadius,
      eyePaint,
    );
    canvas.drawCircle(
      center + Offset(eyeOffset, -eyeOffset * 0.5),
      eyeRadius * 0.5,
      pupilPaint,
    );

    // Nose
    final nosePaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      center + Offset(0, eyeOffset * 0.3),
      eyeRadius * 0.8,
      nosePaint,
    );

    // Special effects based on type
    if (type == MoleType.golden) {
      _drawGoldenEffect(canvas, center, radius);
    } else if (type == MoleType.bomb) {
      _drawBombEffect(canvas, center, radius);
    }
  }

  void _drawGoldenEffect(Canvas canvas, Offset center, double radius) {
    final sparkleRadius = radius * 0.15;
    final sparkleOffset = radius * 1.2;
    final sparklePaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < 8; i++) {
      final angle = i * 3.14159 / 4;
      final offset = Offset(
        cos(angle) * sparkleOffset,
        sin(angle) * sparkleOffset,
      );
      canvas.drawCircle(center + offset, sparkleRadius, sparklePaint);
    }
  }

  void _drawBombEffect(Canvas canvas, Offset center, double radius) {
    final fusePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final fusePath = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(
        center.dx + radius * 0.5,
        center.dy - radius * 1.5,
        center.dx + radius * 0.8,
        center.dy - radius * 1.2,
      );

    canvas.drawPath(fusePath, fusePaint);

    // Spark
    final sparkPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        center.dx + radius * 0.8,
        center.dy - radius * 1.2,
      ),
      radius * 0.1,
      sparkPaint,
    );
  }

  @override
  bool shouldRepaint(MolePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.type != type;
  }
}

class MoleHandDetailsPainter extends CustomPainter {
  final bool isLeft;

  MoleHandDetailsPainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw finger details
    final fingerPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw three curved lines for fingers
    for (var i = 0; i < 3; i++) {
      final path = Path();
      final startY = size.height * (0.3 + i * 0.2);
      final controlY = startY - size.height * 0.1;

      if (isLeft) {
        path.moveTo(size.width * 0.3, startY);
        path.quadraticBezierTo(
          size.width * 0.6,
          controlY,
          size.width * 0.8,
          startY,
        );
      } else {
        path.moveTo(size.width * 0.7, startY);
        path.quadraticBezierTo(
          size.width * 0.4,
          controlY,
          size.width * 0.2,
          startY,
        );
      }

      canvas.drawPath(path, fingerPaint);
    }
  }

  @override
  bool shouldRepaint(MoleHandDetailsPainter oldDelegate) => false;
}

extension ColorExtension on Color {
  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness * (1 - amount)).clamp(0.0, 1.0))
        .toColor();
  }
}
