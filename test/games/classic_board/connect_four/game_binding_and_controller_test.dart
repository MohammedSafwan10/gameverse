import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gameverse/games/classic_board/connect_four/bindings/game_binding.dart';
import 'package:gameverse/games/classic_board/connect_four/controllers/game_controller.dart';
import 'package:gameverse/games/classic_board/connect_four/controllers/settings_controller.dart';
import 'package:gameverse/games/classic_board/connect_four/controllers/stats_controller.dart';
import 'package:gameverse/games/classic_board/connect_four/models/board.dart';
import 'package:gameverse/games/classic_board/connect_four/services/sound_service.dart';

class _FakeSoundService extends SoundService {
  @override
  Future<void> playDropSound() async {}

  @override
  Future<void> playWinSound() async {}
}

class _FakeStatsController extends ConnectFourStatsController {
  int updateCount = 0;
  GameStatus? lastResult;

  @override
  void updateGameStats({
    required GameMode gameMode,
    required GameStatus result,
    AIDifficulty? difficulty,
    required Duration gameDuration,
  }) {
    updateCount++;
    lastResult = result;
  }
}

class _FakeSettingsController extends ConnectFourSettingsController {
  @override
  void setGameMode(GameMode mode) {
    gameMode.value = mode;
  }

  @override
  void setDifficulty(AIDifficulty newDifficulty) {
    difficulty.value = newDifficulty;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return Directory.systemTemp.path;
      }
      return null;
    });

    await GetStorage.init();
  });

  setUp(() async {
    Get.testMode = true;
    Get.reset();
    await GetStorage().erase();
  });

  List<List<CellState>> emptyCells() => List.generate(
        Board.rows,
        (_) => List.filled(Board.cols, CellState.empty),
      );

  void registerDependencies() {
    final settings = Get.put<ConnectFourSettingsController>(
      _FakeSettingsController(),
      permanent: true,
    );
    settings.isSoundEnabled.value = false;
    settings.isVibrationEnabled.value = false;
    settings.isAutoRestartEnabled.value = false;

    Get.put<SoundService>(_FakeSoundService(), permanent: true);
    Get.put<ConnectFourStatsController>(_FakeStatsController(),
        permanent: true);
  }

  ConnectFourController createController() {
    registerDependencies();
    return Get.put(ConnectFourController());
  }

  _FakeStatsController fakeStats() =>
      Get.find<ConnectFourStatsController>() as _FakeStatsController;

  testWidgets('detects diagonal win with more than four connected discs',
      (tester) async {
    final controller = createController();

    final cells = emptyCells();
    cells[5][0] = CellState.player1;

    cells[5][1] = CellState.player2;
    cells[4][1] = CellState.player1;

    cells[5][2] = CellState.player2;
    cells[4][2] = CellState.player2;
    cells[3][2] = CellState.player1;

    cells[5][3] = CellState.player2;
    cells[4][3] = CellState.player2;
    cells[3][3] = CellState.player2;

    cells[5][4] = CellState.player2;
    cells[4][4] = CellState.player2;
    cells[3][4] = CellState.player2;
    cells[2][4] = CellState.player2;
    cells[1][4] = CellState.player1;

    controller.board.value = Board(cells: cells);
    controller.currentPlayer.value = CellState.player1;

    final moveFuture = controller.makeMove(3);
    await tester.pump(const Duration(milliseconds: 600));
    await moveFuture;

    expect(controller.board.value.status, GameStatus.player1Won);
    expect(controller.board.value.winningCells.length, 4);
    expect(
      controller.board.value.winningCells,
      anyOf(
        containsAll(const [
          Point(5, 0),
          Point(4, 1),
          Point(3, 2),
          Point(2, 3),
        ]),
        containsAll(const [
          Point(4, 1),
          Point(3, 2),
          Point(2, 3),
          Point(1, 4),
        ]),
      ),
    );
  });

  testWidgets('reset during player animation cancels stale turn switch',
      (tester) async {
    final controller = createController();
    controller.gameMode.value = GameMode.pvp;

    final moveFuture = controller.makeMove(0);
    await tester.pump(const Duration(milliseconds: 250));

    controller.resetGame();
    await tester.pump(const Duration(milliseconds: 400));
    await moveFuture;

    expect(controller.currentPlayer.value, CellState.player1);
    expect(controller.isAnimating.value, isFalse);
    expect(
      controller.board.value.cells
          .expand((row) => row)
          .every((cell) => cell == CellState.empty),
      isTrue,
    );
  });

  testWidgets('reset while AI is thinking cancels stale AI move',
      (tester) async {
    final controller = createController();
    controller.aiDifficulty.value = AIDifficulty.easy;
    controller.aiController.setDifficulty(AIDifficulty.easy);

    final moveFuture = controller.makeMove(0);
    await tester.pump(const Duration(milliseconds: 750));
    expect(controller.isAIThinking.value, isTrue);

    controller.resetGame();
    await tester.pump(const Duration(seconds: 2));
    await moveFuture;

    expect(controller.currentPlayer.value, CellState.player1);
    expect(controller.isAnimating.value, isFalse);
    expect(controller.isAIThinking.value, isFalse);
    expect(
      controller.board.value.cells
          .expand((row) => row)
          .every((cell) => cell == CellState.empty),
      isTrue,
    );
  });

  testWidgets('records winning result once and resets result guard',
      (tester) async {
    final controller = createController();
    controller.gameMode.value = GameMode.pvp;

    final cells = emptyCells();
    cells[5][0] = CellState.player1;
    cells[5][1] = CellState.player1;
    cells[5][2] = CellState.player1;
    controller.board.value = Board(cells: cells);
    controller.currentPlayer.value = CellState.player1;

    final moveFuture = controller.makeMove(3);
    await tester.pump(const Duration(milliseconds: 600));
    await moveFuture;

    expect(controller.board.value.status, GameStatus.player1Won);
    expect(fakeStats().updateCount, 1);
    expect(fakeStats().lastResult, GameStatus.player1Won);

    controller.resetGame();
    expect(controller.board.value.status, GameStatus.playing);
  });

  testWidgets('settings ignore invalid persisted values', (tester) async {
    final storage = GetStorage();
    await storage.write('connect_four_game_mode', 99);
    await storage.write('connect_four_difficulty', -1);
    await storage.write('connect_four_sound_enabled', 'yes');
    await storage.write('connect_four_vibration_enabled', 1);
    await storage.write('connect_four_auto_restart', null);

    final settings = Get.put(ConnectFourSettingsController());

    expect(settings.gameMode.value, GameMode.vsAI);
    expect(settings.difficulty.value, AIDifficulty.medium);
    expect(settings.isSoundEnabled.value, isTrue);
    expect(settings.isVibrationEnabled.value, isTrue);
    expect(settings.isAutoRestartEnabled.value, isFalse);
  });

  testWidgets('binding reuses existing controller instead of replacing it',
      (tester) async {
    registerDependencies();
    const binding = ConnectFourBinding(gameMode: GameMode.pvp);
    binding.dependencies();

    final firstController = Get.find<ConnectFourController>();
    firstController.currentPlayer.value = CellState.player2;
    firstController.board.value = Board(
      cells: List.generate(
        Board.rows,
        (row) => List.generate(
          Board.cols,
          (col) => row == Board.rows - 1 && col == 0
              ? CellState.player1
              : CellState.empty,
        ),
      ),
    );

    binding.dependencies();

    final reusedController = Get.find<ConnectFourController>();
    expect(identical(firstController, reusedController), isTrue);
    expect(reusedController.currentPlayer.value, CellState.player1);
    expect(reusedController.board.value.status, GameStatus.playing);
    expect(
      reusedController.board.value.cells
          .expand((row) => row)
          .every((cell) => cell == CellState.empty),
      isTrue,
    );
  });
}
