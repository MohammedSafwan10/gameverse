import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/bird.dart';

class BirdWidget extends StatelessWidget {
  const BirdWidget({
    super.key,
    required this.bird,
    required this.isCyber,
  });

  final Bird bird;
  final bool isCyber;

  static const _classicAsset =
      'assets/images/games/flappy_bird/game_classic_bird.png';
  static const _cyberAsset =
      'assets/images/games/flappy_bird/game_cyber_bird.png';

  @override
  Widget build(BuildContext context) {
    final visualWidth = bird.size.width * 1.75;
    final visualHeight = bird.size.height * 1.4;
    final flapLift = math.sin(bird.flapAnimationValue * math.pi) * 2.5;

    return Positioned(
      left: bird.position.dx - (visualWidth - bird.size.width) / 2,
      top: bird.position.dy - (visualHeight - bird.size.height) / 2 + flapLift,
      width: visualWidth,
      height: visualHeight,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: bird.rotation * .72,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isCyber)
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1FE7FF).withValues(alpha: .42),
                        blurRadius: 18,
                        spreadRadius: -3,
                      ),
                    ],
                  ),
                ),
              Image.asset(
                isCyber ? _cyberAsset : _classicAsset,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                cacheWidth: 320,
                gaplessPlayback: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
