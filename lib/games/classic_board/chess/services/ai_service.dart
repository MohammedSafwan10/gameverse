import 'dart:math';
import 'dart:developer' as dev;
import 'package:get/get.dart';
import '../models/chess_board.dart';
import '../models/chess_piece.dart';

class ChessAIService extends GetxService {
  final Random _random = Random();

  // AI difficulty levels
  static const int easyDepth = 1;
  static const int mediumDepth = 2;
  static const int hardDepth = 3;

  int _difficulty = mediumDepth;

  // Observable states for monitoring AI
  final RxBool isThinking = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = "".obs;

  // Piece values for move evaluation
  static const Map<PieceType, int> pieceValues = {
    PieceType.pawn: 10,
    PieceType.knight: 30,
    PieceType.bishop: 30,
    PieceType.rook: 50,
    PieceType.queen: 90,
    PieceType.king: 900,
  };

  // Piece position evaluation tables to encourage good positioning
  static const List<List<int>> pawnPositionWhite = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [50, 50, 50, 50, 50, 50, 50, 50],
    [10, 10, 20, 30, 30, 20, 10, 10],
    [5, 5, 10, 25, 25, 10, 5, 5],
    [0, 0, 0, 20, 20, 0, 0, 0],
    [5, -5, -10, 0, 0, -10, -5, 5],
    [5, 10, 10, -20, -20, 10, 10, 5],
    [0, 0, 0, 0, 0, 0, 0, 0]
  ];

  static const List<List<int>> pawnPositionBlack = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [5, 10, 10, -20, -20, 10, 10, 5],
    [5, -5, -10, 0, 0, -10, -5, 5],
    [0, 0, 0, 20, 20, 0, 0, 0],
    [5, 5, 10, 25, 25, 10, 5, 5],
    [10, 10, 20, 30, 30, 20, 10, 10],
    [50, 50, 50, 50, 50, 50, 50, 50],
    [0, 0, 0, 0, 0, 0, 0, 0]
  ];

  static const List<List<int>> knightPosition = [
    [-50, -40, -30, -30, -30, -30, -40, -50],
    [-40, -20, 0, 0, 0, 0, -20, -40],
    [-30, 0, 10, 15, 15, 10, 0, -30],
    [-30, 5, 15, 20, 20, 15, 5, -30],
    [-30, 0, 15, 20, 20, 15, 0, -30],
    [-30, 5, 10, 15, 15, 10, 5, -30],
    [-40, -20, 0, 5, 5, 0, -20, -40],
    [-50, -40, -30, -30, -30, -30, -40, -50]
  ];

  static const List<List<int>> bishopPositionWhite = [
    [-20, -10, -10, -10, -10, -10, -10, -20],
    [-10, 0, 0, 0, 0, 0, 0, -10],
    [-10, 0, 10, 10, 10, 10, 0, -10],
    [-10, 5, 5, 10, 10, 5, 5, -10],
    [-10, 0, 5, 10, 10, 5, 0, -10],
    [-10, 10, 10, 10, 10, 10, 10, -10],
    [-10, 5, 0, 0, 0, 0, 5, -10],
    [-20, -10, -10, -10, -10, -10, -10, -20]
  ];

  static const List<List<int>> bishopPositionBlack = bishopPositionWhite;

  static const List<List<int>> rookPositionWhite = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [5, 10, 10, 10, 10, 10, 10, 5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [0, 0, 0, 5, 5, 0, 0, 0]
  ];

  static const List<List<int>> rookPositionBlack = rookPositionWhite;

  static const List<List<int>> queenPosition = [
    [-20, -10, -10, -5, -5, -10, -10, -20],
    [-10, 0, 0, 0, 0, 0, 0, -10],
    [-10, 0, 5, 5, 5, 5, 0, -10],
    [-5, 0, 5, 5, 5, 5, 0, -5],
    [0, 0, 5, 5, 5, 5, 0, -5],
    [-10, 5, 5, 5, 5, 5, 0, -10],
    [-10, 0, 5, 0, 0, 0, 0, -10],
    [-20, -10, -10, -5, -5, -10, -10, -20]
  ];

  static const List<List<int>> kingPositionMiddleGame = [
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-20, -30, -30, -40, -40, -30, -30, -20],
    [-10, -20, -20, -20, -20, -20, -20, -10],
    [20, 20, 0, 0, 0, 0, 20, 20],
    [20, 30, 10, 0, 0, 10, 30, 20]
  ];

  // Set AI difficulty level
  void setDifficulty(int difficulty) {
    dev.log('Setting AI difficulty to: $difficulty', name: 'ChessAIService');
    if (difficulty >= easyDepth && difficulty <= hardDepth) {
      _difficulty = difficulty;
    } else {
      dev.log('Invalid difficulty level: $difficulty, defaulting to medium',
          name: 'ChessAIService');
      _difficulty = mediumDepth;
    }
  }

  // Get the AI's best move
  String? getBestMove(ChessBoard chessBoard, PieceColor aiColor) {
    hasError.value = false;
    errorMessage.value = "";
    isThinking.value = true;

    try {
      dev.log('AI calculating move for ${aiColor.name}',
          name: 'ChessAIService');

      // Create a copy of the board to avoid modifying the original
      final boardCopy = chessBoard.deepCopy();

      // Find all valid moves for the AI
      final allMoves = _getAllValidMoves(boardCopy, aiColor);

      if (allMoves.isEmpty) {
        dev.log('No valid moves found for AI', name: 'ChessAIService');
        isThinking.value = false;
        return null; // No valid moves, might be checkmate or stalemate
      }

      dev.log('Found ${allMoves.length} possible moves',
          name: 'ChessAIService');

      // Introduce human-like behavior based on difficulty
      // Easy: Sometimes make random moves, sometimes make mistakes
      // Medium: Occasionally make suboptimal moves
      // Hard: Usually make strong moves but still not perfect

      if (_difficulty == easyDepth) {
        // At easy level, 40% chance to make a random move
        if (_random.nextDouble() < 0.4) {
          final randomMove = allMoves[_random.nextInt(allMoves.length)];
          isThinking.value = false;
          dev.log(
              'Easy mode random move: ${randomMove.from} to ${randomMove.to}',
              name: 'ChessAIService');
          return '${randomMove.from}-${randomMove.to}';
        }
      }

      // Evaluate moves using minimax algorithm
      final bestMoveResult = _findBestMove(boardCopy, _difficulty, aiColor);
      final bestMove = bestMoveResult.$1;

      // For medium difficulty, sometimes choose a random move from the top 3 moves
      if (_difficulty == mediumDepth &&
          allMoves.length > 3 &&
          _random.nextDouble() < 0.25) {
        // Get 3 somewhat good moves
        final moves = _getTopMoves(boardCopy, 3, aiColor);
        if (moves.isNotEmpty) {
          final move = moves[_random.nextInt(moves.length)];
          isThinking.value = false;
          dev.log('Medium mode suboptimal move: ${move.from} to ${move.to}',
              name: 'ChessAIService');
          return '${move.from}-${move.to}';
        }
      }

      if (bestMove.from.isEmpty || bestMove.to.isEmpty) {
        // Fallback to random move if minimax fails
        dev.log('Minimax failed to find a good move, using random fallback',
            name: 'ChessAIService');
        final randomMove = allMoves[_random.nextInt(allMoves.length)];
        isThinking.value = false;
        return '${randomMove.from}-${randomMove.to}';
      }

      isThinking.value = false;
      dev.log('AI selected move: ${bestMove.from} to ${bestMove.to}',
          name: 'ChessAIService');
      return '${bestMove.from}-${bestMove.to}';
    } catch (e) {
      dev.log('Error in AI move calculation: $e',
          name: 'ChessAIService', error: e);
      hasError.value = true;
      errorMessage.value = e.toString();
      isThinking.value = false;

      // Try to get a simple random move as fallback
      try {
        return _getRandomMove(chessBoard, aiColor);
      } catch (e2) {
        dev.log('Fallback random move also failed: $e2',
            name: 'ChessAIService', error: e2);
        return null;
      }
    }
  }

  // Get top N moves by score
  List<_Move> _getTopMoves(ChessBoard board, int count, PieceColor aiColor) {
    final allMoves = _getAllValidMoves(board, aiColor);
    if (allMoves.isEmpty) return [];

    // Calculate score for each move
    final scoredMoves = <(_Move, int)>[];

    for (final move in allMoves) {
      final boardCopy = board.deepCopy();
      _makeMove(boardCopy, move);

      // Use a shallower search depth for quick evaluation
      final score = _minimax(
          boardCopy,
          1, // shallow depth for quick evaluation
          -999999,
          999999,
          aiColor == PieceColor.white ? false : true);

      scoredMoves.add((move, score));
    }

    // Sort by score (highest first for white, lowest first for black)
    if (aiColor == PieceColor.white) {
      scoredMoves.sort((a, b) => b.$2.compareTo(a.$2)); // Descending for white
    } else {
      scoredMoves.sort((a, b) => a.$2.compareTo(b.$2)); // Ascending for black
    }

    // Return top N moves (or all if less than N)
    final topCount = count < scoredMoves.length ? count : scoredMoves.length;
    return scoredMoves.sublist(0, topCount).map((m) => m.$1).toList();
  }

  // Fallback method to get a random valid move
  String? _getRandomMove(ChessBoard chessBoard, PieceColor aiColor) {
    final moves = <_Move>[];

    // Find all pieces of the AI's color
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = chessBoard.board[row][col];
        if (piece != null && piece.color == aiColor) {
          final from = piece.position;
          final possibleMoves = piece.getPossibleMoves(chessBoard.board);

          for (final to in possibleMoves) {
            moves.add(_Move(from, to));
          }
        }
      }
    }

    if (moves.isEmpty) {
      return null;
    }

    final randomMove = moves[_random.nextInt(moves.length)];
    return '${randomMove.from}-${randomMove.to}';
  }

  // Find the best move using the minimax algorithm
  (_Move, int) _findBestMove(ChessBoard board, int depth, PieceColor aiColor) {
    final allMoves = _getAllValidMoves(board, aiColor);

    if (allMoves.isEmpty) {
      // Check if it's checkmate or stalemate
      return (_Move('', ''), -999999); // Very bad score, no moves available
    }

    var bestMove = _Move('', '');
    var bestScore = aiColor == PieceColor.white ? -999999 : 999999;

    for (final move in allMoves) {
      // Create a deep copy of the board
      final boardCopy = board.deepCopy();

      // Make the move on the cloned board
      _makeMove(boardCopy, move);

      // Evaluate the move
      final score = _minimax(boardCopy, depth - 1, -999999, 999999,
          aiColor == PieceColor.white ? false : true);

      // Update the best move based on the score
      if (aiColor == PieceColor.white) {
        if (score > bestScore) {
          bestScore = score;
          bestMove = move;
        }
      } else {
        if (score < bestScore) {
          bestScore = score;
          bestMove = move;
        }
      }
    }

    return (bestMove, bestScore);
  }

  // Minimax algorithm with alpha-beta pruning
  int _minimax(
      ChessBoard board, int depth, int alpha, int beta, bool isMaximizing) {
    if (depth == 0) {
      return _evaluateBoard(board);
    }

    final currentColor = isMaximizing ? PieceColor.white : PieceColor.black;
    final allMoves = _getAllValidMoves(board, currentColor);

    if (allMoves.isEmpty) {
      // Check if it's checkmate or stalemate
      final isKingInCheck = _isKingInCheck(board, currentColor);

      if (isKingInCheck) {
        // Checkmate: return a very high negative value for the current player
        return isMaximizing ? -900000 : 900000;
      } else {
        // Stalemate: return 0 (neutral score)
        return 0;
      }
    }

    if (isMaximizing) {
      var maxScore = -999999;

      for (final move in allMoves) {
        final boardCopy = board.deepCopy();
        _makeMove(boardCopy, move);

        final score = _minimax(boardCopy, depth - 1, alpha, beta, false);
        maxScore = max(maxScore, score);
        alpha = max(alpha, score);

        if (beta <= alpha) {
          break; // Beta cut-off
        }
      }

      return maxScore;
    } else {
      var minScore = 999999;

      for (final move in allMoves) {
        final boardCopy = board.deepCopy();
        _makeMove(boardCopy, move);

        final score = _minimax(boardCopy, depth - 1, alpha, beta, true);
        minScore = min(minScore, score);
        beta = min(beta, score);

        if (beta <= alpha) {
          break; // Alpha cut-off
        }
      }

      return minScore;
    }
  }

  // Check if king is in check
  bool _isKingInCheck(ChessBoard board, PieceColor kingColor) {
    // Find the king's position
    String kingPosition = '';
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board.board[row][col];
        if (piece != null &&
            piece.type == PieceType.king &&
            piece.color == kingColor) {
          kingPosition = piece.position;
          break;
        }
      }
      if (kingPosition.isNotEmpty) break;
    }

    if (kingPosition.isEmpty) {
      // King not found, shouldn't happen in a valid game
      return false;
    }

    // Check if any opponent piece can attack the king
    final opponentColor =
        kingColor == PieceColor.white ? PieceColor.black : PieceColor.white;

    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board.board[row][col];
        if (piece != null && piece.color == opponentColor) {
          final possibleMoves = piece.getPossibleMoves(board.board);
          if (possibleMoves.contains(kingPosition)) {
            return true; // King is in check
          }
        }
      }
    }

    return false; // King is not in check
  }

  // Make a move on the board
  void _makeMove(ChessBoard board, _Move move) {
    final (fromRow, fromCol) = ChessPiece.notationToCoordinates(move.from);
    final (toRow, toCol) = ChessPiece.notationToCoordinates(move.to);

    final movingPiece = board.board[fromRow][fromCol];
    if (movingPiece == null) return;

    // Capture piece if present
    final capturedPiece = board.board[toRow][toCol];
    if (capturedPiece != null) {
      board.capturedPieces.add(capturedPiece);
    }

    // Move the piece
    movingPiece.position = move.to;
    movingPiece.hasMoved = true;
    board.board[toRow][toCol] = movingPiece;
    board.board[fromRow][fromCol] = null;

    // Add move to history
    board.moveHistory.add('${move.from}-${move.to}');
  }

  // Get all valid moves for a player
  List<_Move> _getAllValidMoves(ChessBoard board, PieceColor color) {
    final moves = <_Move>[];

    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board.board[row][col];
        if (piece != null && piece.color == color) {
          final from = piece.position;
          final possibleMoves = piece.getPossibleMoves(board.board);

          for (final to in possibleMoves) {
            // Check if the move would put own king in check
            final boardCopy = board.deepCopy();
            final move = _Move(from, to);
            _makeMove(boardCopy, move);

            if (!_isKingInCheck(boardCopy, color)) {
              moves.add(move);
            }
          }
        }
      }
    }

    return moves;
  }

  // Evaluate the board state
  int _evaluateBoard(ChessBoard board) {
    int score = 0;

    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board.board[row][col];
        if (piece == null) continue;

        int pieceValue = pieceValues[piece.type] ?? 0;

        // Position evaluation
        int positionValue = 0;
        switch (piece.type) {
          case PieceType.pawn:
            positionValue = piece.color == PieceColor.white
                ? pawnPositionWhite[row][col]
                : pawnPositionBlack[row][col];
            break;
          case PieceType.knight:
            positionValue = knightPosition[row][col];
            break;
          case PieceType.bishop:
            positionValue = piece.color == PieceColor.white
                ? bishopPositionWhite[row][col]
                : bishopPositionBlack[row][col];
            break;
          case PieceType.rook:
            positionValue = piece.color == PieceColor.white
                ? rookPositionWhite[row][col]
                : rookPositionBlack[row][col];
            break;
          case PieceType.queen:
            positionValue = queenPosition[row][col];
            break;
          case PieceType.king:
            positionValue = kingPositionMiddleGame[row][col];
            break;
        }

        int totalValue = pieceValue + positionValue;

        // Add to score based on piece color
        if (piece.color == PieceColor.white) {
          score += totalValue;
        } else {
          score -= totalValue;
        }
      }
    }

    return score;
  }
}

// Simple class to represent a move
class _Move {
  final String from;
  final String to;

  _Move(this.from, this.to);
}
