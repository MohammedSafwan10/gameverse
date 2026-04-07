import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_board.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_move.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_piece.dart';
import 'package:gameverse/games/classic_board/chess/models/piece_types/king.dart';
import 'package:gameverse/games/classic_board/chess/models/piece_types/pawn.dart';
import 'package:gameverse/games/classic_board/chess/services/ai_service.dart';

void main() {
  test('AI returns a typed legal move on a constrained position', () {
    final board = ChessBoard();
    final ai = ChessAIService();

    board.board = List.generate(8, (_) => List.generate(8, (_) => null));
    board.board[7][4] = King(color: PieceColor.white, position: 'e1');
    board.board[0][4] = King(color: PieceColor.black, position: 'e8');
    board.board[1][0] = Pawn(color: PieceColor.black, position: 'a7')..hasMoved = true;
    board.positionState = board.positionState.copyWith(isWhiteToMove: false);

    final move = ai.getBestEngineMove(board, PieceColor.black);
    final legalMoves = <String>{
      for (final piece in board.board.expand((row) => row))
        if (piece != null && piece.color == PieceColor.black)
          for (final legalMove in board.getLegalMoves(piece.position))
            '${legalMove.from}-${legalMove.to}',
    };

    expect(move, isA<ChessMove>());
    expect(move, isNotNull);
    expect(legalMoves, contains('${move!.from}-${move.to}'));
  });

  test('AI compatibility wrapper still returns from-to notation', () {
    final board = ChessBoard();
    final ai = ChessAIService();

    board.board = List.generate(8, (_) => List.generate(8, (_) => null));
    board.board[7][4] = King(color: PieceColor.white, position: 'e1');
    board.board[0][4] = King(color: PieceColor.black, position: 'e8');
    board.board[1][0] = Pawn(color: PieceColor.black, position: 'a7')..hasMoved = true;
    board.positionState = board.positionState.copyWith(isWhiteToMove: false);

    final move = ai.getBestMove(board, PieceColor.black);

    expect(move, isNotNull);
    expect(move, contains('-'));
  });
}
