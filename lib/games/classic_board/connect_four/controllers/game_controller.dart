import 'dart:math' show Point;
import 'package:get/get.dart';
import '../models/board.dart';
import '../services/sound_service.dart';
import '../controllers/stats_controller.dart';
import '../controllers/settings_controller.dart';
import 'ai_controller.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart';

enum GameMode { pvp, vsAI }

enum AIDifficulty { easy, medium, hard }

class ConnectFourController extends GetxController {
  static const winLength = 4;
  final board = Rx<Board>(Board.empty());
  final currentPlayer = Rx<CellState>(CellState.player1);
  final isAnimating = false.obs;
  final lastMove = Rx<Point<int>?>(null);
  final gameMode = GameMode.vsAI.obs;
  final aiDifficulty = AIDifficulty.medium.obs;
  final aiController = AIController();
  late final SoundService _soundService;
  late final ConnectFourStatsController _statsController;
  late final ConnectFourSettingsController _settingsController;
  final isAIThinking = false.obs;
  final _logger = Logger();
  final previewColumn = Rx<int?>(null);
  final Stopwatch _gameStopwatch = Stopwatch();

  bool get isGameOver => board.value.status != GameStatus.playing;

  @override
  void onInit() {
    super.onInit();
    _soundService = Get.find<SoundService>();
    _statsController = Get.find<ConnectFourStatsController>();
    _settingsController = Get.find<ConnectFourSettingsController>();

    // Initialize game settings from settings controller
    gameMode.value = _settingsController.gameMode.value;
    aiDifficulty.value = _settingsController.difficulty.value;
    aiController.setDifficulty(aiDifficulty.value);

    // Set up listeners to settings changes
    _setupSettingsListeners();

    _gameStopwatch.start();
    _logger.i('Connect Four game controller initialized');
  }

  void _setupSettingsListeners() {
    // Listen for game mode changes
    ever(_settingsController.gameMode, (GameMode mode) {
      if (gameMode.value != mode) {
        gameMode.value = mode;
        resetGame();
        _logger.d('Game mode updated from settings: $mode');
      }
    });

    // Listen for difficulty changes
    ever(_settingsController.difficulty, (AIDifficulty difficulty) {
      if (aiDifficulty.value != difficulty) {
        aiDifficulty.value = difficulty;
        aiController.setDifficulty(difficulty);
        if (gameMode.value == GameMode.vsAI) {
          resetGame();
        }
        _logger.d('AI difficulty updated from settings: $difficulty');
      }
    });
  }

  void setGameMode(GameMode mode) {
    // Update both local and settings controller
    gameMode.value = mode;
    _settingsController.setGameMode(mode);
    _logger.i('Game mode set to: $mode');
    resetGame();
  }

  void setAIDifficulty(AIDifficulty difficulty) {
    // Update both local and settings controller
    aiDifficulty.value = difficulty;
    _settingsController.setDifficulty(difficulty);
    aiController.setDifficulty(difficulty);
    _logger.i('AI difficulty set to: $difficulty');
    if (gameMode.value == GameMode.vsAI) {
      resetGame();
    }
  }

  void updatePreviewColumn(int col) {
    if (!isAnimating.value && !isGameOver && board.value.isValidMove(col)) {
      previewColumn.value = col;
    }
  }

  void clearPreview() {
    previewColumn.value = null;
  }

  Future<void> makeMove(int col) async {
    // Prevent multiple moves while processing
    if (isAnimating.value ||
        isGameOver ||
        !board.value.isValidMove(col) ||
        isAIThinking.value) {
      _logger.d(
          'Invalid move attempt: col=$col, animating=${isAnimating.value}, gameOver=$isGameOver, thinking=${isAIThinking.value}');
      return;
    }

    // Verify it's the correct player's turn (prevent player from playing during AI turn)
    if (gameMode.value == GameMode.vsAI &&
        currentPlayer.value == CellState.player2) {
      _logger.d('Invalid move attempt: Not player\'s turn');
      return;
    }

    // Set animating flag immediately to prevent multiple taps
    isAnimating.value = true;
    _logger.d('Animation flag set to true for move in column $col');

    // Check for sound and vibration settings
    final soundEnabled = _settingsController.isSoundEnabled.value;
    final vibrationEnabled = _settingsController.isVibrationEnabled.value;

    final targetRow = board.value.getLowestEmptyRow(col);
    if (targetRow == -1) {
      _logger.d('No empty row in column $col');
      isAnimating.value = false;
      return;
    }

    _logger.d(
        'Making move: column=$col, row=$targetRow, player=${currentPlayer.value}');

    // Create a copy of the current board state
    final newCells = List<List<CellState>>.generate(
      Board.rows,
      (i) => List<CellState>.from(board.value.cells[i]),
    );

    // Set the final position immediately
    newCells[targetRow][col] = currentPlayer.value;
    lastMove.value = Point(targetRow, col);

    // Update the board with the final state
    board.value = Board(cells: newCells);

    // Play drop sound if enabled
    if (soundEnabled) {
      _soundService.playDropSound();
    }

    // Add haptic feedback if enabled
    if (vibrationEnabled) {
      HapticFeedback.lightImpact();
    }

    // Check for win
    final winningCells =
        _checkWin(targetRow, col, currentPlayer.value, newCells);
    final newStatus = winningCells.isNotEmpty
        ? currentPlayer.value == CellState.player1
            ? GameStatus.player1Won
            : GameStatus.player2Won
        : _isBoardFull(newCells)
            ? GameStatus.draw
            : GameStatus.playing;

    // Update board state with winning cells if any
    board.value = Board(
      cells: newCells,
      status: newStatus,
      winningCells: winningCells,
    );

    if (winningCells.isNotEmpty) {
      if (soundEnabled) {
        _soundService.playWinSound();
      }
      if (vibrationEnabled) {
        HapticFeedback.mediumImpact();
      }
      _handleGameOver(newStatus);

      // For game over cases, manually reset animation flag after a delay
      // to ensure the disc animation completes
      await Future.delayed(const Duration(milliseconds: 500));
      isAnimating.value = false;
      _logger.d('Animation flag reset after win');
      return;
    } else if (newStatus == GameStatus.draw) {
      if (vibrationEnabled) {
        HapticFeedback.vibrate();
      }
      _handleGameOver(newStatus);

      // For game over cases, manually reset animation flag after a delay
      await Future.delayed(const Duration(milliseconds: 500));
      isAnimating.value = false;
      _logger.d('Animation flag reset after draw');
      return;
    }

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 500));

    // After animation, clear flag and switch players
    isAnimating.value = false;
    _logger.d('Animation flag reset after completed animation');

    // Switch players
    final previousPlayer = currentPlayer.value;
    currentPlayer.value = currentPlayer.value == CellState.player1
        ? CellState.player2
        : CellState.player1;
    _logger.d('Switched from $previousPlayer to ${currentPlayer.value}');

    // Only make AI move if game is still in progress
    if (newStatus == GameStatus.playing &&
        gameMode.value == GameMode.vsAI &&
        currentPlayer.value == CellState.player2) {
      // Add a short delay before AI thinking for better UX
      await Future.delayed(const Duration(milliseconds: 200));

      if (!isGameOver) {
        // Double-check game is still ongoing
        isAIThinking.value = true;
        _logger.d('AI thinking...');

        // Add a slight delay for better UX
        final thinkingTime = aiDifficulty.value == AIDifficulty.easy
            ? 300
            : aiDifficulty.value == AIDifficulty.medium
                ? 700
                : 1000;
        await Future.delayed(Duration(milliseconds: thinkingTime));

        // Verify game is still in progress before AI makes a move
        if (!isGameOver && currentPlayer.value == CellState.player2) {
          final aiMove =
              aiController.findBestMove(board.value, CellState.player2);
          _logger.d('AI chose column: $aiMove');
          isAIThinking.value = false;

          if (aiMove != -1) {
            // Use direct makeMoveInternal to avoid re-entry logic
            await _makeMoveInternal(aiMove);
          } else {
            _logger.w('AI could not find a valid move');
            isAnimating.value = false;
            _logger.d('Animation flag reset after AI failed to find move');
          }
        } else {
          isAIThinking.value = false;
          _logger.d('AI turn cancelled - game over or turn changed');
        }
      }
    }
  }

  // Internal version that bypasses player turn check for AI
  Future<void> _makeMoveInternal(int col) async {
    // Core logic without player turn validation
    if (isAnimating.value || isGameOver || !board.value.isValidMove(col)) {
      _logger.d(
          'Invalid internal move: col=$col, animating=${isAnimating.value}, gameOver=$isGameOver');
      return;
    }

    isAnimating.value = true;
    _logger.d('Animation flag set to true for internal move in column $col');

    final soundEnabled = _settingsController.isSoundEnabled.value;
    final vibrationEnabled = _settingsController.isVibrationEnabled.value;

    final targetRow = board.value.getLowestEmptyRow(col);
    if (targetRow == -1) {
      _logger.d('No empty row in column $col');
      isAnimating.value = false;
      return;
    }

    _logger.d(
        'Making internal move: column=$col, row=$targetRow, player=${currentPlayer.value}');

    // Rest of move logic
    final newCells = List<List<CellState>>.generate(
      Board.rows,
      (i) => List<CellState>.from(board.value.cells[i]),
    );

    newCells[targetRow][col] = currentPlayer.value;
    lastMove.value = Point(targetRow, col);
    board.value = Board(cells: newCells);

    if (soundEnabled) {
      _soundService.playDropSound();
    }
    if (vibrationEnabled) {
      HapticFeedback.lightImpact();
    }

    final winningCells =
        _checkWin(targetRow, col, currentPlayer.value, newCells);
    final newStatus = winningCells.isNotEmpty
        ? currentPlayer.value == CellState.player1
            ? GameStatus.player1Won
            : GameStatus.player2Won
        : _isBoardFull(newCells)
            ? GameStatus.draw
            : GameStatus.playing;

    board.value = Board(
      cells: newCells,
      status: newStatus,
      winningCells: winningCells,
    );

    if (winningCells.isNotEmpty) {
      if (soundEnabled) {
        _soundService.playWinSound();
      }
      if (vibrationEnabled) {
        HapticFeedback.mediumImpact();
      }
      _handleGameOver(newStatus);
      await Future.delayed(const Duration(milliseconds: 500));
      isAnimating.value = false;
      return;
    } else if (newStatus == GameStatus.draw) {
      if (vibrationEnabled) {
        HapticFeedback.vibrate();
      }
      _handleGameOver(newStatus);
      await Future.delayed(const Duration(milliseconds: 500));
      isAnimating.value = false;
      return;
    }

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 500));

    // After animation, clear flag and switch players
    isAnimating.value = false;

    // Switch players
    final previousPlayer = currentPlayer.value;
    currentPlayer.value = currentPlayer.value == CellState.player1
        ? CellState.player2
        : CellState.player1;
    _logger.d(
        '(Internal) Switched from $previousPlayer to ${currentPlayer.value}');
  }

  void _handleGameOver(GameStatus status) {
    _gameStopwatch.stop();
    final gameDuration = _gameStopwatch.elapsed;
    _logger.i('Game over with status: $status, duration: $gameDuration');

    // Update statistics
    _statsController.updateGameStats(
      gameMode: gameMode.value,
      result: status,
      difficulty: gameMode.value == GameMode.vsAI ? aiDifficulty.value : null,
      gameDuration: gameDuration,
    );

    // Check if auto-restart is enabled
    if (_settingsController.isAutoRestartEnabled.value) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!Get.isRegistered<ConnectFourController>()) return;
        _logger.i('Auto-restarting game');
        resetGame();
      });
    }

    // Update UI to reflect the latest statistics
    update();
  }

  List<Point<int>> _checkWin(
    int row,
    int col,
    CellState player,
    List<List<CellState>> cells,
  ) {
    const directions = [
      (0, 1),
      (1, 0),
      (1, 1),
      (1, -1),
    ];

    for (final (dRow, dCol) in directions) {
      final negative = _collectDirection(
        row: row,
        col: col,
        dRow: -dRow,
        dCol: -dCol,
        player: player,
        cells: cells,
      ).reversed;
      final positive = _collectDirection(
        row: row,
        col: col,
        dRow: dRow,
        dCol: dCol,
        player: player,
        cells: cells,
      );

      final line = <Point<int>>[
        ...negative,
        Point(row, col),
        ...positive,
      ];

      if (line.length >= winLength) {
        final centerIndex = line.indexOf(Point(row, col));
        final start = centerIndex >= winLength - 1
            ? centerIndex - (winLength - 1)
            : 0;
        final end = line.length - winLength;
        final safeStart = start > end ? end : start;
        final winningLine = line.sublist(safeStart, safeStart + winLength);
        _logger.i('Win detected for player $player: $winningLine');
        return winningLine;
      }
    }

    return [];
  }

  List<Point<int>> _collectDirection({
    required int row,
    required int col,
    required int dRow,
    required int dCol,
    required CellState player,
    required List<List<CellState>> cells,
  }) {
    final points = <Point<int>>[];
    var currentRow = row + dRow;
    var currentCol = col + dCol;

    while (currentRow >= 0 &&
        currentRow < Board.rows &&
        currentCol >= 0 &&
        currentCol < Board.cols &&
        cells[currentRow][currentCol] == player) {
      points.add(Point(currentRow, currentCol));
      currentRow += dRow;
      currentCol += dCol;
    }

    return points;
  }

  bool _isBoardFull(List<List<CellState>> cells) {
    final isFull =
        cells.every((row) => row.every((cell) => cell != CellState.empty));
    if (isFull) {
      _logger.d('Board is full, game is a draw');
    }
    return isFull;
  }

  void resetGame() {
    _logger.i('Resetting game');
    board.value = Board.empty();
    currentPlayer.value = CellState.player1;
    lastMove.value = null;
    isAnimating.value = false;
    isAIThinking.value = false;
    previewColumn.value = null;

    // Reset and restart the game stopwatch
    _gameStopwatch.reset();
    _gameStopwatch.start();
  }

  @override
  void onClose() {
    _gameStopwatch.stop();
    _logger.i('Connect Four game controller disposed');
    super.onClose();
  }
}
