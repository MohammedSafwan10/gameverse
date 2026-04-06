import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:gameverse/widgets/guarded_exit.dart';
import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../controllers/game_controller.dart';

class GameCompletionScreen extends StatefulWidget {
  final MemoryMatchMode mode;
  final GameDifficulty difficulty;
  final int score;
  final int moves;
  final int timeElapsed;
  final int combo;
  final int starRating;
  final int challengeLevel;
  final bool isTimeUp;

  const GameCompletionScreen({
    super.key,
    required this.mode,
    required this.difficulty,
    required this.score,
    required this.moves,
    required this.timeElapsed,
    this.combo = 0,
    this.starRating = 0,
    this.challengeLevel = 1,
    this.isTimeUp = false,
  });

  @override
  State<GameCompletionScreen> createState() => _GameCompletionScreenState();
}

class _GameCompletionScreenState extends State<GameCompletionScreen> {
  late ConfettiController _confettiController;

  static const _bgDark = Color(0xFF0F0F1A);
  static const _surfaceDark = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));
    if (!widget.isTimeUp) _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Color get _accent => widget.mode.color;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {},
      child: Scaffold(
        backgroundColor: _bgDark,
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    _accent.withValues(alpha: 0.15),
                    _bgDark,
                  ],
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      _buildIcon(),
                      const SizedBox(height: 20),
                      _buildTitle(),
                      if (!widget.isTimeUp) ...[
                        const SizedBox(height: 20),
                        _buildStarRating(),
                      ],
                      const SizedBox(height: 28),
                      _buildStatsCard(),
                      const SizedBox(height: 32),
                      _buildButtons(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Confetti
            if (!widget.isTimeUp) ...[
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2,
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 40,
                  gravity: 0.1,
                  colors: [
                    _accent,
                    Colors.purple,
                    Colors.blue,
                    Colors.pink,
                    Colors.amber
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final icon =
        widget.isTimeUp ? Icons.timer_off_rounded : Icons.emoji_events_rounded;
    final iconColor = widget.isTimeUp ? Colors.redAccent : Colors.amber;

    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: iconColor.withValues(alpha: 0.1),
        border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, size: 60, color: iconColor),
    )
        .animate()
        .scale(duration: 500.ms, curve: Curves.elasticOut)
        .then()
        .shimmer(duration: 1500.ms, color: iconColor.withValues(alpha: 0.3));
  }

  Widget _buildTitle() {
    final title = widget.isTimeUp ? 'Time\'s Up!' : 'Well Done!';
    final subtitle = widget.isTimeUp
        ? 'You ran out of time'
        : widget.mode == MemoryMatchMode.challenge
            ? 'Level ${widget.challengeLevel - 1} Complete'
            : 'All pairs matched!';

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: widget.isTimeUp ? Colors.redAccent : Colors.white,
          ),
        ).animate().fadeIn().slideY(begin: 0.3),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < widget.starRating;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 40,
            color: filled ? Colors.amber : Colors.white.withValues(alpha: 0.2),
          ),
        )
            .animate()
            .scale(
              delay: Duration(milliseconds: 300 + i * 200),
              duration: 400.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(delay: Duration(milliseconds: 300 + i * 200));
      }),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          _statRow(Icons.star_rounded, 'Score', widget.score.toString()),
          _divider(),
          _statRow(Icons.touch_app_rounded, 'Moves', widget.moves.toString()),
          _divider(),
          _statRow(Icons.timer_outlined, 'Time', '${widget.timeElapsed}s'),
          if (widget.combo > 0) ...[
            _divider(),
            _statRow(
              Icons.local_fire_department,
              'Best Combo',
              '${widget.combo}x',
              valueColor: Colors.orangeAccent,
            ),
          ],
          if (widget.mode == MemoryMatchMode.challenge) ...[
            _divider(),
            _statRow(
              Icons.trending_up,
              'Challenge Level',
              '${widget.challengeLevel}',
              valueColor: Colors.purpleAccent,
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.15);
  }

  Widget _statRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: valueColor ?? _accent, size: 20),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 15,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.06),
      height: 16,
    );
  }

  Widget _buildButtons() {
    final isChallenge =
        widget.mode == MemoryMatchMode.challenge && !widget.isTimeUp;

    return Column(
      children: [
        // Primary action
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final controller = Get.find<MemoryMatchGameController>();
              if (isChallenge) {
                Navigator.of(context).pop();
                controller.nextChallengeLevel();
              } else {
                Navigator.of(context).pop();
                controller.restartGame(); // restart with same mode/difficulty
              }
            },
            icon: Icon(isChallenge ? Icons.arrow_forward : Icons.replay),
            label: Text(isChallenge ? 'Next Level' : 'Play Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Exit
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Clean up before exiting
              if (Get.isRegistered<MemoryMatchGameController>()) {
                Get.find<MemoryMatchGameController>().cleanupGame();
              }
              Navigator.of(context).pop();
              popAfterConfirmation(
                context,
                confirmExit: () async => true,
              );
            },
            icon: const Icon(Icons.home_outlined),
            label: const Text('Exit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white.withValues(alpha: 0.7),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2);
  }
}
