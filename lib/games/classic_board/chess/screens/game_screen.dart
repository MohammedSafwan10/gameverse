import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../theme/chess_design.dart';
import '../widgets/chess_board_widget.dart';
import 'settings_screen.dart';

class ChessGameScreen extends StatefulWidget {
  const ChessGameScreen({super.key});
  @override
  State<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen>
    with WidgetsBindingObserver {
  late final ChessGameController controller;
  late final ConfettiController confetti;
  late final Worker resultWorker;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ChessGameController>();
    confetti = ConfettiController(duration: const Duration(seconds: 2));
    resultWorker = ever(controller.gameState, (state) {
      if (state == ChessGameState.checkmate) confetti.play();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    resultWorker.dispose();
    confetti.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused) &&
        !_isFinished &&
        !controller.isGamePaused.value) {
      controller.pauseGame();
    }
  }

  bool get _isFinished =>
      controller.gameState.value == ChessGameState.checkmate ||
      controller.gameState.value == ChessGameState.stalemate ||
      controller.gameState.value == ChessGameState.draw;

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) await _requestExit();
        },
        child: Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(gradient: ChessDesign.background),
            child: SafeArea(
              child: Stack(children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: LayoutBuilder(builder: (context, constraints) {
                      final compact = constraints.maxHeight < 650;
                      return Column(children: [
                        _Header(
                          controller: controller,
                          compact: compact,
                          onBack: _requestExit,
                          onPause: _pause,
                          onSettings: _openSettings,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              compact ? 8 : 12,
                              4,
                              compact ? 8 : 12,
                              18,
                            ),
                            child: Column(children: [
                              _PlayerPanel(
                                controller: controller,
                                white: false,
                              ),
                              SizedBox(height: compact ? 7 : 10),
                              const ChessBoardWidget(),
                              SizedBox(height: compact ? 7 : 10),
                              _PlayerPanel(
                                controller: controller,
                                white: true,
                              ),
                              const SizedBox(height: 10),
                              _BottomActions(
                                controller: controller,
                                onHistory: _showHistory,
                                onRestart: _restart,
                              ),
                            ]),
                          ),
                        ),
                      ]);
                    }),
                  ),
                ),
                Obx(() => controller.isGamePaused.value
                    ? _PauseOverlay(
                        onResume: controller.resumeGame,
                        onRestart: _restart,
                        onLeave: _leaveNow,
                      )
                    : const SizedBox.shrink()),
                Obx(() => _isFinished
                    ? _ResultOverlay(
                        controller: controller,
                        onAgain: () =>
                            controller.startNewGame(controller.gameMode.value),
                        onLeave: _leaveNow,
                      )
                    : const SizedBox.shrink()),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: confetti,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: .05,
                    numberOfParticles: 14,
                    gravity: .16,
                    colors: const [
                      ChessDesign.gold,
                      ChessDesign.orange,
                      ChessDesign.teal,
                      Colors.white,
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      );

  Future<void> _pause() async {
    if (_isFinished) return;
    controller.pauseGame();
    controller.soundService.playMenuSelectionSound();
  }

  Future<void> _openSettings() async {
    if (_isFinished) {
      await Get.to(() => const ChessSettingsScreen());
      return;
    }
    final wasPaused = controller.isGamePaused.value;
    if (!wasPaused) controller.pauseGame();
    await Get.to(() => const ChessSettingsScreen());
    if (!wasPaused && mounted && !_isFinished) controller.resumeGame();
  }

  Future<void> _requestExit() async {
    final wasPaused = controller.isGamePaused.value;
    if (!wasPaused && !_isFinished) controller.pauseGame();
    final leave = await _confirm(
      title: 'LEAVE THE BOARD?',
      body: 'Your current match will stay saved so you can continue later.',
      action: 'LEAVE GAME',
    );
    if (leave) {
      _leaveNow();
    } else if (!wasPaused && !_isFinished) {
      controller.resumeGame();
    }
  }

  Future<void> _restart() async {
    final wasPaused = controller.isGamePaused.value;
    if (!wasPaused && !_isFinished) controller.pauseGame();
    final restart = await _confirm(
      title: 'START A NEW MATCH?',
      body: 'The current board and move history will be reset.',
      action: 'RESTART',
    );
    if (restart) {
      controller.startNewGame(controller.gameMode.value);
      controller.soundService.playGameStartSound();
    } else if (!wasPaused && !_isFinished) {
      controller.resumeGame();
    }
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    required String action,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => _ChessConfirmDialog(
          title: title,
          body: body,
          action: action,
        ),
      ) ??
      false;

  Future<void> _showHistory() async {
    controller.soundService.playMenuSelectionSound();
    final moves = controller.formattedMovePairs();
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380, maxHeight: 520),
          padding: const EdgeInsets.all(22),
          decoration: ChessDesign.ivoryPanel(radius: 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.history_rounded,
                color: ChessDesign.navy, size: 34),
            const SizedBox(height: 8),
            const Text('MOVE HISTORY',
                style: TextStyle(
                    color: ChessDesign.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            Flexible(
              child: moves.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No moves yet.'),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: moves.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, index) => SelectableText(
                        moves[index],
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: moves.isEmpty
                      ? null
                      : () async {
                          await Clipboard.setData(
                            ClipboardData(text: moves.join('\n')),
                          );
                          if (context.mounted) Navigator.pop(context);
                        },
                  child: const Text('COPY'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style:
                      FilledButton.styleFrom(backgroundColor: ChessDesign.navy),
                  child: const Text('DONE'),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  void _leaveNow() {
    controller.pauseGame();
    Get.back();
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.compact,
    required this.onBack,
    required this.onPause,
    required this.onSettings,
  });
  final ChessGameController controller;
  final bool compact;
  final VoidCallback onBack;
  final VoidCallback onPause;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.fromLTRB(10, compact ? 5 : 10, 10, 8),
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: ChessDesign.ivoryPanel(radius: 24),
        child: Row(children: [
          _HeaderButton(icon: Icons.arrow_back_rounded, onTap: onBack),
          _HeaderButton(icon: Icons.pause_rounded, onTap: onPause),
          Expanded(
            child: Obx(() => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      switch (controller.gameMode.value) {
                        ChessGameMode.ai => 'VS AI',
                        ChessGameMode.local => 'LOCAL MATCH',
                        ChessGameMode.training => 'TRAINING',
                      },
                      style: const TextStyle(
                          color: ChessDesign.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '${ChessBoardPalette.fromId(controller.boardTheme.value).name.toUpperCase()} BOARD',
                      style: const TextStyle(
                          color: ChessDesign.orange,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1),
                    ),
                  ],
                )),
          ),
          Obx(() => _HeaderButton(
                icon: controller.soundService.isSoundEnabled.value
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                onTap: controller.soundService.toggleSound,
              )),
          _HeaderButton(icon: Icons.settings_rounded, onTap: onSettings),
        ]),
      );
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: onTap,
        icon: Icon(icon, color: ChessDesign.ink, size: 22),
      );
}

class _PlayerPanel extends StatelessWidget {
  const _PlayerPanel({required this.controller, required this.white});
  final ChessGameController controller;
  final bool white;

  @override
  Widget build(BuildContext context) => Obx(() {
        final active = controller.isWhiteTurn.value == white;
        final seconds = white
            ? controller.whiteTimeRemaining.value
            : controller.blackTimeRemaining.value;
        final captured = controller.capturedPieces
            .where((piece) => piece.contains(white ? 'black' : 'white'))
            .toList();
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: active ? ChessDesign.orange : ChessDesign.ivory,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: active ? Colors.white : ChessDesign.ivoryDeep, width: 2),
            boxShadow: active ? ChessDesign.raisedShadow : null,
          ),
          child: Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: white ? Colors.white : ChessDesign.ink,
                shape: BoxShape.circle,
                border: Border.all(color: ChessDesign.gold, width: 2),
              ),
              child: Icon(Icons.person_rounded,
                  color: white ? ChessDesign.ink : Colors.white, size: 19),
            ),
            const SizedBox(width: 9),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  white ? 'WHITE' : 'BLACK',
                  style: TextStyle(
                      color: active ? Colors.white : ChessDesign.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w900),
                ),
                Text(
                  active ? _stateText(controller.gameState.value) : 'WAITING',
                  style: TextStyle(
                      color: active
                          ? Colors.white.withValues(alpha: .82)
                          : ChessDesign.ink.withValues(alpha: .5),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ListView.builder(
                reverse: true,
                scrollDirection: Axis.horizontal,
                itemCount: captured.length,
                itemBuilder: (_, index) {
                  final piece = captured[index];
                  return Center(
                    child: SvgPicture.asset(
                      'assets/chess/images/$piece.svg',
                      width: 19,
                      height: 19,
                      colorFilter: ColorFilter.mode(
                        piece.contains('white')
                            ? const Color(0xFFF7EBD4)
                            : ChessDesign.ink,
                        BlendMode.srcIn,
                      ),
                    ),
                  );
                },
              ),
            ),
            if (controller.timerEnabled.value)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                    color: active
                        ? Colors.white
                        : ChessDesign.navy.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  controller.formatTime(seconds),
                  style: TextStyle(
                      color: seconds <= 10 ? ChessDesign.red : ChessDesign.ink,
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w900),
                ),
              ),
          ]),
        );
      });

  static String _stateText(ChessGameState state) => switch (state) {
        ChessGameState.check => 'IN CHECK',
        ChessGameState.checkmate => 'GAME OVER',
        ChessGameState.stalemate || ChessGameState.draw => 'DRAW',
        _ => 'YOUR TURN',
      };
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.controller,
    required this.onHistory,
    required this.onRestart,
  });
  final ChessGameController controller;
  final VoidCallback onHistory;
  final VoidCallback onRestart;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
          child: _ActionButton(
              icon: Icons.history_rounded, label: 'MOVES', onTap: onHistory),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Obx(() => Container(
                height: 46,
                decoration: ChessDesign.ivoryPanel(radius: 18),
                alignment: Alignment.center,
                child: Text(
                  controller.gameState.value == ChessGameState.check
                      ? 'CHECK!'
                      : controller.gameMode.value == ChessGameMode.ai &&
                              !controller.isWhiteTurn.value
                          ? 'AI IS THINKING…'
                          : '${controller.isWhiteTurn.value ? "WHITE" : "BLACK"} TO MOVE',
                  style: const TextStyle(
                      color: ChessDesign.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .5),
                ),
              )),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
              icon: Icons.restart_alt_rounded,
              label: 'RESTART',
              onTap: onRestart),
        ),
      ]);
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 46,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              backgroundColor: ChessDesign.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 17),
            Text(label,
                style:
                    const TextStyle(fontSize: 8, fontWeight: FontWeight.w900)),
          ]),
        ),
      );
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay(
      {required this.onResume, required this.onRestart, required this.onLeave});
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onLeave;
  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: ColoredBox(
          color: ChessDesign.navyDeep.withValues(alpha: .88),
          child: Center(
            child: Container(
              width: MediaQuery.sizeOf(context).width.clamp(0, 390) - 32,
              padding: const EdgeInsets.all(24),
              decoration: ChessDesign.ivoryPanel(radius: 30),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.pause_circle_filled_rounded,
                    size: 64, color: ChessDesign.orange),
                const SizedBox(height: 10),
                const Text('GAME PAUSED',
                    style: TextStyle(
                        color: ChessDesign.ink,
                        fontSize: 26,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text('Take your time. The board is waiting.',
                    style: TextStyle(
                        color: ChessDesign.ink.withValues(alpha: .62),
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: onResume,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('RESUME GAME'),
                    style: FilledButton.styleFrom(
                        backgroundColor: ChessDesign.orange,
                        textStyle: const TextStyle(fontWeight: FontWeight.w900),
                        shape: const StadiumBorder()),
                  ),
                ),
                const SizedBox(height: 9),
                Row(children: [
                  Expanded(
                      child: OutlinedButton.icon(
                          onPressed: onRestart,
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('RESTART'))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: OutlinedButton.icon(
                          onPressed: onLeave,
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('LEAVE'))),
                ]),
              ]),
            ),
          ),
        ),
      );
}

class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay(
      {required this.controller, required this.onAgain, required this.onLeave});
  final ChessGameController controller;
  final VoidCallback onAgain;
  final VoidCallback onLeave;
  @override
  Widget build(BuildContext context) {
    final draw = controller.gameState.value == ChessGameState.stalemate ||
        controller.gameState.value == ChessGameState.draw;
    final winner = controller.isWhiteTurn.value ? 'BLACK' : 'WHITE';
    final reason = switch (controller.endReason.value) {
      ChessEndReason.timeout => 'Won on time',
      ChessEndReason.resignation => 'Won by resignation',
      ChessEndReason.stalemate => 'Draw by stalemate',
      ChessEndReason.insufficientMaterial => 'Draw by insufficient material',
      ChessEndReason.repetition => 'Draw by repetition',
      ChessEndReason.fiftyMoveRule => 'Draw by the 50-move rule',
      ChessEndReason.checkmate => '$winner wins',
      ChessEndReason.none => draw ? 'The match ends in a draw' : '$winner wins',
    };
    return Positioned.fill(
      child: ColoredBox(
        color: ChessDesign.navyDeep.withValues(alpha: .9),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 390),
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              decoration: ChessDesign.ivoryPanel(radius: 34),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: const BoxDecoration(
                      color: ChessDesign.gold, shape: BoxShape.circle),
                  child: Icon(
                      draw ? Icons.balance_rounded : Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 51),
                ),
                const SizedBox(height: 14),
                Text(draw ? 'GREAT BATTLE!' : 'CHECKMATE!',
                    style: const TextStyle(
                        color: ChessDesign.orange,
                        fontSize: 34,
                        height: 1,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(reason,
                    style: const TextStyle(
                        color: ChessDesign.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 18),
                Row(children: [
                  _ResultStat(
                      label: 'MOVES',
                      value: '${controller.moveHistory.length}'),
                  const SizedBox(width: 8),
                  _ResultStat(
                      label: 'CAPTURES',
                      value: '${controller.capturedPieces.length}'),
                ]),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: onAgain,
                    style: FilledButton.styleFrom(
                        backgroundColor: ChessDesign.orange,
                        shape: const StadiumBorder()),
                    child: const Text('PLAY AGAIN',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: onLeave,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: ChessDesign.navy,
                        side:
                            const BorderSide(color: ChessDesign.navy, width: 2),
                        shape: const StadiumBorder()),
                    child: const Text('BACK TO GAMES',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
              color: const Color(0xFFF0E8D7),
              borderRadius: BorderRadius.circular(17)),
          child: Column(children: [
            Text(value,
                style: const TextStyle(
                    color: ChessDesign.navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w900)),
            Text(label,
                style: const TextStyle(
                    color: ChessDesign.ink,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1)),
          ]),
        ),
      );
}

class _ChessConfirmDialog extends StatelessWidget {
  const _ChessConfirmDialog(
      {required this.title, required this.body, required this.action});
  final String title;
  final String body;
  final String action;
  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(24),
          decoration: ChessDesign.ivoryPanel(radius: 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.sports_esports_rounded,
                color: ChessDesign.orange, size: 48),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: ChessDesign.ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(body,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: ChessDesign.ink.withValues(alpha: .65),
                    fontWeight: FontWeight.w600,
                    height: 1.35)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('KEEP PLAYING'))),
              const SizedBox(width: 8),
              Expanded(
                  child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                          backgroundColor: ChessDesign.orange),
                      child: Text(action))),
            ]),
          ]),
        ),
      );
}
