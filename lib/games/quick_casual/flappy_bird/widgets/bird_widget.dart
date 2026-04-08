import 'package:flutter/material.dart';
import '../models/bird.dart';

class BirdWidget extends StatelessWidget {
  final Bird bird;
  final bool isCyber;
  final Color bodyColor;
  final Color glowColor;

  const BirdWidget({
    super.key,
    required this.bird,
    this.isCyber = true,
    this.bodyColor = const Color(0xFFFF007A), // Hot Pink
    this.glowColor = const Color(0xFF00E5FF), // Cyan glow
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
            painter: isCyber
                ? _CyberBirdPainter(
                    bodyColor: bodyColor,
                    glowColor: glowColor,
                    flapValue: bird.flapAnimationValue,
                  )
                : _ClassicBirdPainter(
                    color: const Color(0xFFFFEB3B), // Yellow classic
                    flapValue: bird.flapAnimationValue,
                  ),
            size: bird.size,
          ),
        ),
      ),
    );
  }
}

class _ClassicBirdPainter extends CustomPainter {
  final Color color;
  final double flapValue;

  _ClassicBirdPainter({
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

    // Very subtle displacement
    final wingOffset = flapValue * size.height * 0.03;

    final wingPath = Path()
      ..moveTo(size.width * 0.4, size.height * (0.5 - wingOffset))
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * (0.55 - wingOffset),
        size.width * 0.4,
        size.height * (0.6 - wingOffset),
      )
      ..lineTo(size.width * 0.5, size.height * (0.55 - wingOffset))
      ..close();

    canvas.drawPath(wingPath, wingPaint);

    // White belly/chest
    final bellyPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
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
      ..color = Colors.black.withValues(alpha: 0.1)
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
  bool shouldRepaint(_ClassicBirdPainter oldDelegate) =>
      oldDelegate.flapValue != flapValue;
}

class _CyberBirdPainter extends CustomPainter {
  final Color bodyColor;
  final Color glowColor;
  final double flapValue;

  _CyberBirdPainter({
    required this.bodyColor,
    required this.glowColor,
    this.flapValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Outer Glow
    final glowPaint = Paint()
      ..color = bodyColor.withValues(alpha: 0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12)
      ..style = PaintingStyle.fill;

    // Body Path
    final bodyPath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.8, size.height * 0.3)
      ..lineTo(size.width * 0.9, size.height * 0.5)
      ..lineTo(size.width * 0.8, size.height * 0.7)
      ..close();

    // Draw Glow
    canvas.drawPath(bodyPath, glowPaint);

    // Inner Core (Body)
    final corePaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, corePaint);

    // Thruster Wing (flapping part)
    final wingPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;

    // Reduce the wing displacement size drastically and position it nicely
    final wingOffset = flapValue * size.height * 0.03;

    final wingPath = Path()
      ..moveTo(size.width * 0.45, size.height * 0.5) // Closer to body center
      ..lineTo(size.width * 0.35, size.height * (0.55 - wingOffset))
      ..lineTo(size.width * 0.5, size.height * (0.5 - wingOffset));

    canvas.drawPath(wingPath, wingPaint);

    // Wing Glow
    final wingGlowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(wingPath, wingGlowPaint);

    // Cyber Eye
    final eyePaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.fill;

    final eyeCenter = Offset(size.width * 0.75, size.height * 0.45);
    canvas.drawCircle(eyeCenter, size.width * 0.08, eyePaint);

    final eyeGlow = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(eyeCenter, size.width * 0.04, eyeGlow);
  }

  @override
  bool shouldRepaint(_CyberBirdPainter oldDelegate) =>
      oldDelegate.flapValue != flapValue || oldDelegate.bodyColor != bodyColor;
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
