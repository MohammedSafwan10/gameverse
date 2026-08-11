import 'dart:convert';

import 'chess_move.dart';
import 'chess_piece.dart';
import 'chess_position_state.dart';
import 'piece_types/pawn.dart';
import 'piece_types/rook.dart';
import 'piece_types/knight.dart';
import 'piece_types/bishop.dart';
import 'piece_types/queen.dart';
import 'piece_types/king.dart';

class ChessBoard {
  late List<List<ChessPiece?>> board;
  final List<String> moveHistory = [];
  final List<ChessPiece> capturedPieces = [];
  final List<ChessMove> structuredMoveHistory = [];
  final List<String> positionHistory = [];
  ChessPositionState positionState;

  ChessBoard({ChessPositionState? positionState})
      : positionState = positionState ?? ChessPositionState.initial() {
    initializeBoard();
  }

  String repetitionKey() {
    final parts = toFen().split(' ');
    if (parts[3] != '-' && !_hasLegalEnPassantCapture()) {
      parts[3] = '-';
    }
    return parts.take(4).join(' ');
  }

  bool _hasLegalEnPassantCapture() {
    final target = positionState.enPassantTarget;
    if (target == null) return false;

    final (_, targetCol) = ChessPiece.notationToCoordinates(target);
    final pawnRow = positionState.isWhiteToMove ? 3 : 4;
    final color =
        positionState.isWhiteToMove ? PieceColor.white : PieceColor.black;
    for (final pawnCol in <int>[targetCol - 1, targetCol + 1]) {
      if (pawnCol < 0 || pawnCol > 7) continue;
      final pawn = board[pawnRow][pawnCol];
      if (pawn?.type != PieceType.pawn || pawn?.color != color) continue;
      if (getLegalMoves(pawn!.position).any(
        (move) => move.isEnPassant && move.to == target,
      )) {
        return true;
      }
    }
    return false;
  }

  ChessBoard._empty({required this.positionState}) {
    board = List.generate(8, (_) => List.generate(8, (_) => null));
  }

  /// Creates a deep copy of the chess board
  ChessBoard deepCopy() {
    final copy = ChessBoard._empty(positionState: positionState.copyWith());

    // Copy each piece with the same state
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null) {
          final position = ChessPiece.coordinatesToNotation(row, col);
          switch (piece.type) {
            case PieceType.pawn:
              final newPiece = Pawn(
                color: piece.color,
                position: position,
              );
              newPiece.hasMoved = piece.hasMoved;
              copy.board[row][col] = newPiece;
              break;
            case PieceType.rook:
              final newPiece = Rook(
                color: piece.color,
                position: position,
              );
              newPiece.hasMoved = piece.hasMoved;
              copy.board[row][col] = newPiece;
              break;
            case PieceType.knight:
              final newPiece = Knight(
                color: piece.color,
                position: position,
              );
              newPiece.hasMoved = piece.hasMoved;
              copy.board[row][col] = newPiece;
              break;
            case PieceType.bishop:
              final newPiece = Bishop(
                color: piece.color,
                position: position,
              );
              newPiece.hasMoved = piece.hasMoved;
              copy.board[row][col] = newPiece;
              break;
            case PieceType.queen:
              final newPiece = Queen(
                color: piece.color,
                position: position,
              );
              newPiece.hasMoved = piece.hasMoved;
              copy.board[row][col] = newPiece;
              break;
            case PieceType.king:
              final newPiece = King(
                color: piece.color,
                position: position,
              );
              newPiece.hasMoved = piece.hasMoved;
              copy.board[row][col] = newPiece;
              break;
          }
        }
      }
    }

    // Copy move history
    copy.moveHistory.addAll(moveHistory);
    copy.structuredMoveHistory.addAll(structuredMoveHistory);
    copy.positionHistory.addAll(positionHistory);

    // Copy captured pieces list
    for (final capturedPiece in capturedPieces) {
      ChessPiece newPiece;
      switch (capturedPiece.type) {
        case PieceType.pawn:
          newPiece = Pawn(
            color: capturedPiece.color,
            position: capturedPiece.position,
          );
          break;
        case PieceType.rook:
          newPiece = Rook(
            color: capturedPiece.color,
            position: capturedPiece.position,
          );
          break;
        case PieceType.knight:
          newPiece = Knight(
            color: capturedPiece.color,
            position: capturedPiece.position,
          );
          break;
        case PieceType.bishop:
          newPiece = Bishop(
            color: capturedPiece.color,
            position: capturedPiece.position,
          );
          break;
        case PieceType.queen:
          newPiece = Queen(
            color: capturedPiece.color,
            position: capturedPiece.position,
          );
          break;
        case PieceType.king:
          newPiece = King(
            color: capturedPiece.color,
            position: capturedPiece.position,
          );
          break;
      }
      newPiece.hasMoved = capturedPiece.hasMoved;
      copy.capturedPieces.add(newPiece);
    }

    return copy;
  }

  void initializeBoard() {
    positionState = ChessPositionState.initial();
    moveHistory.clear();
    capturedPieces.clear();
    structuredMoveHistory.clear();
    positionHistory.clear();

    // Initialize 8x8 board
    board = List.generate(8, (row) => List.generate(8, (col) => null));

    // Place pawns
    for (int col = 0; col < 8; col++) {
      board[1][col] = Pawn(
        color: PieceColor.black,
        position: ChessPiece.coordinatesToNotation(1, col),
      );
      board[6][col] = Pawn(
        color: PieceColor.white,
        position: ChessPiece.coordinatesToNotation(6, col),
      );
    }

    // Place other pieces
    _placePiece(0, 0, PieceType.rook, PieceColor.black);
    _placePiece(0, 1, PieceType.knight, PieceColor.black);
    _placePiece(0, 2, PieceType.bishop, PieceColor.black);
    _placePiece(0, 3, PieceType.queen, PieceColor.black);
    _placePiece(0, 4, PieceType.king, PieceColor.black);
    _placePiece(0, 5, PieceType.bishop, PieceColor.black);
    _placePiece(0, 6, PieceType.knight, PieceColor.black);
    _placePiece(0, 7, PieceType.rook, PieceColor.black);

    _placePiece(7, 0, PieceType.rook, PieceColor.white);
    _placePiece(7, 1, PieceType.knight, PieceColor.white);
    _placePiece(7, 2, PieceType.bishop, PieceColor.white);
    _placePiece(7, 3, PieceType.queen, PieceColor.white);
    _placePiece(7, 4, PieceType.king, PieceColor.white);
    _placePiece(7, 5, PieceType.bishop, PieceColor.white);
    _placePiece(7, 6, PieceType.knight, PieceColor.white);
    _placePiece(7, 7, PieceType.rook, PieceColor.white);

    positionHistory.add(repetitionKey());
  }

  void _placePiece(int row, int col, PieceType type, PieceColor color) {
    final position = ChessPiece.coordinatesToNotation(row, col);
    board[row][col] = _createPiece(type, color, position);
  }

  ChessPiece _createPiece(PieceType type, PieceColor color, String position) {
    return switch (type) {
      PieceType.pawn => Pawn(color: color, position: position),
      PieceType.rook => Rook(color: color, position: position),
      PieceType.knight => Knight(color: color, position: position),
      PieceType.bishop => Bishop(color: color, position: position),
      PieceType.queen => Queen(color: color, position: position),
      PieceType.king => King(color: color, position: position),
    };
  }

  ChessPiece? getPieceAt(String position) {
    final (row, col) = ChessPiece.notationToCoordinates(position);
    return board[row][col];
  }

  bool movePiece(String from, String to, {PieceType? promotionPiece}) {
    final piece = getPieceAt(from);
    if (piece == null) return false;

    final legalMoves = getLegalMoves(from);
    final move = legalMoves.where((candidate) => candidate.to == to).firstWhere(
          (candidate) =>
              promotionPiece == null ||
              candidate.promotionPiece == promotionPiece,
          orElse: () => const ChessMove(
            from: '',
            to: '',
            movingPiece: PieceType.pawn,
          ),
        );

    if (move.from.isEmpty) return false;

    _applyMove(move, piece.color);
    return true;
  }

  void _applyMove(ChessMove move, PieceColor movingColor) {
    final (fromRow, fromCol) = ChessPiece.notationToCoordinates(move.from);
    final (toRow, toCol) = ChessPiece.notationToCoordinates(move.to);
    final piece = board[fromRow][fromCol];
    if (piece == null) return;

    final isCapture = move.isEnPassant || board[toRow][toCol] != null;
    final sanPrefix = _generateSanPrefix(move, piece, isCapture);

    ChessPiece? capturedPiece;
    if (move.isEnPassant) {
      final captureRow =
          movingColor == PieceColor.white ? toRow + 1 : toRow - 1;
      capturedPiece = board[captureRow][toCol];
      board[captureRow][toCol] = null;
    } else {
      capturedPiece = board[toRow][toCol];
    }

    if (capturedPiece != null) {
      capturedPieces.add(capturedPiece);
    }

    board[toRow][toCol] = piece;
    board[fromRow][fromCol] = null;
    piece.position = move.to;
    piece.hasMoved = true;

    if (move.isCastleKingside || move.isCastleQueenside) {
      final rookFrom = move.isCastleKingside
          ? ChessPiece.coordinatesToNotation(fromRow, 7)
          : ChessPiece.coordinatesToNotation(fromRow, 0);
      final rookTo = move.isCastleKingside
          ? ChessPiece.coordinatesToNotation(fromRow, toCol - 1)
          : ChessPiece.coordinatesToNotation(fromRow, toCol + 1);
      final (rookFromRow, rookFromCol) =
          ChessPiece.notationToCoordinates(rookFrom);
      final (rookToRow, rookToCol) = ChessPiece.notationToCoordinates(rookTo);
      final rook = board[rookFromRow][rookFromCol];
      if (rook != null) {
        board[rookToRow][rookToCol] = rook;
        board[rookFromRow][rookFromCol] = null;
        rook.position = rookTo;
        rook.hasMoved = true;
      }
    }

    if (move.isPromotion && move.promotionPiece != null) {
      board[toRow]
          [toCol] = _createPiece(move.promotionPiece!, movingColor, move.to)
        ..hasMoved = true;
    }

    _updatePositionState(
      board[toRow][toCol]!,
      move.movingPiece,
      move.from,
      move.to,
      capturedPiece,
    );
    final opponent =
        positionState.isWhiteToMove ? PieceColor.white : PieceColor.black;
    final suffix = isCheckmate(opponent)
        ? '#'
        : isCheck(opponent)
            ? '+'
            : '';
    moveHistory.add('$sanPrefix$suffix');
    structuredMoveHistory.add(move);
  }

  void _updatePositionState(
    ChessPiece piece,
    PieceType movingPieceType,
    String from,
    String to,
    ChessPiece? capturedPiece,
  ) {
    final (_, fromCol) = ChessPiece.notationToCoordinates(from);
    final (toRow, _) = ChessPiece.notationToCoordinates(to);

    final isPawnDoubleStep = movingPieceType == PieceType.pawn &&
        (ChessPiece.notationToCoordinates(from).$1 - toRow).abs() == 2;

    var castlingRights = positionState.castlingRights;
    if (movingPieceType == PieceType.king) {
      castlingRights = piece.color == PieceColor.white
          ? castlingRights.copyWith(
              whiteKingside: false,
              whiteQueenside: false,
            )
          : castlingRights.copyWith(
              blackKingside: false,
              blackQueenside: false,
            );
    } else if (movingPieceType == PieceType.rook) {
      if (piece.color == PieceColor.white) {
        if (from == 'a1') {
          castlingRights = castlingRights.copyWith(whiteQueenside: false);
        } else if (from == 'h1') {
          castlingRights = castlingRights.copyWith(whiteKingside: false);
        }
      } else {
        if (from == 'a8') {
          castlingRights = castlingRights.copyWith(blackQueenside: false);
        } else if (from == 'h8') {
          castlingRights = castlingRights.copyWith(blackKingside: false);
        }
      }
    }

    if (capturedPiece?.type == PieceType.rook) {
      switch (capturedPiece!.position) {
        case 'a1':
          castlingRights = castlingRights.copyWith(whiteQueenside: false);
          break;
        case 'h1':
          castlingRights = castlingRights.copyWith(whiteKingside: false);
          break;
        case 'a8':
          castlingRights = castlingRights.copyWith(blackQueenside: false);
          break;
        case 'h8':
          castlingRights = castlingRights.copyWith(blackKingside: false);
          break;
      }
    }

    positionState = positionState.copyWith(
      isWhiteToMove: !positionState.isWhiteToMove,
      castlingRights: castlingRights,
      enPassantTarget: isPawnDoubleStep
          ? ChessPiece.coordinatesToNotation(
              piece.color == PieceColor.white ? toRow + 1 : toRow - 1,
              fromCol,
            )
          : null,
      halfmoveClock:
          (movingPieceType == PieceType.pawn || capturedPiece != null)
              ? 0
              : positionState.halfmoveClock + 1,
      fullmoveNumber: piece.color == PieceColor.black
          ? positionState.fullmoveNumber + 1
          : positionState.fullmoveNumber,
    );
    positionHistory.add(repetitionKey());
  }

  String toFen() {
    final rows = <String>[];
    for (final rank in board) {
      var emptyCount = 0;
      final buffer = StringBuffer();
      for (final piece in rank) {
        if (piece == null) {
          emptyCount++;
          continue;
        }
        if (emptyCount > 0) {
          buffer.write(emptyCount);
          emptyCount = 0;
        }
        buffer.write(_fenSymbol(piece));
      }
      if (emptyCount > 0) {
        buffer.write(emptyCount);
      }
      rows.add(buffer.toString());
    }

    final rights = positionState.castlingRights;
    final castling = StringBuffer();
    if (rights.whiteKingside) castling.write('K');
    if (rights.whiteQueenside) castling.write('Q');
    if (rights.blackKingside) castling.write('k');
    if (rights.blackQueenside) castling.write('q');

    return '${rows.join('/')}'
        ' ${positionState.isWhiteToMove ? 'w' : 'b'}'
        ' ${castling.isEmpty ? '-' : castling.toString()}'
        ' ${positionState.enPassantTarget ?? '-'}'
        ' ${positionState.halfmoveClock}'
        ' ${positionState.fullmoveNumber}';
  }

  String _fenSymbol(ChessPiece piece) {
    final symbol = switch (piece.type) {
      PieceType.pawn => 'p',
      PieceType.rook => 'r',
      PieceType.knight => 'n',
      PieceType.bishop => 'b',
      PieceType.queen => 'q',
      PieceType.king => 'k',
    };
    return piece.color == PieceColor.white ? symbol.toUpperCase() : symbol;
  }

  bool isThreefoldRepetition() {
    final current = repetitionKey();
    return positionHistory
            .where((fen) => _normalizeRepetitionKey(fen) == current)
            .length >=
        3;
  }

  String _normalizeRepetitionKey(String fenOrKey) {
    final parts = fenOrKey.split(' ');
    if (parts.length == 6) {
      try {
        final historicalBoard = ChessBoard();
        historicalBoard.loadFen(fenOrKey);
        return historicalBoard.repetitionKey();
      } on FormatException {
        return parts.take(4).join(' ');
      }
    }
    if (parts.length == 4) {
      return fenOrKey;
    }
    return fenOrKey;
  }

  bool isFiftyMoveRuleDraw() {
    return positionState.halfmoveClock >= 100;
  }

  Map<String, dynamic> toSnapshot() {
    return {
      'fen': toFen(),
      'positionHistory': positionHistory,
      'moveHistory': moveHistory,
      'structuredMoveHistory': structuredMoveHistory
          .map((move) => {
                'from': move.from,
                'to': move.to,
                'movingPiece': move.movingPiece.name,
                'capturedPiece': move.capturedPiece?.name,
                'promotionPiece': move.promotionPiece?.name,
                'isCastleKingside': move.isCastleKingside,
                'isCastleQueenside': move.isCastleQueenside,
                'isEnPassant': move.isEnPassant,
              })
          .toList(),
      'capturedPieces': capturedPieces
          .map((piece) => {
                'type': piece.type.name,
                'color': piece.color.name,
                'position': piece.position,
                'hasMoved': piece.hasMoved,
              })
          .toList(),
    };
  }

  void loadSnapshot(Map<String, dynamic> snapshot) {
    final fen = snapshot['fen'] as String?;
    if (fen == null) {
      throw const FormatException('Missing fen in chess snapshot');
    }

    _loadFromFen(fen);

    moveHistory
      ..clear()
      ..addAll((snapshot['moveHistory'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>());

    structuredMoveHistory
      ..clear()
      ..addAll(((snapshot['structuredMoveHistory'] as List<dynamic>?) ??
              const <dynamic>[])
          .map((raw) {
        final data = raw as Map<String, dynamic>;
        return ChessMove(
          from: data['from'] as String,
          to: data['to'] as String,
          movingPiece: PieceType.values.byName(data['movingPiece'] as String),
          capturedPiece: data['capturedPiece'] == null
              ? null
              : PieceType.values.byName(data['capturedPiece'] as String),
          promotionPiece: data['promotionPiece'] == null
              ? null
              : PieceType.values.byName(data['promotionPiece'] as String),
          isCastleKingside: data['isCastleKingside'] as bool? ?? false,
          isCastleQueenside: data['isCastleQueenside'] as bool? ?? false,
          isEnPassant: data['isEnPassant'] as bool? ?? false,
        );
      }));

    capturedPieces
      ..clear()
      ..addAll(
          ((snapshot['capturedPieces'] as List<dynamic>?) ?? const <dynamic>[])
              .map((raw) {
        final data = raw as Map<String, dynamic>;
        final piece = _createPiece(
          PieceType.values.byName(data['type'] as String),
          PieceColor.values.byName(data['color'] as String),
          data['position'] as String,
        );
        piece.hasMoved = data['hasMoved'] as bool? ?? false;
        return piece;
      }));

    positionHistory
      ..clear()
      ..addAll(
          (snapshot['positionHistory'] as List<dynamic>? ?? const <dynamic>[])
              .cast<String>());
    if (positionHistory.isEmpty) {
      positionHistory.add(repetitionKey());
    }
  }

  void _loadFromFen(String fen) {
    final parts = fen.trim().split(RegExp(r'\s+'));
    if (parts.length != 6) {
      throw FormatException('Invalid FEN: $fen');
    }

    if (parts[1] != 'w' && parts[1] != 'b') {
      throw FormatException('Invalid FEN active color: ${parts[1]}');
    }

    final castling = parts[2];
    if (!RegExp(r'^(-|K?Q?k?q?)$').hasMatch(castling)) {
      throw FormatException('Invalid FEN castling rights: $castling');
    }

    final enPassant = parts[3];
    if (enPassant != '-' && !RegExp(r'^[a-h][36]$').hasMatch(enPassant)) {
      throw FormatException('Invalid FEN en passant target: $enPassant');
    }
    if (enPassant != '-' &&
        ((parts[1] == 'w' && !enPassant.endsWith('6')) ||
            (parts[1] == 'b' && !enPassant.endsWith('3')))) {
      throw FormatException(
          'FEN en passant target is inconsistent with active color');
    }

    final halfmoveClock = int.tryParse(parts[4]);
    final fullmoveNumber = int.tryParse(parts[5]);
    if (halfmoveClock == null || halfmoveClock < 0) {
      throw FormatException('Invalid FEN halfmove clock: ${parts[4]}');
    }
    if (fullmoveNumber == null || fullmoveNumber < 1) {
      throw FormatException('Invalid FEN fullmove number: ${parts[5]}');
    }

    final parsedBoard =
        List.generate(8, (_) => List<ChessPiece?>.filled(8, null));
    final ranks = parts[0].split('/');
    if (ranks.length != 8) {
      throw FormatException('Invalid FEN board: ${parts[0]}');
    }

    for (var row = 0; row < 8; row++) {
      var col = 0;
      for (final char in ranks[row].split('')) {
        final digit = int.tryParse(char);
        if (digit != null) {
          if (digit < 1 || digit > 8) {
            throw FormatException('Invalid FEN empty-square count: $char');
          }
          col += digit;
          if (col > 8) {
            throw FormatException('FEN rank ${8 - row} exceeds 8 squares');
          }
          continue;
        }

        if (col >= 8) {
          throw FormatException('FEN rank ${8 - row} exceeds 8 squares');
        }

        final color =
            char == char.toUpperCase() ? PieceColor.white : PieceColor.black;
        final type = switch (char.toLowerCase()) {
          'p' => PieceType.pawn,
          'r' => PieceType.rook,
          'n' => PieceType.knight,
          'b' => PieceType.bishop,
          'q' => PieceType.queen,
          'k' => PieceType.king,
          _ => throw FormatException('Invalid FEN piece: $char'),
        };
        final position = ChessPiece.coordinatesToNotation(row, col);
        final piece = _createPiece(type, color, position);
        piece.hasMoved = _inferHasMoved(type, color, position);
        parsedBoard[row][col] = piece;
        col++;
      }
      if (col != 8) {
        throw FormatException('FEN rank ${8 - row} contains $col squares');
      }
    }

    final whiteKings = parsedBoard
        .expand((rank) => rank)
        .where((piece) =>
            piece?.type == PieceType.king && piece?.color == PieceColor.white)
        .length;
    final blackKings = parsedBoard
        .expand((rank) => rank)
        .where((piece) =>
            piece?.type == PieceType.king && piece?.color == PieceColor.black)
        .length;
    if (whiteKings != 1 || blackKings != 1) {
      throw const FormatException('FEN must contain exactly one king per side');
    }
    if ([...parsedBoard.first, ...parsedBoard.last]
        .any((piece) => piece?.type == PieceType.pawn)) {
      throw const FormatException('FEN cannot place a pawn on a back rank');
    }

    final parsedState = ChessPositionState(
      isWhiteToMove: parts[1] == 'w',
      castlingRights: ChessCastlingRights(
        whiteKingside: castling.contains('K'),
        whiteQueenside: castling.contains('Q'),
        blackKingside: castling.contains('k'),
        blackQueenside: castling.contains('q'),
      ),
      enPassantTarget: enPassant == '-' ? null : enPassant,
      halfmoveClock: halfmoveClock,
      fullmoveNumber: fullmoveNumber,
    );

    final parsedPosition = ChessBoard._empty(positionState: parsedState)
      ..board = parsedBoard;
    final inactiveColor =
        parsedState.isWhiteToMove ? PieceColor.black : PieceColor.white;
    if (parsedPosition.isCheck(inactiveColor)) {
      throw const FormatException(
          'FEN is illegal: the side that just moved is in check');
    }

    board = parsedBoard;
    positionState = parsedState;
  }

  bool _inferHasMoved(PieceType type, PieceColor color, String position) {
    if (type == PieceType.pawn) {
      return position[1] != (color == PieceColor.white ? '2' : '7');
    }
    if (type == PieceType.king) {
      return position != (color == PieceColor.white ? 'e1' : 'e8');
    }
    if (type == PieceType.rook) {
      final startSquares =
          color == PieceColor.white ? {'a1', 'h1'} : {'a8', 'h8'};
      return !startSquares.contains(position);
    }
    return true;
  }

  String toJson() => jsonEncode(toSnapshot());

  void loadJson(String json) {
    loadSnapshot((jsonDecode(json) as Map).cast<String, dynamic>());
  }

  String _generateSanPrefix(
    ChessMove move,
    ChessPiece piece,
    bool isCapture,
  ) {
    if (move.isCastleKingside) return 'O-O';
    if (move.isCastleQueenside) return 'O-O-O';

    final promotion = move.promotionPiece == null
        ? ''
        : '=${_pieceSymbol(move.promotionPiece!)}';
    if (piece.type == PieceType.pawn) {
      return '${isCapture ? '${move.from[0]}x' : ''}${move.to}$promotion';
    }

    return '${_pieceSymbol(piece.type)}'
        '${_sanDisambiguation(move, piece)}'
        '${isCapture ? 'x' : ''}${move.to}$promotion';
  }

  String _pieceSymbol(PieceType type) => switch (type) {
        PieceType.king => 'K',
        PieceType.queen => 'Q',
        PieceType.rook => 'R',
        PieceType.bishop => 'B',
        PieceType.knight => 'N',
        PieceType.pawn => '',
      };

  String _sanDisambiguation(ChessMove move, ChessPiece piece) {
    final alternatives = <ChessPiece>[];
    for (final candidate in board.expand((rank) => rank)) {
      if (candidate == null ||
          identical(candidate, piece) ||
          candidate.color != piece.color ||
          candidate.type != piece.type) {
        continue;
      }
      if (getLegalMoves(candidate.position)
          .any((legal) => legal.to == move.to)) {
        alternatives.add(candidate);
      }
    }
    if (alternatives.isEmpty) return '';
    final fileIsUnique = alternatives
        .every((candidate) => candidate.position[0] != move.from[0]);
    if (fileIsUnique) return move.from[0];
    final rankIsUnique = alternatives
        .every((candidate) => candidate.position[1] != move.from[1]);
    return rankIsUnique ? move.from[1] : move.from;
  }

  List<String> getValidMoves(String position) {
    return getLegalMoves(position).map((move) => move.to).toSet().toList();
  }

  List<ChessMove> getLegalMoves(String position) {
    final piece = getPieceAt(position);
    if (piece == null) return [];

    final moves = <ChessMove>[];
    for (final to in piece.getPossibleMoves(board)) {
      final targetPiece = getPieceAt(to);
      // Checkmate ends the game; a king is never a capturable piece.
      if (targetPiece?.type == PieceType.king) continue;
      final isPromotion =
          piece.type == PieceType.pawn && _isPromotionSquare(piece.color, to);
      if (!wouldBeInCheck(piece.color, position, to)) {
        if (isPromotion) {
          for (final promotionPiece in const [
            PieceType.queen,
            PieceType.rook,
            PieceType.bishop,
            PieceType.knight,
          ]) {
            moves.add(ChessMove(
              from: position,
              to: to,
              movingPiece: piece.type,
              capturedPiece: targetPiece?.type,
              promotionPiece: promotionPiece,
            ));
          }
        } else {
          moves.add(ChessMove(
            from: position,
            to: to,
            movingPiece: piece.type,
            capturedPiece: targetPiece?.type,
          ));
        }
      }
    }

    moves.addAll(_getSpecialMoves(piece));
    return moves;
  }

  List<ChessMove> _getSpecialMoves(ChessPiece piece) {
    final moves = <ChessMove>[];
    if (piece.type == PieceType.king) {
      moves.addAll(_getCastlingMoves(piece));
    }
    if (piece.type == PieceType.pawn) {
      moves.addAll(_getEnPassantMoves(piece));
    }
    return moves;
  }

  bool _isPromotionSquare(PieceColor color, String position) {
    final (row, _) = ChessPiece.notationToCoordinates(position);
    return (color == PieceColor.white && row == 0) ||
        (color == PieceColor.black && row == 7);
  }

  List<ChessMove> _getCastlingMoves(ChessPiece king) {
    if (king.hasMoved || isCheck(king.color)) return [];

    final rights = positionState.castlingRights;
    final moves = <ChessMove>[];
    final kingside = king.color == PieceColor.white
        ? rights.whiteKingside
        : rights.blackKingside;
    final queenside = king.color == PieceColor.white
        ? rights.whiteQueenside
        : rights.blackQueenside;

    if (kingside && _canCastle(king.color, kingside: true)) {
      moves.add(ChessMove(
        from: king.position,
        to: king.color == PieceColor.white ? 'g1' : 'g8',
        movingPiece: PieceType.king,
        isCastleKingside: true,
      ));
    }

    if (queenside && _canCastle(king.color, kingside: false)) {
      moves.add(ChessMove(
        from: king.position,
        to: king.color == PieceColor.white ? 'c1' : 'c8',
        movingPiece: PieceType.king,
        isCastleQueenside: true,
      ));
    }

    return moves;
  }

  bool _canCastle(PieceColor color, {required bool kingside}) {
    final rank = color == PieceColor.white ? 7 : 0;
    final kingSquare = ChessPiece.coordinatesToNotation(rank, 4);
    final rookSquare = ChessPiece.coordinatesToNotation(rank, kingside ? 7 : 0);
    final rook = getPieceAt(rookSquare);
    if (rook == null ||
        rook.type != PieceType.rook ||
        rook.color != color ||
        rook.hasMoved) {
      return false;
    }

    final betweenCols = kingside ? [5, 6] : [1, 2, 3];
    for (final col in betweenCols) {
      if (board[rank][col] != null) return false;
    }

    final travelCols = kingside ? [4, 5, 6] : [4, 3, 2];
    for (final col in travelCols) {
      if (_isSquareAttacked(rank, col,
          color == PieceColor.white ? PieceColor.black : PieceColor.white)) {
        return false;
      }
    }

    return getPieceAt(kingSquare)?.type == PieceType.king;
  }

  List<ChessMove> _getEnPassantMoves(ChessPiece pawn) {
    final target = positionState.enPassantTarget;
    if (target == null) return [];

    final (fromRow, fromCol) = ChessPiece.notationToCoordinates(pawn.position);
    final (toRow, toCol) = ChessPiece.notationToCoordinates(target);
    final direction = pawn.color == PieceColor.white ? -1 : 1;

    if (toRow == fromRow + direction && (toCol - fromCol).abs() == 1) {
      if (board[toRow][toCol] != null) return [];
      final capturedPawn = board[fromRow][toCol];
      if (capturedPawn == null ||
          capturedPawn.type != PieceType.pawn ||
          capturedPawn.color == pawn.color) {
        return [];
      }
      if (!wouldBeInCheck(pawn.color, pawn.position, target,
          isEnPassant: true)) {
        return [
          ChessMove(
            from: pawn.position,
            to: target,
            movingPiece: PieceType.pawn,
            capturedPiece: PieceType.pawn,
            isEnPassant: true,
          )
        ];
      }
    }

    return [];
  }

  bool _isSquareAttacked(int row, int col, PieceColor byColor) {
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece == null || piece.color != byColor) continue;

        if (piece.type == PieceType.pawn) {
          final direction = byColor == PieceColor.white ? -1 : 1;
          if (row == r + direction && (col == c - 1 || col == c + 1)) {
            return true;
          }
          continue;
        }

        if (piece.isValidMove(r, c, row, col, board)) {
          return true;
        }
      }
    }
    return false;
  }

  bool isCheck(PieceColor color) {
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null &&
            piece.color == color &&
            piece.type == PieceType.king) {
          final attackingColor =
              color == PieceColor.white ? PieceColor.black : PieceColor.white;
          return _isSquareAttacked(row, col, attackingColor);
        }
      }
    }

    return false;
  }

  bool isCheckmate(PieceColor color) {
    if (!isCheck(color)) return false;

    // Check if any piece can make a legal move
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == color) {
          final moves = getValidMoves(piece.position);
          if (moves.isNotEmpty) {
            return false;
          }
        }
      }
    }

    return true;
  }

  bool isStalemate(PieceColor color) {
    if (isCheck(color)) return false;

    // Check if any piece can make a legal move
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == color) {
          final moves = getValidMoves(piece.position);
          if (moves.isNotEmpty) {
            return false;
          }
        }
      }
    }

    return true;
  }

  bool isInsufficientMaterial() {
    final whiteNonKings = <ChessPiece>[];
    final blackNonKings = <ChessPiece>[];

    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece == null || piece.type == PieceType.king) continue;
        if (piece.color == PieceColor.white) {
          whiteNonKings.add(piece);
        } else {
          blackNonKings.add(piece);
        }
      }
    }

    final allNonKings = [...whiteNonKings, ...blackNonKings];
    if (allNonKings.isEmpty) return true;

    if (allNonKings.any((piece) =>
        piece.type == PieceType.pawn ||
        piece.type == PieceType.rook ||
        piece.type == PieceType.queen)) {
      return false;
    }

    if (allNonKings.length == 1) {
      return true; // K+B vs K or K+N vs K
    }

    // With bishops only, mate is impossible when every bishop is confined to
    // the same square color. Knights are deliberately excluded here: K+NN vs K
    // and minor-piece-vs-minor-piece positions can reach a legal checkmate even
    // though it cannot necessarily be forced.
    if (allNonKings.every((piece) => piece.type == PieceType.bishop)) {
      final squareColor = _sameColorSquare(allNonKings.first.position);
      return allNonKings
          .every((piece) => _sameColorSquare(piece.position) == squareColor);
    }

    return false;
  }

  /// Whether [color] could checkmate by some legal sequence from this material.
  /// Used for flag-fall adjudication, which is side-specific.
  bool hasPossibleMatingMaterial(PieceColor color) {
    final own = <ChessPiece>[];
    final opponent = <ChessPiece>[];
    for (final piece in board.expand((rank) => rank)) {
      if (piece == null || piece.type == PieceType.king) continue;
      (piece.color == color ? own : opponent).add(piece);
    }

    if (own.any((piece) =>
        piece.type == PieceType.pawn ||
        piece.type == PieceType.rook ||
        piece.type == PieceType.queen)) {
      return true;
    }

    final bishops =
        own.where((piece) => piece.type == PieceType.bishop).toList();
    final knights = own.where((piece) => piece.type == PieceType.knight).length;
    if (bishops.isNotEmpty && knights > 0) return true;
    if (bishops.length >= 2) {
      final colors = bishops.map((piece) {
        final (row, col) = ChessPiece.notationToCoordinates(piece.position);
        return (row + col).isEven;
      }).toSet();
      if (colors.length > 1) return true;
    }
    if (knights >= 3) return true;

    // Extra opposing material can make otherwise impossible self-blocking mate
    // constructions legal (for example bishop versus a blocked opposing piece).
    return own.isNotEmpty && opponent.isNotEmpty;
  }

  bool _sameColorSquare(String position) {
    final (row, col) = ChessPiece.notationToCoordinates(position);
    return (row + col).isEven;
  }

  void loadFen(String fen) {
    _loadFromFen(fen);
    moveHistory.clear();
    structuredMoveHistory.clear();
    capturedPieces.clear();
    positionHistory
      ..clear()
      ..add(repetitionKey());
  }

  bool wouldBeInCheck(
    PieceColor color,
    String from,
    String to, {
    bool isEnPassant = false,
  }) {
    final (fromRow, fromCol) = ChessPiece.notationToCoordinates(from);
    final (toRow, toCol) = ChessPiece.notationToCoordinates(to);

    final piece = board[fromRow][fromCol];
    final capturedPiece = board[toRow][toCol];
    ChessPiece? enPassantCapturedPiece;

    if (isEnPassant && piece?.type == PieceType.pawn) {
      final captureRow = color == PieceColor.white ? toRow + 1 : toRow - 1;
      enPassantCapturedPiece = board[captureRow][toCol];
      board[captureRow][toCol] = null;
    }

    board[toRow][toCol] = piece;
    board[fromRow][fromCol] = null;
    if (piece != null) {
      piece.position = to;
    }

    final wouldBeInCheck = isCheck(color);

    board[fromRow][fromCol] = piece;
    board[toRow][toCol] = capturedPiece;
    if (isEnPassant && piece?.type == PieceType.pawn) {
      final captureRow = color == PieceColor.white ? toRow + 1 : toRow - 1;
      board[captureRow][toCol] = enPassantCapturedPiece;
    }
    if (piece != null) {
      piece.position = from;
    }

    return wouldBeInCheck;
  }
}
