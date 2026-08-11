import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/chess_piece.dart';

class ChessPieceWidget extends StatelessWidget {
  final ChessPiece piece;
  final double size;
  final bool isSelected;
  final bool isAnimated;
  final VoidCallback? onTap;

  const ChessPieceWidget({
    super.key,
    required this.piece,
    required this.size,
    this.isSelected = false,
    this.isAnimated = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWhitePiece = piece.color == PieceColor.white;
    final pieceColor =
        isWhitePiece ? const Color(0xFFFFF8E7) : const Color(0xFF172431);
    final edgeColor =
        isWhitePiece ? const Color(0xFF5F4B36) : const Color(0xFFFFD77A);

    Widget pieceWidget = GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Stronger Drop shadow for depth
            Center(
              child: Transform.translate(
                offset: const Offset(2.0, 2.5),
                child: SvgPicture.asset(
                  piece.imagePath,
                  width: size * 0.92,
                  height: size * 0.92,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.6),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            // Crisp material edge.
            Center(
              child: SvgPicture.asset(
                piece.imagePath,
                width: size * 0.98,
                height: size * 0.98,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  edgeColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            // Main piece color - slightly smaller to show the outline
            Center(
              child: SvgPicture.asset(
                piece.imagePath,
                width: size * 0.88,
                height: size * 0.88,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  pieceColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (isAnimated) {
      pieceWidget = pieceWidget
          .animate(key: ValueKey(piece.position))
          .fadeIn(duration: 400.ms)
          .scale(
              begin: const Offset(0.5, 0.5),
              duration: 400.ms,
              curve: Curves.easeOutBack);

      if (isSelected) {
        pieceWidget = pieceWidget
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.15, 1.15),
                duration: 600.ms);
      }
    }

    return pieceWidget;
  }
}
