import 'dart:math' show Point;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/game_controller.dart';
import '../models/board.dart';

class BoardWidget extends StatelessWidget {
  final ConnectFourController controller;

  const BoardWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth / Board.cols;
        return Stack(
          children: [
            _buildBackground(cellSize),
            _buildDiscs(cellSize),
            _buildTouchAreas(cellSize),
            _buildDropPreview(cellSize),
          ],
        );
      },
    );
  }

  Widget _buildBackground(double cellSize) {
    return Container(
      color: Get.theme.colorScheme.primary.withValues(
        red: Get.theme.colorScheme.primary.r.toDouble(),
        green: Get.theme.colorScheme.primary.g.toDouble(),
        blue: Get.theme.colorScheme.primary.b.toDouble(),
        alpha: 0.1,
      ),
      child: CustomPaint(
        painter: BoardPainter(cellSize: cellSize),
        child: AspectRatio(
          aspectRatio: Board.cols / Board.rows,
          child: Container(),
        ),
      ),
    );
  }

  Widget _buildDiscs(double cellSize) {
    return Obx(() {
      final board = controller.board.value;
      final lastMove = controller.lastMove.value;
      final previewCol = controller.previewColumn.value;
      final isPlayerTurn = controller.gameMode.value == GameMode.pvp ||
          controller.currentPlayer.value == CellState.player1;

      return Stack(
        children: [
          // Preview disc - only show for player's turn
          if (previewCol != null &&
              !controller.isGameOver &&
              !controller.isAnimating.value &&
              !controller.isAIThinking.value &&
              isPlayerTurn &&
              controller.board.value.isValidMove(previewCol))
            Positioned(
              left: previewCol * cellSize,
              top: 0,
              width: cellSize,
              height: cellSize,
              child: Center(
                child: Container(
                  width: cellSize * 0.8,
                  height: cellSize * 0.8,
                  decoration: BoxDecoration(
                    color: _getDiscColor(controller.currentPlayer.value)
                        .withValues(
                      red: _getDiscColor(controller.currentPlayer.value)
                          .r
                          .toDouble(),
                      green: _getDiscColor(controller.currentPlayer.value)
                          .g
                          .toDouble(),
                      blue: _getDiscColor(controller.currentPlayer.value)
                          .b
                          .toDouble(),
                      alpha: 0.3,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          red: 0.0,
                          green: 0.0,
                          blue: 0.0,
                          alpha: 0.2,
                        ),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ),
            ).animate().fade(duration: const Duration(milliseconds: 200)),

          // AI thinking indicator
          if (controller.isAIThinking.value &&
              !controller.isAnimating.value &&
              !controller.isGameOver)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.primary.withValues(
                      red: Get.theme.colorScheme.primary.r.toDouble(),
                      green: Get.theme.colorScheme.primary.g.toDouble(),
                      blue: Get.theme.colorScheme.primary.b.toDouble(),
                      alpha: 0.8,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(right: 8),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const Text(
                        "AI is thinking...",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 200)),

          // Actual discs
          for (int row = 0; row < Board.rows; row++)
            for (int col = 0; col < Board.cols; col++)
              if (board.cells[row][col] != CellState.empty)
                TweenAnimationBuilder<double>(
                  duration: lastMove?.x == row && lastMove?.y == col
                      ? const Duration(
                          milliseconds:
                              400) // Faster animation for better responsiveness
                      : Duration.zero,
                  curve: Curves.bounceOut,
                  tween: Tween<double>(
                    begin: lastMove?.x == row && lastMove?.y == col
                        ? -cellSize *
                            2 // Start from higher for a more dramatic bounce
                        : row * cellSize,
                    end: row * cellSize,
                  ),
                  builder: (context, value, child) {
                    return Positioned(
                      left: col * cellSize,
                      top: value,
                      width: cellSize,
                      height: cellSize,
                      child: child!,
                    );
                  },
                  child: Center(
                    child: Container(
                      width: cellSize * 0.8,
                      height: cellSize * 0.8,
                      decoration: BoxDecoration(
                        color: _getDiscColor(board.cells[row][col]),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                        gradient: RadialGradient(
                          colors: [
                            _getDiscColor(board.cells[row][col]).withValues(
                              red: _getDiscColor(board.cells[row][col])
                                      .r
                                      .toDouble() +
                                  0.2,
                              green: _getDiscColor(board.cells[row][col])
                                      .g
                                      .toDouble() +
                                  0.2,
                              blue: _getDiscColor(board.cells[row][col])
                                      .b
                                      .toDouble() +
                                  0.2,
                              alpha: 1.0,
                            ),
                            _getDiscColor(board.cells[row][col]),
                          ],
                          center: const Alignment(-0.3, -0.3),
                          radius: 0.8,
                        ),
                      ),
                    )
                        .animate(
                          target: board.winningCells.contains(Point(row, col))
                              ? 1
                              : 0,
                        )
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                          duration: const Duration(milliseconds: 300),
                        )
                        .then()
                        .custom(
                          begin: 0.0,
                          end: board.winningCells.contains(Point(row, col))
                              ? 1.0
                              : 0.0,
                          duration: const Duration(milliseconds: 1000),
                          builder: (_, value, child) => ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                _getDiscColor(board.cells[row][col]),
                                Colors.white,
                                _getDiscColor(board.cells[row][col]),
                              ],
                              stops: [0.0, value, 1.0],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: child,
                          ),
                        ),
                  ),
                  onEnd: () {
                    if (lastMove?.x == row && lastMove?.y == col) {
                      controller.isAnimating.value = false;
                    }
                  },
                ),
        ],
      );
    });
  }

  Widget _buildDropPreview(double cellSize) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Row(
        children: List.generate(
          Board.cols,
          (col) => MouseRegion(
            onEnter: (_) => controller.updatePreviewColumn(col),
            onExit: (_) => controller.clearPreview(),
            child: Container(
              width: cellSize,
              height: cellSize,
              color: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTouchAreas(double cellSize) {
    return Obx(() {
      final isPlayerTurn = controller.gameMode.value == GameMode.pvp ||
          controller.currentPlayer.value == CellState.player1;

      return Row(
        children: List.generate(
          Board.cols,
          (col) => Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: (!isPlayerTurn ||
                      controller.isAnimating.value ||
                      controller.isGameOver ||
                      controller.isAIThinking.value)
                  ? null // Disable when not player's turn or game is in transition
                  : () {
                      if (controller.board.value.isValidMove(col)) {
                        controller.makeMove(col);
                      } else {
                        // Provide feedback for invalid move
                        HapticFeedback.heavyImpact();
                      }
                    },
              onTapDown: (_) {
                if (isPlayerTurn &&
                    !controller.isAnimating.value &&
                    !controller.isGameOver &&
                    !controller.isAIThinking.value) {
                  controller.updatePreviewColumn(col);
                  if (controller.board.value.isValidMove(col)) {
                    HapticFeedback.selectionClick();
                  }
                }
              },
              onTapUp: (_) {
                controller.clearPreview();
              },
              onTapCancel: () {
                controller.clearPreview();
              },
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: controller.previewColumn.value == col &&
                          isPlayerTurn &&
                          !controller.isAnimating.value &&
                          !controller.isGameOver
                      ? Border(
                          top: BorderSide(
                            color: controller.board.value.isValidMove(col)
                                ? _getDiscColor(controller.currentPlayer.value)
                                    .withValues(
                                    red: _getDiscColor(
                                            controller.currentPlayer.value)
                                        .r
                                        .toDouble(),
                                    green: _getDiscColor(
                                            controller.currentPlayer.value)
                                        .g
                                        .toDouble(),
                                    blue: _getDiscColor(
                                            controller.currentPlayer.value)
                                        .b
                                        .toDouble(),
                                    alpha: 0.7,
                                  )
                                : Colors.grey.withValues(
                                    red: Colors.grey.r.toDouble(),
                                    green: Colors.grey.g.toDouble(),
                                    blue: Colors.grey.b.toDouble(),
                                    alpha: 0.5,
                                  ),
                            width: 5,
                          ),
                        )
                      : null,
                ),
                child: controller.previewColumn.value == col &&
                        isPlayerTurn &&
                        !controller.isAnimating.value &&
                        !controller.isGameOver
                    ? Icon(
                        Icons.arrow_downward,
                        color: controller.board.value.isValidMove(col)
                            ? _getDiscColor(controller.currentPlayer.value)
                                .withValues(
                                red: _getDiscColor(
                                        controller.currentPlayer.value)
                                    .r
                                    .toDouble(),
                                green: _getDiscColor(
                                        controller.currentPlayer.value)
                                    .g
                                    .toDouble(),
                                blue: _getDiscColor(
                                        controller.currentPlayer.value)
                                    .b
                                    .toDouble(),
                                alpha: 0.7,
                              )
                            : Colors.grey.withValues(
                                red: Colors.grey.r.toDouble(),
                                green: Colors.grey.g.toDouble(),
                                blue: Colors.grey.b.toDouble(),
                                alpha: 0.5,
                              ),
                        size: 24,
                      )
                    : null,
              ),
            ),
          ),
        ),
      );
    });
  }

  Color _getDiscColor(CellState state) {
    switch (state) {
      case CellState.player1:
        return Colors.red;
      case CellState.player2:
        return Colors.yellow;
      default:
        return Colors.transparent;
    }
  }
}

class BoardPainter extends CustomPainter {
  final double cellSize;

  BoardPainter({required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Draw board background
    canvas.drawRect(Offset.zero & size, paint);

    // Draw holes
    final holePaint = Paint()
      ..color = Colors.white.withValues(
        red: 1.0,
        green: 1.0,
        blue: 1.0,
        alpha: 0.9,
      )
      ..style = PaintingStyle.fill;

    for (int row = 0; row < Board.rows; row++) {
      for (int col = 0; col < Board.cols; col++) {
        final center = Offset(
          (col + 0.5) * cellSize,
          (row + 0.5) * cellSize,
        );
        canvas.drawCircle(center, cellSize * 0.35, holePaint);
      }
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) => false;
}
