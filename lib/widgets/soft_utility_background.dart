import 'package:flutter/material.dart';

class SoftUtilityBackground extends StatelessWidget {
  const SoftUtilityBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFFF8F6F2)),
        Positioned(
          top: -120,
          left: -80,
          child: _blob(
            const Size(280, 280),
            const Color(0xFFF4E8D1).withValues(alpha: 0.9),
          ),
        ),
        Positioned(
          top: 140,
          right: -90,
          child: _blob(
            const Size(260, 260),
            const Color(0xFFDCEAF0).withValues(alpha: 0.75),
          ),
        ),
        Positioned(
          bottom: -120,
          left: 40,
          child: _blob(
            const Size(300, 300),
            const Color(0xFFEFE7DD).withValues(alpha: 0.85),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.24),
                Colors.transparent,
                Colors.white.withValues(alpha: 0.18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _blob(Size size, Color color) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
