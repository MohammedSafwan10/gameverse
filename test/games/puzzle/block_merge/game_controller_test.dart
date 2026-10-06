import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gameverse/games/puzzle/block_merge/controllers/game_controller.dart';
import 'package:gameverse/games/puzzle/block_merge/controllers/settings_controller.dart';
import 'package:gameverse/games/puzzle/block_merge/models/block.dart';
import 'package:gameverse/games/puzzle/block_merge/models/game_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() async {
    final storageDirectory =
        Directory.systemTemp.createTempSync('gameverse-merge-tests-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return storageDirectory.path;
      }
      return null;
    });

    await GetStorage.init();
  });

  setUp(() async {
    await GetStorage().erase();
  });

  BlockMergeController createController({
    BlockMergeMode mode = BlockMergeMode.classic,
  }) {
    final settings = BlockMergeSettingsController();
    settings.onInit();
    settings.gameMode.value = mode;
    settings.soundEnabled.value = false;
    settings.vibrationEnabled.value = false;
    return BlockMergeController(settings,
        now: TestWidgetsFlutterBinding.instance.clock.now);
  }

  List<List<Block?>> gridFromValues(List<List<int>> values) {
    return List.generate(
      4,
      (y) => List.generate(4, (x) {
        final value = values[y][x];
        if (value == 0) return null;
        return Block(value: value, position: Position(x, y));
      }),
    );
  }

  List<List<int>> valuesFromGrid(List<List<Block?>> grid) {
    return List.generate(
      4,
      (y) => List.generate(4, (x) => grid[y][x]?.value ?? 0),
    );
  }

  int occupiedCellCount(List<List<Block?>> grid) {
    return grid.expand((row) => row).where((block) => block != null).length;
  }

  testWidgets('no-op swipe does not change undo state or move count',
      (tester) async {
    final controller = createController();
    addTearDown(controller.onClose);

    await tester.pump(const Duration(milliseconds: 250));

    final stableGrid = gridFromValues(const [
      [2, 4, 8, 16],
      [32, 64, 128, 256],
      [512, 1024, 2, 4],
      [8, 16, 32, 64],
    ]);

    controller.grid.value = stableGrid;
    controller.score.value = 42;
    controller.previousGrid.value = gridFromValues(const [
      [2, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]);
    controller.previousScore.value = 7;
    controller.gameState.value = controller.gameState.value.copyWith(
      status: GameStatus.playing,
      moves: 0,
      canUndo: false,
      previousGrid: controller.previousGrid.value,
      previousScore: 7,
      currentScore: 42,
    );

    controller.moveLeft();

    expect(valuesFromGrid(controller.grid.value), valuesFromGrid(stableGrid));
    expect(controller.gameState.value.moves, 0);
    expect(controller.gameState.value.canUndo, isFalse);
    expect(controller.previousScore.value, 7);
    expect(valuesFromGrid(controller.previousGrid.value), const [
      [2, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]);
    controller.onClose();
  });

  testWidgets('time challenge expiry marks game over in controller state',
      (tester) async {
    final controller = createController(mode: BlockMergeMode.timeChallenge);
    addTearDown(controller.onClose);

    await tester.pump();
    controller.timeRemaining.value = 1;

    await tester.pump(const Duration(seconds: 1));

    expect(controller.timeRemaining.value, 0);
    expect(controller.isGameOver.value, isTrue);
    expect(controller.gameState.value.status, GameStatus.gameOver);
    controller.onClose();
  });

  testWidgets('rapid newGame cancels stale startup block timers',
      (tester) async {
    final controller = createController();
    addTearDown(controller.onClose);

    controller.newGame();

    await tester.pump(const Duration(milliseconds: 250));

    expect(occupiedCellCount(controller.grid.value), 2);
    controller.onClose();
  });

  testWidgets('restored saved game hydrates current state and undo snapshot',
      (tester) async {
    final storage = GetStorage();
    await storage.write(
        'block_merge_current_mode', BlockMergeMode.classic.toString());
    await storage.write('block_merge_grid', [
      [
        {'value': 2, 'x': 0, 'y': 0},
        {},
        {},
        {},
      ],
      [
        {},
        {'value': 128, 'x': 1, 'y': 1},
        {},
        {},
      ],
      [{}, {}, {}, {}],
      [{}, {}, {}, {}],
    ]);
    await storage.write('block_merge_current_score', 256);
    await storage.write('block_merge_previous_grid', [
      [
        {'value': 2, 'x': 0, 'y': 0},
        {'value': 64, 'x': 1, 'y': 0},
        {},
        {},
      ],
      [{}, {}, {}, {}],
      [{}, {}, {}, {}],
      [{}, {}, {}, {}],
    ]);
    await storage.write('block_merge_previous_score', 128);

    final controller = createController();
    addTearDown(controller.onClose);

    expect(controller.score.value, 256);
    expect(controller.gameState.value.currentScore, 256);
    expect(controller.gameState.value.highestTile, 128);
    expect(controller.gameState.value.canUndo, isTrue);
    expect(controller.gameState.value.previousScore, 128);
    expect(valuesFromGrid(controller.gameState.value.previousGrid), const [
      [2, 64, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]);
    controller.onClose();
  });

  testWidgets('reaching 2048 records exactly one win', (tester) async {
    final controller = createController();
    addTearDown(controller.onClose);

    await tester.pump(const Duration(milliseconds: 250));

    controller.grid.value = gridFromValues(const [
      [1024, 1024, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]);
    controller.gameState.value = controller.gameState.value.copyWith(
      status: GameStatus.playing,
      highestTile: 1024,
    );

    controller.moveLeft();

    expect(controller.hasWon.value, isTrue);
    expect(controller.gameState.value.status, GameStatus.won);
    expect(GetStorage().read('block_merge_games_won'), 1);
    controller.onClose();
  });

  for (final mode in BlockMergeMode.values) {
    testWidgets('${mode.name}: undo recovers a blocked board and cannot repeat',
        (tester) async {
      final controller = createController(mode: mode);
      controller.grid.value = gridFromValues(const [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ]);
      controller.previousGrid.value = gridFromValues(const [
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      controller.isGameOver.value = true;
      controller.gameState.value =
          controller.gameState.value.copyWith(canUndo: true, moves: 1);
      controller.undo();
      expect(controller.isGameOver.value, false);
      expect(controller.highest, 2);
      expect(controller.canUndo, false);
      expect(controller.gameState.value.moves, 0);
      controller.moveRight();
      expect(controller.gameState.value.moves, 1);
      controller.onClose();
    });
    testWidgets('${mode.name}: pause blocks input and active time',
        (tester) async {
      final controller = createController(mode: mode);
      controller.setPaused(true);
      final before = valuesFromGrid(controller.grid.value);
      controller.moveRight();
      await tester.pump(const Duration(seconds: 3));
      expect(valuesFromGrid(controller.grid.value), before);
      expect(controller.timeRemaining.value, 180);
      expect(controller.gameState.value.playTime, Duration.zero);
      controller.setPaused(false);
      await tester.pump(const Duration(seconds: 1));
      expect(controller.gameState.value.playTime.inSeconds, 1);
      expect(controller.timeRemaining.value,
          mode == BlockMergeMode.timeChallenge ? 179 : 180);
      controller.onClose();
    });
    testWidgets(
        '${mode.name}: milestone can continue without duplicate wins on resume',
        (tester) async {
      final controller = createController(mode: mode);
      controller.grid.value = gridFromValues(const [
        [1024, 1024, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      controller.moveLeft();
      controller.continueAfterWin();
      expect(controller.hasWon.value, false);
      await tester.pump(const Duration(seconds: 1));
      if (mode == BlockMergeMode.timeChallenge) {
        expect(controller.timeRemaining.value, 179);
      }
      controller.onClose();
      final resumed = createController(mode: mode);
      expect(resumed.hasWon.value, false);
      expect(resumed.highest, 2048);
      expect(resumed.gameState.value.moves, 1);
      expect(GetStorage().read('block_merge_games_won'), 1);
      resumed.onClose();
    });
  }
  testWidgets('expired timed run cannot undo or swipe, including after restore',
      (tester) async {
    final controller = createController(mode: BlockMergeMode.timeChallenge);
    controller.newGame();
    controller.gameState.value =
        controller.gameState.value.copyWith(canUndo: true);
    controller.timeRemaining.value = 1;
    await tester.pump(const Duration(seconds: 1));
    final before = valuesFromGrid(controller.grid.value);
    controller.undo();
    controller.moveRight();
    expect(valuesFromGrid(controller.grid.value), before);
    expect(controller.canUndo, false);
    controller.onClose();
    final resumed = createController(mode: BlockMergeMode.timeChallenge);
    expect(resumed.expired, true);
    expect(resumed.isGameOver.value, true);
    resumed.onClose();
  });

  testWidgets('elapsed time handles delayed ticks and fractional pauses',
      (tester) async {
    var timestamp = DateTime.utc(2026);
    final settings = BlockMergeSettingsController()..onInit();
    settings.setGameMode(BlockMergeMode.timeChallenge);
    settings.soundEnabled.value = settings.vibrationEnabled.value = false;
    final controller = BlockMergeController(settings, now: () => timestamp);
    controller.newGame();
    timestamp = timestamp.add(const Duration(milliseconds: 500));
    controller.setPaused(true);
    timestamp = timestamp.add(const Duration(hours: 1));
    controller.setPaused(false);
    timestamp = timestamp.add(const Duration(milliseconds: 500));
    controller.moveLeft();
    expect(controller.timeRemaining.value, 179);
    timestamp = timestamp.add(const Duration(seconds: 5));
    controller.moveRight();
    expect(controller.timeRemaining.value, 174);
    expect(controller.gameState.value.playTime.inSeconds, 6);
    controller.onClose();
  });

  testWidgets('malformed save does not wipe valid records', (tester) async {
    await GetStorage().write('block_merge_best_score', 5000);
    await GetStorage().write('block_merge_sound_enabled', 'bad');
    await GetStorage().write('block_merge_session_v2', {
      'mode': BlockMergeMode.classic.toString(),
      'board': [
        [3]
      ],
    });
    final controller = createController();
    expect(controller.bestScore.value, 5000);
    expect(occupiedCellCount(controller.grid.value), 2);
    expect(controller.settings.bestScore.value, 5000);
    controller.onClose();
  });
}
