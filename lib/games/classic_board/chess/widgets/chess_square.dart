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
    final baseColor = switch (theme) {
      'classic' => isWhite ? Colors.brown[100]! : Colors.brown[700]!,
      'modern' => isWhite ? Colors.blue[50]! : Colors.blue[800]!,
      'forest' => isWhite ? Colors.green[100]! : Colors.green[800]!,
      'royal' => isWhite ? Colors.amber[50]! : Colors.purple[800]!,
      'ocean' => isWhite ? Colors.cyan[50]! : Colors.teal[800]!,
      'sunset' => isWhite ? Colors.pink[50]! : Colors.deepOrange[800]!,
      _ => isWhite ? Colors.brown[100]! : Colors.brown[700]!,
    };

    return baseColor.withValues(
      red: baseColor.r.toDouble(),
      green: baseColor.g.toDouble(),
      blue: baseColor.b.toDouble(),
      alpha: isWhite ? 1.0 : 0.9,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<ChessGameController>();

    return Obx(() {
      final squareColor = _getSquareColor(context, controller.boardTheme.value);
      final isLightTheme = controller.boardTheme.value == 'modern' ||
          controller.boardTheme.value == 'ocean';

      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(
                    red: theme.colorScheme.primary.r.toDouble(),
                    green: theme.colorScheme.primary.g.toDouble(),
                    blue: theme.colorScheme.primary.b.toDouble(),
                    alpha: 0.3,
                  )
                : isLastMove
                    ? theme.colorScheme.secondary.withValues(
                        red: theme.colorScheme.secondary.r.toDouble(),
                        green: theme.colorScheme.secondary.g.toDouble(),
                        blue: theme.colorScheme.secondary.b.toDouble(),
                        alpha: 0.3,
                      )
                    : squareColor,
            border: isValidMove
                ? Border.all(
                    color: isLightTheme
                        ? theme.colorScheme.primary.withValues(
                            red: theme.colorScheme.primary.r.toDouble(),
                            green: theme.colorScheme.primary.g.toDouble(),
                            blue: theme.colorScheme.primary.b.toDouble(),
                            alpha: 0.8,
                          )
                        : theme.colorScheme.primary.withValues(
                            red: theme.colorScheme.primary.r.toDouble(),
                            green: theme.colorScheme.primary.g.toDouble(),
                            blue: theme.colorScheme.primary.b.toDouble(),
                            alpha: 0.9,
                          ),
                    width: 2,
                  )
                : isCheck
                    ? Border.all(
                        color: theme.colorScheme.error.withValues(
                          red: theme.colorScheme.error.r.toDouble(),
                          green: theme.colorScheme.error.g.toDouble(),
                          blue: theme.colorScheme.error.b.toDouble(),
                          alpha: 0.9,
                        ),
                        width: 2,
                      )
                    : null,
          ),
          child: Stack(
            children: [
              // Valid move indicator
              if (isValidMove && piece == null)
                Center(
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isLightTheme
                          ? theme.colorScheme.primary.withValues(
                              red: theme.colorScheme.primary.r.toDouble(),
                              green: theme.colorScheme.primary.g.toDouble(),
                              blue: theme.colorScheme.primary.b.toDouble(),
                              alpha: 0.8,
                            )
                          : theme.colorScheme.primary.withValues(
                              red: theme.colorScheme.primary.r.toDouble(),
                              green: theme.colorScheme.primary.g.toDouble(),
                              blue: theme.colorScheme.primary.b.toDouble(),
                              alpha: 0.7,
                            ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            red: theme.colorScheme.primary.r.toDouble(),
                            green: theme.colorScheme.primary.g.toDouble(),
                            blue: theme.colorScheme.primary.b.toDouble(),
                            alpha: 0.4,
                          ),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),

              // Capture indicator
              if (isValidMove && piece != null)
                Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isLightTheme
                            ? theme.colorScheme.error.withValues(
                                red: theme.colorScheme.error.r.toDouble(),
                                green: theme.colorScheme.error.g.toDouble(),
                                blue: theme.colorScheme.error.b.toDouble(),
                                alpha: 0.8,
                              )
                            : theme.colorScheme.error.withValues(
                                red: theme.colorScheme.error.r.toDouble(),
                                green: theme.colorScheme.error.g.toDouble(),
                                blue: theme.colorScheme.error.b.toDouble(),
                                alpha: 0.9,
                              ),
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.error.withValues(
                            red: theme.colorScheme.error.r.toDouble(),
                            green: theme.colorScheme.error.g.toDouble(),
                            blue: theme.colorScheme.error.b.toDouble(),
                            alpha: 0.4,
                          ),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
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
                Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(
                          red: theme.colorScheme.error.r.toDouble(),
                          green: theme.colorScheme.error.g.toDouble(),
                          blue: theme.colorScheme.error.b.toDouble(),
                          alpha: 0.9,
                        ),
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.error.withValues(
                            red: theme.colorScheme.error.r.toDouble(),
                            green: theme.colorScheme.error.g.toDouble(),
                            blue: theme.colorScheme.error.b.toDouble(),
                            alpha: 0.4,
                          ),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.warning_rounded,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
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
