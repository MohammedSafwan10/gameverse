import '../chess_piece.dart';

class Rook extends ChessPiece {
  Rook({
    required super.color,
    required super.position,
  });

  @override
  PieceType get type => PieceType.rook;

  @override
  bool isValidMovePattern(int fromRow, int fromCol, int toRow, int toCol, List<List<ChessPiece?>> board) {
    // Rook can only move horizontally or vertically
    return fromRow == toRow || fromCol == toCol;
  }
} 