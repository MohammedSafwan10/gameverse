import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_board.dart';

void main() {
  test('malformed FEN ranks are rejected without corrupting the board', () {
    final board = ChessBoard();
    final before = board.toFen();

    expect(
      () => board.loadFen('9/8/8/8/8/8/8/4K2k w - - 0 1'),
      throwsFormatException,
    );
    expect(board.toFen(), before);
  });

  test('FEN rejects invalid side, counters, and missing kings', () {
    final invalid = [
      '4k3/8/8/8/8/8/8/4K3 x - - 0 1',
      '4k3/8/8/8/8/8/8/4K3 w - - -1 1',
      '4k3/8/8/8/8/8/8/4K3 w - - 0 0',
      '8/8/8/8/8/8/8/4K3 w - - 0 1',
    ];

    for (final fen in invalid) {
      expect(() => ChessBoard().loadFen(fen), throwsFormatException,
          reason: fen);
    }
  });

  test('FEN en passant target must match the active side', () {
    expect(
      () => ChessBoard().loadFen('4k3/8/8/8/4P3/8/8/4K3 w - e3 0 1'),
      throwsFormatException,
    );
    expect(
      () => ChessBoard().loadFen('4k3/8/8/4p3/8/8/8/4K3 b - e6 0 1'),
      throwsFormatException,
    );
  });

  test('forged en passant target does not create a ghost capture', () {
    final board = ChessBoard()..loadFen('4k3/8/8/3P4/8/8/8/4K3 w - e6 0 1');

    expect(board.getValidMoves('d5'), isNot(contains('e6')));
  });

  test('FEN rejects adjacent kings and pawns on back ranks', () {
    final board = ChessBoard();

    expect(
      () => board.loadFen('8/8/8/8/8/8/4k3/4K3 w - - 0 1'),
      throwsFormatException,
    );
    expect(
      () => board.loadFen('P3k3/8/8/8/8/8/8/4K3 w - - 0 1'),
      throwsFormatException,
    );
  });
}
