import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chess_piece.dart';
import 'chess_piece_widget.dart';
import '../controllers/game_controller.dart';

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

  Color _getSquareColor(BuildContext context, String theme) {
    return switch (theme) {
      'classic' => isWhite ? const Color(0xFFF0D9B5) : const Color(0xFFB58863),
      'modern' => isWhite ? const Color(0xFFEBECD0) : const Color(0xFF779556),
      'forest' => isWhite ? const Color(0xFFE2E2BD) : const Color(0xFF4B7399),
      'royal' => isWhite ? const Color(0xFFFFE0B2) : const Color(0xFF7B1FA2),
      'ocean' => isWhite ? const Color(0xFFE0F7FA) : const Color(0xFF006064),
      'sunset' => isWhite ? const Color(0xFFFCE4EC) : const Color(0xFFE64A19),
      _ => isWhite ? const Color(0xFFF0D9B5) : const Color(0xFFB58863),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<ChessGameController>();

    return Obx(() {
      final baseColor = _getSquareColor(context, controller.boardTheme.value);

      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : isLastMove
                    ? theme.colorScheme.secondary.withValues(alpha: 0.4)
                    : baseColor,
          ),
          child: Stack(
            children: [
              // Valid move indicator (empty square)
              if (isValidMove && piece == null)
                Center(
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
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
                        color: Colors.black.withValues(alpha: 0.15),
                        width: 4,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

              // Chess piece
              if (piece != null)
                Center(
                  child: ChessPieceWidget(
                    piece: piece!,
                    size: 40,
                    isSelected: isSelected,
                    isAnimated: true,
                  ),
                ),

              // Check indicator
              if (isCheck)
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.red.withValues(alpha: 0.8),
                        Colors.red.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
