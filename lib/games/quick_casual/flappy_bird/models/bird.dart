import 'package:flutter/material.dart';
import '../models/pipe.dart';

class Bird {
  Offset position;
  final Size size;
  double velocity = 0;
  double rotation = 0;
  double flapAnimationValue = 0.0; // 0.0 to 1.0 for flap animation
  int flapDirection = -1; // -1 for up, 1 for down
  static const double maxVelocity = 520; // Cap maximum velocity
  static const double minVelocity = -340; // Cap minimum velocity
  static const double rotationFactor =
      0.0015; // How much rotation to apply based on velocity

  Bird({
    required this.position,
    required this.size,
  });

  void update(double gravity, double deltaSeconds) {
    // Apply gravity with velocity clamping
    velocity =
        (velocity + gravity * deltaSeconds).clamp(minVelocity, maxVelocity);

    // Integrate against real elapsed time so 60/90/120 Hz devices behave the
    // same and a slow frame cannot change the flight arc.
    position = Offset(position.dx, position.dy + velocity * deltaSeconds);

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
    // The sprite deliberately overhangs this logical box. Keep a fair hitbox,
    // but not the previous near-point-sized box that let visible pipe hits pass.
    return Rect.fromLTWH(
      position.dx + size.width * .14,
      position.dy + size.height * .2,
      size.width * .7,
      size.height * .6,
    );
  }

  bool collidesWith(Pipe pipe) {
    // Test the round visible body as an ellipse against the pipe. A rectangle
    // falsely reports its transparent corners and makes near misses feel wrong.
    final body = hitbox;
    final obstacle = pipe.rect.deflate(3);
    final center = body.center;
    final nearestX = center.dx.clamp(obstacle.left, obstacle.right);
    final nearestY = center.dy.clamp(obstacle.top, obstacle.bottom);
    final normalizedX = (center.dx - nearestX) / (body.width / 2);
    final normalizedY = (center.dy - nearestY) / (body.height / 2);
    return normalizedX * normalizedX + normalizedY * normalizedY <= 1;
  }
}
