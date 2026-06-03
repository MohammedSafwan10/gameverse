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
    await GetStorage().erase();
  });

  BlockMergeController createController({
    BlockMergeMode mode = BlockMergeMode.classic,
  }) {
    final settings = BlockMergeSettingsController();
    settings.gameMode.value = mode;
    settings.soundEnabled.value = false;
    settings.vibrationEnabled.value = false;
    return BlockMergeController(settings);
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
  });

  testWidgets('rapid newGame cancels stale startup block timers',
      (tester) async {
    final controller = createController();
    addTearDown(controller.onClose);

    controller.newGame();

    await tester.pump(const Duration(milliseconds: 250));

    expect(occupiedCellCount(controller.grid.value), 2);
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
  });
}
