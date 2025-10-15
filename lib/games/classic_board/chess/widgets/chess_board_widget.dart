import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../models/chess_piece.dart';
import 'chess_square.dart';

class ChessBoardWidget extends GetView<ChessGameController> {
  const ChessBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                red: 0.0,
                green: 0.0,
                blue: 0.0,
                alpha: 0.2,
              ),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Board squares
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemCount: 64,
                itemBuilder: (context, index) {
                  final row =
                      7 - (index ~/ 8); // Flip board for white's perspective
                  final col = index % 8;
                  final isWhiteSquare = (row + col) % 2 == 0;
                  final position =
                      ChessPiece.coordinatesToNotation(7 - row, col);

                  return Obx(() {
                    final piece = controller.board.getPieceAt(position);
                    final isSelected =
                        controller.selectedPiece.value?.position == position;
                    final isValidMove =
                        controller.selectedPiece.value != null &&
                            controller.board
                                .getValidMoves(
                                    controller.selectedPiece.value!.position)
                                .contains(position);
                    final isLastMove = controller.lastMove.value != null &&
                        (controller.lastMove.value!.$1 == position ||
                            controller.lastMove.value!.$2 == position);
                    final isCheck =
                        controller.gameState.value == ChessGameState.check &&
                            piece?.type == PieceType.king &&
                            piece?.color ==
                                (controller.isWhiteTurn.value
                                    ? PieceColor.white
                                    : PieceColor.black);

                    return ChessSquareWidget(
                      isWhite: isWhiteSquare,
                      position: position,
                      piece: piece,
                      isSelected: isSelected,
                      isValidMove:
                          isValidMove && controller.showLegalMoves.value,
                      isLastMove: isLastMove && controller.showLastMove.value,
                      isCheck: isCheck,
                      onTap: () => _handleSquareTap(position),
                    );
                  });
                },
              ),

              // Rank labels (1-8)
              Positioned(
                left: 4,
                top: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(8, (index) {
                    return SizedBox(
                      height: 20,
                      child: Center(
                        child: Text(
                          '${8 - index}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Get.theme.colorScheme.onSurface.withValues(
                              red: Get.theme.colorScheme.onSurface.r.toDouble(),
                              green:
                                  Get.theme.colorScheme.onSurface.g.toDouble(),
                              blue:
                                  Get.theme.colorScheme.onSurface.b.toDouble(),
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // File labels (a-h)
              Positioned(
                left: 0,
                right: 0,
                bottom: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(8, (index) {
                    return SizedBox(
                      width: 20,
                      child: Center(
                        child: Text(
                          String.fromCharCode('a'.codeUnitAt(0) + index),
                          style: TextStyle(
                            fontSize: 12,
                            color: Get.theme.colorScheme.onSurface.withValues(
                              red: Get.theme.colorScheme.onSurface.r.toDouble(),
                              green:
                                  Get.theme.colorScheme.onSurface.g.toDouble(),
                              blue:
                                  Get.theme.colorScheme.onSurface.b.toDouble(),
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSquareTap(String position) {
    if (controller.gameState.value == ChessGameState.checkmate ||
        controller.gameState.value == ChessGameState.stalemate ||
        controller.gameState.value == ChessGameState.draw ||
        controller.isGamePaused.value) {
      return;
    }

    final selectedPiece = controller.selectedPiece.value;
    final tappedPiece = controller.board.getPieceAt(position);

    // If no piece is selected
    if (selectedPiece == null) {
      if (tappedPiece != null &&
          tappedPiece.color ==
              (controller.isWhiteTurn.value
                  ? PieceColor.white
                  : PieceColor.black)) {
        controller.selectedPiece.value = tappedPiece;
        controller.soundService.playSelectSound();
      }
      return;
    }

    // If a piece is already selected
    if (position == selectedPiece.position) {
      // Deselect the piece
      controller.selectedPiece.value = null;
      controller.soundService.playDeselectSound();
    } else if (tappedPiece != null &&
        tappedPiece.color == selectedPiece.color) {
      // Select another piece of the same color
      controller.selectedPiece.value = tappedPiece;
      controller.soundService.playSelectSound();
    } else {
      // Try to make a move
      final validMoves = controller.board.getValidMoves(selectedPiece.position);
      if (validMoves.contains(position)) {
        controller.makeMove(selectedPiece.position, position);
        controller.selectedPiece.value = null;
      } else {
        controller.soundService.playErrorSound();
      }
    }
  }
}
