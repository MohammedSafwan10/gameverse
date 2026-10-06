import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/puzzle/block_merge/models/game_state.dart';
import 'package:gameverse/games/puzzle/block_merge/models/merge_engine.dart';

void main() {
  List<List<int>> row(List<int> line) =>
      [line, List.filled(4, 0), List.filled(4, 0), List.filled(4, 0)];
  test('equal tiles merge once, with compression through gaps', () {
    final result = MergeEngine.move(row([2, 2, 2, 2]), Direction.left);
    expect(result.board.first, [4, 4, 0, 0]);
    expect(result.gained, 8);
    expect(MergeEngine.move(row([2, 0, 2, 4]), Direction.left).board.first,
        [4, 4, 0, 0]);
    expect(MergeEngine.move(row([4, 4, 8, 0]), Direction.left).board.first,
        [8, 8, 0, 0]);
  });
  test('right and down align at the correct edge', () {
    expect(MergeEngine.move(row([2, 2, 2, 0]), Direction.right).board.first,
        [0, 0, 2, 4]);
    final board = [
      [2, 0, 0, 0],
      [2, 0, 0, 0],
      [4, 0, 0, 0],
      [0, 0, 0, 0]
    ];
    expect(MergeEngine.move(board, Direction.down).board.map((r) => r.first),
        [0, 0, 4, 4]);
    expect(MergeEngine.move(board, Direction.up).board.map((r) => r.first),
        [4, 4, 0, 0]);
  });
  test('blocked boards check both horizontal and vertical neighbors', () {
    final board = [
      [2, 4, 2, 4],
      [4, 2, 4, 2],
      [2, 4, 2, 4],
      [4, 2, 4, 2]
    ];
    expect(MergeEngine.canMove(board), false);
    board[3][0] = 2;
    expect(MergeEngine.canMove(board), true);
  });
  test('1000 boards preserve mass, input and powers of two in every direction',
      () {
    final random = Random(2048);
    for (var n = 0; n < 1000; n++) {
      final board = List.generate(
          4,
          (_) => List.generate(
              4, (_) => random.nextBool() ? 0 : 1 << (1 + random.nextInt(10))));
      final before = board.map((r) => r.toList()).toList();
      for (final direction in Direction.values) {
        final result = MergeEngine.move(board, direction);
        int sum(List<List<int>> b) =>
            b.expand((r) => r).fold(0, (a, v) => a + v);
        expect(sum(result.board), sum(board));
        expect(board, before);
        expect(
            result.board
                .expand((r) => r)
                .every((v) => v == 0 || v & (v - 1) == 0),
            true);
        expect(result.gained, greaterThanOrEqualTo(0));
      }
    }
  });
}
