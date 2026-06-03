import 'package:get/get.dart';
import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../services/ai_service.dart';
import '../models/chess_board.dart';
import '../models/chess_move.dart';
import '../models/chess_piece.dart';
import '../widgets/promotion_dialog.dart';

enum ChessGameMode { local, ai, training }

enum ChessGameState { initial, inProgress, check, checkmate, stalemate, draw }

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
  int _gameGeneration = 0;
  bool _isDisposed = false;

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
    final savedState = storageService.loadSerializedGameState();
    if (savedState != null) {
      try {
        board.loadJson(savedState);
        isWhiteTurn.value = board.positionState.isWhiteToMove;
        moveHistory.assignAll(board.moveHistory);
        capturedPieces.assignAll(
          board.capturedPieces
              .map((piece) => piece.imagePath.split('/').last.split('.').first)
              .toList(),
        );
        gameState.value = ChessGameState.inProgress;
        clearSelection();
        lastMove.value = null;
        isGamePaused.value = false;
        return;
      } catch (e) {
        dev.log('Failed to load saved chess state: $e', name: 'Chess');
      }
    }

    board.initializeBoard();
    isWhiteTurn.value = board.positionState.isWhiteToMove;
    gameState.value = ChessGameState.inProgress;
    clearSelection();
    lastMove.value = null;
    moveHistory.clear();
    capturedPieces.clear();
    isGamePaused.value = false;

    // Initialize timer if enabled
    if (timerEnabled.value) {
      final timeInSeconds = timePerPlayer.value * 60;
      whiteTimeRemaining.value = timeInSeconds;
      blackTimeRemaining.value = timeInSeconds;
      _startTimer();
    }
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
    gameMode.value = mode;
    storageService.saveSerializedGameState('');
    board.initializeBoard();
    isWhiteTurn.value = board.positionState.isWhiteToMove;
    moveHistory.clear();
    capturedPieces.clear();
    clearSelection();
    lastMove.value = null;
    gameState.value = ChessGameState.inProgress;
    isGamePaused.value = false;

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
          if (whiteTimeRemaining.value <= 10) {
            soundService.playClockTickSound();
          }
        } else {
          _handleTimeUp();
        }
      } else {
        if (blackTimeRemaining.value > 0) {
          blackTimeRemaining.value--;
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
    _timer?.cancel();
    soundService.playTimeUpSound();
    gameState.value = ChessGameState.checkmate;
    _updateGameStats(isWhiteTurn.value ? 'loss' : 'win');
  }

  void makeMove(String from, String to) {
    if (gameState.value == ChessGameState.initial ||
        gameState.value == ChessGameState.checkmate ||
        gameState.value == ChessGameState.stalemate ||
        gameState.value == ChessGameState.draw ||
        isGamePaused.value) {
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
    Get.dialog(
      PromotionDialog(
        color: color,
        position: move.to,
        onSelect: (type) {
          Get.back();
          _applyResolvedMove(move.from, move.to, promotionPiece: type);
          soundService.playPromotionSound();
        },
      ),
      barrierDismissible: false,
    );
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
      storageService.saveSerializedGameState(board.toJson());
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
      final move = aiService.getBestEngineMove(board, PieceColor.black);

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

  void _checkGameState() {
    final currentColor =
        isWhiteTurn.value ? PieceColor.white : PieceColor.black;

    if (board.isCheckmate(currentColor)) {
      gameState.value = ChessGameState.checkmate;
      soundService.playCheckmateSound();
      _updateGameStats(isWhiteTurn.value ? 'loss' : 'win');
      _timer?.cancel();
      dev.log('Checkmate! ${!isWhiteTurn.value ? "White" : "Black"} wins',
          name: 'Chess');
    } else if (board.isCheck(currentColor)) {
      gameState.value = ChessGameState.check;
      soundService.playCheckSound();
      dev.log('Check!', name: 'Chess');
    } else if (board.isStalemate(currentColor)) {
      gameState.value = ChessGameState.stalemate;
      soundService.playGameEndSound();
      _updateGameStats('draw');
      _timer?.cancel();
      dev.log('Stalemate!', name: 'Chess');
    } else if (board.isInsufficientMaterial()) {
      gameState.value = ChessGameState.draw;
      soundService.playGameEndSound();
      _updateGameStats('draw');
      _timer?.cancel();
      dev.log('Draw by insufficient material!', name: 'Chess');
    } else if (board.isThreefoldRepetition()) {
      gameState.value = ChessGameState.draw;
      soundService.playGameEndSound();
      _updateGameStats('draw');
      _timer?.cancel();
      dev.log('Draw by threefold repetition!', name: 'Chess');
    } else if (board.isFiftyMoveRuleDraw()) {
      gameState.value = ChessGameState.draw;
      soundService.playGameEndSound();
      _updateGameStats('draw');
      _timer?.cancel();
      dev.log('Draw by 50-move rule!', name: 'Chess');
    }
  }

  // Game control
  void pauseGame() {
    _advanceGameGeneration();
    isGamePaused.value = true;
    _timer?.cancel();
  }

  void resumeGame() {
    isGamePaused.value = false;
    if (timerEnabled.value) {
      _startTimer();
    }
  }

  void forfeitGame() {
    _advanceGameGeneration();
    _timer?.cancel();
    gameState.value = ChessGameState.checkmate;
    soundService.playGameEndSound();
    _updateGameStats('loss');
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

  void importFen(String fen) {
    _advanceGameGeneration();
    board.loadFen(fen);
    isWhiteTurn.value = board.positionState.isWhiteToMove;
    moveHistory.clear();
    capturedPieces.clear();
    clearSelection();
    lastMove.value = null;
    gameState.value = ChessGameState.inProgress;
    storageService.saveSerializedGameState(board.toJson());
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
