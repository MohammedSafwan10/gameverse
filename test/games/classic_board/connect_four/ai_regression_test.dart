import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/classic_board/connect_four/controllers/ai_controller.dart';
import 'package:gameverse/games/classic_board/connect_four/controllers/game_controller.dart';
import 'package:gameverse/games/classic_board/connect_four/models/board.dart';

void main() {
  test('Hard isolate entry point returns a legal center opening', () async {
    final move = await compute(
        searchConnectFourMove, (Board.empty(), AIDifficulty.hard));
    expect(move, 3);
  });
  Board sequence(List<int> moves) {
    var cells = Board.empty().cells;
    var p = CellState.player1;
    for (final c in moves) {
      cells = AIController.drop(cells, c, p);
      p = p == CellState.player1 ? CellState.player2 : CellState.player1;
    }
    return Board(cells: cells);
  }

  test('invalid columns are rejected without indexing the board', () {
    final b = Board.empty();
    for (final c in [-99, -1, 7, 99]) {
      expect(b.isValidMove(c), false);
      expect(b.getLowestEmptyRow(c), -1);
    }
  });
  for (final difficulty in AIDifficulty.values) {
    test('$difficulty returns only valid moves without mutating input', () {
      final ai = AIController(random: Random(4))..setDifficulty(difficulty);
      var b = Board.empty();
      for (var turn = 0; turn < 42; turn++) {
        final snapshot = b.cells.map((r) => List<CellState>.from(r)).toList();
        if (AIController.winner(b.cells) != CellState.empty || b.isFull) break;
        final p = turn.isEven ? CellState.player1 : CellState.player2;
        final move = ai.findBestMove(b, p);
        expect(b.isValidMove(move), true);
        expect(b.cells, snapshot);
        b = Board(cells: AIController.drop(b.cells, move, p));
      }
    });
    test('$difficulty refuses terminal and empty-player searches', () {
      final ai = AIController()..setDifficulty(difficulty);
      expect(
          ai.findBestMove(Board.empty().copyWith(status: GameStatus.draw),
              CellState.player2),
          -1);
      expect(ai.findBestMove(Board.empty(), CellState.empty), -1);
      expect(
          ai.findBestMove(sequence([0, 4, 1, 4, 2, 5, 3]), CellState.player2),
          -1);
    });
  }
  for (final difficulty in [AIDifficulty.medium, AIDifficulty.hard]) {
    test('$difficulty takes its immediate win before blocking', () {
      final ai = AIController(random: Random(0))..setDifficulty(difficulty);
      expect(
          ai.findBestMove(sequence([0, 4, 1, 4, 2, 4, 6]), CellState.player2),
          4);
    });
    test('$difficulty blocks horizontal and vertical wins', () {
      final ai = AIController(random: Random(0))..setDifficulty(difficulty);
      expect(ai.findBestMove(sequence([0, 6, 1, 6, 2]), CellState.player2), 3);
      expect(ai.findBestMove(sequence([0, 6, 0, 6, 0]), CellState.player2), 0);
    });
  }
  test('diagonal wins detected in both directions', () {
    for (final left in [true, false]) {
      final cells =
          Board.empty().cells.map((r) => List<CellState>.from(r)).toList();
      for (var i = 0; i < 4; i++) {
        cells[5 - i][left ? i : 6 - i] = CellState.player1;
      }
      expect(AIController.winner(cells), CellState.player1);
    }
  });
  test('full fixture is a draw, not a false diagonal win', () {
    final rows = [
      'RRYYRRY',
      'YYRRYYR',
      'RRYYRRY',
      'YYRRYYR',
      'RRYYRRY',
      'YYRRYYR'
    ];
    final board = Board(
        cells: rows
            .map((s) => s
                .split('')
                .map((c) => c == 'R' ? CellState.player1 : CellState.player2)
                .toList())
            .toList());
    expect(board.isFull, true);
    expect(AIController.winner(board.cells), CellState.empty);
    expect(AIController().findBestMove(board, CellState.player2), -1);
  });
}
