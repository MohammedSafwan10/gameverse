import 'game_state.dart';

class MergeResult {
  final List<List<int>> board;
  final int gained;
  final bool changed;
  final List<TileMotion> motions;
  const MergeResult(this.board, this.gained, this.changed,
      [this.motions = const []]);
}

class TileMotion {
  final int value, fromX, fromY, toX, toY;
  const TileMotion(this.value, this.fromX, this.fromY, this.toX, this.toY);
}

/// Pure 2048 rules. Newly merged tiles never merge again on the same swipe.
class MergeEngine {
  static MergeResult move(List<List<int>> source, Direction direction) {
    final board = List.generate(4, (_) => List.filled(4, 0));
    var gained = 0;
    final motions = <TileMotion>[];
    for (var lane = 0; lane < 4; lane++) {
      (int, int) cell(int i) => switch (direction) {
            Direction.left => (lane, i),
            Direction.right => (lane, 3 - i),
            Direction.up => (i, lane),
            Direction.down => (3 - i, lane),
          };
      final values = <int>[];
      final origins = <int>[];
      for (var i = 0; i < 4; i++) {
        final (y, x) = cell(i);
        if (source[y][x] != 0) {
          values.add(source[y][x]);
          origins.add(i);
        }
      }
      final merged = <int>[];
      for (var i = 0; i < values.length; i++) {
        var value = values[i];
        final (toY, toX) = cell(merged.length);
        final (fromY, fromX) = cell(origins[i]);
        motions.add(TileMotion(value, fromX, fromY, toX, toY));
        if (i + 1 < values.length && values[i + 1] == value) {
          final (secondY, secondX) = cell(origins[i + 1]);
          motions.add(TileMotion(value, secondX, secondY, toX, toY));
          value *= 2;
          gained += value;
          i++;
        }
        merged.add(value);
      }
      for (var i = 0; i < merged.length; i++) {
        final (y, x) = cell(i);
        board[y][x] = merged[i];
      }
    }
    var changed = false;
    for (var y = 0; y < 4; y++) {
      for (var x = 0; x < 4; x++) {
        changed |= board[y][x] != source[y][x];
      }
    }
    return MergeResult(board, gained, changed, List.unmodifiable(motions));
  }

  static bool canMove(List<List<int>> board) {
    for (var y = 0; y < 4; y++) {
      for (var x = 0; x < 4; x++) {
        final v = board[y][x];
        if (v == 0 ||
            (x < 3 && board[y][x + 1] == v) ||
            (y < 3 && board[y + 1][x] == v)) {
          return true;
        }
      }
    }
    return false;
  }
}
