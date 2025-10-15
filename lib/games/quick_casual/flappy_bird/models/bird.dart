import 'package:flutter/material.dart';
import '../models/pipe.dart';

class Bird {
  Offset position;
  final Size size;
  double velocity = 0;
  double rotation = 0;
  double flapAnimationValue = 0.0; // 0.0 to 1.0 for flap animation
  int flapDirection = -1; // -1 for up, 1 for down
  static const double maxVelocity = 600; // Cap maximum velocity
  static const double minVelocity = -450; // Cap minimum velocity
  static const double rotationFactor =
      0.0015; // How much rotation to apply based on velocity

  Bird({
    required this.position,
    required this.size,
  });

  void update(double gravity) {
    // Apply gravity with velocity clamping
    velocity = (velocity + gravity).clamp(minVelocity, maxVelocity);

    // Update position with smoother movement
    position = Offset(position.dx,
        position.dy + velocity * 0.016 // Assuming 60 FPS (1/60 ≈ 0.016)
        );

    // Update rotation based on velocity with softer movements
    final targetRotation = (velocity * rotationFactor).clamp(-0.8, 0.8);

    // Smooth rotation transition
    rotation = rotation + (targetRotation - rotation) * 0.2;

    // Animate flapping wings continuously when flying
    if (velocity < 0) {
      // Bird is moving upward, flap wings actively
      _animateFlapping();
    } else {
      // Bird is falling, decay flap animation
      if (flapAnimationValue > 0) {
        flapAnimationValue = flapAnimationValue - 0.08;
        if (flapAnimationValue < 0) flapAnimationValue = 0;
      }
    }
  }

  void _animateFlapping() {
    // Create a continuous flapping motion
    if (flapDirection < 0) {
      // Moving wings up
      flapAnimationValue += 0.15;
      if (flapAnimationValue >= 1.0) {
        flapAnimationValue = 1.0;
        flapDirection = 1; // Switch direction
      }
    } else {
      // Moving wings down
      flapAnimationValue -= 0.15;
      if (flapAnimationValue <= 0.3) {
        flapAnimationValue = 0.3;
        flapDirection = -1; // Switch direction
      }
    }
  }

  void flap() {
    // Set velocity and trigger flap animation
    velocity = minVelocity;
    flapAnimationValue = 0.5; // Start from middle position
    flapDirection = -1; // Start flapping upward
  }

  Rect get hitbox {
    // Create a smaller hitbox than the actual bird size for more forgiving collisions
    const shrinkFactor = 0.3;
    final shrinkAmount = size.width * shrinkFactor;

    return Rect.fromLTWH(
      position.dx + shrinkAmount,
      position.dy + shrinkAmount,
      size.width - (shrinkAmount * 2),
      size.height - (shrinkAmount * 2),
    );
  }

  bool collidesWith(Pipe pipe) {
    final birdHitbox = hitbox;
    final pipeHitbox = pipe.rect;

    // Add a small tolerance for more forgiving collisions
    const tolerance = 5.0; // Fixed tolerance in pixels

    final adjustedBirdHitbox = Rect.fromLTWH(
      birdHitbox.left + tolerance,
      birdHitbox.top + tolerance,
      birdHitbox.width - (tolerance * 2),
      birdHitbox.height - (tolerance * 2),
    );

    return adjustedBirdHitbox.overlaps(pipeHitbox);
  }
}
