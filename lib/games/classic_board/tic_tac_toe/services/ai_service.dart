import 'dart:math';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/game_difficulty.dart';
import '../models/game_state.dart';
import '../models/player.dart';

class AIService extends GetxService {
  final _random = Random();
  final _logger = Logger();

  Future<int?> getNextMove(TicTacToeState state) async {
    _logger
        .i('AI calculating move with difficulty: ${state.settings.difficulty}');
    return calculateMove(state, state.settings.difficulty);
  }

  int calculateMove(TicTacToeState state, GameDifficulty difficulty) {
    final emptyPositions = _getEmptyPositions(state.board);
    if (emptyPositions.isEmpty) return -1;

    switch (difficulty) {
      case GameDifficulty.easy:
        return _makeEasyMove(state, emptyPositions);
      case GameDifficulty.medium:
        return _makeMediumMove(state, emptyPositions);
      case GameDifficulty.hard:
        return _makeHardMove(state, emptyPositions);
      case GameDifficulty.impossible:
        return _makeImpossibleMove(state, emptyPositions);
    }
  }

  List<int> _getEmptyPositions(List<Player> board) {
    final positions = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == Player.none) {
        positions.add(i);
      }
    }
    return positions;
  }

  // Easy: 80% random moves, 20% blocking/winning moves
  int _makeEasyMove(TicTacToeState state, List<int> emptyPositions) {
    // 20% chance to make an intelligent move
    if (_random.nextDouble() < 0.2) {
      // Try to win first
      final winningMove = _findWinningMove(state.board, Player.o);
      if (winningMove != null) return winningMove;

      // Block only 50% of the time when there's a threat
      if (_random.nextDouble() < 0.5) {
        final blockingMove = _findWinningMove(state.board, Player.x);
        if (blockingMove != null) return blockingMove;
      }
    }

    // Prefer center and corners slightly (just to make it slightly more realistic)
    List<int> preferredMoves = [];
    if (emptyPositions.contains(4)) preferredMoves.add(4); // Center
    for (final corner in [0, 2, 6, 8]) {
      if (emptyPositions.contains(corner)) preferredMoves.add(corner);
    }

    // 30% chance to pick from preferred moves if available
    if (preferredMoves.isNotEmpty && _random.nextDouble() < 0.3) {
      return preferredMoves[_random.nextInt(preferredMoves.length)];
    }

    // Otherwise make a completely random move
    return emptyPositions[_random.nextInt(emptyPositions.length)];
  }

  // Medium: 70% intelligent moves, 30% mistakes
  int _makeMediumMove(TicTacToeState state, List<int> emptyPositions) {
    // Always check for winning move
    final winningMove = _findWinningMove(state.board, Player.o);
    if (winningMove != null) return winningMove;

    // 80% chance to block opponent's winning move
    if (_random.nextDouble() < 0.8) {
      final blockingMove = _findWinningMove(state.board, Player.x);
      if (blockingMove != null) return blockingMove;
    }

    // Make strategic moves 70% of the time
    if (_random.nextDouble() < 0.7) {
      // Take center if available
      if (state.board[4] == Player.none) return 4;

      // Create fork opportunities or block opponent's forks
      final strategicMove = _findStrategicMove(state.board);
      if (strategicMove != null) return strategicMove;

      // Take corners
      final corners = [0, 2, 6, 8];
      final availableCorners = corners
          .where((corner) => state.board[corner] == Player.none)
          .toList();

      if (availableCorners.isNotEmpty) {
        return availableCorners[_random.nextInt(availableCorners.length)];
      }
    }

    // Otherwise make a random move
    return emptyPositions[_random.nextInt(emptyPositions.length)];
  }

  // Hard: 95% intelligent moves, 5% non-optimal moves
  int _makeHardMove(TicTacToeState state, List<int> emptyPositions) {
    // Always try to win
    final winningMove = _findWinningMove(state.board, Player.o);
    if (winningMove != null) return winningMove;

    // Always block opponent's winning move
    final blockingMove = _findWinningMove(state.board, Player.x);
    if (blockingMove != null) return blockingMove;

    // 95% chance to make optimal move
    if (_random.nextDouble() < 0.95) {
      // Take center if available
      if (state.board[4] == Player.none) return 4;

      // Create or block forks
      final forkMove = _findForkMove(state.board, Player.o);
      if (forkMove != null) return forkMove;

      final opponentForkMove = _findForkMove(state.board, Player.x);
      if (opponentForkMove != null) return opponentForkMove;

      // Take opposite corner from opponent
      final oppositeCornerMove = _findOppositeCornerMove(state.board);
      if (oppositeCornerMove != null) return oppositeCornerMove;

      // Take any corner
      final corners = [0, 2, 6, 8];
      for (final corner in corners) {
        if (state.board[corner] == Player.none) return corner;
      }

      // Take any side
      final sides = [1, 3, 5, 7];
      for (final side in sides) {
        if (state.board[side] == Player.none) return side;
      }
    }

    // 5% chance for a non-optimal move
    return emptyPositions[_random.nextInt(emptyPositions.length)];
  }
  // Impossible: Perfect play using minimax
  int _makeImpossibleMove(TicTacToeState state, List<int> emptyPositions) {
    // First move optimization: always take center or corner for first move
    // This speeds up the algorithm without affecting perfect play
    if (emptyPositions.length >= 8) {
      // First or second move
      if (state.board[4] == Player.none) {
        return 4; // Center is optimal first move
      }
      return [0, 2, 6, 8][_random.nextInt(4)]; // Corner is optimal second move
    }

    int bestScore = -1000;
    int bestMove = emptyPositions[0];

    for (final position in emptyPositions) {
      final board = List<Player>.from(state.board);
      board[position] = Player.o;
      final score = _minimax(board, 0, false, -1000, 1000);
      if (score > bestScore) {
        bestScore = score;
        bestMove = position;
      }
    }

    return bestMove;
  }

  // Minimax with alpha-beta pruning for efficiency
  int _minimax(
      List<Player> board, int depth, bool isMaximizing, int alpha, int beta) {
    final winner = _checkWinner(board);
    if (winner == Player.o) return 10 - depth;
    if (winner == Player.x) return depth - 10;
    if (!board.contains(Player.none)) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == Player.none) {
          board[i] = Player.o;
          bestScore =
              _max(bestScore, _minimax(board, depth + 1, false, alpha, beta));
          board[i] = Player.none;
          alpha = _max(alpha, bestScore);
          if (beta <= alpha) break; // Alpha-beta pruning
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == Player.none) {
          board[i] = Player.x;
          bestScore =
              _min(bestScore, _minimax(board, depth + 1, true, alpha, beta));
          board[i] = Player.none;
          beta = _min(beta, bestScore);
          if (beta <= alpha) break; // Alpha-beta pruning
        }
      }
      return bestScore;
    }
  }

  int? _findWinningMove(List<Player> board, Player player) {
    for (int i = 0; i < board.length; i++) {
      if (board[i] == Player.none) {
        board[i] = player;
        if (_checkWinner(board) == player) {
          board[i] = Player.none;
          return i;
        }
        board[i] = Player.none;
      }
    }
    return null;
  }

  // Find a move that creates a fork (two winning opportunities)
  int? _findForkMove(List<Player> board, Player player) {
    for (int i = 0; i < board.length; i++) {
      if (board[i] == Player.none) {
        board[i] = player;
        int winningOpportunities = 0;
        for (int j = 0; j < board.length; j++) {
          if (board[j] == Player.none) {
            board[j] = player;
            if (_checkWinner(board) == player) winningOpportunities++;
            board[j] = Player.none;
          }
        }
        board[i] = Player.none;
        if (winningOpportunities >= 2) return i;
      }
    }
    return null;
  }

  // Find corners that are opposite to the opponent's
  int? _findOppositeCornerMove(List<Player> board) {
    final oppositeCorners = {0: 8, 2: 6, 6: 2, 8: 0};
    for (final entry in oppositeCorners.entries) {
      if (board[entry.key] == Player.x && board[entry.value] == Player.none) {
        return entry.value;
      }
    }
    return null;
  }

  // Find strategic moves for medium difficulty
  int? _findStrategicMove(List<Player> board) {
    // Look for setups that could lead to future advantages
    final lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];
    for (final line in lines) {
      int oCount = 0;
      int emptyCount = 0;
      int emptyPos = -1;

      for (final pos in line) {
        if (board[pos] == Player.o) {
          oCount++;
        } else if (board[pos] == Player.none) {
          emptyCount++;
          emptyPos = pos;
        }
      }

      // If there's one O and two empty spots, this could set up a future win
      if (oCount == 1 && emptyCount == 2) {
        return emptyPos;
      }
    }

    return null;
  }

  Player? _checkWinner(List<Player> board) {
    final lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (final line in lines) {
      if (board[line[0]] != Player.none &&
          board[line[0]] == board[line[1]] &&
          board[line[0]] == board[line[2]]) {
        return board[line[0]];
      }
    }
    return null;
  }

  int _max(int a, int b) => a > b ? a : b;
  int _min(int a, int b) => a < b ? a : b;
}
