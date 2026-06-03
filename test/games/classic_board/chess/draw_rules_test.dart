import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_board.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_piece.dart';
import 'package:gameverse/games/classic_board/chess/models/piece_types/bishop.dart';
import 'package:gameverse/games/classic_board/chess/models/piece_types/king.dart';
import 'package:gameverse/games/classic_board/chess/models/piece_types/knight.dart';

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

  test('threefold repetition ignores halfmove and fullmove counters', () {
    final board = ChessBoard();
    const positionKey = '8/8/8/8/8/8/8/4K2k w - -';
    board.loadFen('$positionKey 0 1');
    board.positionHistory
      ..clear()
      ..addAll([
        '$positionKey 0 1',
        '$positionKey 8 5',
        '$positionKey 26 14',
      ]);

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

  test('insufficient material detects same-colored bishops only', () {
    final board = ChessBoard();
    board.board = List.generate(8, (_) => List.generate(8, (_) => null));
    board.board[7][4] = King(color: PieceColor.white, position: 'e1');
    board.board[0][4] = King(color: PieceColor.black, position: 'e8');
    board.board[7][2] = Bishop(color: PieceColor.white, position: 'c1');
    board.board[2][3] = Bishop(color: PieceColor.black, position: 'd6');

    expect(board.isInsufficientMaterial(), isTrue);
  });

  test('king bishop and knight versus king has mating material', () {
    final board = ChessBoard();
    board.board = List.generate(8, (_) => List.generate(8, (_) => null));
    board.board[7][4] = King(color: PieceColor.white, position: 'e1');
    board.board[0][4] = King(color: PieceColor.black, position: 'e8');
    board.board[7][2] = Bishop(color: PieceColor.white, position: 'c1');
    board.board[7][1] = Knight(color: PieceColor.white, position: 'b1');

    expect(board.isInsufficientMaterial(), isFalse);
  });
}
