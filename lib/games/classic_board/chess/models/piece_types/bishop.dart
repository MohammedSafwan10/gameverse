import '../chess_piece.dart';

class Bishop extends ChessPiece {
  Bishop({
    required super.color,
    required super.position,
  });

  @override
  PieceType get type => PieceType.bishop;

  @override
  bool isValidMovePattern(int fromRow, int fromCol, int toRow, int toCol, List<List<ChessPiece?>> board) {
    final rowDiff = (toRow - fromRow).abs();
    final colDiff = (toCol - fromCol).abs();
    
    // Bishop can only move diagonally
    return rowDiff == colDiff;
  }
} 