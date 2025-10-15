import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/game_move.dart';
import '../models/game_mode.dart';
import '../models/game_difficulty.dart';
import '../services/ai_service.dart';
import '../services/navigation_service.dart';
import '../controllers/settings_controller.dart';
import '../controllers/stats_controller.dart';

class TicTacToeGameController extends GetxController {
  final AIService _aiService;
  final TicTacToeNavigationService _navigationService;
  final _settingsController = Get.find<TicTacToeSettingsController>();
  final _statsController = Get.find<TicTacToeStatsController>();
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  final Rx<TicTacToeState> _gameState = TicTacToeState.initial().obs;
  final RxBool _isThinking = false.obs;
  final Stopwatch _gameStopwatch = Stopwatch();

  TicTacToeGameController(this._navigationService, this._aiService) {
    _logger.i('Game controller initialized');
    _logger.d('Initial game state: ${_gameState.value}');
    _gameStopwatch.start();
  }

  TicTacToeState get gameState => _gameState.value;
  bool get isThinking => _isThinking.value;
  bool get isGameOver => _gameState.value.isGameOver;

  @override
  void onInit() {
    super.onInit();
    // Update game settings from the settings controller
    _gameState.value = _gameState.value.copyWith(
      settings: _settingsController.settings,
    );
  }

  Future<void> makeMove(int index) async {
    if (isThinking || isGameOver || gameState.board[index] != Player.none) {
      _logger.d(
          'Invalid move attempt: index=$index, thinking=$isThinking, gameOver=$isGameOver');
      return;
    }

    final currentPlayer = gameState.currentPlayer;
    _logger.i(
        '${currentPlayer == Player.x ? "Player X" : "Player O"} making move at index: $index');

    // Make the move
    final newBoard = List<Player>.from(gameState.board);
    newBoard[index] = currentPlayer;
    _gameState.value = gameState.copyWith(
      board: newBoard,
      currentPlayer: currentPlayer == Player.x ? Player.o : Player.x,
      lastMove: GameMove(
        position: index,
        player: currentPlayer,
        timestamp: DateTime.now(),
      ),
    );
    _logger.d('Updated game state after move: ${_gameState.value}');

    // Check for win
    if (_checkWinner(currentPlayer)) {
      _logger.i('${currentPlayer == Player.x ? "Player X" : "Player O"} wins!');
      _gameState.value = gameState.copyWith(
        winner: currentPlayer,
        status: GameStatus.won,
      );
      _handleGameOver();
      return;
    }

    // Check for draw
    if (_isBoardFull()) {
      _logger.i('Game ended in a draw');
      _gameState.value = gameState.copyWith(status: GameStatus.draw);
      _handleGameOver();
      return;
    }

    // If in single player mode and it's AI's turn
    if (_settingsController.settings.gameMode == GameMode.singlePlayer &&
        gameState.currentPlayer == Player.o) {
      await _makeAIMove();
    }
  }

  Future<void> _makeAIMove() async {
    _logger.d('AI starting its turn');
    _isThinking.value = true;
    await Future.delayed(gameState.settings.aiDelay);
    final aiMove = await _aiService.getNextMove(gameState);
    _isThinking.value = false;

    if (aiMove != null) {
      await makeMove(aiMove);
    } else {
      _logger.w('AI failed to make a move');
    }
  }

  void _handleGameOver() {
    _gameStopwatch.stop();
    final gameDuration = _gameStopwatch.elapsed;
    _logger.i('Game over. Duration: $gameDuration');

    final gameMode = _settingsController.settings.gameMode;
    final winner = gameState.winner;
    final isDraw = winner == null;

    // Handle stats for single player mode
    if (gameMode == GameMode.singlePlayer) {
      final isWin = winner == Player.x; // Player is always X in single player

      _statsController.updateGameStats(
        gameMode: gameMode,
        difficulty: _settingsController.settings.difficulty,
        isWin: isWin,
        isDraw: isDraw,
        gameDuration: gameDuration,
      );

      _logger.i(
          'Game stats updated. Player wins: ${_statsController.playerWins}, AI wins: ${_statsController.aiWins}');
    }
    // Handle stats for multiplayer mode
    else if (gameMode == GameMode.multiPlayer) {
      int? winningPlayer;
      if (!isDraw) {
        // Determine the winning player (1 = X, 2 = O)
        winningPlayer = winner == Player.x ? 1 : 2;
        _logger.i('Multiplayer game won by Player $winningPlayer');

        // Force UI update by updating the observable game state
        _gameState.refresh();
      } else {
        _logger.i('Multiplayer game ended in a draw');
      }

      _statsController.updateGameStats(
        gameMode: gameMode,
        isWin: false, // Not relevant in multiplayer
        isDraw: isDraw,
        gameDuration: gameDuration,
        winningPlayer: winningPlayer,
      );

      _logger.i(
          'Multiplayer stats updated. P1 wins: ${_statsController.player1Wins}, P2 wins: ${_statsController.player2Wins}');

      // Ensure UI is updated with latest stats
      update();
    }

    // Schedule auto-restart if enabled with a longer delay to ensure scores are visible
    if (_settingsController.settings.autoRestart) {
      _logger.i('Auto-restart is enabled, scheduling game reset');
      // Using a longer delay ensures the players see the game result
      Future.delayed(const Duration(seconds: 3), () {
        // Check if the game is still in a completed state before restarting
        if (_gameState.value.status != GameStatus.playing) {
          resetGame();
        }
      });
    }
  }

  bool _checkWinner(Player player) {
    final board = gameState.board;
    final winningLines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (final line in winningLines) {
      if (board[line[0]] == player &&
          board[line[1]] == player &&
          board[line[2]] == player) {
        _logger.d('Winning line found: $line for player $player');
        _gameState.value = gameState.copyWith(winningLine: line);
        return true;
      }
    }

    return false;
  }

  bool _isBoardFull() {
    final isFull = !gameState.board.contains(Player.none);
    if (isFull) {
      _logger.d('Board is full');
    }
    return isFull;
  }

  void resetGame() {
    _logger.i('Resetting game');
    _gameState.value = TicTacToeState.initial().copyWith(
      settings: _settingsController.settings,
    );
    _isThinking.value = false;
    _gameStopwatch.reset();
    _gameStopwatch.start();
  }

  void navigateBack() {
    _logger.i('Navigating back');
    _navigationService.back();
  }

  void updateDifficulty(GameDifficulty difficulty) {
    _settingsController.updateDifficulty(difficulty);
    _gameState.value = gameState.copyWith(
      settings: _settingsController.settings,
    );
    resetGame();
  }

  void toggleSound() {
    _settingsController.toggleSound();
    _gameState.value = gameState.copyWith(
      settings: _settingsController.settings,
    );
  }

  void toggleVibration() {
    _settingsController.toggleVibration();
    _gameState.value = gameState.copyWith(
      settings: _settingsController.settings,
    );
  }

  void resetStats() {
    _logger.i('Resetting stats');
    if (_settingsController.settings.gameMode == GameMode.singlePlayer) {
      _statsController.resetSinglePlayerStats();
    } else {
      _statsController.resetMultiplayerStats();
    }
  }

  void resetAllStats() {
    _logger.i('Resetting all stats');
    _statsController.resetAllStats();
  }

  void toggleAutoRestart() {
    _settingsController.toggleAutoRestart();
    _gameState.value = gameState.copyWith(
      settings: _settingsController.settings,
    );
    _logger.i(
        'Auto-restart toggled to: ${_settingsController.settings.autoRestart}');
  }

  @override
  void onClose() {
    _gameStopwatch.stop();
    _logger.i('Game controller disposed');
    super.onClose();
  }
}
