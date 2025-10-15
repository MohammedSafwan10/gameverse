import 'dart:math' show Random, Point;
import '../models/board.dart';
import 'game_controller.dart';
import 'package:logger/logger.dart';

class AIController {
  static const int maxDepth = 5;
  final Random _random = Random();
  AIDifficulty _difficulty = AIDifficulty.medium;
  final _logger = Logger();

  void setDifficulty(AIDifficulty difficulty) {
    _difficulty = difficulty;
    _logger.i('AI difficulty set to: $difficulty');
  }

  int findBestMove(Board board, CellState aiPlayer) {
    _logger.d(
        'Finding best move for AI player: $aiPlayer, difficulty: $_difficulty');

    switch (_difficulty) {
      case AIDifficulty.easy:
        return _findEasyMove(board, aiPlayer);
      case AIDifficulty.medium:
        return _findMediumMove(board, aiPlayer);
      case AIDifficulty.hard:
        return _findHardMove(board, aiPlayer);
    }
  }

  int _findEasyMove(Board board, CellState aiPlayer) {
    _logger.d('Using easy difficulty strategy');

    // 70% random move, 30% smart move
    if (_random.nextDouble() < 0.7) {
      return _findRandomMove(board);
    }

    // Check for immediate winning move
    final winningMove = _findWinningMove(board, aiPlayer);
    if (winningMove != -1) {
      _logger.d('Easy AI found winning move at column: $winningMove');
      return winningMove;
    }

    // Otherwise, random move
    return _findRandomMove(board);
  }

  int _findRandomMove(Board board) {
    final validMoves = _getValidMoves(board);
    if (validMoves.isEmpty) return -1;

    final move = validMoves[_random.nextInt(validMoves.length)];
    _logger.d('AI selected random move at column: $move');
    return move;
  }

  int _findMediumMove(Board board, CellState aiPlayer) {
    _logger.d('Using medium difficulty strategy');

    // First check for winning move
    final winningMove = _findWinningMove(board, aiPlayer);
    if (winningMove != -1) {
      _logger.d('Medium AI found winning move at column: $winningMove');
      return winningMove;
    }

    // Then check for blocking opponent's winning move
    final blockingMove = _findWinningMove(board, _getOpponent(aiPlayer));
    if (blockingMove != -1) {
      _logger.d('Medium AI found blocking move at column: $blockingMove');
      return blockingMove;
    }

    // Check for moves that create a potential three-in-a-row
    final threateningMove = _findThreateningMove(board, aiPlayer);
    if (threateningMove != -1) {
      _logger.d('Medium AI found threatening move at column: $threateningMove');
      return threateningMove;
    }

    // Prefer center column when available (better strategic position)
    final centerCol = Board.cols ~/ 2;
    if (board.isValidMove(centerCol)) {
      _logger.d('Medium AI playing center column: $centerCol');
      return centerCol;
    }

    // Otherwise make a random move with 60% chance or best move with 40% chance
    if (_random.nextDouble() < 0.6) {
      return _findRandomMove(board);
    } else {
      return _findBestMoveMinMax(board, aiPlayer, maxDepth: 3);
    }
  }

  int _findHardMove(Board board, CellState aiPlayer) {
    _logger.d('Using hard difficulty strategy');

    // First check for immediate win
    final winningMove = _findWinningMove(board, aiPlayer);
    if (winningMove != -1) {
      _logger.d('Hard AI found winning move at column: $winningMove');
      return winningMove;
    }

    // Then check for blocking opponent's winning move
    final blockingMove = _findWinningMove(board, _getOpponent(aiPlayer));
    if (blockingMove != -1) {
      _logger.d('Hard AI found blocking move at column: $blockingMove');
      return blockingMove;
    }

    // Use minimax for the best strategic move
    return _findBestMoveMinMax(board, aiPlayer);
  }

  int _findBestMoveMinMax(Board board, CellState aiPlayer,
      {int maxDepth = maxDepth}) {
    _logger.d('Running minimax with depth $maxDepth');

    int bestScore = -1000;
    int bestMove = -1;
    final List<int> validMoves = _getValidMoves(board);

    // Prefer center column as initial consideration for hard AI
    final centerCol = Board.cols ~/ 2;
    if (validMoves.contains(centerCol)) {
      validMoves.remove(centerCol);
      validMoves.insert(0, centerCol);
    } else {
      // Add some randomness to move order to avoid predictable play
      validMoves.shuffle(_random);
    }

    for (final col in validMoves) {
      final row = board.getLowestEmptyRow(col);
      if (row == -1) continue;

      final newBoard = _makeMove(board, col, row, aiPlayer);
      final score = _minimax(
        newBoard,
        maxDepth - 1,
        -1000,
        1000,
        false,
        aiPlayer,
      );

      _logger.d('Column $col has score: $score');

      if (score > bestScore) {
        bestScore = score;
        bestMove = col;
      }
    }

    if (bestMove == -1 && validMoves.isNotEmpty) {
      bestMove = validMoves[_random.nextInt(validMoves.length)];
      _logger.w('No best move found, using fallback random move: $bestMove');
    } else {
      _logger.d('Best move found at column: $bestMove with score: $bestScore');
    }

    return bestMove;
  }

  int _findWinningMove(Board board, CellState player) {
    final validMoves = _getValidMoves(board);
    for (final col in validMoves) {
      final row = board.getLowestEmptyRow(col);
      if (row == -1) continue;

      final newBoard = _makeMove(board, col, row, player);
      if (_checkWin(row, col, player, newBoard.cells).isNotEmpty) {
        return col;
      }
    }
    return -1;
  }

  int _findThreateningMove(Board board, CellState player) {
    final validMoves = _getValidMoves(board);

    for (final col in validMoves) {
      final row = board.getLowestEmptyRow(col);
      if (row == -1) continue;

      final newBoard = _makeMove(board, col, row, player);

      // Check if this creates a potential threat
      if (_evaluateThreats(newBoard, player) >= 2) {
        return col;
      }
    }
    return -1;
  }

  int _evaluateThreats(Board board, CellState player) {
    int threatCount = 0;

    // Check for patterns where the AI has 3 in a row with an empty spot at either end
    for (int row = 0; row < Board.rows; row++) {
      for (int col = 0; col < Board.cols; col++) {
        if (board.cells[row][col] != player) continue;

        final directions = [
          [0, 1], // horizontal
          [1, 0], // vertical
          [1, 1], // diagonal right
          [1, -1], // diagonal left
        ];

        for (final dir in directions) {
          final dRow = dir[0];
          final dCol = dir[1];

          int count = 1; // Start with 1 for the current piece
          bool hasFreeSpace = false;

          // Check in positive direction
          for (int i = 1; i < 4; i++) {
            final r = row + (dRow * i);
            final c = col + (dCol * i);

            if (r < 0 || r >= Board.rows || c < 0 || c >= Board.cols) break;

            if (board.cells[r][c] == player) {
              count++;
            } else if (board.cells[r][c] == CellState.empty) {
              hasFreeSpace = true;
              break;
            } else {
              // Opponent's piece
              break;
            }
          }

          // Check in negative direction
          for (int i = 1; i < 4; i++) {
            final r = row - (dRow * i);
            final c = col - (dCol * i);

            if (r < 0 || r >= Board.rows || c < 0 || c >= Board.cols) break;

            if (board.cells[r][c] == player) {
              count++;
            } else if (board.cells[r][c] == CellState.empty) {
              hasFreeSpace = true;
              break;
            } else {
              // Opponent's piece
              break;
            }
          }

          // If we found 3 in a row with an open space, it's a threat
          if (count >= 3 && hasFreeSpace) {
            threatCount++;
          }
        }
      }
    }

    return threatCount;
  }

  int _minimax(
    Board board,
    int depth,
    int alpha,
    int beta,
    bool isMaximizing,
    CellState aiPlayer,
  ) {
    final gameStatus = _checkGameStatus(board);
    if (gameStatus != GameStatus.playing || depth == 0) {
      return _evaluatePosition(board, aiPlayer, depth);
    }

    final currentPlayer = isMaximizing ? aiPlayer : _getOpponent(aiPlayer);
    final validMoves = _getValidMoves(board);

    if (isMaximizing) {
      int maxScore = -1000;
      for (final col in validMoves) {
        final row = board.getLowestEmptyRow(col);
        if (row == -1) continue;

        final newBoard = _makeMove(board, col, row, currentPlayer);
        final score = _minimax(
          newBoard,
          depth - 1,
          alpha,
          beta,
          false,
          aiPlayer,
        );

        maxScore = score > maxScore ? score : maxScore;
        alpha = score > alpha ? score : alpha;
        if (beta <= alpha) break;
      }
      return maxScore;
    } else {
      int minScore = 1000;
      for (final col in validMoves) {
        final row = board.getLowestEmptyRow(col);
        if (row == -1) continue;

        final newBoard = _makeMove(board, col, row, currentPlayer);
        final score = _minimax(
          newBoard,
          depth - 1,
          alpha,
          beta,
          true,
          aiPlayer,
        );

        minScore = score < minScore ? score : minScore;
        beta = score < beta ? score : beta;
        if (beta <= alpha) break;
      }
      return minScore;
    }
  }

  Board _makeMove(Board board, int col, int row, CellState player) {
    final newCells = List<List<CellState>>.generate(
      Board.rows,
      (i) => List<CellState>.from(board.cells[i]),
    );
    newCells[row][col] = player;
    return Board(cells: newCells);
  }

  List<int> _getValidMoves(Board board) {
    return List.generate(Board.cols, (i) => i)
        .where((col) => board.isValidMove(col))
        .toList();
  }

  CellState _getOpponent(CellState player) {
    return player == CellState.player1 ? CellState.player2 : CellState.player1;
  }

  GameStatus _checkGameStatus(Board board) {
    // Check for win
    for (int row = 0; row < Board.rows; row++) {
      for (int col = 0; col < Board.cols; col++) {
        if (board.cells[row][col] != CellState.empty) {
          final winningCells =
              _checkWin(row, col, board.cells[row][col], board.cells);
          if (winningCells.isNotEmpty) {
            return board.cells[row][col] == CellState.player1
                ? GameStatus.player1Won
                : GameStatus.player2Won;
          }
        }
      }
    }

    // Check for draw
    if (board.isFull) return GameStatus.draw;

    return GameStatus.playing;
  }

  List<Point<int>> _checkWin(
    int row,
    int col,
    CellState player,
    List<List<CellState>> cells,
  ) {
    final directions = [
      [0, 1], // horizontal
      [1, 0], // vertical
      [1, 1], // diagonal right
      [1, -1], // diagonal left
    ];

    for (final direction in directions) {
      final line =
          _getLine(row, col, direction[0], direction[1], player, cells);
      if (line.length >= 4) return line;
    }
    return [];
  }

  List<Point<int>> _getLine(
    int row,
    int col,
    int dRow,
    int dCol,
    CellState player,
    List<List<CellState>> cells,
  ) {
    final line = <Point<int>>[];

    // Check in positive direction
    int r = row, c = col;
    while (r >= 0 &&
        r < Board.rows &&
        c >= 0 &&
        c < Board.cols &&
        cells[r][c] == player) {
      line.add(Point(r, c));
      r += dRow;
      c += dCol;
    }

    // Check in negative direction
    r = row - dRow;
    c = col - dCol;
    while (r >= 0 &&
        r < Board.rows &&
        c >= 0 &&
        c < Board.cols &&
        cells[r][c] == player) {
      line.insert(0, Point(r, c));
      r -= dRow;
      c -= dCol;
    }

    return line;
  }

  int _evaluatePosition(Board board, CellState aiPlayer, int depth) {
    final gameStatus = _checkGameStatus(board);

    switch (gameStatus) {
      case GameStatus.player1Won:
        return aiPlayer == CellState.player1 ? 1000 + depth : -1000 - depth;
      case GameStatus.player2Won:
        return aiPlayer == CellState.player2 ? 1000 + depth : -1000 - depth;
      case GameStatus.draw:
        return 0;
      default:
        return _evaluateBoard(board, aiPlayer);
    }
  }

  int _evaluateBoard(Board board, CellState aiPlayer) {
    int score = 0;
    final opponent = _getOpponent(aiPlayer);

    // Evaluate center column control - center positions are stronger
    for (int row = 0; row < Board.rows; row++) {
      final centerCol = Board.cols ~/ 2;
      if (board.cells[row][centerCol] == aiPlayer) {
        score += 3;
      } else if (board.cells[row][centerCol] == opponent) {
        score -= 3;
      }
    }

    // Evaluate columns adjacent to center
    final leftOfCenter = (Board.cols ~/ 2) - 1;
    final rightOfCenter = (Board.cols ~/ 2) + 1;
    for (int row = 0; row < Board.rows; row++) {
      if (leftOfCenter >= 0) {
        if (board.cells[row][leftOfCenter] == aiPlayer) {
          score += 2;
        } else if (board.cells[row][leftOfCenter] == opponent) {
          score -= 2;
        }
      }

      if (rightOfCenter < Board.cols) {
        if (board.cells[row][rightOfCenter] == aiPlayer) {
          score += 2;
        } else if (board.cells[row][rightOfCenter] == opponent) {
          score -= 2;
        }
      }
    }

    // Evaluate potential winning positions and threats
    score += _evaluatePotentialWins(board, aiPlayer);
    score -= _evaluatePotentialWins(board, opponent);

    // Evaluate defensive positions
    score += _evaluateDefensivePositions(board, aiPlayer);

    return score;
  }

  int _evaluatePotentialWins(Board board, CellState player) {
    int score = 0;
    final directions = [
      [0, 1], // horizontal
      [1, 0], // vertical
      [1, 1], // diagonal right
      [1, -1], // diagonal left
    ];

    // Evaluate potential connecting pieces
    for (int row = 0; row < Board.rows; row++) {
      for (int col = 0; col < Board.cols; col++) {
        if (board.cells[row][col] != player) continue;

        for (final direction in directions) {
          final count = _countSequence(
              row, col, direction[0], direction[1], player, board.cells);

          // Score based on sequence length and opportunity to connect
          if (count == 2) {
            // 2 in a row
            score += 2;

            // Check if both ends are open
            if (_hasOpenEnds(
                row, col, direction[0], direction[1], player, board.cells)) {
              score += 3;
            }
          } else if (count == 3) {
            // 3 in a row
            score += 5;

            // Check if at least one end is open
            if (_hasOpenEnds(
                row, col, direction[0], direction[1], player, board.cells)) {
              score += 10;
            }
          }
        }
      }
    }

    return score;
  }

  bool _hasOpenEnds(int row, int col, int dRow, int dCol, CellState player,
      List<List<CellState>> cells) {
    int openEnds = 0;

    // Check in positive direction
    int r = row + dRow;
    int c = col + dCol;
    while (r >= 0 &&
        r < Board.rows &&
        c >= 0 &&
        c < Board.cols &&
        cells[r][c] == player) {
      r += dRow;
      c += dCol;
    }

    // Check if end is open
    if (r >= 0 &&
        r < Board.rows &&
        c >= 0 &&
        c < Board.cols &&
        cells[r][c] == CellState.empty) {
      openEnds++;
    }

    // Check opposite direction
    r = row - dRow;
    c = col - dCol;
    while (r >= 0 &&
        r < Board.rows &&
        c >= 0 &&
        c < Board.cols &&
        cells[r][c] == player) {
      r -= dRow;
      c -= dCol;
    }

    // Check if this end is open
    if (r >= 0 &&
        r < Board.rows &&
        c >= 0 &&
        c < Board.cols &&
        cells[r][c] == CellState.empty) {
      openEnds++;
    }

    return openEnds > 0;
  }

  int _evaluateDefensivePositions(Board board, CellState player) {
    int score = 0;
    final opponent = _getOpponent(player);

    // Check if we need to block opponent's potential win
    final validMoves = _getValidMoves(board);
    for (final col in validMoves) {
      final row = board.getLowestEmptyRow(col);
      if (row == -1) continue;

      // Check if opponent would win by placing here
      final tempBoard = _makeMove(board, col, row, opponent);
      if (_checkWin(row, col, opponent, tempBoard.cells).isNotEmpty) {
        score += 15; // Incentivize blocking opponent's win
      }
    }

    return score;
  }

  int _countSequence(
    int row,
    int col,
    int dRow,
    int dCol,
    CellState player,
    List<List<CellState>> cells,
  ) {
    int count = 1; // Start with 1 for the current piece

    // Count one direction
    int r = row + dRow;
    int c = col + dCol;
    while (r >= 0 &&
        r < Board.rows &&
        c >= 0 &&
        c < Board.cols &&
        cells[r][c] == player) {
      count++;
      r += dRow;
      c += dCol;
    }

    // Count opposite direction
    r = row - dRow;
    c = col - dCol;
    while (r >= 0 &&
        r < Board.rows &&
        c >= 0 &&
        c < Board.cols &&
        cells[r][c] == player) {
      count++;
      r -= dRow;
      c -= dCol;
    }

    return count;
  }
}
