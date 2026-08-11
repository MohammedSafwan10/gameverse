import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/pipe.dart';

class PipeWidget extends StatelessWidget {
  const PipeWidget({
    super.key,
    required this.pipe,
    required this.isCyber,
  });

  final Pipe pipe;
  final bool isCyber;

  static const _classicAsset =
      'assets/images/games/flappy_bird/game_classic_pipe.png';
  static const _cyberAsset =
      'assets/images/games/flappy_bird/game_cyber_pipe.png';

  @override
  Widget build(BuildContext context) {
    final visualWidth = pipe.width * 1.28;
    final visualHeight = math.max(pipe.height, 34.0);

    return Positioned(
      left: pipe.position.dx - (visualWidth - pipe.width) / 2,
      top: pipe.isTop ? 0 : pipe.position.dy,
      width: visualWidth,
      height: visualHeight,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: pipe.isTop ? math.pi : 0,
          child: Image.asset(
            isCyber ? _cyberAsset : _classicAsset,
            fit: BoxFit.fill,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.low,
            cacheWidth: 180,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }
}
