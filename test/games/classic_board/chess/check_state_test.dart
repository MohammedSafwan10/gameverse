import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_board.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_piece.dart';

void main() {
  test('legal move generation never allows capturing a king', () {
    final board = ChessBoard()..loadFen('4k3/8/8/8/8/8/4R3/4K3 b - - 0 1');

    expect(board.getValidMoves('e2'), isNot(contains('e8')));
  });

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
      ..movePiece('f2', 'f3')
      ..movePiece('e7', 'e5')
      ..movePiece('g2', 'g4')
      ..movePiece('d8', 'h4');

    expect(board.isCheck(PieceColor.white), isTrue);
    expect(board.isCheckmate(PieceColor.white), isTrue);
    expect(board.moveHistory.last, 'Qh4#');
    expect(board.isStalemate(PieceColor.white), isFalse);
  });

  test('king with no legal move but not in check is stalemate', () {
    final board = ChessBoard()..loadFen('7k/5Q2/6K1/8/8/8/8/8 b - - 0 1');

    expect(board.isCheck(PieceColor.black), isFalse);
    expect(board.isCheckmate(PieceColor.black), isFalse);
    expect(board.isStalemate(PieceColor.black), isTrue);
  });

  test('pinned piece cannot move and expose king to check', () {
    final board = ChessBoard()..loadFen('4r2k/8/8/8/8/8/4R3/4K3 w - - 0 1');

    final legalMoves = board.getLegalMoves('e2').map((move) => move.to).toSet();

    expect(legalMoves, contains('e8'));
    expect(legalMoves, isNot(contains('d2')));
    expect(board.movePiece('e2', 'd2'), isFalse);
  });
}
