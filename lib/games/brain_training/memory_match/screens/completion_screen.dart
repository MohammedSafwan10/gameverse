import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../theme/memory_match_theme.dart';

const _assetRoot = 'assets/images/games/memory_match';

class GameCompletionScreen extends StatelessWidget {
  const GameCompletionScreen({
    super.key,
    required this.mode,
    required this.difficulty,
    required this.score,
    required this.moves,
    required this.timeElapsed,
    required this.combo,
    required this.starRating,
    this.challengeLevel = 1,
    this.isTimeUp = false,
  });

  final MemoryMatchMode mode;
  final GameDifficulty difficulty;
  final int score;
  final int moves;
  final int timeElapsed;
  final int combo;
  final int starRating;
  final int challengeLevel;
  final bool isTimeUp;

  bool get _nextChallenge =>
      mode == MemoryMatchMode.challenge && !isTimeUp && challengeLevel < 3;
  bool get _challengeFinished =>
      mode == MemoryMatchMode.challenge && !isTimeUp && challengeLevel >= 3;

  @override
  Widget build(BuildContext context) {
    final short = MediaQuery.sizeOf(context).height < 700;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                key: const ValueKey('memory-completion-content'),
                child: MemoryMatchBackdrop(
                  child: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(short ? 14 : 18),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 470),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                              short ? 17 : 22,
                              short ? 18 : 26,
                              short ? 17 : 22,
                              short ? 17 : 22,
                            ),
                            decoration: BoxDecoration(
                              color: MemoryMatchTheme.cream,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: MemoryMatchTheme.softShadow,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ResultArt(isTimeUp: isTimeUp),
                                SizedBox(height: short ? 12 : 18),
                                Text(
                                  isTimeUp
                                      ? 'TIME’S UP!'
                                      : _challengeFinished
                                          ? 'CHALLENGE COMPLETE!'
                                          : 'BRILLIANT!',
                                  textAlign: TextAlign.center,
                                  style: MemoryMatchTheme.display(
                                    size: short ? 27 : 32,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 180.ms, duration: 360.ms)
                                    .slideY(
                                        begin: .18, curve: Curves.easeOutCubic),
                                const SizedBox(height: 7),
                                Text(
                                  isTimeUp
                                      ? 'Great try! Play again and beat the clock.'
                                      : _nextChallenge
                                          ? 'Level $challengeLevel complete. The next board is tougher!'
                                          : _challengeFinished
                                              ? 'You cleared all three challenge levels!'
                                              : 'All pairs matched. Sharp memory!',
                                  textAlign: TextAlign.center,
                                  style: MemoryMatchTheme.body(
                                    size: 13,
                                    color: MemoryMatchTheme.muted,
                                  ),
                                ),
                                if (!isTimeUp) ...[
                                  SizedBox(height: short ? 10 : 15),
                                  _Stars(rating: starRating),
                                ],
                                SizedBox(height: short ? 13 : 20),
                                _ScoreCard(
                                  score: score,
                                  moves: moves,
                                  seconds: timeElapsed,
                                  combo: combo,
                                  challengeLevel:
                                      mode == MemoryMatchMode.challenge
                                          ? challengeLevel
                                          : null,
                                )
                                    .animate()
                                    .fadeIn(delay: 650.ms, duration: 380.ms)
                                    .slideY(
                                        begin: .14, curve: Curves.easeOutCubic),
                                SizedBox(height: short ? 14 : 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: MemoryMatchPrimaryButton(
                                    label: _nextChallenge
                                        ? 'NEXT LEVEL'
                                        : _challengeFinished
                                            ? 'PLAY CHALLENGE AGAIN'
                                            : 'PLAY AGAIN',
                                    icon: _nextChallenge
                                        ? Icons.arrow_forward_rounded
                                        : Icons.refresh_rounded,
                                    onPressed: () => _playAgain(context),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _exit(context),
                                    icon: const Icon(Icons.home_rounded),
                                    label: const Text('BACK TO MODES'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: MemoryMatchTheme.ink,
                                      side: BorderSide(
                                        color: MemoryMatchTheme.ink
                                            .withValues(alpha: 0.18),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(17),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 320.ms).scale(
                                begin: const Offset(.93, .93),
                                curve: Curves.easeOutBack,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!isTimeUp)
              const Positioned.fill(
                child: IgnorePointer(child: _CelebrationConfetti()),
              ),
          ],
        ),
      ),
    );
  }

  void _playAgain(BuildContext context) {
    final controller = Get.find<MemoryMatchGameController>();
    Navigator.of(context).pop();
    if (_nextChallenge) {
      controller.nextChallengeLevel();
    } else if (_challengeFinished) {
      controller.initGame(
        MemoryMatchMode.challenge,
        GameDifficulty.easy,
      );
    } else {
      controller.restartGame();
    }
  }

  void _exit(BuildContext context) {
    final navigator = Navigator.of(context);
    if (Get.isRegistered<MemoryMatchGameController>()) {
      Get.find<MemoryMatchGameController>().cleanupGame();
    }
    navigator.pop();
    if (navigator.canPop()) navigator.pop();
  }
}

class _ResultArt extends StatelessWidget {
  const _ResultArt({required this.isTimeUp});

  final bool isTimeUp;

  @override
  Widget build(BuildContext context) => Image.asset(
        isTimeUp ? '$_assetRoot/stopwatch_v1.png' : '$_assetRoot/trophy_v1.png',
        width: 150,
        height: 118,
        fit: BoxFit.contain,
      )
          .animate()
          .fadeIn(duration: 320.ms)
          .slideY(begin: -.38, curve: Curves.easeOutBack)
          .scale(
            delay: 90.ms,
            begin: const Offset(.72, .72),
            curve: Curves.elasticOut,
          );
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Opacity(
              opacity: index < rating ? 1 : .18,
              child: Image.asset(
                '$_assetRoot/star_v1.png',
                width: index == 1 ? 48 : 40,
                height: index == 1 ? 48 : 40,
              ),
            )
                .animate(delay: Duration(milliseconds: 320 + index * 120))
                .fadeIn(duration: 180.ms)
                .scale(
                  begin: Offset.zero,
                  curve: Curves.elasticOut,
                  duration: 650.ms,
                ),
          ),
        ),
      );
}

class _CelebrationConfetti extends StatefulWidget {
  const _CelebrationConfetti();

  @override
  State<_CelebrationConfetti> createState() => _CelebrationConfettiState();
}

class _CelebrationConfettiState extends State<_CelebrationConfetti> {
  late final ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: _controller,
          blastDirection: pi / 2,
          blastDirectionality: BlastDirectionality.explosive,
          emissionFrequency: .045,
          numberOfParticles: 16,
          minBlastForce: 9,
          maxBlastForce: 22,
          gravity: .2,
          shouldLoop: false,
          colors: const [
            MemoryMatchTheme.orange,
            Color(0xFFFFC93D),
            MemoryMatchTheme.mint,
            MemoryMatchTheme.pink,
            Color(0xFF6EA8FF),
          ],
        ),
      );
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.score,
    required this.moves,
    required this.seconds,
    required this.combo,
    required this.challengeLevel,
  });

  final int score;
  final int moves;
  final int seconds;
  final int combo;
  final int? challengeLevel;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: MemoryMatchTheme.paper,
          borderRadius: BorderRadius.circular(22),
          border:
              Border.all(color: MemoryMatchTheme.ink.withValues(alpha: 0.06)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _ResultStat(
                    label: 'SCORE',
                    value: '$score',
                    color: MemoryMatchTheme.orange),
                const SizedBox(width: 8),
                _ResultStat(
                    label: 'MOVES',
                    value: '$moves',
                    color: MemoryMatchTheme.ink),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _ResultStat(
                  label: 'TIME',
                  value:
                      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
                  color: MemoryMatchTheme.ink,
                ),
                const SizedBox(width: 8),
                _ResultStat(
                  label: challengeLevel == null ? 'BEST COMBO' : 'LEVEL',
                  value: challengeLevel == null ? '$combo×' : '$challengeLevel',
                  color: MemoryMatchTheme.ink,
                ),
              ],
            ),
          ],
        ),
      );
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .62),
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: MemoryMatchTheme.ink.withValues(alpha: .08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  maxLines: 1,
                  style: MemoryMatchTheme.display(size: 17, color: color)),
              const SizedBox(height: 3),
              Text(label,
                  style: MemoryMatchTheme.body(
                    size: 8,
                    weight: FontWeight.w800,
                    color: MemoryMatchTheme.muted,
                  )),
            ],
          ),
        ),
      );
}
