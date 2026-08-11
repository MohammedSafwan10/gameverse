import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../services/sound_service.dart';
import '../theme/memory_match_theme.dart';
import '../widgets/flip_card.dart';

const _assetRoot = 'assets/images/games/memory_match';

class MemoryMatchGameScreen extends StatefulWidget {
  const MemoryMatchGameScreen({
    super.key,
    required this.mode,
    required this.difficulty,
  });

  final MemoryMatchMode mode;
  final GameDifficulty difficulty;

  @override
  State<MemoryMatchGameScreen> createState() => _MemoryMatchGameScreenState();
}

class _MemoryMatchGameScreenState extends State<MemoryMatchGameScreen>
    with WidgetsBindingObserver {
  late final MemoryMatchGameController controller;
  late final MemoryMatchSoundService soundService;
  bool _pausedForLifecycle = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<MemoryMatchGameController>();
    soundService = Get.find<MemoryMatchSoundService>();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.initGame(widget.mode, widget.difficulty);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (controller.state?.status == GameStatus.playing) {
        _pausedForLifecycle = true;
        controller.pauseGame();
      }
      return;
    }
    if (state == AppLifecycleState.resumed && _pausedForLifecycle) {
      _pausedForLifecycle = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
          _showPauseSheet();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _requestExit();
      },
      child: Scaffold(
        body: MemoryMatchBackdrop(
          child: SafeArea(
            child: Obx(() {
              final state = controller.state;
              if (state == null) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              return Column(
                children: [
                  _GameHeader(
                    state: state,
                    challengeLevel: controller.challengeLevel,
                    muted: soundService.isMuted,
                    onBack: _requestExit,
                    onPause: _showPauseSheet,
                    onSound: soundService.toggleMute,
                  ),
                  _StatsStrip(state: state),
                  Expanded(
                    child: _GameBoard(
                      state: state,
                      onCardTap: controller.flipCard,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> _requestExit() async {
    controller.pauseGame();
    final exit = await _showExitDialog();
    if (!mounted) return;
    if (!exit) {
      controller.resumeGame();
      return;
    }
    controller.cleanupGame();
    Navigator.of(context).pop();
  }

  Future<bool> _showExitDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 22),
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                decoration: BoxDecoration(
                  color: MemoryMatchTheme.cream,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: MemoryMatchTheme.softShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 48,
                            child: Transform.rotate(
                              angle: -.12,
                              child: Image.asset(
                                '$_assetRoot/blue_card_back_v1.png',
                                width: 78,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 48,
                            child: Transform.rotate(
                              angle: .12,
                              child: Image.asset(
                                '$_assetRoot/flower_card_v1.png',
                                width: 78,
                              ),
                            ),
                          ),
                          const CircleAvatar(
                            radius: 27,
                            backgroundColor: MemoryMatchTheme.orange,
                            child: Icon(Icons.flag_rounded,
                                color: Colors.white, size: 28),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('LEAVE THIS GAME?',
                        textAlign: TextAlign.center,
                        style: MemoryMatchTheme.display(size: 24)),
                    const SizedBox(height: 7),
                    Text(
                      'Your current board, score, and combo will be lost.',
                      textAlign: TextAlign.center,
                      style:
                          MemoryMatchTheme.body(color: MemoryMatchTheme.muted),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: MemoryMatchPrimaryButton(
                        label: 'KEEP PLAYING',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () => Navigator.pop(dialogContext, false),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('LEAVE GAME'),
                        style: TextButton.styleFrom(
                          foregroundColor: MemoryMatchTheme.pink,
                          textStyle: MemoryMatchTheme.body(
                            color: MemoryMatchTheme.pink,
                            weight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false;
  }

  Future<void> _showPauseSheet() async {
    controller.pauseGame();
    final pausedState = controller.state;
    final action = await showModalBottomSheet<_PauseAction>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: const BoxDecoration(
            color: MemoryMatchTheme.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 116,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: MemoryMatchTheme.cobalt,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 28,
                      top: 18,
                      bottom: 18,
                      child: Transform.rotate(
                        angle: -.1,
                        child: Image.asset('$_assetRoot/rocket_card_v1.png'),
                      ),
                    ),
                    Positioned(
                      right: 28,
                      top: 18,
                      bottom: 18,
                      child: Transform.rotate(
                        angle: .1,
                        child: Image.asset('$_assetRoot/flower_card_v1.png'),
                      ),
                    ),
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: MemoryMatchTheme.cream,
                        shape: BoxShape.circle,
                        boxShadow: MemoryMatchTheme.softShadow,
                      ),
                      child: const Icon(Icons.pause_rounded,
                          size: 36, color: MemoryMatchTheme.orange),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text('GAME PAUSED', style: MemoryMatchTheme.display(size: 27)),
              const SizedBox(height: 6),
              Text('Take a breath—your board is safe.',
                  style: MemoryMatchTheme.body(color: MemoryMatchTheme.muted)),
              if (pausedState != null) ...[
                const SizedBox(height: 15),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: MemoryMatchTheme.paper,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      _PauseStat('SCORE', '${pausedState.score}',
                          MemoryMatchTheme.cobalt),
                      _PauseStat('MOVES', '${pausedState.moves}',
                          MemoryMatchTheme.orange),
                      _PauseStat('PAIRS', '${pausedState.remainingPairs} left',
                          MemoryMatchTheme.mint),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: MemoryMatchPrimaryButton(
                  label: 'RESUME GAME',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () =>
                      Navigator.pop(sheetContext, _PauseAction.resume),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pop(sheetContext, _PauseAction.restart),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('RESTART'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pop(sheetContext, _PauseAction.exit),
                      icon: const Icon(Icons.flag_rounded),
                      label: const Text('EXIT'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    switch (action) {
      case _PauseAction.restart:
        controller.restartGame();
      case _PauseAction.exit:
        controller.cleanupGame();
        Navigator.of(context).pop();
      case _PauseAction.resume:
      case null:
        controller.resumeGame();
    }
  }
}

enum _PauseAction { resume, restart, exit }

class _PauseStat extends StatelessWidget {
  const _PauseStat(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                maxLines: 1,
                style: MemoryMatchTheme.display(size: 15, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: MemoryMatchTheme.body(
                  size: 8,
                  color: MemoryMatchTheme.muted,
                  weight: FontWeight.w900,
                )),
          ],
        ),
      );
}

class _GameHeader extends StatelessWidget {
  const _GameHeader({
    required this.state,
    required this.challengeLevel,
    required this.muted,
    required this.onBack,
    required this.onPause,
    required this.onSound,
  });

  final MemoryMatchState state;
  final int challengeLevel;
  final bool muted;
  final VoidCallback onBack;
  final VoidCallback onPause;
  final VoidCallback onSound;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 350;
    final subtitle = state.mode == MemoryMatchMode.challenge
        ? 'Level $challengeLevel · ${state.difficulty.name}'
        : '${state.mode.displayName} · ${state.difficulty.name}';
    return Container(
      margin: EdgeInsets.fromLTRB(compact ? 9 : 14, 10, compact ? 9 : 14, 9),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 7 : 9,
      ),
      decoration: BoxDecoration(
        color: MemoryMatchTheme.cream,
        borderRadius: BorderRadius.circular(27),
        boxShadow: MemoryMatchTheme.softShadow,
      ),
      child: Row(
        children: [
          MemoryMatchIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: onBack,
            tooltip: 'Exit game',
          ),
          SizedBox(width: compact ? 6 : 8),
          MemoryMatchIconButton(
            icon: Icons.pause_rounded,
            onPressed: onPause,
            tooltip: 'Pause',
          ),
          SizedBox(width: compact ? 7 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(state.mode.displayName.toUpperCase(),
                    maxLines: 1,
                    style: MemoryMatchTheme.display(
                      size: compact ? 18 : 22,
                    )),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: MemoryMatchTheme.orange,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    subtitle.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MemoryMatchTheme.body(
                      size: 9,
                      color: Colors.white,
                      weight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          MemoryMatchIconButton(
            icon: muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            onPressed: onSound,
            tooltip: muted ? 'Turn sound on' : 'Mute sound',
          ),
        ],
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.state});

  final MemoryMatchState state;

  @override
  Widget build(BuildContext context) {
    final timeTrial = state.mode == MemoryMatchMode.timeTrial;
    final seconds = timeTrial ? state.timeRemaining : state.timeElapsed;
    final urgent = timeTrial && seconds <= 10;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          Row(
            children: [
              _Stat(
                icon: Icons.star_rounded,
                value: '${state.score}',
                label: 'SCORE',
                color: MemoryMatchTheme.yellow,
              ),
              const SizedBox(width: 7),
              _Stat(
                icon: Icons.touch_app_rounded,
                value: '${state.moves}',
                label: 'MOVES',
                color: MemoryMatchTheme.cobalt,
              ),
              const SizedBox(width: 7),
              _Stat(
                icon: Icons.timer_rounded,
                value: _formatTime(seconds),
                label: timeTrial ? 'LEFT' : 'TIME',
                color: urgent ? MemoryMatchTheme.pink : const Color(0xFF26A65B),
              ),
            ],
          ),
          if (timeTrial) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: state.timeRemaining / state.timeLimit,
                minHeight: 5,
                color: urgent ? MemoryMatchTheme.pink : MemoryMatchTheme.orange,
                backgroundColor: MemoryMatchTheme.pinkPale,
              ),
            ),
          ],
          if (state.combo > 1) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              decoration: BoxDecoration(
                color: MemoryMatchTheme.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${state.combo}× COMBO',
                  style: MemoryMatchTheme.body(
                    size: 12,
                    color: Colors.white,
                    weight: FontWeight.w900,
                  )),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatTime(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 7),
          decoration: BoxDecoration(
            color: MemoryMatchTheme.cream,
            borderRadius: BorderRadius.circular(20),
            boxShadow: MemoryMatchTheme.softShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 21),
              const SizedBox(width: 5),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: MemoryMatchTheme.body(
                          size: 8,
                          weight: FontWeight.w800,
                        )),
                    Text(value,
                        maxLines: 1,
                        style: MemoryMatchTheme.display(size: 15, height: 1.1)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _PairsProgress extends StatelessWidget {
  const _PairsProgress({required this.state});
  final MemoryMatchState state;

  @override
  Widget build(BuildContext context) {
    final found = state.totalPairs - state.remainingPairs;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: MemoryMatchTheme.cream,
        borderRadius: BorderRadius.circular(22),
        boxShadow: MemoryMatchTheme.softShadow,
      ),
      child: Row(
        children: [
          Text('$found OF ${state.totalPairs} PAIRS',
              style: MemoryMatchTheme.body(size: 10, weight: FontWeight.w900)),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: LinearProgressIndicator(
                value: found / state.totalPairs,
                minHeight: 10,
                color: MemoryMatchTheme.orange,
                backgroundColor: const Color(0xFFF1DFC2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameBoard extends StatelessWidget {
  const _GameBoard({required this.state, required this.onCardTap});

  final MemoryMatchState state;
  final ValueChanged<int> onCardTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 440;
        final spacing = compact ? 5.0 : 7.0;
        const cardAspectRatio = .78;
        final horizontalPadding =
            MediaQuery.sizeOf(context).width < 350 ? 10.0 : 14.0;
        final boardW = constraints.maxWidth - horizontalPadding * 2;
        final boardH = constraints.maxHeight - (compact ? 70 : 105);
        final maxCardW =
            (boardW - (state.columns - 1) * spacing) / state.columns;
        final maxCardH = (boardH - (state.rows - 1) * spacing) / state.rows;
        final cardW = min(maxCardW, maxCardH * cardAspectRatio);
        final cardH = cardW / cardAspectRatio;
        final gridW = cardW * state.columns + spacing * (state.columns - 1);
        final gridH = cardH * state.rows + spacing * (state.rows - 1);

        return Padding(
          padding: EdgeInsets.only(top: compact ? 8 : 42),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: gridW + 16,
                  height: gridH + 16,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: state.columns,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: cardAspectRatio,
                    ),
                    itemCount: state.cards.length,
                    itemBuilder: (context, index) => Semantics(
                      button: true,
                      label: state.cards[index].isFlipped ||
                              state.cards[index].isMatched
                          ? 'Card ${index + 1}, ${state.cards[index].emoji}'
                          : 'Hidden card ${index + 1}',
                      child: GestureDetector(
                        key: ValueKey('memory-card-$index'),
                        onTap: () => onCardTap(index),
                        child: FlipCard(
                            card: state.cards[index], mode: state.mode),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: compact ? 8 : 18),
                SizedBox(
                  width: gridW + 8,
                  child: _PairsProgress(state: state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
