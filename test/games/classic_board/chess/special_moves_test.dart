import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_board.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_piece.dart';
import 'package:gameverse/games/classic_board/chess/models/piece_types/king.dart';
import 'package:gameverse/games/classic_board/chess/models/piece_types/pawn.dart';
import 'package:gameverse/games/classic_board/chess/models/piece_types/queen.dart';
import 'package:gameverse/games/classic_board/chess/models/piece_types/rook.dart';

void main() {
  test('quiet promotion resets the halfmove clock', () {
    final board = ChessBoard()..loadFen('4k3/P7/8/8/8/8/8/4K3 w - - 99 1');

    expect(
      board.movePiece('a7', 'a8', promotionPiece: PieceType.queen),
      isTrue,
    );
    expect(board.positionState.halfmoveClock, 0);
    expect(board.moveHistory.last, 'a8=Q+');
  });

  test('SAN records castling and disambiguates identical pieces', () {
    final castle = ChessBoard()
      ..loadFen('r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1');
    expect(castle.movePiece('e1', 'g1'), isTrue);
    expect(castle.moveHistory.last, 'O-O');

    final knights = ChessBoard()..loadFen('4k3/8/8/8/8/8/8/1N2KN2 w - - 0 1');
    expect(knights.movePiece('b1', 'd2'), isTrue);
    expect(knights.moveHistory.last, 'Nbd2');
  });

  test('kingside castling appears in legal moves when path is clear', () {
    final board = ChessBoard();

    board.board[7][5] = null;
    board.board[7][6] = null;
    board.board[6][5] = null;
    board.board[6][6] = null;

    final legalMoves = board.getLegalMoves('e1');
    final castleMove = legalMoves.where((move) => move.to == 'g1').single;

    expect(castleMove.isCastleKingside, isTrue);
  });

  test('castling moves rook and updates king castling rights', () {
    final board = ChessBoard();

    board.board[7][5] = null;
    board.board[7][6] = null;
    board.board[6][5] = null;
    board.board[6][6] = null;

    final moved = board.movePiece('e1', 'g1');

    expect(moved, isTrue);
    expect(board.getPieceAt('g1'), isA<King>());
    expect(board.getPieceAt('f1'), isA<Rook>());
    expect(board.getPieceAt('h1'), isNull);
    expect(board.positionState.castlingRights.whiteKingside, isFalse);
    expect(board.positionState.castlingRights.whiteQueenside, isFalse);
    expect(board.structuredMoveHistory.last.isCastleKingside, isTrue);
  });

  test('castling is blocked when king travels through an attacked square', () {
    final board = ChessBoard();

    board.board = List.generate(8, (_) => List.generate(8, (_) => null));
    board.board[7][4] = King(color: PieceColor.white, position: 'e1');
    board.board[7][7] = Rook(color: PieceColor.white, position: 'h1');
    board.board[0][4] = King(color: PieceColor.black, position: 'e8');
    board.board[0][5] = Rook(color: PieceColor.black, position: 'f8');

    final legalMoves = board.getLegalMoves('e1');

    expect(legalMoves.where((move) => move.to == 'g1'), isEmpty);
  });

  test('moving a rook clears only its matching castling right', () {
    final board = ChessBoard();

    board.board[6][7] = null;

    final moved = board.movePiece('h1', 'h2');

    expect(moved, isTrue);
    expect(board.positionState.castlingRights.whiteKingside, isFalse);
    expect(board.positionState.castlingRights.whiteQueenside, isTrue);
  });

  test('capturing a corner rook clears that rook castling right', () {
    final board = ChessBoard();

    board.board = List.generate(8, (_) => List.generate(8, (_) => null));
    board.board[7][4] = King(color: PieceColor.white, position: 'e1');
    board.board[7][7] = Rook(color: PieceColor.white, position: 'h1');
    board.board[0][4] = King(color: PieceColor.black, position: 'e8');
    board.board[4][7] = Queen(color: PieceColor.black, position: 'h4');
    board.positionState = board.positionState.copyWith(isWhiteToMove: false);

    final moved = board.movePiece('h4', 'h1');

    expect(moved, isTrue);
    expect(board.getPieceAt('h1')!.type, PieceType.queen);
    expect(board.positionState.castlingRights.whiteKingside, isFalse);
    expect(board.positionState.castlingRights.whiteQueenside, isTrue);
  });

  test('en passant target creates legal en passant move', () {
    final board = ChessBoard();

    board.board = List.generate(8, (_) => List.generate(8, (_) => null));
    board.board[7][4] = King(color: PieceColor.white, position: 'e1');
    board.board[0][4] = King(color: PieceColor.black, position: 'e8');
    board.board[3]
        [4] = Pawn(color: PieceColor.white, position: 'e5')..hasMoved = true;
    board.board[3]
        [3] = Pawn(color: PieceColor.black, position: 'd5')..hasMoved = true;
    board.positionState = board.positionState.copyWith(
      isWhiteToMove: true,
      enPassantTarget: 'd6',
    );

    final legalMoves = board.getLegalMoves('e5');
    final enPassant = legalMoves.where((move) => move.to == 'd6').single;

    expect(enPassant.isEnPassant, isTrue);
    expect(enPassant.capturedPiece, PieceType.pawn);
  });

  test('en passant move removes captured pawn and clears target', () {
    final board = ChessBoard();

    board.board = List.generate(8, (_) => List.generate(8, (_) => null));
    board.board[7][4] = King(color: PieceColor.white, position: 'e1');
    board.board[0][4] = King(color: PieceColor.black, position: 'e8');
    board.board[3]
        [4] = Pawn(color: PieceColor.white, position: 'e5')..hasMoved = true;
    board.board[3]
        [3] = Pawn(color: PieceColor.black, position: 'd5')..hasMoved = true;
    board.positionState = board.positionState.copyWith(
      isWhiteToMove: true,
      enPassantTarget: 'd6',
    );

    final moved = board.movePiece('e5', 'd6');

    expect(moved, isTrue);
    expect(board.getPieceAt('d6'), isA<Pawn>());
    expect(board.getPieceAt('d5'), isNull);
    expect(board.capturedPieces.last.type, PieceType.pawn);
    expect(board.positionState.enPassantTarget, isNull);
    expect(board.structuredMoveHistory.last.isEnPassant, isTrue);
  });

  test('en passant is illegal when it exposes own king to check', () {
    final board = ChessBoard();

    board.board = List.generate(8, (_) => List.generate(8, (_) => null));
    board.board[7][4] = King(color: PieceColor.white, position: 'e1');
    board.board[0][0] = King(color: PieceColor.black, position: 'a8');
    board.board[0][4] = Rook(color: PieceColor.black, position: 'e8');
    board.board[3]
        [4] = Pawn(color: PieceColor.white, position: 'e5')..hasMoved = true;
    board.board[3]
        [3] = Pawn(color: PieceColor.black, position: 'd5')..hasMoved = true;
    board.positionState = board.positionState.copyWith(
      isWhiteToMove: true,
      enPassantTarget: 'd6',
    );

    final legalMoves = board.getLegalMoves('e5');

    expect(legalMoves.where((move) => move.to == 'd6'), isEmpty);
    expect(board.movePiece('e5', 'd6'), isFalse);
  });

  test(
      'pawn promotion exposes all promotion options and applies selected piece',
      () {
    final board = ChessBoard();

    board.board = List.generate(8, (_) => List.generate(8, (_) => null));
    board.board[7][4] = King(color: PieceColor.white, position: 'e1');
    board.board[0][4] = King(color: PieceColor.black, position: 'e8');
    board.board[1]
        [0] = Pawn(color: PieceColor.white, position: 'a7')..hasMoved = true;
    board.positionState = board.positionState.copyWith(isWhiteToMove: true);

    final promotionMoves =
        board.getLegalMoves('a7').where((move) => move.to == 'a8').toList();
    expect(promotionMoves.map((move) => move.promotionPiece).toSet(), {
      PieceType.queen,
      PieceType.rook,
      PieceType.bishop,
      PieceType.knight,
    });

    final moved = board.movePiece('a7', 'a8', promotionPiece: PieceType.knight);

    expect(moved, isTrue);
    expect(board.getPieceAt('a8')!.type, PieceType.knight);
    expect(board.structuredMoveHistory.last.promotionPiece, PieceType.knight);
  });
}
