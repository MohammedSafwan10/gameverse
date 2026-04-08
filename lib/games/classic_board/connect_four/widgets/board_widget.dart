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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade900,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
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
        state == CellState.player1 ? Colors.redAccent : Colors.amber.shade400;

    final darkColor = state == CellState.player1
        ? Colors.red.shade900
        : Colors.orange.shade800;

    return Container(
      width: cellSize * 0.82,
      height: cellSize * 0.82,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          // Deep drop shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
          // Inner glow
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(-2, -2),
          ),
        ],
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.8),
            color,
            darkColor,
          ],
          stops: const [0.0, 0.5, 1.0],
          center: const Alignment(-0.3, -0.3),
          radius: 0.8,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.4),
              Colors.transparent,
              darkColor.withValues(alpha: 0.4),
            ],
          ),
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
    // Semi-transparent blue for the cabinet
    final paint = Paint()
      ..color = Colors.blue.shade800.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    // Inner shadow for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Highlight for 3D effect
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int row = 0; row < Board.rows; row++) {
      for (int col = 0; col < Board.cols; col++) {
        final center = Offset((col + 0.5) * cellSize, (row + 0.5) * cellSize);
        final radius = cellSize * 0.42;

        final rect =
            Rect.fromCenter(center: center, width: cellSize, height: cellSize);

        // Complex path for the "punched out" hole effect
        final path = Path()
          ..addRect(rect)
          ..addOval(Rect.fromCircle(center: center, radius: radius))
          ..fillType = PathFillType.evenOdd;

        canvas.drawPath(path, paint);

        // Draw inner dark shadow ring
        canvas.drawOval(
            Rect.fromCircle(center: center, radius: radius), shadowPaint);

        // Draw light highlight slightly offset
        canvas.drawArc(
            Rect.fromCircle(
                center: Offset(center.dx - 1, center.dy - 1),
                radius: radius + 1),
            3.14,
            3.14,
            false,
            highlightPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CabinetPainter oldDelegate) => false;
}
