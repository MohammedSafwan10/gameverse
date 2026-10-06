import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/controllers/game_controller.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/controllers/settings_controller.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/controllers/stats_controller.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/game_stats.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/game_settings.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/game_state.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/game_mode.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/game_difficulty.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/player.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/services/storage_service.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/services/ai_service.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/services/navigation_service.dart';

class _Storage extends StorageService {
  final Completer<GameStats>? initial;
  _Storage({this.initial});
  GameStats saved = const GameStats();
  @override
  Future<GameStats> loadStats() async =>
      initial == null ? saved : initial!.future;
  @override
  Future<void> saveStats(GameStats stats) async {
    saved = stats;
  }
}

class _ControlledAI extends AIService {
  final requests = <Completer<int?>>[];
  @override
  Future<int?> getNextMove(TicTacToeState state) {
    final request = Completer<int?>();
    requests.add(request);
    return request.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    Get.testMode = true;
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => 'D:/Dev/freela/gameverse/.dart_tool/test_storage');
  });
  tearDown(Get.reset);
  Future<TicTacToeGameController> create(AIService ai,
      {bool local = false, bool restart = false}) async {
    final stats = Get.put(TicTacToeStatsController(_Storage()));
    await stats.ready;
    Get.put(TicTacToeSettingsController()).updateSettings(GameSettings(
        gameMode: local ? GameMode.multiPlayer : GameMode.singlePlayer,
        aiDelay: Duration.zero,
        autoRestart: restart));
    return Get.put(
        TicTacToeGameController(Get.put(TicTacToeNavigationService()), ai));
  }

  test('old AI response cannot unlock a newer AI turn', () async {
    final ai = _ControlledAI();
    final c = await create(ai);
    final first = c.makeMove(0);
    await Future<void>.delayed(Duration.zero);
    c.resetGame();
    final second = c.makeMove(1);
    await Future<void>.delayed(Duration.zero);
    ai.requests[0].complete(4);
    await first;
    expect(c.isThinking, isTrue);
    await c.makeMove(2);
    expect(c.gameState.board[2], Player.none);
    ai.requests[1].complete(4);
    await second;
    expect(c.gameState.board[1], Player.x);
    expect(c.gameState.board[4], Player.o);
    expect(c.gameState.board[0], Player.none);
    expect(c.isThinking, isFalse);
  });
  test('suspension cancels pending AI and resumes exactly once', () async {
    final ai = _ControlledAI();
    final c = await create(ai);
    final move = c.makeMove(0);
    await Future<void>.delayed(Duration.zero);
    c.setSuspended(true);
    ai.requests[0].complete(4);
    await move;
    expect(c.gameState.board[4], Player.none);
    await c.makeMove(1);
    expect(c.gameState.board[1], Player.none);
    c.setSuspended(false);
    c.setSuspended(false);
    await Future<void>.delayed(Duration.zero);
    expect(ai.requests.length, 2);
    ai.requests[1].complete(4);
    await Future<void>.delayed(Duration.zero);
    expect(c.gameState.board[4], Player.o);
    expect(c.gameState.currentPlayer, Player.x);
  });
  test('local wins, draws, duplicate taps and reset update stats once',
      () async {
    final c = await create(AIService(), local: true);
    await c.makeMove(0);
    await c.makeMove(0);
    expect(c.gameState.currentPlayer, Player.o);
    for (final i in [1, 4, 2, 8]) {
      await c.makeMove(i);
    }
    expect(c.gameState.winningLine, [0, 4, 8]);
    await c.makeMove(3);
    expect(Get.find<TicTacToeStatsController>().player1Wins, 1);
    c.resetGame();
    expect(c.gameState.winningLine, isEmpty);
    expect(c.gameState.winner, isNull);
    for (final i in [0, 1, 2, 4, 3, 5, 7, 6, 8]) {
      await c.makeMove(i);
    }
    expect(c.gameState.status, GameStatus.draw);
    expect(Get.find<TicTacToeStatsController>().multiplayerDraws, 1);
    expect(
        Get.find<TicTacToeStatsController>().stats.multiplayerStats.gamesPlayed,
        2);
  });
  test('auto restart is frozen while a confirmation is open', () async {
    final c = await create(AIService(), local: true, restart: true);
    for (final i in [0, 3, 1, 4, 2]) {
      await c.makeMove(i);
    }
    c.setSuspended(true);
    await Future<void>.delayed(const Duration(milliseconds: 3200));
    expect(c.isGameOver, isTrue);
    expect(c.countdown.value, 3);
    c.resetGame();
    c.onClose();
  });
  test('late stats load cannot overwrite the first completed round', () async {
    final initial = Completer<GameStats>();
    final storage = _Storage(initial: initial);
    final stats = TicTacToeStatsController(storage);
    final update = stats.updateGameStats(
        gameMode: GameMode.singlePlayer,
        difficulty: GameDifficulty.medium,
        isWin: true,
        isDraw: false,
        gameDuration: const Duration(seconds: 1));
    initial.complete(const GameStats(difficultyStats: {
      GameDifficulty.medium:
          DifficultyStats(gamesPlayed: 10, gamesWon: 5, gamesLost: 5)
    }));
    await update;
    expect(stats.stats.gamesPlayed, 11);
    expect(storage.saved.gamesWon, 6);
    stats.onClose();
  });
}
