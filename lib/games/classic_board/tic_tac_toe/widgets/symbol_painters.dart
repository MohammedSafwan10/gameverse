import 'package:flutter/material.dart';

class XSymbolPainter extends CustomPainter {
  final Color color;
  final bool isWinning;

  XSymbolPainter({required this.color, required this.isWinning});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color,
          color.withValues(alpha: 0.9),
          color.withValues(alpha: 0.6),
        ],
      ).createShader(rect)
      ..strokeWidth = size.width / 6.0 // Scale stroke width based on size
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (isWinning) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..strokeWidth = size.width / 4.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      _drawX(canvas, size, glowPaint);
    }

    _drawX(canvas, size, paint);
  }

  void _drawX(Canvas canvas, Size size, Paint paint) {
    // Relative padding
    final double paddingX = size.width * 0.22;
    final double paddingY = size.height * 0.22;
    
    canvas.drawLine(
      Offset(paddingX, paddingY),
      Offset(size.width - paddingX, size.height - paddingY),
      paint,
    );
    
    canvas.drawLine(
      Offset(size.width - paddingX, paddingY),
      Offset(paddingX, size.height - paddingY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant XSymbolPainter oldDelegate) => 
      oldDelegate.color != color || oldDelegate.isWinning != isWinning;
}

class OSymbolPainter extends CustomPainter {
  final Color color;
  final bool isWinning;

  OSymbolPainter({required this.color, required this.isWinning});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          color,
          color.withValues(alpha: 0.7),
          color.withValues(alpha: 0.9),
          color,
        ],
      ).createShader(rect)
      ..strokeWidth = size.width / 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (isWinning) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..strokeWidth = size.width / 4.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        (size.width / 2) - (size.width * 0.22),
        glowPaint,
      );
    }

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      (size.width / 2) - (size.width * 0.22),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant OSymbolPainter oldDelegate) => 
      oldDelegate.color != color || oldDelegate.isWinning != isWinning;
}
