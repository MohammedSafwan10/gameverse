import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/chess_piece.dart';
import 'chess_piece_widget.dart';
import '../controllers/game_controller.dart';
import '../theme/chess_design.dart';

class ChessSquareWidget extends StatelessWidget {
  final bool isWhite;
  final String position;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final bool isLastMove;
  final bool isCheck;
  final VoidCallback onTap;

  const ChessSquareWidget({
    super.key,
    required this.isWhite,
    required this.position,
    required this.piece,
    required this.isSelected,
    required this.isValidMove,
    required this.isLastMove,
    this.isCheck = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChessGameController>();

    return Obx(() {
      final palette = ChessBoardPalette.fromId(controller.boardTheme.value);
      final baseColor = isWhite ? palette.light : palette.dark;
      final accentColor = palette.accent;

      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.6)
                : isLastMove
                    ? accentColor.withValues(alpha: 0.3)
                    : baseColor,
            border: isSelected
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.5), width: 2)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Valid move indicator (empty square)
              if (isValidMove && piece == null)
                Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.2),
                          blurRadius: 4,
                        )
                      ],
                    ),
                  ),
                ),

              // Valid move indicator (capture)
              if (isValidMove && piece != null)
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.6),
                        width: 3,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

              // Chess piece
              if (piece != null)
                Positioned.fill(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Center(
                      child: ChessPieceWidget(
                        piece: piece!,
                        size: constraints.maxWidth * 1.08,
                        isSelected: isSelected,
                        isAnimated: false,
                      ),
                    );
                  }),
                ),

              // Check indicator
              if (isCheck)
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.redAccent.withValues(alpha: 0.8),
                        Colors.redAccent.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(duration: 1000.ms),
            ],
          ),
        ),
      );
    });
  }
}
