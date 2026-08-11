import 'package:flutter/material.dart';
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
    Widget pieceWidget = GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          piece.imagePath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
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
