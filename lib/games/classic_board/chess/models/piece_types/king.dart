import '../chess_piece.dart';

class King extends ChessPiece {
  King({
    required super.color,
    required super.position,
  });

  @override
  PieceType get type => PieceType.king;

  @override
  bool isValidMovePattern(int fromRow, int fromCol, int toRow, int toCol, List<List<ChessPiece?>> board) {
    // King can move one square in any direction
    final rowDiff = (toRow - fromRow).abs();
    final colDiff = (toCol - fromCol).abs();
    
    // Regular move: one square in any direction
    return rowDiff <= 1 && colDiff <= 1;
  }
} 