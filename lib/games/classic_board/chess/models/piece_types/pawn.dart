import '../chess_piece.dart';

class Pawn extends ChessPiece {
  Pawn({
    required super.color,
    required super.position,
  });

  @override
  PieceType get type => PieceType.pawn;

  @override
  bool isValidMovePattern(int fromRow, int fromCol, int toRow, int toCol, List<List<ChessPiece?>> board) {
    final direction = color == PieceColor.white ? -1 : 1;
    final startingRow = color == PieceColor.white ? 6 : 1;
    
    // Forward movement
    if (fromCol == toCol) {
      // Single square forward
      if (toRow == fromRow + direction) {
        return board[toRow][toCol] == null;
      }
      
      // Double square forward from starting position
      if (fromRow == startingRow && toRow == fromRow + (2 * direction)) {
        return board[fromRow + direction][toCol] == null && 
               board[toRow][toCol] == null;
      }
    }
    
    // Capture diagonally
    if (toRow == fromRow + direction && 
        (toCol == fromCol - 1 || toCol == fromCol + 1)) {
      return isValidCapture(fromRow, fromCol, toRow, toCol, board);
    }
    
    return false;
  }

  @override
  bool isValidCapture(int fromRow, int fromCol, int toRow, int toCol, List<List<ChessPiece?>> board) {
    final direction = color == PieceColor.white ? -1 : 1;
    
    // Must move forward one square diagonally
    if (toRow != fromRow + direction || 
        (toCol != fromCol - 1 && toCol != fromCol + 1)) {
      return false;
    }
    
    // Must capture an enemy piece
    final targetPiece = board[toRow][toCol];
    return targetPiece != null && targetPiece.color != color;
  }
}