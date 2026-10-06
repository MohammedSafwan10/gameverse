import 'dart:math' show Point;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../models/board.dart';
import 'arcade_ui.dart';

/// The entire column is tappable; rendering and collision use the same cell grid.
class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key, required this.controller});
  final ConnectFourController controller;
  @override
  Widget build(BuildContext context) => Obx(() => ConnectFourBoard(
      board: controller.board.value,
      lastMove: controller.lastMove.value,
      animating: controller.isAnimating.value,
      paused: controller.isPaused.value,
      onColumn: controller.isPaused.value ||
              controller.isGameOver ||
              controller.isAnimating.value ||
              controller.isAIThinking.value ||
              (controller.gameMode.value == GameMode.vsAI &&
                  controller.currentPlayer.value == CellState.player2)
          ? null
          : (c) => controller.makeMove(c)));
}

class ConnectFourBoard extends StatelessWidget {
  const ConnectFourBoard(
      {super.key,
      required this.board,
      this.lastMove,
      this.animating = false,
      this.paused = false,
      this.onColumn});
  final Board board;
  final Point<int>? lastMove;
  final bool animating, paused;
  final ValueChanged<int>? onColumn;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final cell = (box.maxWidth - 32) / 7;
        final height = cell * 6;
        return Column(children: [
          if (board.status == GameStatus.playing)
            Row(children: [
              const SizedBox(width: 12),
              for (var c = 0; c < 7; c++)
                Expanded(
                    child: Semantics(
                        label: 'Drop in column ${c + 1}',
                        button: true,
                        child: IconButton(
                            key: ValueKey('cf-column-$c'),
                            padding: EdgeInsets.zero,
                            onPressed: onColumn != null && board.isValidMove(c)
                                ? () => onColumn!(c)
                                : null,
                            icon: Icon(Icons.arrow_downward_rounded,
                                color: board.isValidMove(c)
                                    ? cfCream
                                    : cfCream.withValues(alpha: .25),
                                size: 22)))),
              const SizedBox(width: 12),
            ]),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1974F5),
                        Color(0xFF004CCA),
                        Color(0xFF002E94)
                      ]),
                  border: Border.all(color: cfCream, width: 6),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: .35),
                        offset: const Offset(0, 6),
                        blurRadius: 12)
                  ]),
              child: SizedBox(
                  height: height,
                  child: ClipRect(
                      child: TickerMode(
                          enabled: !paused,
                          child: Stack(children: [
                            for (var r = 0; r < 6; r++)
                              for (var c = 0; c < 7; c++)
                                Positioned(
                                    left: c * cell,
                                    top: r * cell,
                                    width: cell,
                                    height: cell,
                                    child: Padding(
                                        padding: EdgeInsets.all(cell * .07),
                                        child: Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: const RadialGradient(
                                                    center: Alignment(.25, .3),
                                                    colors: [
                                                      Color(0xFF0950BC),
                                                      Color(0xFF002B80),
                                                      Color(0xFF001B5D)
                                                    ],
                                                    stops: [
                                                      0,
                                                      .72,
                                                      1
                                                    ]),
                                                border: Border.all(
                                                    color:
                                                        const Color(0xFF5296FF),
                                                    width: 1.5)),
                                            child: board.cells[r][c] ==
                                                    CellState.empty
                                                ? null
                                                : _Token(
                                                    key: ValueKey(
                                                        '${board.cells[r][c]}-$r-$c'),
                                                    red: board.cells[r][c] ==
                                                        CellState.player1,
                                                    winning: board.winningCells.contains(Point(r, c)),
                                                    distance: animating && lastMove == Point(r, c) ? -(r + 1) * cell : 0)))),
                            if (onColumn != null)
                              for (var c = 0; c < 7; c++)
                                Positioned(
                                    left: c * cell,
                                    top: 0,
                                    width: cell,
                                    height: height,
                                    child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                            onTap: board.isValidMove(c)
                                                ? () => onColumn!(c)
                                                : null,
                                            child: Semantics(
                                                label: 'Column ${c + 1}',
                                                button: true,
                                                child:
                                                    const SizedBox.expand())))),
                          ]))))),
          Container(
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                  color: const Color(0xFF002E89),
                  borderRadius: BorderRadius.circular(8))),
        ]);
      });
}

class _Token extends StatelessWidget {
  const _Token(
      {super.key,
      required this.red,
      required this.winning,
      required this.distance});
  final bool red, winning;
  final double distance;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
      tween: Tween(begin: distance, end: 0),
      duration: const Duration(milliseconds: 480),
      curve: Curves.bounceOut,
      builder: (context, dy, child) =>
          Transform.translate(offset: Offset(0, dy), child: child),
      child: Container(
          decoration: winning
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: cfCream, width: 3),
                  boxShadow: const [
                      BoxShadow(color: Color(0xFFFFD260), blurRadius: 10)
                    ])
              : null,
          child: Image.asset('$cfAssets${red ? 'red' : 'yellow'}-disc.png',
              fit: BoxFit.contain, excludeFromSemantics: true)));
}
