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
}
