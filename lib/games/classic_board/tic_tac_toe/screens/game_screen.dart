import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../controllers/stats_controller.dart';
import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../widgets/tactile_ui.dart';

class TicTacToeGameScreen extends StatefulWidget {
  const TicTacToeGameScreen({super.key});
  @override
  State<TicTacToeGameScreen> createState() => _TicTacToeGameScreenState();
}

class _TicTacToeGameScreenState extends State<TicTacToeGameScreen>
    with WidgetsBindingObserver {
  final controller = Get.find<TicTacToeGameController>();
  bool dialogOpen = false;
  bool helpOpen = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    controller.setSuspended(
        state != AppLifecycleState.resumed || dialogOpen || helpOpen);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _leave() async {
    if (dialogOpen) return;
    dialogOpen = true;
    controller.setSuspended(true);
    final leave = controller.isGameOver ||
        await tactileConfirm(context,
            title: 'LEAVE GAME?',
            message: 'Your current round will be lost.',
            action: 'LEAVE GAME',
            leave: true);
    dialogOpen = false;
    if (!mounted) return;
    if (leave) {
      controller.resetGame();
      Get.back();
    } else {
      controller.setSuspended(false);
    }
  }

  Future<void> _restart() async {
    if (dialogOpen) return;
    dialogOpen = true;
    controller.setSuspended(true);
    final restart = await tactileConfirm(context,
        title: 'RESTART GAME?',
        message: 'Start this round again?',
        action: 'RESTART');
    dialogOpen = false;
    if (!mounted) return;
    if (restart) {
      controller.resetGame();
    } else {
      controller.setSuspended(false);
    }
  }

  Future<void> _help() async {
    helpOpen = true;
    controller.setSuspended(true);
    await Navigator.push(context,
        MaterialPageRoute<void>(builder: (_) => const TactileHelpPage()));
    helpOpen = false;
    if (mounted) controller.setSuspended(false);
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _leave();
        },
        child: TactilePage(
            builder: (context, constraints) => Obx(() {
                  final s = controller.gameState;
                  final compact = constraints.maxHeight < 650;
                  final over = s.isGameOver;
                  final local = s.settings.gameMode == GameMode.multiPlayer;
                  final draw = s.status == GameStatus.draw;
                  final winnerTitle = draw
                      ? "IT'S A DRAW"
                      : local
                          ? 'PLAYER ${s.winner == Player.x ? 1 : 2} WINS!'
                          : s.winner == Player.x
                              ? 'YOU WIN!'
                              : 'AI WINS';
                  final stats = Get.find<TicTacToeStatsController>();
                  final available = constraints.maxWidth.clamp(0.0, 560.0) - 36;
                  final boardSize = math.min(
                      available,
                      math.max(
                          210.0, constraints.maxHeight - (over ? 350 : 355)));
                  return SingleChildScrollView(
                      padding: const EdgeInsets.all(18),
                      child: Column(children: [
                        Row(children: [
                          TactileIcon(Icons.arrow_back_rounded,
                              label: 'Leave game', onPressed: _leave),
                          const Spacer(),
                          TactileIcon(
                              s.settings.soundEnabled
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_off_rounded,
                              label: 'Toggle sound',
                              onPressed: controller.toggleSound),
                          const SizedBox(width: 10),
                          TactileIcon(Icons.restart_alt_rounded,
                              label: 'Restart game', onPressed: _restart)
                        ]),
                        SizedBox(height: compact ? 8 : 12),
                        if (over) ...[
                          if (!draw && (local || s.winner == Player.x))
                            Image.asset(
                                'assets/images/games/memory_match/trophy_v1.png',
                                height: compact ? 55 : 80),
                          TactileTitle(winnerTitle,
                              size: compact ? 40 : 52,
                              color: draw ? tttInk : tttOrange),
                          const SizedBox(height: 4),
                          Text(
                              draw
                                  ? 'A well-matched round'
                                  : s.winner == Player.o && !local
                                      ? 'Try a different strategy'
                                      : 'Three in a row',
                              style: tttText(17)),
                        ] else ...[
                          TactileGameTitle(size: compact ? 38 : 48),
                          const SizedBox(height: 8),
                          TactileSurface(
                              color: tttOrange,
                              radius: 30,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 5),
                              child: Text(
                                  local
                                      ? 'TWO PLAYERS'
                                      : 'VS AI · ${s.settings.difficulty.displayName.toUpperCase()}',
                                  style: tttText(19,
                                      heavy: true, color: Colors.white))),
                          const SizedBox(height: 14),
                          Row(children: [
                            Expanded(
                                child: _player(
                                    Player.x,
                                    local ? 'PLAYER 1' : 'YOU',
                                    local
                                        ? stats.player1Wins
                                        : stats.getWinsForDifficulty(
                                            s.settings.difficulty),
                                    compact)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _player(
                                    Player.o,
                                    local ? 'PLAYER 2' : 'AI',
                                    local
                                        ? stats.player2Wins
                                        : stats.getLossesForDifficulty(
                                            s.settings.difficulty),
                                    compact)),
                          ]),
                          const SizedBox(height: 14),
                          TactileSurface(
                              color: s.currentPlayer == Player.x
                                  ? tttOrange
                                  : tttBlue,
                              radius: 30,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 6),
                              child: Text(
                                  controller.isThinking
                                      ? 'AI IS THINKING…'
                                      : local
                                          ? 'PLAYER ${s.currentPlayer == Player.x ? 1 : 2}’S TURN'
                                          : 'YOUR TURN',
                                  style: tttText(23,
                                      heavy: true, color: Colors.white))),
                        ],
                        SizedBox(height: compact ? 14 : 20),
                        SizedBox(
                            width: boardSize,
                            child: TactileBoard(
                                board: s.board,
                                winningLine: s.winningLine,
                                enabled: !over &&
                                    !controller.isThinking &&
                                    !controller.isSuspended &&
                                    (local || s.currentPlayer == Player.x),
                                onMove: controller.makeMove)),
                        SizedBox(height: compact ? 16 : 24),
                        if (over) ...[
                          if (s.settings.autoRestart)
                            Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                    'Next round in ${controller.countdown.value}',
                                    style: tttText(15))),
                          TactileButton('PLAY AGAIN',
                              primary: true,
                              icon: Icons.restart_alt_rounded,
                              onPressed: controller.resetGame),
                          const SizedBox(height: 14),
                          TactileButton('BACK TO MODES',
                              icon: Icons.arrow_back_rounded,
                              onPressed: _leave),
                        ] else ...[
                          Text(
                              controller.isThinking
                                  ? 'Your opponent is choosing a move'
                                  : 'Place an ${s.currentPlayer.symbol} in an empty square',
                              textAlign: TextAlign.center,
                              style: tttText(16)),
                          const SizedBox(height: 18),
                          TactileButton('HOW TO PLAY',
                              icon: Icons.menu_book_rounded, onPressed: _help),
                        ],
                        const SizedBox(height: 8),
                      ]));
                })),
      );
  Widget _player(Player p, String label, int wins, bool compact) =>
      TactileSurface(
          padding: EdgeInsets.all(compact ? 8 : 12),
          child: Row(children: [
            TactilePiece(p, size: compact ? 39 : 54),
            const SizedBox(width: 8),
            Expanded(
                child: Column(children: [
              Text(label, style: tttText(18, heavy: true)),
              Text('$wins', style: tttText(compact ? 28 : 36, heavy: true))
            ]))
          ]));
}
