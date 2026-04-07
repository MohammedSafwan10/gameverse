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
    final pieceColor = isWhitePiece ? const Color(0xFFF7F7FA) : const Color(0xFF111111);
    final outlineColor = isWhitePiece ? const Color(0xCC2D3142) : const Color(0x66FFFFFF);

    Widget pieceWidget = GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Center(
              child: Transform.translate(
                offset: const Offset(0.8, 1.2),
                child: SvgPicture.asset(
                  piece.imagePath,
                  width: size * 0.9,
                  height: size * 0.9,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    outlineColor.withValues(alpha: isWhitePiece ? 0.55 : 0.35),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            Center(
              child: SvgPicture.asset(
                piece.imagePath,
                width: size * 0.9,
                height: size * 0.9,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  pieceColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            if (isWhitePiece)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.22),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
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
