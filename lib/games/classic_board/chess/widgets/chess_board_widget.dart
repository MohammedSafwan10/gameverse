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
          decoration: BoxDecoration(
            color: palette.frame,
            image: DecorationImage(
              image: AssetImage(palette.textureAsset),
              fit: BoxFit.cover,
              opacity: .68,
              colorFilter: const ColorFilter.mode(
                Color(0x66001432),
                BlendMode.srcATop,
              ),
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.frameEdge, width: 2),
            boxShadow: const [
              BoxShadow(
                  color: Color(0xAA000A1C),
                  blurRadius: 18,
                  offset: Offset(0, 10))
            ],
          ),
          child: Stack(children: [
            Positioned(
              left: 18,
              top: 18,
              right: 18,
              bottom: 18,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: GridView.builder(
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
              ),
            ),
            _FileCoordinates(palette: palette, top: true),
            _FileCoordinates(palette: palette, top: false),
            _RankCoordinates(palette: palette, left: true),
            _RankCoordinates(palette: palette, left: false),
          ]),
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

class _FileCoordinates extends StatelessWidget {
  const _FileCoordinates({required this.palette, required this.top});
  final ChessBoardPalette palette;
  final bool top;

  @override
  Widget build(BuildContext context) => Positioned(
        left: 18,
        right: 18,
        top: top ? 1 : null,
        bottom: top ? null : 1,
        height: 16,
        child: IgnorePointer(
          child: Row(
            children: List.generate(
              8,
              (index) => Expanded(
                child: Center(
                  child: Text(
                    String.fromCharCode('a'.codeUnitAt(0) + index),
                    style: TextStyle(
                      fontFamily: 'BarlowCondensed',
                      fontSize: 11,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: palette.coordinate,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _RankCoordinates extends StatelessWidget {
  const _RankCoordinates({required this.palette, required this.left});
  final ChessBoardPalette palette;
  final bool left;

  @override
  Widget build(BuildContext context) => Positioned(
        top: 18,
        bottom: 18,
        left: left ? 1 : null,
        right: left ? null : 1,
        width: 16,
        child: IgnorePointer(
          child: Column(
            children: List.generate(
              8,
              (index) => Expanded(
                child: Center(
                  child: Text(
                    '${8 - index}',
                    style: TextStyle(
                      fontFamily: 'BarlowCondensed',
                      fontSize: 11,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: palette.coordinate,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
