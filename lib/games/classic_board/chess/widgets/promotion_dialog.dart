import 'package:flutter/material.dart';

import '../models/chess_piece.dart';
import '../models/piece_types/bishop.dart';
import '../models/piece_types/knight.dart';
import '../models/piece_types/queen.dart';
import '../models/piece_types/rook.dart';
import '../theme/chess_design.dart';
import 'chess_piece_widget.dart';

class PromotionDialog extends StatelessWidget {
  const PromotionDialog({
    super.key,
    required this.color,
    required this.position,
    required this.onSelect,
  });
  final PieceColor color;
  final String position;
  final ValueChanged<PieceType> onSelect;

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 410),
          padding: const EdgeInsets.all(22),
          decoration: ChessDesign.ivoryPanel(radius: 30),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                  color: ChessDesign.gold, shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            const Text('PAWN PROMOTION',
                style: TextStyle(
                    color: ChessDesign.navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7)),
            const SizedBox(height: 4),
            Text('Choose your new piece',
                style: TextStyle(
                    color: ChessDesign.ink.withValues(alpha: .62),
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 18),
            Row(children: [
              _option(PieceType.queen, 'QUEEN'),
              _option(PieceType.rook, 'ROOK'),
              _option(PieceType.bishop, 'BISHOP'),
              _option(PieceType.knight, 'KNIGHT'),
            ]),
          ]),
        ),
      );

  Widget _option(PieceType type, String label) {
    final piece = switch (type) {
      PieceType.queen => Queen(color: color, position: position),
      PieceType.rook => Rook(color: color, position: position),
      PieceType.bishop => Bishop(color: color, position: position),
      PieceType.knight => Knight(color: color, position: position),
      _ => Queen(color: color, position: position),
    };
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: const Color(0xFFF0E8D7),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => onSelect(type),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(children: [
                ChessPieceWidget(
                    piece: piece,
                    size: 50,
                    isAnimated: false,
                    isSelected: false),
                const SizedBox(height: 4),
                FittedBox(
                  child: Text(label,
                      style: const TextStyle(
                          color: ChessDesign.ink,
                          fontSize: 9,
                          fontWeight: FontWeight.w900)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
