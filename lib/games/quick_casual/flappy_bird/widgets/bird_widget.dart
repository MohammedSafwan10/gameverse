import 'package:flutter/material.dart';
import '../models/bird.dart';

class BirdWidget extends StatelessWidget {
  final Bird bird;
  final Color color;

  const BirdWidget({
    super.key,
    required this.bird,
    this.color = const Color(0xFFFFEB3B), // More vibrant yellow
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: bird.position,
      child: Transform.rotate(
        angle: bird.rotation,
        child: SizedBox(
          width: bird.size.width,
          height: bird.size.height,
          child: CustomPaint(
            painter: _FlappyBirdPainter(
                color: color, flapValue: bird.flapAnimationValue),
            size: bird.size,
          ),
        ),
      ),
    );
  }
}

class _FlappyBirdPainter extends CustomPainter {
  final Color color;
  final double flapValue;

  _FlappyBirdPainter({
    required this.color,
    this.flapValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Main body
    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw round body
    final bodyPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(size.width * 0.4, size.height * 0.5),
        width: size.width * 0.8,
        height: size.height * 0.8,
      ));
    canvas.drawPath(bodyPath, bodyPaint);

    // Eye
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final eyeCenter = Offset(size.width * 0.65, size.height * 0.35);
    final eyeRadius = size.width * 0.15;

    canvas.drawCircle(eyeCenter, eyeRadius, eyePaint);

    // Pupil
    final pupilPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(eyeCenter.dx + 2, eyeCenter.dy - 2),
      eyeRadius * 0.6,
      pupilPaint,
    );

    // Beak
    final beakPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    final beakPath = Path()
      ..moveTo(size.width * 0.75, size.height * 0.48)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width * 0.75, size.height * 0.58)
      ..close();

    canvas.drawPath(beakPath, beakPaint);

    // Wing - with flap animation
    final wingPaint = Paint()
      ..color = color.darken()
      ..style = PaintingStyle.fill;

    // Apply wing position based on flap animation
    final wingOffset =
        flapValue * size.height * 0.1; // Move wing up when flapping

    final wingPath = Path()
      ..moveTo(size.width * 0.3,
          size.height * (0.4 - flapValue * 0.1)) // Move up based on flap
      ..quadraticBezierTo(
        size.width *
            (0.15 - flapValue * 0.05), // Wing moves out a bit when flapping
        size.height * (0.6 - wingOffset),
        size.width * 0.3,
        size.height * (0.7 - wingOffset),
      )
      ..lineTo(size.width * 0.4, size.height * (0.6 - wingOffset))
      ..close();

    canvas.drawPath(wingPath, wingPaint);

    // White belly/chest
    final bellyPaint = Paint()
      ..color = Colors.white.withValues(
        red: Colors.white.r.toDouble(),
        green: Colors.white.g.toDouble(),
        blue: Colors.white.b.toDouble(),
        alpha: 0.9,
      )
      ..style = PaintingStyle.fill;

    final bellyPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.65),
        width: size.width * 0.5,
        height: size.height * 0.5,
      ));

    canvas.drawPath(bellyPath, bellyPaint);

    // Add shadow for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 0.1,
      )
      ..style = PaintingStyle.fill;

    final shadowPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(size.width * 0.4, size.height * 0.5),
        width: size.width * 0.8,
        height: size.height * 0.1,
      ));

    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(_FlappyBirdPainter oldDelegate) =>
      oldDelegate.flapValue != flapValue;
}

extension on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
