import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/chess_piece.dart';
import '../models/piece_types/queen.dart';
import '../models/piece_types/rook.dart';
import '../models/piece_types/bishop.dart';
import '../models/piece_types/knight.dart';
import 'chess_piece_widget.dart';
import 'package:gameverse/theme/app_theme.dart';

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
    final accentColor = const Color(0xFFF4B860);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: AppTheme.glassmorphicDecoration(
            backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.9),
            borderColor: Colors.white.withValues(alpha: 0.1),
            borderRadius: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: accentColor.withValues(alpha: 0.4), width: 2),
                ),
                child:
                    Icon(Icons.upgrade_rounded, color: accentColor, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'PAWN PROMOTION',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your new piece',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
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
      ),
    );
  }

  Widget _buildOption(BuildContext context, PieceType type, int index) {
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
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: ChessPieceWidget(
            piece: piece,
            size: 44,
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
