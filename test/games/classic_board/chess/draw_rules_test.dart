import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_board.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_piece.dart';
import 'package:gameverse/games/classic_board/chess/models/piece_types/king.dart';

void main() {
  test('board tracks FEN snapshots for repetition detection', () {
    final board = ChessBoard();

    expect(board.positionHistory, isNotEmpty);
    expect(board.positionHistory.first, board.toFen());
  });

  test('threefold repetition is detected from repeated positions', () {
    final board = ChessBoard();

    final currentFen = board.toFen();
    board.positionHistory
      ..clear()
      ..addAll([currentFen, currentFen, currentFen]);

    expect(board.isThreefoldRepetition(), isTrue);
  });

  test('fifty move rule draw triggers at halfmove clock 100', () {
    final board = ChessBoard();
    board.positionState = board.positionState.copyWith(halfmoveClock: 100);

    expect(board.isFiftyMoveRuleDraw(), isTrue);
  });

  test('FEN reflects side to move, castling, and en passant target', () {
    final board = ChessBoard();
    board.positionState = board.positionState.copyWith(
      isWhiteToMove: false,
      enPassantTarget: 'e3',
      halfmoveClock: 4,
      fullmoveNumber: 7,
    );

    final fen = board.toFen();

    expect(fen, contains(' b '));
    expect(fen, contains(' KQkq '));
    expect(fen, contains(' e3 '));
    expect(fen.endsWith('4 7'), isTrue);
  });

  test('insufficient material still works with kings only', () {
    final board = ChessBoard();
    board.board = List.generate(8, (_) => List.generate(8, (_) => null));
    board.board[7][4] = King(color: PieceColor.white, position: 'e1');
    board.board[0][4] = King(color: PieceColor.black, position: 'e8');

    expect(board.isInsufficientMaterial(), isTrue);
  });
}
