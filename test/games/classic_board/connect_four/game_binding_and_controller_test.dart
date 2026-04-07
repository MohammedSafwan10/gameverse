import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
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
  @override
  void updateGameStats({
    required GameMode gameMode,
    required GameStatus result,
    AIDifficulty? difficulty,
    required Duration gameDuration,
  }) {}
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

  setUp(() {
    Get.testMode = true;
    Get.reset();
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
    Get.put<ConnectFourStatsController>(_FakeStatsController(), permanent: true);
  }

  ConnectFourController createController() {
    registerDependencies();
    return Get.put(ConnectFourController());
  }

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
