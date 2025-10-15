import '../chess_piece.dart';

class Queen extends ChessPiece {
  Queen({
    required super.color,
    required super.position,
  });

  @override
  PieceType get type => PieceType.queen;

  @override
  bool isValidMovePattern(int fromRow, int fromCol, int toRow, int toCol, List<List<ChessPiece?>> board) {
    final rowDiff = (toRow - fromRow).abs();
    final colDiff = (toCol - fromCol).abs();
    
    // Queen can move like a rook (horizontally/vertically)
    // or like a bishop (diagonally)
    return rowDiff == 0 || colDiff == 0 || // Rook-like moves
           rowDiff == colDiff;              // Bishop-like moves
  }
} 