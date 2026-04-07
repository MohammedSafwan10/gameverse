import 'chess_piece.dart';

class ChessMove {
  const ChessMove({
    required this.from,
    required this.to,
    required this.movingPiece,
    this.capturedPiece,
    this.promotionPiece,
    this.isCastleKingside = false,
    this.isCastleQueenside = false,
    this.isEnPassant = false,
  });

  final String from;
  final String to;
  final PieceType movingPiece;
  final PieceType? capturedPiece;
  final PieceType? promotionPiece;
  final bool isCastleKingside;
  final bool isCastleQueenside;
  final bool isEnPassant;

  bool get isCapture => capturedPiece != null;
  bool get isPromotion => promotionPiece != null;
}
