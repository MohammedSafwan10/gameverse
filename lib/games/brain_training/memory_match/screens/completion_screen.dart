import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../models/game_mode.dart';
import '../models/game_state.dart';

class GameCompletionScreen extends StatefulWidget {
  final MemoryMatchMode mode;
  final GameDifficulty difficulty;
  final int score;
  final int moves;
  final int timeElapsed;

  const GameCompletionScreen({
    super.key,
    required this.mode,
    required this.difficulty,
    required this.score,
    required this.moves,
    required this.timeElapsed,
  });

  @override
  State<GameCompletionScreen> createState() => _GameCompletionScreenState();
}

class _GameCompletionScreenState extends State<GameCompletionScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5))..play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic result) {
        if (!didPop) {
          // Do nothing, prevent back navigation
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.mode.color.withValues(
                  red: widget.mode.color.r.toDouble(),
                  green: widget.mode.color.g.toDouble(),
                  blue: widget.mode.color.b.toDouble(),
                  alpha: 0.3,
                ),
                Colors.white,
              ],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTrophy(),
                    const SizedBox(height: 24),
                    _buildCongratulations(),
                    const SizedBox(height: 32),
                    _buildStats(),
                    const SizedBox(height: 48),
                    _buildButtons(),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2,
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.1,
                  colors: [
                    widget.mode.color,
                    Colors.purple,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.yellow,
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 4,
                  maxBlastForce: 4,
                  minBlastForce: 2,
                  emissionFrequency: 0.03,
                  numberOfParticles: 30,
                  gravity: 0.1,
                  colors: [
                    widget.mode.color,
                    Colors.green,
                    Colors.blue,
                    Colors.red,
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 3 * pi / 4,
                  maxBlastForce: 4,
                  minBlastForce: 2,
                  emissionFrequency: 0.03,
                  numberOfParticles: 30,
                  gravity: 0.1,
                  colors: [
                    widget.mode.color,
                    Colors.yellow,
                    Colors.orange,
                    Colors.teal,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrophy() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: widget.mode.color.withValues(
          red: widget.mode.color.r.toDouble(),
          green: widget.mode.color.g.toDouble(),
          blue: widget.mode.color.b.toDouble(),
          alpha: 0.1,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.mode.color.withValues(
              red: widget.mode.color.r.toDouble(),
              green: widget.mode.color.g.toDouble(),
              blue: widget.mode.color.b.toDouble(),
              alpha: 0.2,
            ),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.emoji_events_rounded,
        size: 80,
        color: widget.mode.color,
      ),
    )
        .animate()
        .scale(
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
        )
        .then()
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: widget.mode.color.withValues(
            red: widget.mode.color.r.toDouble(),
            green: widget.mode.color.g.toDouble(),
            blue: widget.mode.color.b.toDouble(),
            alpha: 0.3,
          ),
        )
        .then()
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          duration: const Duration(milliseconds: 2000),
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
        )
        .then()
        .scale(
          duration: const Duration(milliseconds: 2000),
          begin: const Offset(1.05, 1.05),
          end: const Offset(1.0, 1.0),
        );
  }

  Widget _buildCongratulations() {
    return Column(
      children: [
        Text(
          'Congratulations!',
          style: Get.textTheme.headlineMedium?.copyWith(
            color: widget.mode.color,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn().scale(),
        const SizedBox(height: 8),
        Text(
          'You completed the game!',
          style: Get.textTheme.titleMedium?.copyWith(
            color: Colors.black54,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.mode.color.withValues(
              red: widget.mode.color.r.toDouble(),
              green: widget.mode.color.g.toDouble(),
              blue: widget.mode.color.b.toDouble(),
              alpha: 0.1,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow(
            icon: Icons.star,
            label: 'Score',
            value: widget.score.toString(),
            delay: 0,
          ),
          const Divider(height: 24),
          _buildStatRow(
            icon: Icons.swap_horiz,
            label: 'Moves',
            value: widget.moves.toString(),
            delay: 200,
          ),
          const Divider(height: 24),
          _buildStatRow(
            icon: Icons.timer,
            label: 'Time',
            value: '${widget.timeElapsed}s',
            delay: 400,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2);
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required int delay,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.mode.color.withValues(
              red: widget.mode.color.r.toDouble(),
              green: widget.mode.color.g.toDouble(),
              blue: widget.mode.color.b.toDouble(),
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: widget.mode.color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: Get.textTheme.titleMedium?.copyWith(
            color: Colors.black54,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: Get.textTheme.titleLarge?.copyWith(
            color: widget.mode.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay.ms).slideX();
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: widget.mode.color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                side: BorderSide(
                  color: widget.mode.color.withValues(
                    red: widget.mode.color.r.toDouble(),
                    green: widget.mode.color.g.toDouble(),
                    blue: widget.mode.color.b.toDouble(),
                    alpha: 0.2,
                  ),
                ),
              ),
              child: const Text('Exit'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.mode.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text('Play Again'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2);
  }
}
