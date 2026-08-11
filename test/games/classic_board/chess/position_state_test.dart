import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_board.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_piece.dart';

void main() {
  test('initial board exposes canonical starting position state', () {
    final board = ChessBoard();

    expect(board.positionState.isWhiteToMove, isTrue);
    expect(board.positionState.castlingRights.whiteKingside, isTrue);
    expect(board.positionState.castlingRights.whiteQueenside, isTrue);
    expect(board.positionState.castlingRights.blackKingside, isTrue);
    expect(board.positionState.castlingRights.blackQueenside, isTrue);
    expect(board.positionState.enPassantTarget, isNull);
    expect(board.positionState.halfmoveClock, 0);
    expect(board.positionState.fullmoveNumber, 1);
    expect(board.structuredMoveHistory, isEmpty);
  });

  test('double pawn move updates en passant target and structured move history',
      () {
    final board = ChessBoard();

    final moved = board.movePiece('e2', 'e4');

    expect(moved, isTrue);
    expect(board.positionState.isWhiteToMove, isFalse);
    expect(board.positionState.enPassantTarget, 'e3');
    expect(board.positionState.halfmoveClock, 0);
    expect(board.positionState.fullmoveNumber, 1);
    expect(board.structuredMoveHistory.length, 1);
    expect(board.structuredMoveHistory.first.from, 'e2');
    expect(board.structuredMoveHistory.first.to, 'e4');
    expect(board.structuredMoveHistory.first.movingPiece, PieceType.pawn);
    expect(board.structuredMoveHistory.first.isCapture, isFalse);
  });

  test('rook move updates castling rights and black move increments fullmove',
      () {
    final board = ChessBoard();

    board.board[6][7] = null;
    board.board[5][7] = null;
    board.board[4][7] = null;
    board.board[3][7] = null;
    board.board[2][7] = null;
    board.board[1][0] = null;
    board.board[6][0] = null;
    board.board[5][0] = null;

    final whiteMoved = board.movePiece('h1', 'h3');
    final blackMoved = board.movePiece('a8', 'a6');

    expect(whiteMoved, isTrue);
    expect(blackMoved, isTrue);
    expect(board.positionState.castlingRights.whiteKingside, isFalse);
    expect(board.positionState.castlingRights.whiteQueenside, isTrue);
    expect(board.positionState.castlingRights.blackQueenside, isFalse);
    expect(board.positionState.castlingRights.blackKingside, isTrue);
    expect(board.positionState.fullmoveNumber, 2);
  });

  test('deep copy preserves canonical position state and move history', () {
    final board = ChessBoard();
    board.movePiece('e2', 'e4');
    board.movePiece('e7', 'e5');

    final copy = board.deepCopy();

    expect(copy.positionState.isWhiteToMove, board.positionState.isWhiteToMove);
    expect(copy.positionState.enPassantTarget,
        board.positionState.enPassantTarget);
    expect(
        copy.positionState.fullmoveNumber, board.positionState.fullmoveNumber);
    expect(
        copy.structuredMoveHistory.length, board.structuredMoveHistory.length);
    expect(copy.moveHistory, board.moveHistory);
  });
}
