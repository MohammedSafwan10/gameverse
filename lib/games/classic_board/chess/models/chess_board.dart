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

    positionHistory.add(toFen());
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
              promotionPiece == null || candidate.promotionPiece == promotionPiece,
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

    ChessPiece? capturedPiece;
    if (move.isEnPassant) {
      final captureRow = movingColor == PieceColor.white ? toRow + 1 : toRow - 1;
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
      final (rookFromRow, rookFromCol) = ChessPiece.notationToCoordinates(rookFrom);
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
      board[toRow][toCol] = _createPiece(move.promotionPiece!, movingColor, move.to)
        ..hasMoved = true;
    }

    final moveNotation =
        _generateMoveNotation(board[toRow][toCol]!, move.from, move.to, capturedPiece != null);
    moveHistory.add(moveNotation);
    structuredMoveHistory.add(move);
    _updatePositionState(board[toRow][toCol]!, move.from, move.to, capturedPiece != null);
  }

  void _updatePositionState(
    ChessPiece piece,
    String from,
    String to,
    bool isCapture,
  ) {
    final (_, fromCol) = ChessPiece.notationToCoordinates(from);
    final (toRow, _) = ChessPiece.notationToCoordinates(to);

    final isPawnDoubleStep = piece.type == PieceType.pawn &&
        (ChessPiece.notationToCoordinates(from).$1 - toRow).abs() == 2;

    var castlingRights = positionState.castlingRights;
    if (piece.type == PieceType.king) {
      castlingRights = piece.color == PieceColor.white
          ? castlingRights.copyWith(
              whiteKingside: false,
              whiteQueenside: false,
            )
          : castlingRights.copyWith(
              blackKingside: false,
              blackQueenside: false,
            );
    } else if (piece.type == PieceType.rook) {
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

    final lastCaptured = capturedPieces.lastOrNull;
    if (lastCaptured?.type == PieceType.rook) {
      switch (lastCaptured!.position) {
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
      halfmoveClock: (piece.type == PieceType.pawn || isCapture)
          ? 0
          : positionState.halfmoveClock + 1,
      fullmoveNumber: piece.color == PieceColor.black
          ? positionState.fullmoveNumber + 1
          : positionState.fullmoveNumber,
    );
    positionHistory.add(toFen());
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
    final current = toFen();
    return positionHistory.where((fen) => fen == current).length >= 3;
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
      ..addAll(((snapshot['capturedPieces'] as List<dynamic>?) ??
              const <dynamic>[])
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
      ..addAll((snapshot['positionHistory'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>());
    if (positionHistory.isEmpty) {
      positionHistory.add(toFen());
    }
  }

  void _loadFromFen(String fen) {
    final parts = fen.split(' ');
    if (parts.length != 6) {
      throw FormatException('Invalid FEN: $fen');
    }

    board = List.generate(8, (_) => List.generate(8, (_) => null));
    final ranks = parts[0].split('/');
    if (ranks.length != 8) {
      throw FormatException('Invalid FEN board: ${parts[0]}');
    }

    for (var row = 0; row < 8; row++) {
      var col = 0;
      for (final char in ranks[row].split('')) {
        final digit = int.tryParse(char);
        if (digit != null) {
          col += digit;
          continue;
        }

        final color = char == char.toUpperCase() ? PieceColor.white : PieceColor.black;
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
        board[row][col] = piece;
        col++;
      }
    }

    final castling = parts[2];
    positionState = ChessPositionState(
      isWhiteToMove: parts[1] == 'w',
      castlingRights: ChessCastlingRights(
        whiteKingside: castling.contains('K'),
        whiteQueenside: castling.contains('Q'),
        blackKingside: castling.contains('k'),
        blackQueenside: castling.contains('q'),
      ),
      enPassantTarget: parts[3] == '-' ? null : parts[3],
      halfmoveClock: int.parse(parts[4]),
      fullmoveNumber: int.parse(parts[5]),
    );
  }

  bool _inferHasMoved(PieceType type, PieceColor color, String position) {
    if (type == PieceType.pawn) {
      return position[1] != (color == PieceColor.white ? '2' : '7');
    }
    if (type == PieceType.king) {
      return position != (color == PieceColor.white ? 'e1' : 'e8');
    }
    if (type == PieceType.rook) {
      final startSquares = color == PieceColor.white ? {'a1', 'h1'} : {'a8', 'h8'};
      return !startSquares.contains(position);
    }
    return true;
  }

  String toJson() => jsonEncode(toSnapshot());

  void loadJson(String json) {
    loadSnapshot((jsonDecode(json) as Map).cast<String, dynamic>());
  }

  String _generateMoveNotation(
      ChessPiece piece, String from, String to, bool isCapture) {
    if (piece.type == PieceType.pawn) {
      if (isCapture) {
        return '${from[0]}x$to';
      }
      return to;
    }

    final pieceSymbol = switch (piece.type) {
      PieceType.king => 'K',
      PieceType.queen => 'Q',
      PieceType.rook => 'R',
      PieceType.bishop => 'B',
      PieceType.knight => 'N',
      PieceType.pawn => '',
    };

    return '$pieceSymbol${isCapture ? 'x' : ''}$to';
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
    final kingside = king.color == PieceColor.white ? rights.whiteKingside : rights.blackKingside;
    final queenside = king.color == PieceColor.white ? rights.whiteQueenside : rights.blackQueenside;

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
    if (rook == null || rook.type != PieceType.rook || rook.color != color || rook.hasMoved) {
      return false;
    }

    final betweenCols = kingside ? [5, 6] : [1, 2, 3];
    for (final col in betweenCols) {
      if (board[rank][col] != null) return false;
    }

    final travelCols = kingside ? [4, 5, 6] : [4, 3, 2];
    for (final col in travelCols) {
      if (_isSquareAttacked(rank, col, color == PieceColor.white ? PieceColor.black : PieceColor.white)) {
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
      if (!wouldBeInCheck(pawn.color, pawn.position, target, isEnPassant: true)) {
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
    // Find king's position
    String? kingPosition;
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null &&
            piece.color == color &&
            piece.type == PieceType.king) {
          kingPosition = ChessPiece.coordinatesToNotation(row, col);
          break;
        }
      }
      if (kingPosition != null) break;
    }

    if (kingPosition == null) return false;

    // Check if any enemy piece can capture the king
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color != color) {
          final moves = piece.getPossibleMoves(board);
          if (moves.contains(kingPosition)) {
            return true;
          }
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

    if (allNonKings.length == 2) {
      final bishops = allNonKings.where((piece) => piece.type == PieceType.bishop).toList();
      final knights = allNonKings.where((piece) => piece.type == PieceType.knight).toList();

      if (knights.length == 2) {
        return true; // K+N vs K+N or K+NN vs K
      }

      if (bishops.length == 2) {
        return _sameColorSquare(bishops[0].position) == _sameColorSquare(bishops[1].position);
      }

      if (bishops.length == 1 && knights.length == 1) {
        return whiteNonKings.length == 1 && blackNonKings.length == 1;
      }

      return whiteNonKings.length == 1 && blackNonKings.length == 1;
    }

    return false;
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
      ..add(toFen());
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
