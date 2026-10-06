import 'package:flutter/material.dart';
import 'dart:math' show pi;
import 'package:confetti/confetti.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/board.dart';
import '../widgets/arcade_ui.dart';
import '../widgets/board_widget.dart';
import 'mode_selection_screen.dart';

class ConnectFourGameScreen extends StatefulWidget {
  const ConnectFourGameScreen({super.key});
  @override
  State<ConnectFourGameScreen> createState() => _ConnectFourGameScreenState();
}

class _ConnectFourGameScreenState extends State<ConnectFourGameScreen>
    with WidgetsBindingObserver {
  late final ConnectFourController controller;
  final _confetti = ConfettiController(duration: const Duration(seconds: 2));
  late final Worker _resultWorker;
  bool _dialogOpen = false, _allowPop = false;
  @override
  void initState() {
    super.initState();
    controller = Get.find<ConnectFourController>();
    _resultWorker = ever(controller.board, (Board board) {
      final celebrate = board.status == GameStatus.player1Won ||
          (board.status == GameStatus.player2Won &&
              controller.gameMode.value == GameMode.pvp);
      if (!celebrate) {
        _confetti.stop();
        return;
      }
      Future.delayed(const Duration(milliseconds: 550), () {
        if (mounted &&
            identical(controller.board.value, board) &&
            !MediaQuery.disableAnimationsOf(context)) {
          _confetti.play();
        }
      });
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _resultWorker.dispose();
    _confetti.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      controller.pauseGame();
    } else if (!_dialogOpen && controller.isPaused.value) {
      _pause();
    }
  }

  Future<void> _leave() async {
    if (_dialogOpen) return;
    if (controller.isGameOver) {
      _pop();
      return;
    }
    _dialogOpen = true;
    controller.pauseGame();
    final leave = await cfConfirm(context,
        title: 'LEAVE GAME?',
        message: 'This round will not be saved.',
        action: 'LEAVE GAME');
    _dialogOpen = false;
    if (!mounted) return;
    if (leave) {
      _pop();
    } else {
      controller.resumeGame();
    }
  }

  void _pop() {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _restart() async {
    if (_dialogOpen) return;
    _dialogOpen = true;
    controller.pauseGame();
    final restart = await cfConfirm(context,
        title: 'RESTART GAME?',
        message: 'Start a fresh round with the same settings?',
        action: 'RESTART');
    _dialogOpen = false;
    if (restart) controller.resetGame();
    controller.resumeGame();
  }

  Future<void> _pause() async {
    if (_dialogOpen || !mounted) return;
    _dialogOpen = true;
    controller.pauseGame();
    final action = await showDialog<String>(
        context: context,
        builder: (dialogContext) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: CFSurface(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const CFPair(height: 75),
                  Text('GAME PAUSED', style: cfText(27)),
                  const SizedBox(height: 8),
                  Text('Take your time', style: cfText(16)),
                  const SizedBox(height: 22),
                  CFButton(
                      label: 'RESUME',
                      red: true,
                      onTap: () => Navigator.pop(dialogContext, 'resume')),
                  const SizedBox(height: 12),
                  CFButton(
                      label: 'RESTART',
                      onTap: () => Navigator.pop(dialogContext, 'restart')),
                  const SizedBox(height: 12),
                  CFButton(
                      label: 'BACK TO MODES',
                      onTap: () => Navigator.pop(dialogContext, 'leave')),
                ])))));
    _dialogOpen = false;
    if (!mounted) return;
    if (action == 'restart') {
      await _restart();
    } else if (action == 'leave') {
      await _leave();
    } else {
      controller.resumeGame();
    }
  }

  Future<void> _help() async {
    if (_dialogOpen) return;
    _dialogOpen = true;
    controller.pauseGame();
    await Get.to(() => const ConnectFourHelpScreen());
    _dialogOpen = false;
    if (mounted) controller.resumeGame();
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _leave();
      },
      child: CFPage(
          overlay: IgnorePointer(
              child: Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                      confettiController: _confetti,
                      blastDirection: pi / 2,
                      emissionFrequency: .04,
                      numberOfParticles: 8,
                      gravity: .12,
                      colors: const [
                        cfCream,
                        cfRed,
                        Color(0xFFFFCF24),
                        Color(0xFF56A2FF)
                      ]))),
          child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Obx(() {
                final board = controller.board.value;
                final finished =
                    controller.isGameOver && !controller.isAnimating.value;
                final ai = controller.gameMode.value == GameMode.vsAI;
                final settings = Get.find<ConnectFourSettingsController>();
                final mode = ai
                    ? 'VS AI · ${controller.aiDifficulty.value.name.toUpperCase()}'
                    : 'TWO PLAYERS';
                return Column(children: [
                  Row(children: [
                    CFIcon(
                        icon: Icons.arrow_back_rounded,
                        label: 'Back to modes',
                        onTap: _leave),
                    const Spacer(),
                    CFIcon(
                        icon: settings.isSoundEnabled.value
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        label: settings.isSoundEnabled.value
                            ? 'Mute sound'
                            : 'Enable sound',
                        onTap: settings.toggleSound),
                    const SizedBox(width: 10),
                    CFIcon(
                        icon: Icons.pause_rounded,
                        label: 'Pause',
                        onTap: _pause),
                    const SizedBox(width: 10),
                    CFIcon(
                        icon: Icons.restart_alt_rounded,
                        label: 'Restart',
                        onTap: _restart),
                  ]),
                  if (finished) ...[
                    const SizedBox(height: 14),
                    if (board.status == GameStatus.draw)
                      const CFPair(height: 100)
                    else
                      Image.asset(
                          'assets/images/games/memory_match/trophy_v1.png',
                          height: 115,
                          fit: BoxFit.contain),
                    TweenAnimationBuilder<double>(
                        tween: Tween(begin: .85, end: 1),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.elasticOut,
                        builder: (context, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: Text(
                            board.status == GameStatus.draw
                                ? "IT'S A DRAW!"
                                : board.status == GameStatus.player1Won
                                    ? (ai ? 'YOU WIN!' : 'RED WINS!')
                                    : (ai ? 'AI WINS!' : 'YELLOW WINS!'),
                            style: cfText(37, color: cfCream))),
                    Text(
                        board.status == GameStatus.draw
                            ? 'A well-matched round'
                            : 'Four in a row!',
                        style: cfText(21, color: cfCream)),
                  ] else
                    const CFTitle(compact: true),
                  const SizedBox(height: 14),
                  CFSurface(
                      color: const Color(0xFF093B96),
                      radius: 50,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      child: Text(mode, style: cfText(15, color: cfCream))),
                  const SizedBox(height: 18),
                  if (!finished) ...[
                    Row(children: [
                      Expanded(
                          child: _Player(
                              label: ai ? 'YOU' : 'RED',
                              red: true,
                              active: controller.currentPlayer.value ==
                                  CellState.player1)),
                      Expanded(
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                  controller.isPaused.value
                                      ? 'PAUSED'
                                      : controller.isAIThinking.value
                                          ? 'AI THINKING…'
                                          : controller.currentPlayer.value ==
                                                  CellState.player1
                                              ? (ai
                                                  ? 'YOUR TURN'
                                                  : 'RED’S TURN')
                                              : (ai
                                                  ? 'AI’S TURN'
                                                  : 'YELLOW’S TURN'),
                                  textAlign: TextAlign.center,
                                  style: cfText(16, color: cfCream)))),
                      Expanded(
                          child: _Player(
                              label: ai ? 'AI' : 'YELLOW',
                              red: false,
                              active: controller.currentPlayer.value ==
                                  CellState.player2)),
                    ]),
                    const SizedBox(height: 12),
                  ],
                  BoardWidget(controller: controller),
                  const SizedBox(height: 22),
                  if (finished) ...[
                    CFButton(
                        label: 'PLAY AGAIN',
                        red: true,
                        onTap: controller.resetGame),
                    const SizedBox(height: 14),
                    CFButton(label: 'BACK TO MODES', onTap: _pop),
                    if (settings.isAutoRestartEnabled.value) ...[
                      const SizedBox(height: 12),
                      Text('A new round starts automatically',
                          style: cfText(14, color: cfCream))
                    ],
                  ] else ...[
                    Text('Tap a column to drop your disc',
                        style: cfText(16, color: cfCream)),
                    const SizedBox(height: 18),
                    CFButton(
                        label: 'HOW TO PLAY',
                        icon: Icons.menu_book_rounded,
                        onTap: _help),
                  ],
                ]);
              }))));
}

class _Player extends StatelessWidget {
  const _Player({required this.label, required this.red, required this.active});
  final String label;
  final bool red, active;
  @override
  Widget build(BuildContext context) => CFSurface(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      radius: 16,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        CFDisc(red: red, size: 26),
        const SizedBox(width: 4),
        Flexible(
            child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label,
                    maxLines: 1,
                    softWrap: false,
                    style: cfText(16, color: active ? cfRed : cfInk)))),
      ]));
}
