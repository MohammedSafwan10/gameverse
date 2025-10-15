import 'package:flutter/material.dart';

class WhackAMoleTheme {
  // Colors
  static const primaryColor = Color(0xFFFFB300); // Amber
  static const secondaryColor = Color(0xFF4CAF50); // Green
  static const backgroundColor = Color(0xFF2E7D32); // Dark Green
  static const accentColor = Color(0xFFFF6F00); // Orange

  // Gradients
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF81C784), // Light Green
      Color(0xFF2E7D32), // Dark Green
    ],
  );

  static const moleHoleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF5D4037), // Brown
      Color(0xFF3E2723), // Dark Brown
    ],
  );

  // Text Styles
  static const titleStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        color: Colors.black26,
        offset: Offset(2, 2),
        blurRadius: 4,
      ),
    ],
  );

  static const scoreStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const comboStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: primaryColor,
    shadows: [
      Shadow(
        color: Colors.black26,
        offset: Offset(2, 2),
        blurRadius: 4,
      ),
    ],
  );

  // Button Styles
  static final buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: 40,
      vertical: 15,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    elevation: 5,
    shadowColor: Colors.black38,
  );

  // Animation Durations
  static const molePopDuration = Duration(milliseconds: 200);
  static const scorePopDuration = Duration(milliseconds: 300);
  static const comboFadeDuration = Duration(milliseconds: 400);

  // Game UI Constants
  static const moleHoleRadius = 20.0;
  static const moleEyeSize = 12.0;
  static const moleNoseSize = 24.0;
  static const gridSpacing = 15.0;

  // Score Animation Colors
  static const normalScoreColor = Colors.white;
  static const goldenScoreColor = Color(0xFFFFD700);
  static const bombScoreColor = Color(0xFFFF5252);

  // Particle Effects Colors
  static const List<Color> hitParticleColors = [
    Color(0xFFFFEB3B),
    Color(0xFFFFC107),
    Color(0xFFFF9800),
    Color(0xFFFFFFFF),
  ];
}
