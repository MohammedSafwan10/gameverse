import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/chess_piece.dart';
import '../models/piece_types/queen.dart';
import '../models/piece_types/rook.dart';
import '../models/piece_types/bishop.dart';
import '../models/piece_types/knight.dart';
import 'chess_piece_widget.dart';

class PromotionDialog extends StatelessWidget {
  final PieceColor color;
  final String position;
  final Function(PieceType) onSelect;

  const PromotionDialog({
    super.key,
    required this.color,
    required this.position,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.upgrade_rounded,
                  color: theme.colorScheme.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Pawn Promotion',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your new piece',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOption(context, PieceType.queen, 0),
                _buildOption(context, PieceType.rook, 1),
                _buildOption(context, PieceType.bishop, 2),
                _buildOption(context, PieceType.knight, 3),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, PieceType type, int index) {
    final theme = Theme.of(context);
    final piece = switch (type) {
      PieceType.queen => Queen(color: color, position: position),
      PieceType.rook => Rook(color: color, position: position),
      PieceType.bishop => Bishop(color: color, position: position),
      PieceType.knight => Knight(color: color, position: position),
      _ => Queen(color: color, position: position),
    };

    return GestureDetector(
      onTap: () => onSelect(type),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: ChessPieceWidget(
            piece: piece,
            size: 40,
            isSelected: false,
            isAnimated: false,
          ),
        ),
      )
          .animate(delay: (index * 100).ms)
          .scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }
}
