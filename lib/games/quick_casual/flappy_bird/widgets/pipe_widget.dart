import 'package:flutter/material.dart';
import '../models/pipe.dart';

class PipeWidget extends StatelessWidget {
  final Pipe pipe;
  final bool isCyber;
  final Color cyberColor;
  final Color classicColor;

  const PipeWidget({
    super.key,
    required this.pipe,
    this.isCyber = true,
    this.cyberColor = const Color(0xFF00E5FF), // Cyber Cyan
    this.classicColor = const Color(0xFF4CAF50), // Classic Green
  });

  @override
  Widget build(BuildContext context) {
    if (isCyber) {
      return _buildCyberPipe();
    } else {
      return _buildClassicPipe();
    }
  }

  Widget _buildCyberPipe() {
    return Transform.translate(
      offset: pipe.position,
      child: Container(
        width: pipe.width,
        height: pipe.height,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E21).withValues(alpha: 0.8), // Dark core
          border: Border(
            left: BorderSide(color: cyberColor, width: 2),
            right: BorderSide(color: cyberColor, width: 2),
            top: pipe.isTop
                ? BorderSide.none
                : BorderSide(color: cyberColor, width: 3),
            bottom: pipe.isTop
                ? BorderSide(color: cyberColor, width: 3)
                : BorderSide.none,
          ),
          boxShadow: [
            BoxShadow(
              color: cyberColor.withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Inner glowing core
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      cyberColor.withValues(alpha: 0.2),
                      Colors.transparent,
                      cyberColor.withValues(alpha: 0.2),
                    ],
                  ),
                ),
              ),
            ),
            // Neon vertical stripes
            Positioned(
              left: pipe.width * 0.2,
              top: 0,
              bottom: 0,
              width: 1,
              child: Container(color: cyberColor.withValues(alpha: 0.5)),
            ),
            Positioned(
              right: pipe.width * 0.2,
              top: 0,
              bottom: 0,
              width: 1,
              child: Container(color: cyberColor.withValues(alpha: 0.5)),
            ),
            // Pipe End Cap (Neon rim)
            if (pipe.isTop)
              Positioned(
                left: -4,
                right: -4,
                bottom: -2,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0E21),
                    border: Border.all(color: cyberColor, width: 2),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: cyberColor.withValues(alpha: 0.6),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      height: 4,
                      width: pipe.width * 0.6,
                      decoration: BoxDecoration(
                        color: cyberColor.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(color: cyberColor, blurRadius: 6),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Positioned(
                left: -4,
                right: -4,
                top: -2,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0E21),
                    border: Border.all(color: cyberColor, width: 2),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: cyberColor.withValues(alpha: 0.6),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      height: 4,
                      width: pipe.width * 0.6,
                      decoration: BoxDecoration(
                        color: cyberColor.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(color: cyberColor, blurRadius: 6),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassicPipe() {
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
              classicColor.darken(0.2),
              classicColor,
              classicColor.brighten(0.1),
              classicColor,
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
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
                  color: Colors.white.withValues(alpha: 0.1),
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
                    color: classicColor.darken(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
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
                    color: classicColor.darken(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
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
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color brighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
