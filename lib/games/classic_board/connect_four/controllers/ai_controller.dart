import 'dart:math';
import '../models/board.dart';
import 'game_controller.dart';

/// Hard search runs outside the rendering isolate.
int searchConnectFourMove((Board, AIDifficulty) input) {
  final ai = AIController()..setDifficulty(input.$2);
  return ai.findBestMove(input.$1, CellState.player2);
}

/// Center-ordered, gravity-aware alpha-beta search with bounded heuristics.
class AIController {
  AIController({Random? random}) : _random = random ?? Random();
  final Random _random;
  AIDifficulty _difficulty = AIDifficulty.medium;
  void setDifficulty(AIDifficulty value) => _difficulty = value;
  static const order = [3, 2, 4, 1, 5, 0, 6];
  CellState other(CellState p) =>
      p == CellState.player1 ? CellState.player2 : CellState.player1;
  int findBestMove(Board board, CellState player) {
    if (player == CellState.empty ||
        board.status != GameStatus.playing ||
        winner(board.cells) != CellState.empty) {
      return -1;
    }
    final moves = order.where(board.isValidMove).toList();
    if (moves.isEmpty) return -1;
    if (_difficulty == AIDifficulty.easy && _random.nextDouble() < .7) {
      return moves[_random.nextInt(moves.length)];
    }
    for (final c in moves) {
      if (winner(drop(board.cells, c, player)) == player) return c;
    }
    if (_difficulty == AIDifficulty.easy) {
      return moves[_random.nextInt(moves.length)];
    }
    for (final c in moves) {
      if (winner(drop(board.cells, c, other(player))) == other(player)) {
        return c;
      }
    }
    var best = moves.first, score = -1000000, alpha = -1000000;
    final depth = _difficulty == AIDifficulty.hard ? 5 : 3;
    for (final c in moves) {
      final value = search(drop(board.cells, c, player), depth - 1,
          other(player), player, alpha, 1000000);
      if (value > score) {
        score = value;
        best = c;
      }
      alpha = max(alpha, score);
    }
    return best;
  }

  static List<List<CellState>> drop(
      List<List<CellState>> cells, int col, CellState p) {
    final next = cells.map((r) => List<CellState>.from(r)).toList();
    for (var r = 5; r >= 0; r--) {
      if (next[r][col] == CellState.empty) {
        next[r][col] = p;
        break;
      }
    }
    return next;
  }

  static CellState winner(List<List<CellState>> cells) {
    for (var r = 0; r < 6; r++) {
      for (var c = 0; c < 7; c++) {
        final p = cells[r][c];
        if (p == CellState.empty) continue;
        for (final (dr, dc) in const [(0, 1), (1, 0), (1, 1), (1, -1)]) {
          final er = r + dr * 3, ec = c + dc * 3;
          if (er < 0 || er >= 6 || ec < 0 || ec >= 7) continue;
          if (List.generate(4, (i) => cells[r + dr * i][c + dc * i])
              .every((v) => v == p)) {
            return p;
          }
        }
      }
    }
    return CellState.empty;
  }

  int search(List<List<CellState>> cells, int depth, CellState turn,
      CellState root, int alpha, int beta) {
    final win = winner(cells);
    if (win != CellState.empty) {
      return win == root ? 100000 + depth : -100000 - depth;
    }
    final moves = order.where((c) => cells[0][c] == CellState.empty).toList();
    if (moves.isEmpty) return 0;
    if (depth == 0) return evaluate(cells, root);
    var best = turn == root ? -1000000 : 1000000;
    for (final c in moves) {
      final score = search(
          drop(cells, c, turn), depth - 1, other(turn), root, alpha, beta);
      if (turn == root) {
        best = max(best, score);
        alpha = max(alpha, best);
      } else {
        best = min(best, score);
        beta = min(beta, best);
      }
      if (alpha >= beta) break;
    }
    return best;
  }

  int evaluate(List<List<CellState>> cells, CellState root) {
    var score = cells.where((r) => r[3] == root).length * 6;
    for (var r = 0; r < 6; r++) {
      for (var c = 0; c < 7; c++) {
        for (final (dr, dc) in const [(0, 1), (1, 0), (1, 1), (1, -1)]) {
          final er = r + dr * 3, ec = c + dc * 3;
          if (er < 0 || er >= 6 || ec < 0 || ec >= 7) continue;
          var own = 0, foe = 0, playable = false;
          for (var i = 0; i < 4; i++) {
            final rr = r + dr * i, cc = c + dc * i, v = cells[rr][cc];
            if (v == root) {
              own++;
            } else if (v != CellState.empty) {
              foe++;
            } else if (rr == 5 || cells[rr + 1][cc] != CellState.empty) {
              playable = true;
            }
          }
          if (foe == 0) {
            score += own == 3
                ? (playable ? 90 : 20)
                : own == 2
                    ? 8
                    : 0;
          }
          if (own == 0) {
            score -= foe == 3
                ? (playable ? 120 : 25)
                : foe == 2
                    ? 10
                    : 0;
          }
        }
      }
    }
    return score;
  }
}
