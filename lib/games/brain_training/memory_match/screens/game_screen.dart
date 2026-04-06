import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/game_controller.dart';
import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../widgets/flip_card.dart';
import '../services/sound_service.dart';
import 'package:gameverse/widgets/guarded_exit.dart';

class MemoryMatchGameScreen extends StatefulWidget {
  final MemoryMatchMode mode;
  final GameDifficulty difficulty;

  const MemoryMatchGameScreen({
    super.key,
    required this.mode,
    required this.difficulty,
  });

  @override
  State<MemoryMatchGameScreen> createState() => _MemoryMatchGameScreenState();
}

class _MemoryMatchGameScreenState extends State<MemoryMatchGameScreen> {
  late final MemoryMatchGameController controller;
  late final MemoryMatchSoundService soundService;

  static const _bgDark = Color(0xFF0F0F1A);
  static const _surfaceDark = Color(0xFF1A1A2E);
  static const _surfaceLight = Color(0xFF22223A);

  @override
  void initState() {
    super.initState();
    controller = Get.find<MemoryMatchGameController>();
    soundService = Get.find<MemoryMatchSoundService>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initGame(widget.mode, widget.difficulty);
    });
  }

  @override
  void dispose() {
    // Only cleanup if we're actually leaving the game (not just pushing completion)
    // cleanupGame is called explicitly by exit buttons
    super.dispose();
  }

  Color get _accent => widget.mode.color;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic result) async {
        if (!didPop) {
          controller.pauseGame();
          final shouldPop = await _showExitConfirmation();
          if (!shouldPop) {
            controller.resumeGame();
            return;
          }
          if (!context.mounted) return;
          controller.cleanupGame();
          await popAfterConfirmation(
            context,
            confirmExit: () async => true,
          );
        }
      },
      child: Scaffold(
        backgroundColor: _bgDark,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStatsBar(),
              Expanded(child: _buildGameBoard()),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmation() async {
    return await Get.dialog<bool>(
          Dialog(
            backgroundColor: _surfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pause_circle_outline, size: 48, color: _accent),
                  const SizedBox(height: 16),
                  const Text(
                    'Exit Game?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your progress will be lost.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(result: false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _accent,
                            side: BorderSide(
                                color: _accent.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Continue'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back(result: true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Exit'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  // ---------- HEADER ----------

  Widget _buildHeader() {
    return Obx(() {
      final s = controller.state;
      if (s == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(
          children: [
            // Back button
            _backButton(),
            const SizedBox(width: 12),

            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mode.displayName,
                    style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${s.remainingPairs} pairs left',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Combo badge
            if (s.combo > 1)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orangeAccent, Colors.deepOrange],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 2),
                    Text(
                      '${s.combo}x',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ).animate().scale(duration: 200.ms, curve: Curves.elasticOut),

            // Mute button
            _iconButton(
              soundService.isMuted ? Icons.volume_off : Icons.volume_up,
              soundService.toggleMute,
            ),
          ],
        ),
      );
    });
  }

  Widget _backButton() {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accent.withValues(alpha: 0.15)),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, size: 20),
        onPressed: () {
          controller.pauseGame();
          popAfterConfirmation(
            context,
            confirmExit: _showExitConfirmation,
          ).then((_) {
            if (!mounted) return;
            if (!ModalRoute.of(context)!.isCurrent) {
              controller.cleanupGame();
            } else {
              controller.resumeGame();
            }
          });
        },
        color: _accent,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accent.withValues(alpha: 0.15)),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onTap,
        color: _accent,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }

  // ---------- STATS BAR ----------

  Widget _buildStatsBar() {
    return Obx(() {
      final s = controller.state;
      if (s == null) return const SizedBox.shrink();

      final isTimeTrial = s.mode == MemoryMatchMode.timeTrial;
      final timeText =
          isTimeTrial ? '${s.timeRemaining}s' : '${s.timeElapsed}s';
      final timeColor =
          isTimeTrial && s.timeRemaining <= 10 ? Colors.redAccent : _accent;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: Column(
          children: [
            // Time-trial progress bar
            if (isTimeTrial)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: s.timeRemaining / s.timeLimit,
                    backgroundColor: _surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      s.timeRemaining <= 10 ? Colors.redAccent : _accent,
                    ),
                    minHeight: 4,
                  ),
                ),
              ),

            // Stats row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: _surfaceDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _accent.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statChip(Icons.star_rounded, s.score.toString(), 'Score'),
                  _statChip(
                      Icons.touch_app_rounded, s.moves.toString(), 'Moves'),
                  _statChip(
                    isTimeTrial ? Icons.hourglass_bottom : Icons.timer_outlined,
                    timeText,
                    isTimeTrial ? 'Left' : 'Time',
                    valueColor: timeColor,
                  ),
                  _statChip(
                    Icons.grid_view_rounded,
                    '${s.columns}×${s.rows}',
                    'Grid',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _statChip(IconData icon, String value, String label,
      {Color? valueColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            color: valueColor ?? _accent.withValues(alpha: 0.7), size: 18),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ---------- GAME BOARD ----------

  Widget _buildGameBoard() {
    return Obx(() {
      final s = controller.state;
      if (s == null) {
        return Center(
          child: CircularProgressIndicator(color: _accent),
        );
      }

      final cols = s.columns;
      final rows = s.rows;

      return LayoutBuilder(
        builder: (context, constraints) {
          final spacing = 6.0;
          final availW = constraints.maxWidth - 24; // horizontal padding
          final availH = constraints.maxHeight - 16;

          // Calculate card size to fit grid
          final cardW = (availW - (cols - 1) * spacing) / cols;
          final cardH = (availH - (rows - 1) * spacing) / rows;
          final cardSize = min(cardW, cardH);

          final gridW = cardSize * cols + (cols - 1) * spacing;
          final gridH = cardSize * rows + (rows - 1) * spacing;

          return Center(
            child: SizedBox(
              width: gridW,
              height: gridH,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
                itemCount: s.cards.length,
                itemBuilder: (context, index) {
                  final card = s.cards[index];
                  return GestureDetector(
                    onTap: () => controller.flipCard(index),
                    child: FlipCard(
                      card: card,
                      mode: widget.mode,
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 30 * index),
                        duration: 300.ms,
                      )
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        delay: Duration(milliseconds: 30 * index),
                        duration: 300.ms,
                        curve: Curves.easeOutBack,
                      );
                },
              ),
            ),
          );
        },
      );
    });
  }
}
