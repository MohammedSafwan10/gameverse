import 'package:get/get.dart';
import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../services/ai_service.dart';
import '../models/chess_board.dart';
import '../models/chess_move.dart';
import '../models/chess_piece.dart';
import '../widgets/promotion_dialog.dart';

enum ChessGameMode { local, ai, training }

enum ChessGameState { initial, inProgress, check, checkmate, stalemate, draw }

enum ChessEndReason {
  none,
  checkmate,
  timeout,
  resignation,
  stalemate,
  insufficientMaterial,
  repetition,
  fiftyMoveRule,
}

class ChessGameController extends GetxController {
  final ChessStorageService storageService;
  final ChessSoundService soundService;
  late ChessBoard board;
  late ChessAIService aiService;
  final Random _random = Random();

  // Game state variables
  final Rx<ChessGameState> gameState = ChessGameState.initial.obs;
  final Rx<ChessGameMode> gameMode = ChessGameMode.local.obs;
  final RxBool isWhiteTurn = true.obs;
  final RxList<String> moveHistory = <String>[].obs;
  final RxList<String> capturedPieces = <String>[].obs;
  final RxBool isGamePaused = false.obs;
  final RxBool hasSavedMatch = false.obs;
  final Rx<ChessEndReason> endReason = ChessEndReason.none.obs;
  int _gameGeneration = 0;
  bool _isDisposed = false;
  bool _gameResultRecorded = false;
  bool _promotionDialogOpen = false;
  Future<void> _storageChain = Future<void>.value();

  // Board state
  final Rxn<ChessPiece> selectedPiece = Rxn<ChessPiece>();
  final RxSet<String> legalMovesForSelection = <String>{}.obs;
  final Rxn<(String, String)> lastMove = Rxn<(String, String)>();

  // Settings
  final RxBool showLegalMoves = true.obs;
  final RxBool showLastMove = true.obs;
  final RxString boardTheme = 'classic'.obs;

  // Timer settings
  final RxBool timerEnabled = false.obs;
  final RxInt timePerPlayer = 10.obs; // minutes
  final RxInt whiteTimeRemaining = 0.obs;
  final RxInt blackTimeRemaining = 0.obs;
  Timer? _timer;

  // AI settings
  final RxInt aiDifficulty = 2.obs; // 1: Easy, 2: Medium, 3: Hard

  ChessGameController(this.storageService, this.soundService) {
    aiService = Get.find<ChessAIService>();
  }

  @override
  void onInit() {
    super.onInit();
    board = ChessBoard();
    _loadSettings();
    _initializeGame();
  }

  void _initializeGame() {
    _advanceGameGeneration();
    _timer?.cancel();
    final savedState = storageService.loadSerializedGameState();
    if (savedState != null && savedState.isNotEmpty) {
      try {
        board.loadJson(savedState);
        final metadata = storageService.loadSessionMetadata();
        final modeName = metadata?['mode'] as String?;
        if (modeName != null) {
          gameMode.value = ChessGameMode.values.byName(modeName);
        }
        timerEnabled.value = metadata?['timerEnabled'] as bool? ?? false;
        timePerPlayer.value = metadata?['timePerPlayer'] as int? ?? 10;
        aiDifficulty.value = metadata?['aiDifficulty'] as int? ?? 2;
        final initialSeconds = timePerPlayer.value * 60;
        whiteTimeRemaining.value =
            metadata?['whiteTimeRemaining'] as int? ?? initialSeconds;
        blackTimeRemaining.value =
            metadata?['blackTimeRemaining'] as int? ?? initialSeconds;
        if (timerEnabled.value && metadata?['clockRunning'] == true) {
          final savedAt = metadata?['savedAtEpochMs'] as int?;
          if (savedAt != null) {
            final elapsed = max(
              0,
              (DateTime.now().millisecondsSinceEpoch - savedAt) ~/ 1000,
            );
            if (board.positionState.isWhiteToMove) {
              whiteTimeRemaining.value =
                  max(0, whiteTimeRemaining.value - elapsed);
            } else {
              blackTimeRemaining.value =
                  max(0, blackTimeRemaining.value - elapsed);
            }
          }
        }
        isWhiteTurn.value = board.positionState.isWhiteToMove;
        moveHistory.assignAll(board.moveHistory);
        capturedPieces.assignAll(
          board.capturedPieces
              .map((piece) => piece.imagePath.split('/').last.split('.').first)
              .toList(),
        );
        gameState.value = ChessGameState.inProgress;
        _gameResultRecorded = false;
        clearSelection();
        lastMove.value = null;
        // A restored match waits safely on the mode screen until Continue.
        isGamePaused.value = true;
        hasSavedMatch.value = true;
        endReason.value = ChessEndReason.none;
        return;
      } catch (e) {
        dev.log('Failed to load saved chess state: $e', name: 'Chess');
      }
    }

    board.initializeBoard();
    isWhiteTurn.value = board.positionState.isWhiteToMove;
    gameState.value = ChessGameState.initial;
    clearSelection();
    lastMove.value = null;
    moveHistory.clear();
    capturedPieces.clear();
    isGamePaused.value = false;
    hasSavedMatch.value = false;
    _gameResultRecorded = false;
    endReason.value = ChessEndReason.none;

    final timeInSeconds = timePerPlayer.value * 60;
    whiteTimeRemaining.value = timeInSeconds;
    blackTimeRemaining.value = timeInSeconds;
  }

  void _loadSettings() {
    showLegalMoves.value = storageService.showLegalMoves;
    showLastMove.value = storageService.showLastMove;
    boardTheme.value = storageService.boardTheme;
    timerEnabled.value = storageService.timerEnabled;
    timePerPlayer.value = storageService.timePerPlayer;
    aiDifficulty.value = storageService.aiDifficulty;
  }

  void updateBoardTheme(String theme) {
    boardTheme.value = theme;
    storageService.boardTheme = theme;
    soundService.playMenuSelectionSound();
  }

  @override
  void onClose() {
    _isDisposed = true;
    _advanceGameGeneration();
    _dismissPromotionDialog();
    _timer?.cancel();
    super.onClose();
  }

  void _advanceGameGeneration() {
    _gameGeneration++;
  }

  bool _isCurrentAiTurn(int generation) {
    return !_isDisposed &&
        generation == _gameGeneration &&
        gameMode.value == ChessGameMode.ai &&
        !isWhiteTurn.value &&
        !isGamePaused.value &&
        gameState.value != ChessGameState.checkmate &&
        gameState.value != ChessGameState.stalemate &&
        gameState.value != ChessGameState.draw;
  }

  void startNewGame(ChessGameMode mode) {
    _advanceGameGeneration();
    _dismissPromotionDialog();
    _timer?.cancel();
    gameMode.value = mode;
    _queueStorage(storageService.clearSavedGame);
    board.initializeBoard();
    isWhiteTurn.value = board.positionState.isWhiteToMove;
    moveHistory.clear();
    capturedPieces.clear();
    clearSelection();
    lastMove.value = null;
    gameState.value = ChessGameState.inProgress;
    isGamePaused.value = false;
    hasSavedMatch.value = false;
    _gameResultRecorded = false;
    endReason.value = ChessEndReason.none;

    // Initialize timer if enabled
    if (timerEnabled.value) {
      final timeInSeconds = timePerPlayer.value * 60;
      whiteTimeRemaining.value = timeInSeconds;
      blackTimeRemaining.value = timeInSeconds;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isGamePaused.value) return;

      if (isWhiteTurn.value) {
        if (whiteTimeRemaining.value > 0) {
          whiteTimeRemaining.value--;
          if (whiteTimeRemaining.value == 0) {
            _handleTimeUp();
            return;
          }
          if (whiteTimeRemaining.value <= 10) {
            soundService.playClockTickSound();
          }
        } else {
          _handleTimeUp();
        }
      } else {
        if (blackTimeRemaining.value > 0) {
          blackTimeRemaining.value--;
          if (blackTimeRemaining.value == 0) {
            _handleTimeUp();
            return;
          }
          if (blackTimeRemaining.value <= 10) {
            soundService.playClockTickSound();
          }
        } else {
          _handleTimeUp();
        }
      }
    });
  }

  void _handleTimeUp() {
    _advanceGameGeneration();
    _dismissPromotionDialog();
    _timer?.cancel();
    final winnerColor = isWhiteTurn.value ? PieceColor.black : PieceColor.white;
    if (!board.hasPossibleMatingMaterial(winnerColor)) {
      soundService.playGameEndSound();
      endReason.value = ChessEndReason.insufficientMaterial;
      gameState.value = ChessGameState.draw;
      _recordGameResultOnce('draw');
    } else {
      soundService.playTimeUpSound();
      endReason.value = ChessEndReason.timeout;
      gameState.value = ChessGameState.checkmate;
      _recordGameResultOnce(isWhiteTurn.value ? 'loss' : 'win');
    }
    hasSavedMatch.value = false;
    _queueStorage(storageService.clearSavedGame);
  }

  void makeMove(String from, String to) {
    if (gameState.value == ChessGameState.initial ||
        gameState.value == ChessGameState.checkmate ||
        gameState.value == ChessGameState.stalemate ||
        gameState.value == ChessGameState.draw ||
        isGamePaused.value) {
      return;
    }

    if (gameMode.value == ChessGameMode.ai && !isWhiteTurn.value) {
      soundService.playErrorSound();
      return;
    }

    final piece = board.getPieceAt(from);
    if (piece == null) {
      dev.log('No piece at $from', name: 'Chess');
      return;
    }

    if ((piece.color == PieceColor.white) != isWhiteTurn.value) {
      dev.log('Wrong turn', name: 'Chess');
      soundService.playErrorSound();
      return;
    }

    final legalMoves =
        board.getLegalMoves(from).where((move) => move.to == to).toList();
    if (legalMoves.isEmpty) {
      dev.log('Invalid move $from-$to', name: 'Chess');
      soundService.playErrorSound();
      return;
    }

    final promotionMove = legalMoves.cast<ChessMove?>().firstWhere(
          (move) => move?.isPromotion ?? false,
          orElse: () => null,
        );

    if (promotionMove != null) {
      _handlePromotionMove(promotionMove, piece.color);
      return;
    }

    _applyResolvedMove(from, to);
  }

  void _handlePromotionMove(ChessMove move, PieceColor color) {
    final generation = _gameGeneration;
    _promotionDialogOpen = true;
    Get.dialog<void>(
      PromotionDialog(
        color: color,
        position: move.to,
        onSelect: (type) {
          if (!_promotionDialogOpen ||
              generation != _gameGeneration ||
              isGamePaused.value ||
              gameState.value == ChessGameState.checkmate ||
              gameState.value == ChessGameState.stalemate ||
              gameState.value == ChessGameState.draw ||
              board.getPieceAt(move.from)?.color != color ||
              isWhiteTurn.value != (color == PieceColor.white)) {
            return;
          }
          _promotionDialogOpen = false;
          Get.back();
          _applyResolvedMove(move.from, move.to, promotionPiece: type);
          soundService.playPromotionSound();
        },
      ),
      barrierDismissible: false,
    ).whenComplete(() => _promotionDialogOpen = false);
  }

  void _dismissPromotionDialog() {
    if (!_promotionDialogOpen) return;
    _promotionDialogOpen = false;
    if (Get.isDialogOpen ?? false) Get.back<void>();
  }

  void _applyResolvedMove(String from, String to, {PieceType? promotionPiece}) {
    final piece = board.getPieceAt(from);
    if (piece == null) return;

    if (board.movePiece(from, to, promotionPiece: promotionPiece)) {
      dev.log('Move made $from-$to', name: 'Chess');
      soundService.playMoveSound();
      lastMove.value = (from, to);
      moveHistory.assignAll(board.moveHistory);
      _syncCapturedPieces();
      isWhiteTurn.value = board.positionState.isWhiteToMove;
      _persistGame();
      gameState.value = ChessGameState.inProgress;
      clearSelection();
      _checkGameState();

      if (gameMode.value == ChessGameMode.ai &&
          !isWhiteTurn.value &&
          gameState.value != ChessGameState.checkmate &&
          gameState.value != ChessGameState.stalemate &&
          gameState.value != ChessGameState.draw) {
        _makeAiMove();
      }
    } else {
      dev.log('Move failed $from-$to', name: 'Chess');
      soundService.playErrorSound();
    }
  }

  Future<void> _makeAiMove() async {
    final generation = _gameGeneration;
    // Add a variable delay based on difficulty and move complexity to simulate human thinking
    // In timer mode, AI should still "think" but more efficiently
    final isTimerMode = timerEnabled.value;

    final baseThinkingTime = switch (aiDifficulty.value) {
      1 =>
        isTimerMode ? 600 : 900, // Easy: Faster in timer mode, normal otherwise
      2 => isTimerMode ? 800 : 1200, // Medium: More thoughtful
      3 => isTimerMode ? 1000 : 1500, // Hard: Longer thinking time
      _ => isTimerMode ? 800 : 1200, // Default to medium
    };

    // Add some randomness to make it feel more human-like
    // More difficult AI should have less random variance
    final randomFactor = switch (aiDifficulty.value) {
      1 => 0.5, // Easy: High variance (±50%)
      2 => 0.3, // Medium: Medium variance (±30%)
      3 => 0.2, // Hard: Low variance (±20%)
      _ => 0.3, // Default to medium
    };

    final randomVariance =
        (baseThinkingTime * randomFactor * (_random.nextDouble() * 2 - 1))
            .toInt();
    final thinkingTime = baseThinkingTime + randomVariance;

    // Make sure thinking time is reasonable
    final actualThinkingTime =
        thinkingTime.clamp(500, isTimerMode ? 1500 : 2500);

    dev.log(
        'AI thinking for ${actualThinkingTime}ms (base: $baseThinkingTime, variance: $randomVariance)',
        name: 'Chess');
    await Future.delayed(Duration(milliseconds: actualThinkingTime));

    if (!_isCurrentAiTurn(generation)) return;

    // Set AI difficulty
    aiService.setDifficulty(aiDifficulty.value);

    try {
      aiService.isThinking.value = true;
      final rawMove = await compute(_computeChessAiMove, {
        'board': board.toJson(),
        'difficulty': aiDifficulty.value,
      });
      aiService.isThinking.value = false;
      final move = rawMove == null
          ? null
          : ChessMove(
              from: rawMove['from']! as String,
              to: rawMove['to']! as String,
              movingPiece:
                  PieceType.values.byName(rawMove['movingPiece']! as String),
              capturedPiece: rawMove['capturedPiece'] == null
                  ? null
                  : PieceType.values
                      .byName(rawMove['capturedPiece']! as String),
              promotionPiece: rawMove['promotionPiece'] == null
                  ? null
                  : PieceType.values
                      .byName(rawMove['promotionPiece']! as String),
              isCastleKingside: rawMove['isCastleKingside']! as bool? ?? false,
              isCastleQueenside:
                  rawMove['isCastleQueenside']! as bool? ?? false,
              isEnPassant: rawMove['isEnPassant']! as bool? ?? false,
            );

      if (!_isCurrentAiTurn(generation)) return;

      if (move == null) {
        dev.log('AI could not find a valid move', name: 'Chess');
        _checkGameState();
        return;
      }

      dev.log('AI move: ${move.from}-${move.to}', name: 'Chess');
      _applyResolvedMove(
        move.from,
        move.to,
        promotionPiece: move.promotionPiece,
      );
    } catch (e) {
      aiService.isThinking.value = false;
      dev.log('AI move error: $e', name: 'Chess');
      // If AI can't make a move, check if it's in checkmate or stalemate
      _checkGameState();
    }
  }

  void _syncCapturedPieces() {
    final newPieces = board.capturedPieces.skip(capturedPieces.length).toList();
    if (newPieces.isEmpty) return;

    for (final piece in newPieces) {
      capturedPieces.add(piece.imagePath.split('/').last.split('.').first);
      dev.log('Piece captured: ${piece.type}', name: 'Chess');
    }

    soundService.playCaptureSound();
  }

  void _checkGameState({bool recordResult = true}) {
    final currentColor =
        isWhiteTurn.value ? PieceColor.white : PieceColor.black;

    if (board.isCheckmate(currentColor)) {
      _advanceGameGeneration();
      gameState.value = ChessGameState.checkmate;
      endReason.value = ChessEndReason.checkmate;
      soundService.playCheckmateSound();
      if (recordResult) {
        _recordGameResultOnce(isWhiteTurn.value ? 'loss' : 'win');
      }
      _timer?.cancel();
      dev.log('Checkmate! ${!isWhiteTurn.value ? "White" : "Black"} wins',
          name: 'Chess');
    } else if (board.isStalemate(currentColor)) {
      _advanceGameGeneration();
      gameState.value = ChessGameState.stalemate;
      endReason.value = ChessEndReason.stalemate;
      soundService.playGameEndSound();
      if (recordResult) _recordGameResultOnce('draw');
      _timer?.cancel();
      dev.log('Stalemate!', name: 'Chess');
    } else if (board.isInsufficientMaterial()) {
      _advanceGameGeneration();
      gameState.value = ChessGameState.draw;
      endReason.value = ChessEndReason.insufficientMaterial;
      soundService.playGameEndSound();
      if (recordResult) _recordGameResultOnce('draw');
      _timer?.cancel();
      dev.log('Draw by insufficient material!', name: 'Chess');
    } else if (board.isThreefoldRepetition()) {
      _advanceGameGeneration();
      gameState.value = ChessGameState.draw;
      endReason.value = ChessEndReason.repetition;
      soundService.playGameEndSound();
      if (recordResult) _recordGameResultOnce('draw');
      _timer?.cancel();
      dev.log('Draw by threefold repetition!', name: 'Chess');
    } else if (board.isFiftyMoveRuleDraw()) {
      _advanceGameGeneration();
      gameState.value = ChessGameState.draw;
      endReason.value = ChessEndReason.fiftyMoveRule;
      soundService.playGameEndSound();
      if (recordResult) _recordGameResultOnce('draw');
      _timer?.cancel();
      dev.log('Draw by 50-move rule!', name: 'Chess');
    } else if (board.isCheck(currentColor)) {
      gameState.value = ChessGameState.check;
      soundService.playCheckSound();
      dev.log('Check!', name: 'Chess');
    }

    if (gameState.value == ChessGameState.checkmate ||
        gameState.value == ChessGameState.stalemate ||
        gameState.value == ChessGameState.draw) {
      hasSavedMatch.value = false;
      _queueStorage(storageService.clearSavedGame);
    }
  }

  // Game control
  void pauseGame() {
    _advanceGameGeneration();
    _dismissPromotionDialog();
    isGamePaused.value = true;
    _timer?.cancel();
    _persistGame();
  }

  void continueSavedGame() {
    if (!hasSavedMatch.value || !isGamePaused.value) return;
    if (timerEnabled.value &&
        (isWhiteTurn.value
                ? whiteTimeRemaining.value
                : blackTimeRemaining.value) <=
            0) {
      isGamePaused.value = false;
      _handleTimeUp();
      return;
    }
    resumeGame();
  }

  void resumeGame() {
    if (!isGamePaused.value ||
        gameState.value == ChessGameState.checkmate ||
        gameState.value == ChessGameState.stalemate ||
        gameState.value == ChessGameState.draw) {
      return;
    }
    isGamePaused.value = false;
    if (timerEnabled.value) {
      _startTimer();
    }
    if (gameMode.value == ChessGameMode.ai && !isWhiteTurn.value) {
      unawaited(_makeAiMove());
    }
  }

  void forfeitGame() {
    _advanceGameGeneration();
    _dismissPromotionDialog();
    _timer?.cancel();
    gameState.value = ChessGameState.checkmate;
    endReason.value = ChessEndReason.resignation;
    soundService.playGameEndSound();
    _recordGameResultOnce('loss');
    hasSavedMatch.value = false;
    _queueStorage(storageService.clearSavedGame);
  }

  void selectPiece(ChessPiece piece) {
    selectedPiece.value = piece;
    legalMovesForSelection
      ..clear()
      ..addAll(board.getValidMoves(piece.position));
  }

  void clearSelection() {
    selectedPiece.value = null;
    legalMovesForSelection.clear();
  }

  // Statistics
  void _updateGameStats(String result) {
    storageService.updateGameStats(result: result);
  }

  void _recordGameResultOnce(String result) {
    if (_gameResultRecorded) return;
    _gameResultRecorded = true;
    if (gameMode.value == ChessGameMode.local) return;
    _updateGameStats(result);
  }

  void importFen(String fen) {
    _advanceGameGeneration();
    _dismissPromotionDialog();
    _timer?.cancel();
    final wasPaused = isGamePaused.value;
    board.loadFen(fen);
    isWhiteTurn.value = board.positionState.isWhiteToMove;
    moveHistory.clear();
    capturedPieces.clear();
    clearSelection();
    lastMove.value = null;
    gameState.value = ChessGameState.inProgress;
    _gameResultRecorded = false;
    endReason.value = ChessEndReason.none;
    if (timerEnabled.value) {
      final seconds = timePerPlayer.value * 60;
      whiteTimeRemaining.value = seconds;
      blackTimeRemaining.value = seconds;
    }
    _checkGameState(recordResult: false);
    if (gameState.value == ChessGameState.inProgress ||
        gameState.value == ChessGameState.check) {
      _persistGame();
      if (!wasPaused) {
        if (timerEnabled.value) _startTimer();
        if (gameMode.value == ChessGameMode.ai && !isWhiteTurn.value) {
          unawaited(_makeAiMove());
        }
      }
    }
  }

  void _persistGame() {
    if (gameState.value == ChessGameState.checkmate ||
        gameState.value == ChessGameState.stalemate ||
        gameState.value == ChessGameState.draw) {
      return;
    }
    hasSavedMatch.value = true;
    final metadata = <String, dynamic>{
      'mode': gameMode.value.name,
      'timerEnabled': timerEnabled.value,
      'timePerPlayer': timePerPlayer.value,
      'whiteTimeRemaining': whiteTimeRemaining.value,
      'blackTimeRemaining': blackTimeRemaining.value,
      'aiDifficulty': aiDifficulty.value,
      'clockRunning': timerEnabled.value && !isGamePaused.value,
      'savedAtEpochMs': DateTime.now().millisecondsSinceEpoch,
    };
    final serializedBoard = board.toJson();
    _queueStorage(() => storageService.saveSession(serializedBoard, metadata));
  }

  void _queueStorage(Future<void> Function() operation) {
    _storageChain = _storageChain.then((_) => operation()).catchError((error) {
      dev.log('Chess persistence failed: $error', name: 'Chess');
    });
  }

  String exportFen() => board.toFen();

  List<String> formattedMovePairs() {
    final pairs = <String>[];
    for (var i = 0; i < board.moveHistory.length; i += 2) {
      final moveNumber = (i ~/ 2) + 1;
      final whiteMove = board.moveHistory[i];
      final blackMove =
          i + 1 < board.moveHistory.length ? board.moveHistory[i + 1] : '';
      pairs.add(
          '$moveNumber. $whiteMove${blackMove.isEmpty ? '' : '  $blackMove'}');
    }
    return pairs;
  }

  // Settings
  void toggleLegalMoves() {
    showLegalMoves.value = !showLegalMoves.value;
    storageService.updateShowLegalMoves(showLegalMoves.value);
  }

  void toggleLastMove() {
    showLastMove.value = !showLastMove.value;
    storageService.updateShowLastMove(showLastMove.value);
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

Map<String, Object?>? _computeChessAiMove(Map<String, Object?> request) {
  final searchBoard = ChessBoard()..loadJson(request['board']! as String);
  final search = ChessAIService()..setDifficulty(request['difficulty']! as int);
  final move = search.getBestEngineMove(searchBoard, PieceColor.black);
  if (move == null) return null;
  return {
    'from': move.from,
    'to': move.to,
    'movingPiece': move.movingPiece.name,
    'capturedPiece': move.capturedPiece?.name,
    'promotionPiece': move.promotionPiece?.name,
    'isCastleKingside': move.isCastleKingside,
    'isCastleQueenside': move.isCastleQueenside,
    'isEnPassant': move.isEnPassant,
  };
}
