import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../services/sound_service.dart';
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
  final RxBool _isSuspended = false.obs;
  final RxInt countdown = 3.obs;
  final Stopwatch _gameStopwatch = Stopwatch();
  bool _isDisposed = false;
  Timer? _countdownTimer;
  int _moveGeneration = 0;
  int _roundGeneration = 0;

  TicTacToeGameController(this._navigationService, this._aiService) {
    _gameStopwatch.start();
  }

  TicTacToeState get gameState => _gameState.value;
  bool get isThinking => _isThinking.value;
  bool get isSuspended => _isSuspended.value;
  bool get isGameOver => _gameState.value.isGameOver;

  @override
  void onInit() {
    super.onInit();
    _gameState.value = _gameState.value.copyWith(
      settings: _settingsController.settings,
    );
  }

  Future<void> makeMove(int index) async {
    if (gameState.settings.gameMode == GameMode.singlePlayer &&
        gameState.currentPlayer == Player.o) {
      return;
    }
    await _applyMove(index);
  }

  Future<void> _applyMove(int index) async {
    if (_isDisposed ||
        isSuspended ||
        index < 0 ||
        index >= gameState.board.length ||
        isThinking ||
        isGameOver ||
        gameState.board[index] != Player.none) {
      return;
    }

    _moveGeneration++;
    final currentPlayer = gameState.currentPlayer;
    if (Get.isRegistered<TicTacToeSoundService>()) {
      unawaited(Get.find<TicTacToeSoundService>().play('move'));
    }
    if (gameState.settings.vibrationEnabled) {
      unawaited(HapticFeedback.selectionClick());
    }

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
      await _handleGameOver();
      return;
    }

    if (_isBoardFull()) {
      _gameState.value = gameState.copyWith(status: GameStatus.draw);
      await _handleGameOver();
      return;
    }

    if (gameState.settings.gameMode == GameMode.singlePlayer &&
        gameState.currentPlayer == Player.o) {
      await _makeAIMove();
    }
  }

  Future<void> _makeAIMove() async {
    final generation = _moveGeneration;
    final aiPlayer = gameState.currentPlayer;

    _isThinking.value = true;
    try {
      await Future.delayed(gameState.settings.aiDelay);
      if (_isDisposed ||
          isSuspended ||
          isGameOver ||
          generation != _moveGeneration ||
          gameState.currentPlayer != aiPlayer) {
        return;
      }
      final aiMove = await _aiService.getNextMove(gameState);
      if (_isDisposed ||
          isSuspended ||
          isGameOver ||
          generation != _moveGeneration ||
          gameState.currentPlayer != aiPlayer) {
        return;
      }
      _isThinking.value = false;
      if (aiMove != null && aiMove >= 0 && aiMove < gameState.board.length) {
        await _applyMove(aiMove);
      }
    } catch (_) {
      // Keep a failed calculation from locking the board forever.
      if (!_isDisposed && !isSuspended && generation == _moveGeneration) {
        final fallback = gameState.board.indexOf(Player.none);
        _isThinking.value = false;
        if (fallback >= 0 && !isGameOver) await _applyMove(fallback);
      }
    } finally {
      // A response from an old round must not unlock a newer AI turn.
      if (!_isDisposed && generation == _moveGeneration) {
        _isThinking.value = false;
      }
    }
  }

  Future<void> _handleGameOver() async {
    final generation = _roundGeneration;
    final settings = gameState.settings;
    _gameStopwatch.stop();
    final gameDuration = _gameStopwatch.elapsed;

    final gameMode = settings.gameMode;
    final winner = gameState.winner;
    final isDraw = winner == null;
    if (Get.isRegistered<TicTacToeSoundService>()) {
      unawaited(
          Get.find<TicTacToeSoundService>().play(isDraw ? 'draw' : 'win'));
    }

    if (gameMode == GameMode.singlePlayer) {
      final isWin = winner == Player.x;

      await _statsController.updateGameStats(
        gameMode: gameMode,
        difficulty: settings.difficulty,
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

      if (!_isDisposed && generation == _roundGeneration) _gameState.refresh();
    }

    if (!_isDisposed &&
        generation == _roundGeneration &&
        settings.autoRestart) {
      countdown.value = 3;
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_isDisposed || generation != _roundGeneration) {
          timer.cancel();
          return;
        }
        if (isSuspended) return;
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
    _roundGeneration++;
    _moveGeneration++;
    _countdownTimer?.cancel();
    _gameState.value = TicTacToeState.initial().copyWith(
      settings: _settingsController.settings,
    );
    _isThinking.value = false;
    _isSuspended.value = false;
    countdown.value = 3;
    _gameStopwatch.reset();
    _gameStopwatch.start();
  }

  /// Dialogs/help suspend both input and pending AI, and freeze auto-restart.
  void setSuspended(bool value) {
    if (_isDisposed || value == isSuspended) return;
    _isSuspended.value = value;
    _moveGeneration++;
    _isThinking.value = false;
    if (value) {
      _gameStopwatch.stop();
    } else {
      if (!isGameOver) _gameStopwatch.start();
      if (!isGameOver &&
          gameState.settings.gameMode == GameMode.singlePlayer &&
          gameState.currentPlayer == Player.o) {
        unawaited(_makeAIMove());
      }
    }
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
    _roundGeneration++;
    _moveGeneration++;
    _countdownTimer?.cancel();
    _gameStopwatch.stop();
    super.onClose();
  }
}
