import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class MemoryMatchTheme {
  static const cobalt = Color(0xFF1455D9);
  static const cobaltDark = Color(0xFF0B3EAD);
  static const orange = Color(0xFFFF5A16);
  static const orangeDark = Color(0xFFE74608);
  static const cream = Color(0xFFFFF8E9);
  static const paper = Color(0xFFFFFCF4);
  static const ink = Color(0xFF172033);
  static const muted = Color(0xFF657084);
  static const mint = Color(0xFF56D7B0);
  static const mintPale = Color(0xFFDDF8EE);
  static const pink = Color(0xFFF45B83);
  static const pinkPale = Color(0xFFFFE1E9);
  static const yellow = Color(0xFFFFD052);

  static TextStyle display({
    double size = 28,
    Color color = ink,
    FontWeight weight = FontWeight.w900,
    double height = 0.98,
  }) =>
      GoogleFonts.outfit(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: -0.8,
        color: color,
      );

  static TextStyle body({
    double size = 14,
    Color color = ink,
    FontWeight weight = FontWeight.w500,
    double height = 1.25,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color,
      );

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF082762).withValues(alpha: 0.16),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}

class MemoryMatchBackdrop extends StatelessWidget {
  const MemoryMatchBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MemoryMatchTheme.cobalt,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            right: -80,
            top: -70,
            child: _Glow(size: 240, color: MemoryMatchTheme.mint),
          ),
          const Positioned(
            left: -110,
            bottom: -80,
            child: _Glow(size: 280, color: MemoryMatchTheme.orange),
          ),
          CustomPaint(painter: _PatternPainter()),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.14),
        ),
      );
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const step = 54.0;
    for (double y = 24; y < size.height; y += step) {
      for (double x = (y ~/ step).isEven ? 20 : 46;
          x < size.width;
          x += step * 2) {
        canvas.drawCircle(Offset(x, y), 3.5, paint);
        canvas.drawLine(Offset(x + 10, y - 5), Offset(x + 18, y + 3), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MemoryMatchIconButton extends StatelessWidget {
  const MemoryMatchIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => Material(
        color: MemoryMatchTheme.paper,
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: Colors.black26,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, color: MemoryMatchTheme.ink, size: 21),
          constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        ),
      );
}

class MemoryMatchPrimaryButton extends StatelessWidget {
  const MemoryMatchPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          iconAlignment: IconAlignment.end,
          icon: Icon(icon, size: 21),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            elevation: 5,
            shadowColor: MemoryMatchTheme.orange.withValues(alpha: 0.36),
            backgroundColor: MemoryMatchTheme.orange,
            foregroundColor: Colors.white,
            textStyle: MemoryMatchTheme.body(
              size: 15,
              color: Colors.white,
              weight: FontWeight.w800,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      );
}
