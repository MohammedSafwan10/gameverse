import '../chess_piece.dart';

class Knight extends ChessPiece {
  Knight({
    required super.color,
    required super.position,
  });

  @override
  PieceType get type => PieceType.knight;

  @override
  bool isValidMovePattern(int fromRow, int fromCol, int toRow, int toCol, List<List<ChessPiece?>> board) {
    final rowDiff = (toRow - fromRow).abs();
    final colDiff = (toCol - fromCol).abs();
    
    // Knight moves in an L-shape: 2 squares in one direction and 1 square perpendicular
    return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2);
  }

  @override
  bool isPathClear(int fromRow, int fromCol, int toRow, int toCol, List<List<ChessPiece?>> board) {
    // Knights can jump over pieces, so we don't need to check the path
    return true;
  }
} 