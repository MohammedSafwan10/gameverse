import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                              SizedBox(height: compact ? 6 : 8),
                              _TurnBanner(controller: controller),
                              SizedBox(height: compact ? 6 : 8),
                              const ChessBoardWidget(),
                              SizedBox(height: compact ? 7 : 10),
                              _PlayerPanel(
                                controller: controller,
                                white: true,
                              ),
                              const SizedBox(height: 10),
                              _BottomActions(
                                onHistory: _showHistory,
                                onRestart: _restart,
                                onSettings: _openSettings,
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
                        onSettings: _openSettings,
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
      builder: (context) => _MoveHistoryDialog(moves: moves),
    );
  }

  void _leaveNow() {
    controller.pauseGame();
    Get.back();
  }
}

class _MoveHistoryDialog extends StatelessWidget {
  const _MoveHistoryDialog({required this.moves});
  final List<String> moves;

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350, maxHeight: 570),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: ChessDesign.ivory,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: ChessDesign.gold, width: 2),
            boxShadow: const [
              BoxShadow(
                  color: Color(0xAA000511),
                  blurRadius: 28,
                  offset: Offset(0, 14))
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: ChessDesign.navyDeep,
                  shape: BoxShape.circle,
                  border: Border.all(color: ChessDesign.gold, width: 1.5),
                ),
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/images/games/chess/pieces_v2/black_knight.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'MOVE HISTORY',
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'BarlowCondensed',
                    color: ChessDesign.navyDeep,
                    fontSize: 29,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton.filled(
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: ChessDesign.navyDeep,
                  foregroundColor: const Color(0xFFFFE7AD),
                  side: const BorderSide(color: ChessDesign.gold),
                ),
                icon: const Icon(Icons.close_rounded),
              ),
            ]),
            const SizedBox(height: 14),
            Container(
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFE9D9B9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Row(children: [
                SizedBox(width: 44),
                Expanded(
                    child: Center(
                        child: Text('WHITE',
                            style: TextStyle(
                                color: ChessDesign.navyDeep,
                                fontWeight: FontWeight.w900)))),
                Expanded(
                    child: Center(
                        child: Text('BLACK',
                            style: TextStyle(
                                color: ChessDesign.navyDeep,
                                fontWeight: FontWeight.w900)))),
              ]),
            ),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF1),
                  border: Border.all(color: const Color(0xFFD8C49E)),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: moves.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(28),
                          child: Text('Your moves will appear here.',
                              style: TextStyle(
                                  color: ChessDesign.ink,
                                  fontWeight: FontWeight.w600)),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: moves.length,
                        itemBuilder: (_, index) =>
                            _HistoryRow(index: index, value: moves[index]),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: moves.isEmpty
                      ? null
                      : () async {
                          await Clipboard.setData(
                              ClipboardData(text: moves.join('\n')));
                          if (context.mounted) Navigator.pop(context);
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ChessDesign.navyDeep,
                    side:
                        const BorderSide(color: ChessDesign.navyDeep, width: 2),
                    minimumSize: const Size.fromHeight(48),
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('COPY'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: ChessDesign.orange,
                    minimumSize: const Size.fromHeight(48),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('CLOSE'),
                ),
              ),
            ]),
          ]),
        ),
      );
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.index, required this.value});
  final int index;
  final String value;

  @override
  Widget build(BuildContext context) {
    final prefix = '${index + 1}. ';
    final notation =
        value.startsWith(prefix) ? value.substring(prefix.length) : value;
    final pair = notation.split(RegExp(r'\s{2,}'));
    return Container(
      height: 43,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE4D8C1))),
      ),
      child: Row(children: [
        SizedBox(
          width: 44,
          child: Center(
            child: Text('${index + 1}.',
                style: const TextStyle(
                    color: ChessDesign.ink, fontWeight: FontWeight.w800)),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(pair.first,
                style: const TextStyle(
                    color: ChessDesign.ink,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800)),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(pair.length > 1 ? pair[1] : '',
                style: const TextStyle(
                    color: ChessDesign.ink,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
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
        height: compact ? 62 : 72,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: ChessDesign.ivory,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: ChessDesign.gold, width: 1.5),
          boxShadow: ChessDesign.raisedShadow,
        ),
        child: Row(children: [
          _HeaderButton(icon: Icons.arrow_back_rounded, onTap: onBack),
          _HeaderButton(icon: Icons.pause_rounded, onTap: onPause),
          Expanded(
            child: Obx(() => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 28,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          switch (controller.gameMode.value) {
                            ChessGameMode.ai => 'VS AI',
                            ChessGameMode.local => 'LOCAL MATCH',
                            ChessGameMode.training => 'TRAINING',
                          },
                          maxLines: 1,
                          style: const TextStyle(
                              fontFamily: 'BarlowCondensed',
                              color: ChessDesign.navyDeep,
                              fontSize: 24,
                              height: .95,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${ChessBoardPalette.fromId(controller.boardTheme.value).name.toUpperCase()} BOARD',
                          maxLines: 1,
                          style: const TextStyle(
                              color: ChessDesign.orange,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1),
                        ),
                      ),
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ChessDesign.navyDeep,
              border: Border.all(color: ChessDesign.gold, width: 1.5),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 5,
                    offset: Offset(0, 3))
              ],
            ),
            child: Icon(icon, color: const Color(0xFFFFE7AD), size: 21),
          ),
        ),
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
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: active
                  ? const [Color(0xFF124D89), Color(0xFF062B59)]
                  : const [Color(0xFF0A386A), Color(0xFF031E43)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: active ? ChessDesign.gold : const Color(0xFF285987),
                width: active ? 2 : 1.5),
            boxShadow: ChessDesign.raisedShadow,
          ),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF061D3B),
                shape: BoxShape.circle,
                border: Border.all(color: ChessDesign.gold, width: 2),
              ),
              padding: const EdgeInsets.all(3),
              child: Image.asset(
                white
                    ? 'assets/images/games/chess/pieces_v2/white_king.png'
                    : 'assets/images/games/chess/pieces_v2/black_knight.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 9),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  white ? 'WHITE' : 'BLACK',
                  style: TextStyle(
                      fontFamily: 'BarlowCondensed',
                      color: const Color(0xFFFFE7AD),
                      fontSize: 20,
                      height: .95,
                      fontWeight: FontWeight.w800),
                ),
                Text(
                  active ? _stateText(controller.gameState.value) : 'WAITING',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: .65),
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
                    child: Image.asset(
                      'assets/images/games/chess/pieces_v2/$piece.png',
                      width: 23,
                      height: 27,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
            if (controller.timerEnabled.value)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                    color: const Color(0xFF061D3B),
                    border: Border.all(color: ChessDesign.gold),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  controller.formatTime(seconds),
                  style: TextStyle(
                      color: seconds <= 10
                          ? const Color(0xFFFF7C69)
                          : const Color(0xFFFFE7AD),
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
    required this.onHistory,
    required this.onRestart,
    required this.onSettings,
  });
  final VoidCallback onHistory;
  final VoidCallback onRestart;
  final VoidCallback onSettings;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
          child: _ActionButton(
              icon: Icons.format_list_bulleted_rounded,
              label: 'HISTORY',
              onTap: onHistory),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
              icon: Icons.restart_alt_rounded,
              label: 'RESTART',
              onTap: onRestart),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
              icon: Icons.settings_rounded,
              label: 'OPTIONS',
              onTap: onSettings),
        ),
      ]);
}

class _TurnBanner extends StatelessWidget {
  const _TurnBanner({required this.controller});
  final ChessGameController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
        final check = controller.gameState.value == ChessGameState.check;
        final thinking = controller.gameMode.value == ChessGameMode.ai &&
            !controller.isWhiteTurn.value;
        final text = check
            ? 'CHECK — YOUR MOVE'
            : thinking
                ? 'COMPUTER IS THINKING…'
                : '${controller.isWhiteTurn.value ? "WHITE" : "BLACK"} TO MOVE';
        return Center(
          child: Container(
            height: 34,
            constraints: const BoxConstraints(maxWidth: 260),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF0C427D), Color(0xFF031E43)]),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: ChessDesign.gold, width: 1.5),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x77000000),
                    blurRadius: 7,
                    offset: Offset(0, 4))
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'BarlowCondensed',
                  color: check ? ChessDesign.orange : const Color(0xFFFFE7AD),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .6,
                ),
              ),
            ),
          ),
        );
      });
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 50,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              backgroundColor: ChessDesign.navyDeep,
              foregroundColor: const Color(0xFFFFE7AD),
              side: const BorderSide(color: ChessDesign.gold, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 19),
            Text(label,
                style:
                    const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
          ]),
        ),
      );
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({
    required this.onResume,
    required this.onRestart,
    required this.onSettings,
    required this.onLeave,
  });
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onSettings;
  final VoidCallback onLeave;
  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: ColoredBox(
          color: ChessDesign.navyDeep.withValues(alpha: .88),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Container(
                width: MediaQuery.sizeOf(context).width.clamp(0, 390) - 32,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
                decoration: BoxDecoration(
                  color: ChessDesign.ivory,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: ChessDesign.gold, width: 2),
                  boxShadow: ChessDesign.raisedShadow,
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('GAME PAUSED',
                        maxLines: 1,
                        style: TextStyle(
                            fontFamily: 'BarlowCondensed',
                            color: ChessDesign.navyDeep,
                            fontSize: 34,
                            height: 1,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 5),
                  Text('Take your time. The board is waiting.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: ChessDesign.ink.withValues(alpha: .62),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: 96,
                    child: Image.asset(
                      'assets/images/games/chess/pause_pieces_v2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: onResume,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('RESUME GAME'),
                      style: FilledButton.styleFrom(
                          backgroundColor: ChessDesign.orange,
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.w900),
                          shape: const StadiumBorder()),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(children: [
                    Expanded(
                      child: _PauseSecondaryAction(
                        onPressed: onRestart,
                        icon: Icons.restart_alt_rounded,
                        label: 'RESTART',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PauseSecondaryAction(
                        onPressed: onSettings,
                        icon: Icons.settings_rounded,
                        label: 'SETTINGS',
                      ),
                    ),
                  ]),
                  const SizedBox(height: 9),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onLeave,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ChessDesign.red,
                        side:
                            const BorderSide(color: ChessDesign.red, width: 2),
                        minimumSize: const Size.fromHeight(48),
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('LEAVE MATCH'),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
}

class _PauseSecondaryAction extends StatelessWidget {
  const _PauseSecondaryAction({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ChessDesign.navy, width: 1.5),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, color: ChessDesign.gold, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label,
                      maxLines: 1,
                      style: const TextStyle(
                        color: ChessDesign.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .4,
                      )),
                ),
              ),
            ]),
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
              decoration: BoxDecoration(
                color: ChessDesign.ivory,
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: ChessDesign.gold, width: 2),
                boxShadow: ChessDesign.raisedShadow,
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 116,
                  height: 116,
                  decoration: BoxDecoration(
                    color: ChessDesign.navyDeep,
                    shape: BoxShape.circle,
                    border: Border.all(color: ChessDesign.gold, width: 2),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    draw
                        ? 'assets/images/games/chess/local_kings_v1.png'
                        : 'assets/images/games/chess/pieces_v2/${winner.toLowerCase()}_king.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 14),
                Text(draw ? 'GREAT BATTLE!' : 'CHECKMATE!',
                    style: const TextStyle(
                        fontFamily: 'BarlowCondensed',
                        color: ChessDesign.orange,
                        fontSize: 42,
                        height: 1,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  decoration: BoxDecoration(
                    color: ChessDesign.navyDeep,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: ChessDesign.gold),
                  ),
                  child: Text(reason,
                      style: const TextStyle(
                          color: Color(0xFFFFE7AD),
                          fontSize: 16,
                          fontWeight: FontWeight.w900)),
                ),
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
                const SizedBox(height: 8),
                Row(children: [
                  _ResultStat(
                      label: 'MODE',
                      value: controller.gameMode.value == ChessGameMode.ai
                          ? 'VS AI'
                          : 'LOCAL'),
                  const SizedBox(width: 8),
                  _ResultStat(
                      label: 'LEVEL',
                      value: controller.gameMode.value == ChessGameMode.ai
                          ? const [
                              'EASY',
                              'MEDIUM',
                              'HARD'
                            ][controller.aiDifficulty.value - 1]
                          : 'CLASSIC'),
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: ChessDesign.gold, width: 2),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D4683), Color(0xFF031E43)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xAA000714),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFF3D8),
                border: Border.all(color: ChessDesign.gold, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: ChessDesign.navyDeep, size: 30),
            ),
            const SizedBox(height: 14),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: 'BarlowCondensed',
                  color: Color(0xFFFFE9B9),
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .4,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .82),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, false),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC34D),
                  foregroundColor: ChessDesign.navyDeep,
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'KEEP PLAYING',
                  maxLines: 1,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFE9B9),
                  side: const BorderSide(color: ChessDesign.orange, width: 2),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  action,
                  maxLines: 1,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ]),
        ),
      );
}
