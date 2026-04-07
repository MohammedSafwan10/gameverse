class ChessCastlingRights {
  const ChessCastlingRights({
    this.whiteKingside = true,
    this.whiteQueenside = true,
    this.blackKingside = true,
    this.blackQueenside = true,
  });

  final bool whiteKingside;
  final bool whiteQueenside;
  final bool blackKingside;
  final bool blackQueenside;

  ChessCastlingRights copyWith({
    bool? whiteKingside,
    bool? whiteQueenside,
    bool? blackKingside,
    bool? blackQueenside,
  }) {
    return ChessCastlingRights(
      whiteKingside: whiteKingside ?? this.whiteKingside,
      whiteQueenside: whiteQueenside ?? this.whiteQueenside,
      blackKingside: blackKingside ?? this.blackKingside,
      blackQueenside: blackQueenside ?? this.blackQueenside,
    );
  }
}

class ChessPositionState {
  const ChessPositionState({
    required this.isWhiteToMove,
    required this.castlingRights,
    this.enPassantTarget,
    this.halfmoveClock = 0,
    this.fullmoveNumber = 1,
  });

  final bool isWhiteToMove;
  final ChessCastlingRights castlingRights;
  final String? enPassantTarget;
  final int halfmoveClock;
  final int fullmoveNumber;

  factory ChessPositionState.initial() {
    return const ChessPositionState(
      isWhiteToMove: true,
      castlingRights: ChessCastlingRights(),
    );
  }

  ChessPositionState copyWith({
    bool? isWhiteToMove,
    ChessCastlingRights? castlingRights,
    Object? enPassantTarget = _sentinel,
    int? halfmoveClock,
    int? fullmoveNumber,
  }) {
    return ChessPositionState(
      isWhiteToMove: isWhiteToMove ?? this.isWhiteToMove,
      castlingRights: castlingRights ?? this.castlingRights,
      enPassantTarget: identical(enPassantTarget, _sentinel)
          ? this.enPassantTarget
          : enPassantTarget as String?,
      halfmoveClock: halfmoveClock ?? this.halfmoveClock,
      fullmoveNumber: fullmoveNumber ?? this.fullmoveNumber,
    );
  }
}

const _sentinel = Object();
