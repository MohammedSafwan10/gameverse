abstract class ChessPiece {
  final PieceColor color;
  String position;
  bool hasMoved = false;
  
  ChessPiece({
    required this.color,
    required this.position,
  });

  String get imagePath => 'assets/chess/images/${color.name}_${type.name}.svg';
  PieceType get type;

  static String coordinatesToNotation(int row, int col) {
    if (row < 0 || row > 7 || col < 0 || col > 7) {
      throw RangeError('Invalid coordinates: row=$row, col=$col');
    }
    final file = String.fromCharCode('a'.codeUnitAt(0) + col);
    final rank = (8 - row).toString();
    return '$file$rank';
  }

  static (int, int) notationToCoordinates(String notation) {
    if (notation.length != 2) {
      throw FormatException('Invalid notation: $notation');
    }
    final file = notation[0].toLowerCase();
    final rank = notation[1];
    
    if (file.codeUnitAt(0) < 'a'.codeUnitAt(0) || file.codeUnitAt(0) > 'h'.codeUnitAt(0)) {
      throw RangeError('Invalid file: $file');
    }
    
    final rankNum = int.tryParse(rank);
    if (rankNum == null || rankNum < 1 || rankNum > 8) {
      throw RangeError('Invalid rank: $rank');
    }
    
    final col = file.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final row = 8 - rankNum;
    
    return (row, col);
  }

  List<String> getPossibleMoves(List<List<ChessPiece?>> board) {
    final moves = <String>[];
    final (currentRow, currentCol) = notationToCoordinates(position);

    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        if (isValidMove(currentRow, currentCol, row, col, board)) {
          moves.add(coordinatesToNotation(row, col));
        }
      }
    }

    return moves;
  }

  bool isValidMove(int fromRow, int fromCol, int toRow, int toCol, List<List<ChessPiece?>> board) {
    // Basic validation
    if (toRow < 0 || toRow > 7 || toCol < 0 || toCol > 7) return false;
    if (fromRow == toRow && fromCol == toCol) return false;

    // Can't capture own piece
    final targetPiece = board[toRow][toCol];
    if (targetPiece != null && targetPiece.color == color) return false;

    // Check if move pattern is valid for piece type
    if (!isValidMovePattern(fromRow, fromCol, toRow, toCol, board)) return false;

    // Check if path is clear (except for knights)
    if (type != PieceType.knight && !isPathClear(fromRow, fromCol, toRow, toCol, board)) {
      return false;
    }

    return true;
  }

  bool isValidMovePattern(int fromRow, int fromCol, int toRow, int toCol, List<List<ChessPiece?>> board);

  bool isPathClear(int fromRow, int fromCol, int toRow, int toCol, List<List<ChessPiece?>> board) {
    final rowDir = toRow.compareTo(fromRow);
    final colDir = toCol.compareTo(fromCol);
    var currentRow = fromRow + rowDir;
    var currentCol = fromCol + colDir;

    while (currentRow != toRow || currentCol != toCol) {
      if (board[currentRow][currentCol] != null) {
        return false;
      }
      currentRow += rowDir;
      currentCol += colDir;
    }

    return true;
  }

  bool isValidCapture(int fromRow, int fromCol, int toRow, int toCol, List<List<ChessPiece?>> board) {
    final targetPiece = board[toRow][toCol];
    return targetPiece != null && targetPiece.color != color;
  }
}

enum PieceColor { white, black }
enum PieceType { pawn, rook, knight, bishop, queen, king } 