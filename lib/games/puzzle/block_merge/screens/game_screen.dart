import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/resin_ui.dart';
import 'support_screens.dart';
import 'settings_screen.dart';

class BlockMergeGameScreen extends StatefulWidget {
  const BlockMergeGameScreen({super.key});
  @override
  State<BlockMergeGameScreen> createState() => _BlockMergeGameScreenState();
}

class _BlockMergeGameScreenState extends State<BlockMergeGameScreen>
    with WidgetsBindingObserver {
  late final BlockMergeController game;
  late final BlockMergeSettingsController settings;
  final ConfettiController confetti =
      ConfettiController(duration: const Duration(seconds: 2));
  Worker? worker;
  Offset drag = Offset.zero;
  bool resultShowing = false, navigating = false, lifecyclePause = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    game = Get.find<BlockMergeController>();
    settings = game.settings;
    game.setPaused(false);
    worker = ever(game.gameState, (_) => _scheduleResult());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (settings.showTutorial.value) {
        game.setPaused(true);
        await Get.to(() => const BlockMergeHelpScreen());
        if (!mounted) return;
        settings.setShowTutorial(false);
        game.setPaused(false);
      }
      _scheduleResult();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      if (!game.isPaused.value) {
        lifecyclePause = true;
        game.setPaused(true);
      }
    } else if (lifecyclePause && !navigating) {
      lifecyclePause = false;
      game.setPaused(false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    worker?.dispose();
    confetti.dispose();
    game.setPaused(true);
    super.dispose();
  }

  Future<void> leave() async {
    if (navigating) return;
    navigating = true;
    final paused = game.isPaused.value;
    game.setPaused(true);
    final exit = await resinConfirm(
        context,
        'LEAVE THIS GAME?',
        'Return to mode selection? Your current board is saved on this device.',
        'LEAVE',
        icon: Icons.exit_to_app_rounded,
        art: 'leave');
    if (!mounted) return;
    if (exit) {
      Navigator.of(context).pop();
    } else {
      navigating = false;
      game.setPaused(paused);
    }
  }

  Future<void> restart() async {
    final paused = game.isPaused.value;
    game.setPaused(true);
    if (await resinConfirm(context, 'START AGAIN?',
        'Your current board will be cleared. Your best score stays.', 'RESTART',
        art: 'restart')) {
      game.newGame();
    } else {
      game.setPaused(paused);
    }
  }

  Future<void> pause() async {
    game.setPaused(true);
    final action = await showDialog<String>(
        context: context,
        builder: (c) =>
            _dialog(Column(mainAxisSize: MainAxisSize.min, children: [
              const ResinArt('pause', height: 110),
              const SizedBox(height: 12),
              Text('GAME PAUSED', style: resinText(30)),
              const SizedBox(height: 8),
              Text('Take a breath. Your board is waiting.',
                  style: resinText(15)),
              const SizedBox(height: 20),
              _scores(),
              const SizedBox(height: 20),
              ResinButton('RESUME', onTap: () => Navigator.pop(c)),
              const SizedBox(height: 10),
              ResinButton('RESTART',
                  color: resinMint, onTap: () => Navigator.pop(c, 'restart')),
              const SizedBox(height: 10),
              ResinButton('BACK TO MODES',
                  color: resinLilac, onTap: () => Navigator.pop(c, 'leave')),
            ])));
    if (!mounted) return;
    if (action == 'restart') {
      await restart();
    } else if (action == 'leave') {
      await leave();
    }
    if (mounted && !navigating) game.setPaused(false);
  }

  Widget _dialog(Widget child) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(22),
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ResinSurface(child: SingleChildScrollView(child: child))));
  Widget _scores() => Row(children: [
        Expanded(child: ResinStat('SCORE', '${game.score.value}')),
        const SizedBox(width: 12),
        Expanded(child: ResinStat('BEST', '${settings.bestScore.value}')),
      ]);
  void _scheduleResult() {
    if (!mounted ||
        resultShowing ||
        navigating ||
        (!game.hasWon.value && !game.isGameOver.value)) {
      return;
    }
    resultShowing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final won = game.hasWon.value, expired = game.expired;
      if (won && !MediaQuery.of(context).disableAnimations) confetti.play();
      await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (c) => PopScope(
              canPop: false,
              child: _dialog(Column(mainAxisSize: MainAxisSize.min, children: [
                ResinArt(
                    won
                        ? 'trophy'
                        : expired
                            ? 'clock'
                            : 'objects',
                    height: 110),
                Text(
                    won
                        ? '2048!'
                        : expired
                            ? 'TIME’S UP'
                            : 'NO MOVES LEFT',
                    style: resinText(31),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                    won
                        ? 'You made the tile.'
                        : expired
                            ? 'Great run. Ready for another?'
                            : 'A fresh board awaits.',
                    style: resinText(16),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(modeName(settings.gameMode.value), style: resinText(15)),
                const SizedBox(height: 14),
                if (won)
                  const SizedBox.square(dimension: 74, child: ResinTile(2048))
                else
                  SizedBox(width: 155, child: ResinBoard(game.grid.value)),
                const SizedBox(height: 16),
                _scores(),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child:
                          ResinStat('MOVES', '${game.gameState.value.moves}')),
                  const SizedBox(width: 12),
                  Expanded(child: ResinStat('HIGHEST', '${game.highest}'))
                ]),
                const SizedBox(height: 12),
                Text(
                    'TIME  ${clockText(game.gameState.value.playTime.inSeconds)}',
                    style: resinText(15)),
                const SizedBox(height: 18),
                if (won) ...[
                  ResinButton('KEEP PLAYING', onTap: () {
                    game.continueAfterWin();
                    Navigator.pop(c);
                  }),
                  const SizedBox(height: 10)
                ],
                ResinButton(won || expired ? 'PLAY AGAIN' : 'TRY AGAIN',
                    color: won ? resinMint : resinCoral, onTap: () {
                  game.newGame();
                  Navigator.pop(c);
                }),
                if (!won && !expired && game.canUndo) ...[
                  const SizedBox(height: 10),
                  ResinButton('UNDO LAST MOVE', color: resinMint, onTap: () {
                    game.undo();
                    Navigator.pop(c);
                  })
                ],
                const SizedBox(height: 10),
                ResinButton('BACK TO MODES', color: resinLilac, onTap: () {
                  navigating = true;
                  Navigator.pop(c);
                  Navigator.of(context).pop();
                }),
              ]))));
      resultShowing = false;
      if (mounted) _scheduleResult();
    });
  }

  void _swipe() {
    if (drag.distance < 20) return;
    if (drag.dx.abs() > drag.dy.abs()) {
      drag.dx > 0 ? game.moveRight() : game.moveLeft();
    } else {
      drag.dy > 0 ? game.moveDown() : game.moveUp();
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: navigating,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) leave();
      },
      child: ResinPage(
          child: Stack(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: ResinViewport(
                builder: (context, box) => Obx(() {
                      final timed = settings.gameMode.value ==
                          BlockMergeMode.timeChallenge;
                      final boardSize = math.min(box.maxWidth,
                          math.max(160.0, box.maxHeight - (timed ? 328 : 278)));
                      return Column(children: [
                        ResinHeader('BLOCK MERGE', back: leave, actions: [
                          ResinIcon(
                              settings.soundEnabled.value
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_off_rounded,
                              label: 'Toggle sound',
                              onTap: () => settings.setSoundEnabled(
                                  !settings.soundEnabled.value)),
                          const SizedBox(width: 5),
                          ResinIcon(Icons.pause_rounded,
                              label: 'Pause', onTap: pause),
                        ]),
                        const SizedBox(height: 8),
                        Text(modeName(settings.gameMode.value),
                            style: resinText(16)),
                        const SizedBox(height: 12),
                        _scores(),
                        if (timed) ...[
                          const SizedBox(height: 10),
                          ResinSurface(
                              color: resinMint,
                              padding: const EdgeInsets.all(8),
                              child: Row(children: [
                                const Icon(Icons.timer_outlined,
                                    color: resinInk),
                                const SizedBox(width: 10),
                                Text(clockText(game.timeRemaining.value),
                                    style: resinText(21)),
                                const SizedBox(width: 14),
                                Expanded(
                                    child: LinearProgressIndicator(
                                        value: game.timeRemaining.value / 180,
                                        color: resinInk,
                                        backgroundColor: Colors.white,
                                        minHeight: 7)),
                              ]))
                        ],
                        const Spacer(),
                        GestureDetector(
                            onPanStart: (_) => drag = Offset.zero,
                            onPanUpdate: (d) => drag += d.delta,
                            onPanEnd: (_) => _swipe(),
                            child: SizedBox.square(
                                dimension: boardSize,
                                child: ResinBoard(game.grid.value,
                                    motion: game.motion.value))),
                        const Spacer(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text('MOVES  ${game.gameState.value.moves}',
                                  style: resinText(14)),
                              Text('HIGHEST  ${game.highest}',
                                  style: resinText(14)),
                            ]),
                        const SizedBox(height: 14),
                        Row(children: [
                          Expanded(
                              child: ResinButton('UNDO',
                                  color: resinMint,
                                  icon: Icons.undo_rounded,
                                  onTap: game.canUndo ? game.undo : null)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: ResinButton('RESTART',
                                  icon: Icons.restart_alt_rounded,
                                  onTap: restart))
                        ]),
                        const SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Swipe to merge',
                                  style:
                                      resinText(13, weight: FontWeight.w600)),
                              const SizedBox(width: 12),
                              InkWell(
                                  onTap: () async {
                                    game.setPaused(true);
                                    await Get.to(
                                        () => const BlockMergeSettingsScreen());
                                    if (mounted) game.setPaused(false);
                                  },
                                  child: Text('OPTIONS', style: resinText(13))),
                            ]),
                      ]);
                    }))),
        Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
                confettiController: confetti,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 12,
                emissionFrequency: .04,
                colors: const [resinCoral, resinMint, resinLilac],
                shouldLoop: false)),
      ])));
}
