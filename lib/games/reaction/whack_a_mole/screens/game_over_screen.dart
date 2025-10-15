import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

class WhackAMoleGameOverScreen extends StatelessWidget {
  final int score;
  final int highScore;
  final int combo;

  const WhackAMoleGameOverScreen({
    super.key,
    required this.score,
    required this.highScore,
    required this.combo,
  });

  void _playAgain() {
    final gameController = Get.find<WhackAMoleGameController>();

    // Reset the game state
    gameController.resetGame();

    // Start the game immediately instead of navigating
    gameController.startGame();

    // Pop the game over screen to return to game screen
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isNewHighScore = score >= highScore;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF0D47A1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game Over Text with Animation
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: const Text(
                    'Game Over!',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black38,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Score Display
                _buildScoreCard(
                  'Score',
                  score,
                  isHighScore: isNewHighScore,
                  delay: 200,
                ),
                const SizedBox(height: 20),
                _buildScoreCard(
                  'High Score',
                  highScore,
                  delay: 400,
                ),
                const SizedBox(height: 20),
                _buildScoreCard(
                  'Best Combo',
                  combo,
                  delay: 600,
                ),
                const SizedBox(height: 40),

                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      _buildButton(
                        'Play Again',
                        Icons.replay,
                        Colors.green,
                        _playAgain,
                        delay: 800,
                      ),
                      const SizedBox(height: 16),
                      _buildButton(
                        'Back to Menu',
                        Icons.home,
                        Colors.blue,
                        () => Get.back(),
                        delay: 1000,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(String label, int value,
      {bool isHighScore = false, required int delay}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: isHighScore ? Colors.amber : Colors.white24,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isHighScore
                  ? Colors.amber.withValues(
                      red: Colors.amber.r.toDouble(),
                      green: Colors.amber.g.toDouble(),
                      blue: Colors.amber.b.toDouble(),
                      alpha: 0.3,
                    )
                  : Colors.black.withValues(
                      red: Colors.black.r.toDouble(),
                      green: Colors.black.g.toDouble(),
                      blue: Colors.black.b.toDouble(),
                      alpha: 0.2,
                    ),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isHighScore ? Colors.black87 : Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isHighScore ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(
            label,
            style: const TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }
}
