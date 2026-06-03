import 'dart:async';
import 'package:get/get.dart';
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

  final Rx<TicTacToeState> _gameState = TicTacToeState.initial().obs;
  final RxBool _isThinking = false.obs;
  final RxInt countdown = 3.obs;
  final Stopwatch _gameStopwatch = Stopwatch();
  bool _isDisposed = false;
  Timer? _countdownTimer;
  int _moveGeneration = 0;

  TicTacToeGameController(this._navigationService, this._aiService) {
    _gameStopwatch.start();
  }

  TicTacToeState get gameState => _gameState.value;
  bool get isThinking => _isThinking.value;
  bool get isGameOver => _gameState.value.isGameOver;

  @override
  void onInit() {
    super.onInit();
    _gameState.value = _gameState.value.copyWith(
      settings: _settingsController.settings,
    );
  }

  Future<void> makeMove(int index) async {
    if (_isDisposed ||
        index < 0 ||
        index >= gameState.board.length ||
        isThinking ||
        isGameOver ||
        gameState.board[index] != Player.none) {
      return;
    }

    _moveGeneration++;
    final currentPlayer = gameState.currentPlayer;

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

    if (_checkWinner(currentPlayer)) {
      _gameState.value = gameState.copyWith(
        winner: currentPlayer,
        status: GameStatus.won,
      );
      _handleGameOver();
      return;
    }

    if (_isBoardFull()) {
      _gameState.value = gameState.copyWith(status: GameStatus.draw);
      _handleGameOver();
      return;
    }

    if (_settingsController.settings.gameMode == GameMode.singlePlayer &&
        gameState.currentPlayer == Player.o) {
      await _makeAIMove();
    }
  }

  Future<void> _makeAIMove() async {
    final generation = _moveGeneration;
    final aiPlayer = gameState.currentPlayer;

    _isThinking.value = true;
    await Future.delayed(gameState.settings.aiDelay);

    if (_isDisposed ||
        isGameOver ||
        generation != _moveGeneration ||
        gameState.currentPlayer != aiPlayer) {
      _isThinking.value = false;
      return;
    }

    final aiMove = await _aiService.getNextMove(gameState);

    if (_isDisposed ||
        isGameOver ||
        generation != _moveGeneration ||
        gameState.currentPlayer != aiPlayer) {
      _isThinking.value = false;
      return;
    }

    _isThinking.value = false;

    if (aiMove != null && aiMove >= 0 && aiMove < gameState.board.length) {
      await makeMove(aiMove);
    }
  }

  Future<void> _handleGameOver() async {
    _gameStopwatch.stop();
    final gameDuration = _gameStopwatch.elapsed;

    final gameMode = _settingsController.settings.gameMode;
    final winner = gameState.winner;
    final isDraw = winner == null;

    if (gameMode == GameMode.singlePlayer) {
      final isWin = winner == Player.x;

      await _statsController.updateGameStats(
        gameMode: gameMode,
        difficulty: _settingsController.settings.difficulty,
        isWin: isWin,
        isDraw: isDraw,
        gameDuration: gameDuration,
      );
    } else if (gameMode == GameMode.multiPlayer) {
      int? winningPlayer;
      if (!isDraw) {
        winningPlayer = winner == Player.x ? 1 : 2;
      }

      await _statsController.updateGameStats(
        gameMode: gameMode,
        isWin: false,
        isDraw: isDraw,
        gameDuration: gameDuration,
        winningPlayer: winningPlayer,
      );

      _gameState.refresh();
      update();
    }

    if (_settingsController.settings.autoRestart) {
      countdown.value = 3;
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_isDisposed) {
          timer.cancel();
          return;
        }
        if (countdown.value > 1) {
          countdown.value--;
        } else {
          timer.cancel();
          if (_gameState.value.status != GameStatus.playing) {
            resetGame();
          }
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
        _gameState.value = gameState.copyWith(winningLine: line);
        return true;
      }
    }

    return false;
  }

  bool _isBoardFull() {
    return !gameState.board.contains(Player.none);
  }

  void resetGame() {
    _moveGeneration++;
    _countdownTimer?.cancel();
    _gameState.value = TicTacToeState.initial().copyWith(
      settings: _settingsController.settings,
    );
    _isThinking.value = false;
    countdown.value = 3;
    _gameStopwatch.reset();
    _gameStopwatch.start();
  }

  void navigateBack() {
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
    if (_settingsController.settings.gameMode == GameMode.singlePlayer) {
      _statsController.resetSinglePlayerStats();
    } else {
      _statsController.resetMultiplayerStats();
    }
  }

  void resetAllStats() {
    _statsController.resetAllStats();
  }

  void toggleAutoRestart() {
    _settingsController.toggleAutoRestart();
    _gameState.value = gameState.copyWith(
      settings: _settingsController.settings,
    );
  }

  @override
  void onClose() {
    _isDisposed = true;
    _moveGeneration++;
    _countdownTimer?.cancel();
    _gameStopwatch.stop();
    super.onClose();
  }
}
