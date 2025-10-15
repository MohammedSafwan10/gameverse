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
    final theme = Theme.of(context);

    Widget pieceWidget = GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: isSelected
            ? BoxDecoration(
                color: theme.colorScheme.primary.withValues(
                  red: theme.colorScheme.primary.r.toDouble(),
                  green: theme.colorScheme.primary.g.toDouble(),
                  blue: theme.colorScheme.primary.b.toDouble(),
                  alpha: 0.3,
                ),
                shape: BoxShape.circle,
              )
            : null,
        child: Stack(
          children: [
            // Shadow effect for depth
            if (!isSelected)
              Center(
                child: Container(
                  width: size * 0.9,
                  height: size * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          red: 0.0,
                          green: 0.0,
                          blue: 0.0,
                          alpha: 0.2,
                        ),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

            // Piece SVG with improved contrast
            Center(
              child: SvgPicture.asset(
                piece.imagePath,
                width: size * 0.9,
                height: size * 0.9,
                fit: BoxFit.contain,
                placeholderBuilder: (context) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary.withValues(
                      red: theme.colorScheme.primary.r.toDouble(),
                      green: theme.colorScheme.primary.g.toDouble(),
                      blue: theme.colorScheme.primary.b.toDouble(),
                      alpha: 0.5,
                    ),
                  ),
                ),
                colorFilter: ColorFilter.mode(
                  piece.color == PieceColor.white ? Colors.white : Colors.black,
                  BlendMode.srcATop,
                ),
              ),
            ),

            // Highlight effect for white pieces
            if (piece.color == PieceColor.white)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(
                          red: 1.0,
                          green: 1.0,
                          blue: 1.0,
                          alpha: 0.2,
                        ),
                        Colors.white.withValues(
                          red: 1.0,
                          green: 1.0,
                          blue: 1.0,
                          alpha: 0.0,
                        ),
                      ],
                      center: Alignment.topLeft,
                      radius: 0.8,
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
          .animate(target: isSelected ? 1 : 0)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            curve: Curves.easeOutBack,
            duration: const Duration(milliseconds: 200),
          )
          .elevation(
            end: 8,
            curve: Curves.easeOutBack,
            duration: const Duration(milliseconds: 200),
          );
    }

    return pieceWidget;
  }
}
