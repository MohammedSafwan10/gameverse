import 'package:get/get.dart';
import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../services/ai_service.dart';
import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/piece_types/queen.dart';
import '../models/piece_types/rook.dart';
import '../models/piece_types/bishop.dart';
import '../models/piece_types/knight.dart';
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

  // Board state
  final Rxn<ChessPiece> selectedPiece = Rxn<ChessPiece>();
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
    board.initializeBoard();
    isWhiteTurn.value = true;
    gameState.value = ChessGameState.initial;
    selectedPiece.value = null;
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
    _timer?.cancel();
    super.onClose();
  }

  void startNewGame(ChessGameMode mode) {
    gameMode.value = mode;
    board.initializeBoard();
    isWhiteTurn.value = true;
    moveHistory.clear();
    capturedPieces.clear();
    selectedPiece.value = null;
    lastMove.value = null;
    gameState.value = ChessGameState.initial;
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
    _timer?.cancel();
    soundService.playTimeUpSound();

    // Update game state to checkmate (time loss)
    gameState.value = ChessGameState.checkmate;

    final currentPlayerLost = isWhiteTurn.value;

    // Determine if the time loss is a fair outcome by evaluating board position
    // If human player has a significant material advantage against AI, give them another chance
    final isFairOutcome = _evaluateTimeUpFairness();

    // Only consider mercy rule against AI if the player was making progress
    if (gameMode.value == ChessGameMode.ai) {
      // If player is losing by a lot against AI, consider it a fair time loss
      // If player is winning against AI, give them a chance to recover
      if (currentPlayerLost && !isFairOutcome) {
        // Human timed out but was winning - just resume with less time
        whiteTimeRemaining.value = 30; // Give 30 seconds grace period
        soundService.playClockTickSound();
        _startTimer();
        return;
      }
    }

    // Update stats for normal time loss
    _updateGameStats(isWhiteTurn.value ? 'loss' : 'win');
  }

  // Determines if a time loss is fair based on material advantage
  bool _evaluateTimeUpFairness() {
    // In a two player game, time loss is always fair
    if (gameMode.value == ChessGameMode.local) {
      return true;
    }

    // For AI game, check if human player has significant material advantage
    if (gameMode.value == ChessGameMode.ai && isWhiteTurn.value) {
      // Calculate material difference
      int whiteMaterial = 0;
      int blackMaterial = 0;

      for (var row = 0; row < 8; row++) {
        for (var col = 0; col < 8; col++) {
          final piece = board.board[row][col];
          if (piece == null) continue;

          int value = switch (piece.type) {
            PieceType.pawn => 1,
            PieceType.knight => 3,
            PieceType.bishop => 3,
            PieceType.rook => 5,
            PieceType.queen => 9,
            PieceType.king => 0, // Don't count king for material advantage
          };

          if (piece.color == PieceColor.white) {
            whiteMaterial += value;
          } else {
            blackMaterial += value;
          }
        }
      }

      // If human player has significant material advantage, time loss is unfair
      // and they deserve a second chance
      final materialDifference = whiteMaterial - blackMaterial;
      return materialDifference <=
          5; // If white has 5+ point advantage, give a chance
    }

    return true;
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

    // Validate turn
    if ((piece.color == PieceColor.white) != isWhiteTurn.value) {
      dev.log('Wrong turn', name: 'Chess');
      soundService.playErrorSound();
      return;
    }

    // Validate move
    final validMoves = board.getValidMoves(from);
    if (!validMoves.contains(to)) {
      dev.log('Invalid move $from-$to', name: 'Chess');
      soundService.playErrorSound();
      return;
    }

    // Check for pawn promotion
    final (toRow, _) = ChessPiece.notationToCoordinates(to);
    final isPawnPromotion =
        piece.type == PieceType.pawn && (toRow == 0 || toRow == 7);

    // Make move
    if (board.movePiece(from, to)) {
      dev.log('Move made $from-$to', name: 'Chess');
      soundService.playMoveSound();
      lastMove.value = (from, to);
      moveHistory.add('${piece.type.name} $from-$to');

      // Handle pawn promotion
      if (isPawnPromotion) {
        _handlePawnPromotion(to);
        return;
      }

      // Update captured pieces (only if a piece was actually captured)
      final capturedPiece = board.capturedPieces.lastOrNull;
      if (capturedPiece != null &&
          !capturedPieces.contains(
              capturedPiece.imagePath.split('/').last.split('.').first)) {
        capturedPieces
            .add(capturedPiece.imagePath.split('/').last.split('.').first);
        dev.log('Piece captured: ${capturedPiece.type}', name: 'Chess');
        soundService.playCaptureSound();
      }

      // Switch turns
      isWhiteTurn.value = !isWhiteTurn.value;
      gameState.value = ChessGameState.inProgress;

      // Check game state
      _checkGameState();

      // Make AI move if it's AI's turn
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

  void _handlePawnPromotion(String position) {
    final color = isWhiteTurn.value ? PieceColor.white : PieceColor.black;

    Get.dialog(
      PromotionDialog(
        color: color,
        position: position,
        onSelect: (type) {
          // Create and place the promoted piece
          final promotedPiece = switch (type) {
            PieceType.queen => Queen(color: color, position: position),
            PieceType.rook => Rook(color: color, position: position),
            PieceType.bishop => Bishop(color: color, position: position),
            PieceType.knight => Knight(color: color, position: position),
            _ => Queen(color: color, position: position), // Default to queen
          };

          // Replace the pawn with the promoted piece
          final (row, col) = ChessPiece.notationToCoordinates(position);
          board.board[row][col] = promotedPiece;

          soundService.playPromotionSound();
          Get.back();

          // Continue with turn switch and game state check
          isWhiteTurn.value = !isWhiteTurn.value;
          gameState.value = ChessGameState.inProgress;
          _checkGameState();

          // Make AI move if needed
          if (gameMode.value == ChessGameMode.ai &&
              !isWhiteTurn.value &&
              gameState.value != ChessGameState.checkmate &&
              gameState.value != ChessGameState.stalemate &&
              gameState.value != ChessGameState.draw) {
            _makeAiMove();
          }
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _makeAiMove() async {
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

    // Set AI difficulty
    aiService.setDifficulty(aiDifficulty.value);

    try {
      final moveNotation = aiService.getBestMove(board, PieceColor.black);

      if (moveNotation == null) {
        dev.log('AI could not find a valid move', name: 'Chess');
        _checkGameState();
        return;
      }

      // Parse move notation (format: "from-to")
      final parts = moveNotation.split('-');
      if (parts.length != 2) {
        dev.log('Invalid move format: $moveNotation', name: 'Chess');
        return;
      }

      final from = parts[0];
      final to = parts[1];

      dev.log('AI move: $from-$to', name: 'Chess');
      makeMove(from, to);
    } catch (e) {
      dev.log('AI move error: $e', name: 'Chess');
      // If AI can't make a move, check if it's in checkmate or stalemate
      _checkGameState();
    }
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
    }
  }

  // Game control
  void pauseGame() {
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
    _timer?.cancel();
    gameState.value = ChessGameState.checkmate;
    soundService.playGameEndSound();
    _updateGameStats('loss');
  }

  // Statistics
  void _updateGameStats(String result) {
    storageService.updateGameStats(result: result);
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
