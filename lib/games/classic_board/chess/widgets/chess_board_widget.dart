import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../models/chess_piece.dart';
import 'chess_square.dart';
import '../theme/chess_design.dart';

class ChessBoardWidget extends GetView<ChessGameController> {
  const ChessBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final palette = ChessBoardPalette.fromId(controller.boardTheme.value);
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: palette.frame,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.frameEdge, width: 3),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x77001736),
                  blurRadius: 16,
                  offset: Offset(0, 9))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
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
                          controller.legalMovesForSelection.contains(position);
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
                IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(8, (index) {
                        return Expanded(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '${8 - index}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color:
                                    palette.coordinate.withValues(alpha: 0.72),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // File labels (a-h)
                IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(8, (index) {
                        return Expanded(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              String.fromCharCode('a'.codeUnitAt(0) + index),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color:
                                    palette.coordinate.withValues(alpha: 0.72),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _handleSquareTap(String position) {
    if (controller.gameState.value == ChessGameState.checkmate ||
        controller.gameState.value == ChessGameState.stalemate ||
        controller.gameState.value == ChessGameState.draw ||
        controller.isGamePaused.value) {
      return;
    }
    if (controller.gameMode.value == ChessGameMode.ai &&
        !controller.isWhiteTurn.value) {
      return;
    }

    final selectedPiece = controller.selectedPiece.value;
    final tappedPiece = controller.board.getPieceAt(position);

    if (selectedPiece == null) {
      if (tappedPiece != null &&
          tappedPiece.color ==
              (controller.isWhiteTurn.value
                  ? PieceColor.white
                  : PieceColor.black)) {
        controller.selectPiece(tappedPiece);
        controller.soundService.playSelectSound();
      }
      return;
    }

    if (position == selectedPiece.position) {
      controller.clearSelection();
      controller.soundService.playDeselectSound();
    } else if (tappedPiece != null &&
        tappedPiece.color == selectedPiece.color) {
      controller.selectPiece(tappedPiece);
      controller.soundService.playSelectSound();
    } else {
      if (controller.legalMovesForSelection.contains(position)) {
        controller.makeMove(selectedPiece.position, position);
        controller.clearSelection();
      } else {
        controller.soundService.playErrorSound();
      }
    }
  }
}
