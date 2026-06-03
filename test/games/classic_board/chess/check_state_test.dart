import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_board.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_piece.dart';

void main() {
  test('pawn attacks are counted as check only on diagonals', () {
    final checkedBoard = ChessBoard()
      ..loadFen('8/8/8/8/8/3p4/4K3/7k w - - 0 1');
    final blockedBoard = ChessBoard()
      ..loadFen('8/8/8/8/8/4p3/4K3/7k w - - 0 1');

    expect(checkedBoard.isCheck(PieceColor.white), isTrue);
    expect(blockedBoard.isCheck(PieceColor.white), isFalse);
  });

  test('fools mate is detected as white checkmate', () {
    final board = ChessBoard()
      ..loadFen('rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 1 3');

    expect(board.isCheck(PieceColor.white), isTrue);
    expect(board.isCheckmate(PieceColor.white), isTrue);
    expect(board.isStalemate(PieceColor.white), isFalse);
  });

  test('king with no legal move but not in check is stalemate', () {
    final board = ChessBoard()
      ..loadFen('7k/5Q2/6K1/8/8/8/8/8 b - - 0 1');

    expect(board.isCheck(PieceColor.black), isFalse);
    expect(board.isCheckmate(PieceColor.black), isFalse);
    expect(board.isStalemate(PieceColor.black), isTrue);
  });

  test('pinned piece cannot move and expose king to check', () {
    final board = ChessBoard()
      ..loadFen('4r2k/8/8/8/8/8/4R3/4K3 w - - 0 1');

    final legalMoves = board.getLegalMoves('e2').map((move) => move.to).toSet();

    expect(legalMoves, contains('e8'));
    expect(legalMoves, isNot(contains('d2')));
    expect(board.movePiece('e2', 'd2'), isFalse);
  });
}
