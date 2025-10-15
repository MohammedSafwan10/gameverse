import 'package:flutter/material.dart';
import '../models/pipe.dart';

class PipeWidget extends StatelessWidget {
  final Pipe pipe;
  final Color color;

  const PipeWidget({
    super.key,
    required this.pipe,
    this.color = const Color(0xFF43A047),
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: pipe.position,
      child: Container(
        width: pipe.width,
        height: pipe.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color.darken(0.2),
              color,
              color.brighten(0.1),
              color,
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                red: Colors.black.r.toDouble(),
                green: Colors.black.g.toDouble(),
                blue: Colors.black.b.toDouble(),
                alpha: 0.3,
              ),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Pipe body highlights
            Positioned(
              left: pipe.width * 0.1,
              top: 0,
              bottom: 0,
              width: pipe.width * 0.05,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    red: Colors.white.r.toDouble(),
                    green: Colors.white.g.toDouble(),
                    blue: Colors.white.b.toDouble(),
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Pipe end cap
            if (pipe.isTop)
              Positioned(
                left: -5,
                right: -5,
                bottom: 0,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: color.darken(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          red: Colors.black.r.toDouble(),
                          green: Colors.black.g.toDouble(),
                          blue: Colors.black.b.toDouble(),
                          alpha: 0.2,
                        ),
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              )
            else
              Positioned(
                left: -5,
                right: -5,
                top: 0,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: color.darken(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          red: Colors.black.r.toDouble(),
                          green: Colors.black.g.toDouble(),
                          blue: Colors.black.b.toDouble(),
                          alpha: 0.2,
                        ),
                        blurRadius: 2,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

extension on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  Color brighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
} 