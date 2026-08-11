import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_board.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_piece.dart';

void main() {
  test('snapshot round-trip preserves canonical board state', () {
    final board = ChessBoard();
    board.movePiece('e2', 'e4');
    board.movePiece('e7', 'e5');
    board.movePiece('g1', 'f3');

    final snapshot = board.toSnapshot();
    final restored = ChessBoard();
    restored.loadSnapshot(snapshot);

    expect(restored.toFen(), board.toFen());
    expect(restored.moveHistory, board.moveHistory);
    expect(restored.structuredMoveHistory.length,
        board.structuredMoveHistory.length);
    expect(restored.positionHistory, board.positionHistory);
  });

  test('json round-trip preserves en passant and castling rights state', () {
    final board = ChessBoard();
    board.movePiece('e2', 'e4');
    board.movePiece('a7', 'a6');
    board.movePiece('h1', 'h3');

    final restored = ChessBoard();
    restored.loadJson(board.toJson());

    expect(restored.positionState.enPassantTarget,
        board.positionState.enPassantTarget);
    expect(restored.positionState.castlingRights.whiteKingside,
        board.positionState.castlingRights.whiteKingside);
    expect(restored.positionState.castlingRights.whiteQueenside,
        board.positionState.castlingRights.whiteQueenside);
    expect(restored.positionState.fullmoveNumber,
        board.positionState.fullmoveNumber);
  });

  test('snapshot preserves captured pieces', () {
    final board = ChessBoard();
    board.board = List.generate(8, (_) => List.generate(8, (_) => null));
    board.initializeBoard();
    board.movePiece('e2', 'e4');
    board.movePiece('d7', 'd5');
    board.movePiece('e4', 'd5');

    final restored = ChessBoard();
    restored.loadSnapshot(board.toSnapshot());

    expect(restored.capturedPieces.length, board.capturedPieces.length);
    expect(restored.capturedPieces.first.type, PieceType.pawn);
  });
}
