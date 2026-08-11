import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gameverse/games/quick_casual/flappy_bird/models/bird.dart';
import 'package:gameverse/games/quick_casual/flappy_bird/models/pipe.dart';

void main() {
  Bird birdAt(Offset position) => Bird(
        position: position,
        size: const Size(40, 40),
      );

  test('flight integration remains nearly identical across frame rates', () {
    final sixtyHz = birdAt(const Offset(100, 300));
    final oneTwentyHz = birdAt(const Offset(100, 300));

    for (var i = 0; i < 60; i++) {
      sixtyHz.update(1200, 1 / 60);
    }
    for (var i = 0; i < 120; i++) {
      oneTwentyHz.update(1200, 1 / 120);
    }

    expect((sixtyHz.position.dy - oneTwentyHz.position.dy).abs(), lessThan(6));
    expect((sixtyHz.velocity - oneTwentyHz.velocity).abs(), lessThan(.01));
  });

  test('visible body contact with a pipe is detected', () {
    final bird = birdAt(const Offset(100, 100));
    final pipe = Pipe(
      position: const Offset(125, 0),
      size: const Size(60, 130),
      isTop: true,
    );

    expect(bird.collidesWith(pipe), isTrue);
  });

  test('bird inside the opening does not collide', () {
    final bird = birdAt(const Offset(100, 150));
    final topPipe = Pipe(
      position: const Offset(125, 0),
      size: const Size(60, 130),
      isTop: true,
    );
    final bottomPipe = Pipe(
      position: const Offset(125, 210),
      size: const Size(60, 300),
      isTop: false,
    );

    expect(bird.collidesWith(topPipe), isFalse);
    expect(bird.collidesWith(bottomPipe), isFalse);
  });
}
