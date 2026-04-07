import 'dart:math';
import 'dart:developer' as dev;
import 'package:get/get.dart';
import '../models/chess_board.dart';
import '../models/chess_move.dart';
import '../models/chess_piece.dart';

/// Production-grade Chess AI with proper difficulty separation.
///
/// Difficulty design philosophy:
/// - **Easy**: Depth 2, no quiescence, no move ordering, basic eval (material +
///   position tables only). 15% chance to pick a suboptimal move from top-5 pool.
///   Feels like a casual player who knows the rules but misses tactics.
/// - **Medium**: Depth 3 + quiescence depth 3, MVV-LVA move ordering, enhanced
///   eval (+ mobility + king safety + bishop pair + rook files). 5% suboptimal.
///   Feels like a club-level player who plays solid positional chess.
/// - **Hard**: Depth 4 + quiescence depth 4, full move ordering, complete eval
///   (+ pawn structure with doubled/isolated/passed pawns + endgame king tables).
///   Never intentionally suboptimal. Feels like a strong intermediate player.
class ChessAIService extends GetxService {
  final Random _random = Random();

  // Difficulty constants
  static const int easy = 1;
  static const int medium = 2;
  static const int hard = 3;

  int _difficulty = medium;

  // Observable states for monitoring AI
  final RxBool isThinking = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Keep old names accessible for backward compatibility
  static const int easyDepth = 1;
  static const int mediumDepth = 2;
  static const int hardDepth = 3;

  // ─── Piece values (centipawn scale — industry standard) ───
  static const Map<PieceType, int> pieceValues = {
    PieceType.pawn: 100,
    PieceType.knight: 320,
    PieceType.bishop: 330,
    PieceType.rook: 500,
    PieceType.queen: 900,
    PieceType.king: 20000,
  };

  // ─── Piece-Square Tables (from White's perspective, row 0 = rank 8) ───
  // For Black pieces the row index is mirrored: tableRow = 7 - row.

  static const List<List<int>> _pawnTable = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [50, 50, 50, 50, 50, 50, 50, 50],
    [10, 10, 20, 30, 30, 20, 10, 10],
    [5, 5, 10, 25, 25, 10, 5, 5],
    [0, 0, 0, 20, 20, 0, 0, 0],
    [5, -5, -10, 0, 0, -10, -5, 5],
    [5, 10, 10, -20, -20, 10, 10, 5],
    [0, 0, 0, 0, 0, 0, 0, 0],
  ];

  static const List<List<int>> _knightTable = [
    [-50, -40, -30, -30, -30, -30, -40, -50],
    [-40, -20, 0, 0, 0, 0, -20, -40],
    [-30, 0, 10, 15, 15, 10, 0, -30],
    [-30, 5, 15, 20, 20, 15, 5, -30],
    [-30, 0, 15, 20, 20, 15, 0, -30],
    [-30, 5, 10, 15, 15, 10, 5, -30],
    [-40, -20, 0, 5, 5, 0, -20, -40],
    [-50, -40, -30, -30, -30, -30, -40, -50],
  ];

  static const List<List<int>> _bishopTable = [
    [-20, -10, -10, -10, -10, -10, -10, -20],
    [-10, 0, 0, 0, 0, 0, 0, -10],
    [-10, 0, 10, 10, 10, 10, 0, -10],
    [-10, 5, 5, 10, 10, 5, 5, -10],
    [-10, 0, 5, 10, 10, 5, 0, -10],
    [-10, 10, 10, 10, 10, 10, 10, -10],
    [-10, 5, 0, 0, 0, 0, 5, -10],
    [-20, -10, -10, -10, -10, -10, -10, -20],
  ];

  static const List<List<int>> _rookTable = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [5, 10, 10, 10, 10, 10, 10, 5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [0, 0, 0, 5, 5, 0, 0, 0],
  ];

  static const List<List<int>> _queenTable = [
    [-20, -10, -10, -5, -5, -10, -10, -20],
    [-10, 0, 0, 0, 0, 0, 0, -10],
    [-10, 0, 5, 5, 5, 5, 0, -10],
    [-5, 0, 5, 5, 5, 5, 0, -5],
    [0, 0, 5, 5, 5, 5, 0, -5],
    [-10, 5, 5, 5, 5, 5, 0, -10],
    [-10, 0, 5, 0, 0, 0, 0, -10],
    [-20, -10, -10, -5, -5, -10, -10, -20],
  ];

  static const List<List<int>> _kingMiddleGameTable = [
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-20, -30, -30, -40, -40, -30, -30, -20],
    [-10, -20, -20, -20, -20, -20, -20, -10],
    [20, 20, 0, 0, 0, 0, 20, 20],
    [20, 30, 10, 0, 0, 10, 30, 20],
  ];

  // Endgame: king should centralise, not hide in the corner
  static const List<List<int>> _kingEndGameTable = [
    [-50, -40, -30, -20, -20, -30, -40, -50],
    [-30, -20, -10, 0, 0, -10, -20, -30],
    [-30, -10, 20, 30, 30, 20, -10, -30],
    [-30, -10, 30, 40, 40, 30, -10, -30],
    [-30, -10, 30, 40, 40, 30, -10, -30],
    [-30, -10, 20, 30, 30, 20, -10, -30],
    [-30, -30, 0, 0, 0, 0, -30, -30],
    [-50, -30, -30, -30, -30, -30, -30, -50],
  ];

  // ─── Search constants ───
  static const int _infinity = 999999;
  static const int _checkmateScore = 100000;

  // ─── Per-difficulty search configuration ───
  static const Map<int, _SearchConfig> _configs = {
    easy: _SearchConfig(
      mainDepth: 2,
      quiescenceDepth: 0, // no quiescence — misses tactical sequences
      useMoveOrdering: false,
      useMobility: false,
      useKingSafety: false,
      usePawnStructure: false,
      useRookFiles: false,
      blunderChance: 0.15,
      topMovesPool: 5,
    ),
    medium: _SearchConfig(
      mainDepth: 3,
      quiescenceDepth: 3,
      useMoveOrdering: true,
      useMobility: true,
      useKingSafety: true,
      usePawnStructure: false,
      useRookFiles: true,
      blunderChance: 0.05,
      topMovesPool: 3,
    ),
    hard: _SearchConfig(
      mainDepth: 4,
      quiescenceDepth: 4,
      useMoveOrdering: true,
      useMobility: true,
      useKingSafety: true,
      usePawnStructure: true,
      useRookFiles: true,
      blunderChance: 0.0,
      topMovesPool: 1,
    ),
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC API
  // ═══════════════════════════════════════════════════════════════════════════

  void setDifficulty(int difficulty) {
    dev.log('Setting AI difficulty to: $difficulty', name: 'ChessAIService');
    _difficulty = difficulty.clamp(easy, hard);
  }

  /// Returns the best legal engine move for the given color, or `null` if none.
  ChessMove? getBestEngineMove(ChessBoard chessBoard, PieceColor aiColor) {
    hasError.value = false;
    errorMessage.value = '';
    isThinking.value = true;

    try {
      final config = _configs[_difficulty]!;
      final boardCopy = chessBoard.deepCopy();
      final allMoves = _getAllValidMoves(boardCopy, aiColor);

      if (allMoves.isEmpty) {
        isThinking.value = false;
        return null;
      }

      final diffLabel = _difficulty == easy
          ? 'Easy'
          : _difficulty == medium
              ? 'Medium'
              : 'Hard';
      dev.log(
        'AI ($diffLabel) calculating for ${aiColor.name}, '
        '${allMoves.length} legal moves, depth ${config.mainDepth}'
        '${config.quiescenceDepth > 0 ? "+q${config.quiescenceDepth}" : ""}',
        name: 'ChessAIService',
      );

      // ── Score every root move ──
      final scoredMoves = <(ChessMove, int)>[];

      // Order root moves for better pruning (if enabled)
      final orderedMoves =
          config.useMoveOrdering ? _orderMoves(boardCopy, allMoves) : allMoves;

      int alpha = -_infinity;
      int beta = _infinity;

      for (final move in orderedMoves) {
        final copy = boardCopy.deepCopy();
        _makeMove(copy, move);

        final isWhiteNext = aiColor != PieceColor.white;
        final score = _minimax(
          copy,
          config.mainDepth - 1,
          alpha,
          beta,
          isWhiteNext,
          config,
        );

        scoredMoves.add((move, score));

        // Update alpha/beta window at root for better pruning
        if (aiColor == PieceColor.white) {
          alpha = max(alpha, score);
        } else {
          beta = min(beta, score);
        }
      }

      // Sort: best first for the AI's colour
      if (aiColor == PieceColor.white) {
        scoredMoves.sort((a, b) => b.$2.compareTo(a.$2));
      } else {
        scoredMoves.sort((a, b) => a.$2.compareTo(b.$2));
      }

      // ── Pick move (with difficulty-appropriate randomness) ──
      ChessMove chosen;
      if (config.blunderChance > 0 &&
          _random.nextDouble() < config.blunderChance &&
          scoredMoves.length > 1) {
        final poolSize = min(config.topMovesPool, scoredMoves.length);
        chosen = scoredMoves[_random.nextInt(poolSize)].$1;
        dev.log('AI picked from top-$poolSize pool (blunder path)',
            name: 'ChessAIService');
      } else {
        chosen = scoredMoves.first.$1;
      }

      isThinking.value = false;
      dev.log(
        'AI move: ${chosen.from}-${chosen.to} '
        '(best score: ${scoredMoves.first.$2})',
        name: 'ChessAIService',
      );
      return chosen;
    } catch (e, st) {
      dev.log('AI error: $e', name: 'ChessAIService', error: e, stackTrace: st);
      hasError.value = true;
      errorMessage.value = e.toString();
      isThinking.value = false;

      // Fallback: any legal move
      try {
        return _getRandomEngineMove(chessBoard, aiColor);
      } catch (_) {
        return null;
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MINIMAX + ALPHA-BETA PRUNING
  // ═══════════════════════════════════════════════════════════════════════════

  String? getBestMove(ChessBoard chessBoard, PieceColor aiColor) {
    final move = getBestEngineMove(chessBoard, aiColor);
    if (move == null) return null;
    return '${move.from}-${move.to}';
  }

  int _minimax(
    ChessBoard board,
    int depth,
    int alpha,
    int beta,
    bool isMaximizing,
    _SearchConfig config,
  ) {
    // At leaf depth, fall into quiescence (or static eval if q-depth = 0)
    if (depth <= 0) {
      if (config.quiescenceDepth > 0) {
        return _quiescence(
            board, config.quiescenceDepth, alpha, beta, isMaximizing, config);
      }
      return _evaluate(board, config);
    }

    final currentColor = isMaximizing ? PieceColor.white : PieceColor.black;
    List<ChessMove> moves = _getAllValidMoves(board, currentColor);

    // Terminal node detection
    if (moves.isEmpty) {
      if (_isKingInCheck(board, currentColor)) {
        // Checkmate — prefer faster mates
        return isMaximizing
            ? -_checkmateScore - depth
            : _checkmateScore + depth;
      }
      return 0; // Stalemate
    }

    // Move ordering for better pruning
    if (config.useMoveOrdering) {
      moves = _orderMoves(board, moves);
    }

    if (isMaximizing) {
      int best = -_infinity;
      for (final move in moves) {
        final copy = board.deepCopy();
        _makeMove(copy, move);
        final score = _minimax(copy, depth - 1, alpha, beta, false, config);
        best = max(best, score);
        alpha = max(alpha, score);
        if (beta <= alpha) break; // Beta cut-off
      }
      return best;
    } else {
      int best = _infinity;
      for (final move in moves) {
        final copy = board.deepCopy();
        _makeMove(copy, move);
        final score = _minimax(copy, depth - 1, alpha, beta, true, config);
        best = min(best, score);
        beta = min(beta, score);
        if (beta <= alpha) break; // Alpha cut-off
      }
      return best;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // QUIESCENCE SEARCH — eliminates the horizon effect
  // Only examines capture moves so the AI never stops evaluating in the middle
  // of a tactical exchange (e.g. queen takes pawn → pawn takes queen).
  // ═══════════════════════════════════════════════════════════════════════════

  int _quiescence(
    ChessBoard board,
    int depth,
    int alpha,
    int beta,
    bool isMaximizing,
    _SearchConfig config,
  ) {
    final standPat = _evaluate(board, config);
    if (depth <= 0) return standPat;

    final currentColor = isMaximizing ? PieceColor.white : PieceColor.black;
    List<ChessMove> captures = _getCaptureMovesOnly(board, currentColor);

    // Order captures by MVV-LVA for better pruning
    if (config.useMoveOrdering && captures.length > 1) {
      captures.sort((a, b) {
        final valA = _getPieceValueAt(board, a.to) * 10 -
            _getPieceValueAt(board, a.from);
        final valB = _getPieceValueAt(board, b.to) * 10 -
            _getPieceValueAt(board, b.from);
        return valB.compareTo(valA);
      });
    }

    if (isMaximizing) {
      if (standPat >= beta) return beta; // Standing pat is good enough
      alpha = max(alpha, standPat);

      for (final move in captures) {
        final copy = board.deepCopy();
        _makeMove(copy, move);
        final score = _quiescence(copy, depth - 1, alpha, beta, false, config);
        alpha = max(alpha, score);
        if (beta <= alpha) break;
      }
      return alpha;
    } else {
      if (standPat <= alpha) return alpha;
      beta = min(beta, standPat);

      for (final move in captures) {
        final copy = board.deepCopy();
        _makeMove(copy, move);
        final score = _quiescence(copy, depth - 1, alpha, beta, true, config);
        beta = min(beta, score);
        if (beta <= alpha) break;
      }
      return beta;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOVE ORDERING — MVV-LVA (Most Valuable Victim, Least Valuable Attacker)
  // Good move ordering makes alpha-beta pruning dramatically more effective,
  // effectively doubling the search depth for the same computation time.
  // ═══════════════════════════════════════════════════════════════════════════

  List<ChessMove> _orderMoves(ChessBoard board, List<ChessMove> moves) {
    final scored = moves.map((move) {
      int score = 0;

      // Priority 1: Captures — high victim / low attacker is best
      final victim = _getPieceAt(board, move.to);
      if (victim != null) {
        final attackerVal = _getPieceValueAt(board, move.from);
        final victimVal = pieceValues[victim.type] ?? 0;
        score += 10000 + victimVal * 10 - attackerVal;
      }

      // Priority 2: Central squares (d4/d5/e4/e5) get a small bonus
      final (toRow, toCol) = ChessPiece.notationToCoordinates(move.to);
      if ((toRow == 3 || toRow == 4) && (toCol == 3 || toCol == 4)) {
        score += 50;
      }

      // Priority 3: Moving to inner ring (c3-f3 to c6-f6)
      if (toRow >= 2 && toRow <= 5 && toCol >= 2 && toCol <= 5) {
        score += 20;
      }

      return (move, score);
    }).toList();

    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return scored.map((s) => s.$1).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EVALUATION FUNCTION
  // Difficulty controls which components are active:
  //   Easy   → material + position tables
  //   Medium → + mobility + king safety + bishop pair + rook files
  //   Hard   → + pawn structure (doubled / isolated / passed)
  // ═══════════════════════════════════════════════════════════════════════════

  int _evaluate(ChessBoard board, _SearchConfig config) {
    int score = 0;
    int whiteMaterial = 0;
    int blackMaterial = 0;
    int whiteBishops = 0;
    int blackBishops = 0;

    // ── Pass 1: Material + Piece-Square Tables ──
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.board[row][col];
        if (piece == null) continue;

        final matVal = pieceValues[piece.type] ?? 0;

        // Track material (excluding king) for endgame detection
        if (piece.type != PieceType.king) {
          if (piece.color == PieceColor.white) {
            whiteMaterial += matVal;
          } else {
            blackMaterial += matVal;
          }
        }

        if (piece.type == PieceType.bishop) {
          if (piece.color == PieceColor.white) {
            whiteBishops++;
          } else {
            blackBishops++;
          }
        }

        // Position value — mirror row for Black pieces
        final tableRow = piece.color == PieceColor.white ? row : 7 - row;
        final posVal = _getPositionValue(
          piece.type,
          tableRow,
          col,
          _isEndgame(whiteMaterial, blackMaterial),
        );

        final total = matVal + posVal;
        score += piece.color == PieceColor.white ? total : -total;
      }
    }

    // ── Bishop pair bonus (≈50 cp advantage) ──
    if (whiteBishops >= 2) score += 50;
    if (blackBishops >= 2) score -= 50;

    // ── Mobility (number of pseudo-legal moves, ≈5 cp / move) ──
    if (config.useMobility) {
      final wMob = _countMobility(board, PieceColor.white);
      final bMob = _countMobility(board, PieceColor.black);
      score += (wMob - bMob) * 5;
    }

    // ── King safety (pawn shield + open files near king) ──
    if (config.useKingSafety && !_isEndgame(whiteMaterial, blackMaterial)) {
      score += _evaluateKingSafety(board, PieceColor.white);
      score -= _evaluateKingSafety(board, PieceColor.black);
    }

    // ── Rook on open / semi-open file ──
    if (config.useRookFiles) {
      score += _evaluateRookFiles(board, PieceColor.white);
      score -= _evaluateRookFiles(board, PieceColor.black);
    }

    // ── Pawn structure (doubled, isolated, passed) — Hard only ──
    if (config.usePawnStructure) {
      score += _evaluatePawnStructure(board, PieceColor.white);
      score -= _evaluatePawnStructure(board, PieceColor.black);
    }

    return score;
  }

  // ─── Piece-square table lookup with endgame king support ───
  int _getPositionValue(PieceType type, int row, int col, bool isEndgame) {
    return switch (type) {
      PieceType.pawn => _pawnTable[row][col],
      PieceType.knight => _knightTable[row][col],
      PieceType.bishop => _bishopTable[row][col],
      PieceType.rook => _rookTable[row][col],
      PieceType.queen => _queenTable[row][col],
      PieceType.king => isEndgame
          ? _kingEndGameTable[row][col]
          : _kingMiddleGameTable[row][col],
    };
  }

  /// Endgame when both sides have ≤ queen + minor piece worth of material.
  bool _isEndgame(int whiteMaterial, int blackMaterial) {
    return whiteMaterial < 1300 && blackMaterial < 1300;
  }

  // ─── Mobility: count pseudo-legal moves for non-king pieces ───
  int _countMobility(ChessBoard board, PieceColor color) {
    int mobility = 0;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.board[row][col];
        if (piece != null &&
            piece.color == color &&
            piece.type != PieceType.king) {
          mobility += piece.getPossibleMoves(board.board).length;
        }
      }
    }
    return mobility;
  }

  // ─── King safety: pawn shield & open files near king ───
  int _evaluateKingSafety(ChessBoard board, PieceColor color) {
    int safety = 0;

    // Find king
    int kingRow = -1, kingCol = -1;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.board[row][col];
        if (piece != null &&
            piece.type == PieceType.king &&
            piece.color == color) {
          kingRow = row;
          kingCol = col;
          break;
        }
      }
      if (kingRow >= 0) break;
    }
    if (kingRow < 0) return 0;

    // Pawn shield: check the 3 squares directly in front of king
    final direction = color == PieceColor.white ? -1 : 1;
    for (int dc = -1; dc <= 1; dc++) {
      final shieldRow = kingRow + direction;
      final shieldCol = kingCol + dc;
      if (shieldRow < 0 || shieldRow > 7 || shieldCol < 0 || shieldCol > 7) {
        continue;
      }
      final piece = board.board[shieldRow][shieldCol];
      if (piece != null &&
          piece.type == PieceType.pawn &&
          piece.color == color) {
        safety += 15; // Pawn shield present
      } else {
        safety -= 10; // Missing pawn shield
      }
    }

    // Open files near king
    for (int dc = -1; dc <= 1; dc++) {
      final fileCol = kingCol + dc;
      if (fileCol < 0 || fileCol > 7) continue;
      bool hasFriendlyPawn = false;
      for (int r = 0; r < 8; r++) {
        final p = board.board[r][fileCol];
        if (p != null && p.type == PieceType.pawn && p.color == color) {
          hasFriendlyPawn = true;
          break;
        }
      }
      if (!hasFriendlyPawn) {
        safety -= 20; // Open file next to king is dangerous
      }
    }

    return safety;
  }

  // ─── Pawn structure: doubled, isolated, passed ───
  int _evaluatePawnStructure(ChessBoard board, PieceColor color) {
    int score = 0;
    final pawns = <(int, int)>[];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.board[row][col];
        if (piece != null &&
            piece.type == PieceType.pawn &&
            piece.color == color) {
          pawns.add((row, col));
        }
      }
    }

    for (final (pawnRow, pawnCol) in pawns) {
      // Doubled pawns (multiple on same file)
      final sameFile = pawns.where((p) => p.$2 == pawnCol).length;
      if (sameFile > 1) score -= 15;

      // Isolated pawns (no friendly pawns on adjacent files)
      bool hasNeighbour = false;
      for (final (_, otherCol) in pawns) {
        if ((otherCol - pawnCol).abs() == 1) {
          hasNeighbour = true;
          break;
        }
      }
      if (!hasNeighbour) score -= 20;

      // Passed pawn (no enemy pawns blocking or guarding ahead)
      bool isPassed = true;
      final dir = color == PieceColor.white ? -1 : 1;
      final endRow = color == PieceColor.white ? 0 : 7;
      int r = pawnRow + dir;
      while (color == PieceColor.white ? r >= endRow : r <= endRow) {
        for (int dc = -1; dc <= 1; dc++) {
          final c = pawnCol + dc;
          if (c < 0 || c > 7) continue;
          final p = board.board[r][c];
          if (p != null && p.type == PieceType.pawn && p.color != color) {
            isPassed = false;
            break;
          }
        }
        if (!isPassed) break;
        r += dir;
      }
      if (isPassed) {
        // More valuable the further the pawn has advanced
        final advancement = color == PieceColor.white ? 7 - pawnRow : pawnRow;
        score += 20 + advancement * 10;
      }
    }

    return score;
  }

  // ─── Rook on open / semi-open file ───
  int _evaluateRookFiles(ChessBoard board, PieceColor color) {
    int score = 0;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.board[row][col];
        if (piece == null ||
            piece.type != PieceType.rook ||
            piece.color != color) {
          continue;
        }

        bool hasFriendlyPawn = false;
        bool hasEnemyPawn = false;
        for (int r = 0; r < 8; r++) {
          final p = board.board[r][col];
          if (p != null && p.type == PieceType.pawn) {
            if (p.color == color) {
              hasFriendlyPawn = true;
            } else {
              hasEnemyPawn = true;
            }
          }
        }

        if (!hasFriendlyPawn && !hasEnemyPawn) {
          score += 25; // Fully open file
        } else if (!hasFriendlyPawn) {
          score += 15; // Semi-open file
        }
      }
    }
    return score;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CAPTURE-ONLY MOVE GENERATION (for quiescence search)
  // ═══════════════════════════════════════════════════════════════════════════

  List<ChessMove> _getCaptureMovesOnly(ChessBoard board, PieceColor color) {
    final captures = <ChessMove>[];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.board[row][col];
        if (piece == null || piece.color != color) continue;

        for (final move in board.getLegalMoves(piece.position)) {
          if (move.isCapture) {
            captures.add(move);
          }
        }
      }
    }
    return captures;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  int _getPieceValueAt(ChessBoard board, String position) {
    final piece = _getPieceAt(board, position);
    return piece != null ? (pieceValues[piece.type] ?? 0) : 0;
  }

  ChessPiece? _getPieceAt(ChessBoard board, String position) {
    final (row, col) = ChessPiece.notationToCoordinates(position);
    return board.board[row][col];
  }

  ChessMove? _getRandomEngineMove(ChessBoard board, PieceColor color) {
    final moves = _getAllValidMoves(board, color);
    if (moves.isEmpty) return null;
    return moves[_random.nextInt(moves.length)];
  }

  bool _isKingInCheck(ChessBoard board, PieceColor kingColor) {
    String kingPosition = '';
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.board[row][col];
        if (piece != null &&
            piece.type == PieceType.king &&
            piece.color == kingColor) {
          kingPosition = piece.position;
          break;
        }
      }
      if (kingPosition.isNotEmpty) break;
    }
    if (kingPosition.isEmpty) return false;

    final opponentColor =
        kingColor == PieceColor.white ? PieceColor.black : PieceColor.white;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.board[row][col];
        if (piece != null && piece.color == opponentColor) {
          if (piece.getPossibleMoves(board.board).contains(kingPosition)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void _makeMove(ChessBoard board, ChessMove move) {
    board.movePiece(
      move.from,
      move.to,
      promotionPiece: move.promotionPiece,
    );
  }

  /// Uses the board engine's typed legal moves.
  List<ChessMove> _getAllValidMoves(ChessBoard board, PieceColor color) {
    final moves = <ChessMove>[];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.board[row][col];
        if (piece != null && piece.color == color) {
          moves.addAll(board.getLegalMoves(piece.position));
        }
      }
    }
    return moves;
  }
}

// ─── Search configuration per difficulty ───
class _SearchConfig {
  final int mainDepth;
  final int quiescenceDepth;
  final bool useMoveOrdering;
  final bool useMobility;
  final bool useKingSafety;
  final bool usePawnStructure;
  final bool useRookFiles;
  final double blunderChance;
  final int topMovesPool;

  const _SearchConfig({
    required this.mainDepth,
    required this.quiescenceDepth,
    required this.useMoveOrdering,
    required this.useMobility,
    required this.useKingSafety,
    required this.usePawnStructure,
    required this.useRookFiles,
    required this.blunderChance,
    required this.topMovesPool,
  });
}

