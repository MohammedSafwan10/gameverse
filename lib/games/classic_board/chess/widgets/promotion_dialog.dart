import 'package:flutter/material.dart';
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
    return AlertDialog(
      title: const Text('Promote Pawn'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Choose a piece to promote to:'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOption(context, PieceType.queen),
              _buildOption(context, PieceType.rook),
              _buildOption(context, PieceType.bishop),
              _buildOption(context, PieceType.knight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, PieceType type) {
    final piece = switch (type) {
      PieceType.queen => Queen(color: color, position: position),
      PieceType.rook => Rook(color: color, position: position),
      PieceType.bishop => Bishop(color: color, position: position),
      PieceType.knight => Knight(color: color, position: position),
      _ => Queen(color: color, position: position), // Default to queen
    };
    
    return GestureDetector(
      onTap: () => onSelect(type),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        child: ChessPieceWidget(
          piece: piece,
          size: 40,
          isSelected: false,
          isAnimated: false,
        ),
      ),
    );
  }
} 