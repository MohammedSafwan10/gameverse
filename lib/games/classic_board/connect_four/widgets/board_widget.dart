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
            _buildCabinetOverlay(cellSize),
            _buildTouchAreas(cellSize),
          ],
        );
      },
    );
  }

  Widget _buildBackground(double cellSize) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildCabinetOverlay(double cellSize) {
    return IgnorePointer(
      child: CustomPaint(
        painter: CabinetPainter(cellSize: cellSize),
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

      return Stack(
        children: [
          for (int row = 0; row < Board.rows; row++)
            for (int col = 0; col < Board.cols; col++)
              if (board.cells[row][col] != CellState.empty)
                TweenAnimationBuilder<double>(
                  key: ValueKey('disc_${row}_${col}_${board.cells[row][col]}'),
                  duration: lastMove?.x == row && lastMove?.y == col
                      ? const Duration(milliseconds: 500)
                      : Duration.zero,
                  curve: Curves.bounceOut,
                  tween: Tween<double>(
                    begin: lastMove?.x == row && lastMove?.y == col
                        ? -cellSize
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
                    child: _buildDisc(board.cells[row][col], cellSize,
                        board.winningCells.contains(Point(row, col))),
                  ),
                ),
        ],
      );
    });
  }

  Widget _buildDisc(CellState state, double cellSize, bool isWinning) {
    final color =
        state == CellState.player1 ? Colors.red : Colors.yellow.shade600;

    return Container(
      width: cellSize * 0.82,
      height: cellSize * 0.82,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 1,
            offset: const Offset(-1, -1),
          ),
        ],
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.3),
            color,
            color.withValues(alpha: 0.8),
          ],
          center: const Alignment(-0.3, -0.3),
          radius: 0.8,
        ),
      ),
    )
        .animate(target: isWinning ? 1 : 0)
        .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 300.ms)
        .then(delay: 200.ms)
        .shimmer(duration: 1000.ms, color: Colors.white.withValues(alpha: 0.4));
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
                  ? null
                  : () {
                      if (controller.board.value.isValidMove(col)) {
                        controller.makeMove(col);
                      } else {
                        HapticFeedback.heavyImpact();
                      }
                    },
              onTapDown: (_) {
                if (isPlayerTurn &&
                    !controller.isAnimating.value &&
                    !controller.isGameOver) {
                  controller.updatePreviewColumn(col);
                  HapticFeedback.selectionClick();
                }
              },
              onTapUp: (_) => controller.clearPreview(),
              onTapCancel: () => controller.clearPreview(),
              child: Container(
                color: Colors.transparent,
                child: Column(
                  children: [
                    const Spacer(),
                    if (controller.previewColumn.value == col &&
                        isPlayerTurn &&
                        !controller.isGameOver)
                      Icon(
                        Icons.arrow_drop_down_circle_rounded,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 32,
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(begin: -5, end: 5, duration: 500.ms),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class CabinetPainter extends CustomPainter {
  final double cellSize;

  CabinetPainter({required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade800
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int row = 0; row < Board.rows; row++) {
      for (int col = 0; col < Board.cols; col++) {
        final center = Offset((col + 0.5) * cellSize, (row + 0.5) * cellSize);
        final radius = cellSize * 0.42;

        // Draw the square part of the cabinet with a hole
        final rect =
            Rect.fromCenter(center: center, width: cellSize, height: cellSize);

        // Complex path for the "punched out" hole effect
        final path = Path()
          ..addRect(rect)
          ..addOval(Rect.fromCircle(center: center, radius: radius))
          ..fillType = PathFillType.evenOdd;

        canvas.drawPath(path, paint);
        canvas.drawOval(
            Rect.fromCircle(center: center, radius: radius), shadowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CabinetPainter oldDelegate) => false;
}
