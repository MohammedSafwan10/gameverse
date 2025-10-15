import 'chess_piece.dart';
import 'piece_types/pawn.dart';
import 'piece_types/rook.dart';
import 'piece_types/knight.dart';
import 'piece_types/bishop.dart';
import 'piece_types/queen.dart';
import 'piece_types/king.dart';

class ChessBoard {
  late List<List<ChessPiece?>> board;
  final List<String> moveHistory = [];
  final List<ChessPiece> capturedPieces = [];

  ChessBoard() {
    initializeBoard();
  }

  /// Creates a deep copy of the chess board
  ChessBoard deepCopy() {
    final copy = ChessBoard();

    // Create a new empty board
    copy.board = List.generate(8, (row) => List.generate(8, (col) => null));

    // Copy each piece with the same state
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null) {
          final position = ChessPiece.coordinatesToNotation(row, col);
          switch (piece.type) {
            case PieceType.pawn:
              final newPiece = Pawn(
                color: piece.color,
                position: position,
              );
              newPiece.hasMoved = piece.hasMoved;
              copy.board[row][col] = newPiece;
              break;
            case PieceType.rook:
              final newPiece = Rook(
                color: piece.color,
                position: position,
              );
              newPiece.hasMoved = piece.hasMoved;
              copy.board[row][col] = newPiece;
              break;
            case PieceType.knight:
              final newPiece = Knight(
                color: piece.color,
                position: position,
              );
              newPiece.hasMoved = piece.hasMoved;
              copy.board[row][col] = newPiece;
              break;
            case PieceType.bishop:
              final newPiece = Bishop(
                color: piece.color,
                position: position,
              );
              newPiece.hasMoved = piece.hasMoved;
              copy.board[row][col] = newPiece;
              break;
            case PieceType.queen:
              final newPiece = Queen(
                color: piece.color,
                position: position,
              );
              newPiece.hasMoved = piece.hasMoved;
              copy.board[row][col] = newPiece;
              break;
            case PieceType.king:
              final newPiece = King(
                color: piece.color,
                position: position,
              );
              newPiece.hasMoved = piece.hasMoved;
              copy.board[row][col] = newPiece;
              break;
          }
        }
      }
    }

    // Copy move history
    copy.moveHistory.addAll(moveHistory);

    // Copy captured pieces list
    for (final capturedPiece in capturedPieces) {
      ChessPiece newPiece;
      switch (capturedPiece.type) {
        case PieceType.pawn:
          newPiece = Pawn(
            color: capturedPiece.color,
            position: capturedPiece.position,
          );
          break;
        case PieceType.rook:
          newPiece = Rook(
            color: capturedPiece.color,
            position: capturedPiece.position,
          );
          break;
        case PieceType.knight:
          newPiece = Knight(
            color: capturedPiece.color,
            position: capturedPiece.position,
          );
          break;
        case PieceType.bishop:
          newPiece = Bishop(
            color: capturedPiece.color,
            position: capturedPiece.position,
          );
          break;
        case PieceType.queen:
          newPiece = Queen(
            color: capturedPiece.color,
            position: capturedPiece.position,
          );
          break;
        case PieceType.king:
          newPiece = King(
            color: capturedPiece.color,
            position: capturedPiece.position,
          );
          break;
      }
      newPiece.hasMoved = capturedPiece.hasMoved;
      copy.capturedPieces.add(newPiece);
    }

    return copy;
  }

  void initializeBoard() {
    // Initialize 8x8 board
    board = List.generate(8, (row) => List.generate(8, (col) => null));

    // Place pawns
    for (int col = 0; col < 8; col++) {
      board[1][col] = Pawn(
        color: PieceColor.black,
        position: ChessPiece.coordinatesToNotation(1, col),
      );
      board[6][col] = Pawn(
        color: PieceColor.white,
        position: ChessPiece.coordinatesToNotation(6, col),
      );
    }

    // Place other pieces
    _placePiece(0, 0, PieceType.rook, PieceColor.black);
    _placePiece(0, 1, PieceType.knight, PieceColor.black);
    _placePiece(0, 2, PieceType.bishop, PieceColor.black);
    _placePiece(0, 3, PieceType.queen, PieceColor.black);
    _placePiece(0, 4, PieceType.king, PieceColor.black);
    _placePiece(0, 5, PieceType.bishop, PieceColor.black);
    _placePiece(0, 6, PieceType.knight, PieceColor.black);
    _placePiece(0, 7, PieceType.rook, PieceColor.black);

    _placePiece(7, 0, PieceType.rook, PieceColor.white);
    _placePiece(7, 1, PieceType.knight, PieceColor.white);
    _placePiece(7, 2, PieceType.bishop, PieceColor.white);
    _placePiece(7, 3, PieceType.queen, PieceColor.white);
    _placePiece(7, 4, PieceType.king, PieceColor.white);
    _placePiece(7, 5, PieceType.bishop, PieceColor.white);
    _placePiece(7, 6, PieceType.knight, PieceColor.white);
    _placePiece(7, 7, PieceType.rook, PieceColor.white);
  }

  void _placePiece(int row, int col, PieceType type, PieceColor color) {
    final position = ChessPiece.coordinatesToNotation(row, col);
    board[row][col] = switch (type) {
      PieceType.pawn => Pawn(color: color, position: position),
      PieceType.rook => Rook(color: color, position: position),
      PieceType.knight => Knight(color: color, position: position),
      PieceType.bishop => Bishop(color: color, position: position),
      PieceType.queen => Queen(color: color, position: position),
      PieceType.king => King(color: color, position: position),
    };
  }

  ChessPiece? getPieceAt(String position) {
    final (row, col) = ChessPiece.notationToCoordinates(position);
    return board[row][col];
  }

  bool movePiece(String from, String to) {
    final (fromRow, fromCol) = ChessPiece.notationToCoordinates(from);
    final (toRow, toCol) = ChessPiece.notationToCoordinates(to);

    final piece = board[fromRow][fromCol];
    if (piece == null) return false;

    // Validate move
    final validMoves = getValidMoves(from);
    if (!validMoves.contains(to)) return false;

    // Capture piece if present
    final capturedPiece = board[toRow][toCol];
    if (capturedPiece != null) {
      capturedPieces.add(capturedPiece);
    }

    // Move piece
    board[toRow][toCol] = piece;
    board[fromRow][fromCol] = null;
    piece.position = to;
    piece.hasMoved = true;

    // Record move
    final moveNotation =
        _generateMoveNotation(piece, from, to, capturedPiece != null);
    moveHistory.add(moveNotation);

    return true;
  }

  String _generateMoveNotation(
      ChessPiece piece, String from, String to, bool isCapture) {
    if (piece.type == PieceType.pawn) {
      if (isCapture) {
        return '${from[0]}x$to';
      }
      return to;
    }

    final pieceSymbol = switch (piece.type) {
      PieceType.king => 'K',
      PieceType.queen => 'Q',
      PieceType.rook => 'R',
      PieceType.bishop => 'B',
      PieceType.knight => 'N',
      PieceType.pawn => '',
    };

    return '$pieceSymbol${isCapture ? 'x' : ''}$to';
  }

  List<String> getValidMoves(String position) {
    final piece = getPieceAt(position);
    if (piece == null) return [];

    final moves = piece.getPossibleMoves(board);
    return moves
        .where((move) => !wouldBeInCheck(piece.color, position, move))
        .toList();
  }

  bool isCheck(PieceColor color) {
    // Find king's position
    String? kingPosition;
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null &&
            piece.color == color &&
            piece.type == PieceType.king) {
          kingPosition = ChessPiece.coordinatesToNotation(row, col);
          break;
        }
      }
      if (kingPosition != null) break;
    }

    if (kingPosition == null) return false;

    // Check if any enemy piece can capture the king
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color != color) {
          final moves = piece.getPossibleMoves(board);
          if (moves.contains(kingPosition)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  bool isCheckmate(PieceColor color) {
    if (!isCheck(color)) return false;

    // Check if any piece can make a legal move
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == color) {
          final moves = getValidMoves(piece.position);
          if (moves.isNotEmpty) {
            return false;
          }
        }
      }
    }

    return true;
  }

  bool isStalemate(PieceColor color) {
    if (isCheck(color)) return false;

    // Check if any piece can make a legal move
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == color) {
          final moves = getValidMoves(piece.position);
          if (moves.isNotEmpty) {
            return false;
          }
        }
      }
    }

    return true;
  }

  bool isInsufficientMaterial() {
    var whitePieces = <PieceType, int>{};
    var blackPieces = <PieceType, int>{};

    // Count remaining pieces
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null) {
          final pieces =
              piece.color == PieceColor.white ? whitePieces : blackPieces;
          pieces[piece.type] = (pieces[piece.type] ?? 0) + 1;
        }
      }
    }

    // King vs King
    if (whitePieces.length == 1 && blackPieces.length == 1) {
      return true;
    }

    // King and Bishop/Knight vs King
    if ((whitePieces.length == 2 && blackPieces.length == 1) ||
        (whitePieces.length == 1 && blackPieces.length == 2)) {
      final morePieces =
          whitePieces.length > blackPieces.length ? whitePieces : blackPieces;
      if (morePieces[PieceType.bishop] == 1 ||
          morePieces[PieceType.knight] == 1) {
        return true;
      }
    }

    return false;
  }

  bool wouldBeInCheck(PieceColor color, String from, String to) {
    final (fromRow, fromCol) = ChessPiece.notationToCoordinates(from);
    final (toRow, toCol) = ChessPiece.notationToCoordinates(to);

    // Save current state
    final piece = board[fromRow][fromCol];
    final capturedPiece = board[toRow][toCol];

    // Try move
    board[toRow][toCol] = piece;
    board[fromRow][fromCol] = null;
    if (piece != null) {
      piece.position = to;
    }

    // Check if king would be in check
    final wouldBeInCheck = isCheck(color);

    // Restore position
    board[fromRow][fromCol] = piece;
    board[toRow][toCol] = capturedPiece;
    if (piece != null) {
      piece.position = from;
    }

    return wouldBeInCheck;
  }
}
