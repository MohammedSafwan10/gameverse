import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/controllers/game_controller.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/controllers/settings_controller.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/controllers/stats_controller.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/game_difficulty.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/game_mode.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/game_settings.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/game_state.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/game_stats.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/player.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/services/ai_service.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/services/navigation_service.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/services/storage_service.dart';

class _FakeAIService extends AIService {
  _FakeAIService(this.nextMove);

  final int? nextMove;

  @override
  Future<int?> getNextMove(state) async => nextMove;
}

class _FakeNavigationService extends TicTacToeNavigationService {}

class _FakeStorageService extends StorageService {
  GameStats stored = const GameStats();

  @override
  Future<GameStats> loadStats() async => stored;

  @override
  Future<void> saveStats(GameStats stats) async {
    stored = stats;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return 'C:/Users/User/AppData/Local/Temp';
      }
      return null;
    });
  });

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  TicTacToeGameController createController({
    required AIService aiService,
    GameSettings settings = const GameSettings(),
  }) {
    final storage = _FakeStorageService();
    Get.put<StorageService>(storage);
    Get.put<TicTacToeStatsController>(TicTacToeStatsController(storage));
    final settingsController = Get.put(TicTacToeSettingsController());
    settingsController.updateSettings(settings);
    Get.put<TicTacToeNavigationService>(_FakeNavigationService());

    return TicTacToeGameController(
      Get.find<TicTacToeNavigationService>(),
      aiService,
    )..onInit();
  }

  test('ignores invalid AI move indexes', () async {
    final controller = createController(
      aiService: _FakeAIService(-1),
      settings: const GameSettings(
        gameMode: GameMode.singlePlayer,
        aiDelay: Duration.zero,
      ),
    );

    await controller.makeMove(0);

    expect(controller.gameState.board[0], Player.x);
    expect(controller.gameState.board.where((cell) => cell == Player.o), isEmpty);
    expect(controller.gameState.currentPlayer, Player.o);
    expect(controller.isThinking, isFalse);
  });

  test('auto restart callback does nothing after controller closes', () async {
    final controller = createController(
      aiService: _FakeAIService(null),
      settings: const GameSettings(
        gameMode: GameMode.multiPlayer,
        autoRestart: true,
      ),
    );

    await controller.makeMove(0);
    await controller.makeMove(3);
    await controller.makeMove(1);
    await controller.makeMove(4);
    await controller.makeMove(2);

    expect(controller.gameState.status, GameStatus.won);
    controller.onClose();

    await Future<void>.delayed(const Duration(milliseconds: 3200));

    expect(controller.gameState.status, GameStatus.won);
    expect(controller.gameState.winner, Player.x);
  });

  test('ai service returns valid opening move on impossible difficulty', () {
    final ai = AIService();
    final move = ai.calculateMove(
      const TicTacToeState(
        board: [
          Player.none,
          Player.none,
          Player.none,
          Player.none,
          Player.none,
          Player.none,
          Player.none,
          Player.none,
          Player.none,
        ],
        currentPlayer: Player.o,
        status: GameStatus.playing,
        settings: GameSettings(
          gameMode: GameMode.singlePlayer,
          difficulty: GameDifficulty.impossible,
        ),
      ),
      GameDifficulty.impossible,
    );

    expect(move, isNot(-1));
    expect([0, 2, 4, 6, 8], contains(move));
  });
}
