import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gameverse/games/classic_board/chess/controllers/game_controller.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_board.dart';
import 'package:gameverse/games/classic_board/chess/models/chess_piece.dart';
import 'package:gameverse/games/classic_board/chess/services/ai_service.dart';
import 'package:gameverse/games/classic_board/chess/services/sound_service.dart';
import 'package:gameverse/games/classic_board/chess/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  test('human cannot move the black side while AI is thinking', () {
    fakeAsync((async) {
      final controller = _controller();
      controller.startNewGame(ChessGameMode.ai);

      controller.makeMove('e2', 'e4');
      expect(controller.isWhiteTurn.value, isFalse);

      controller.makeMove('e7', 'e5');

      expect(controller.board.getPieceAt('e7'), isNotNull);
      expect(controller.board.getPieceAt('e5'), isNull);
      expect(controller.isWhiteTurn.value, isFalse);
      controller.onClose();
    });
  });

  test('timer ends the game on the tick that reaches zero', () {
    fakeAsync((async) {
      final controller = _controller();
      controller.timerEnabled.value = true;
      controller.startNewGame(ChessGameMode.local);
      controller.whiteTimeRemaining.value = 1;

      async.elapse(const Duration(seconds: 1));

      expect(controller.whiteTimeRemaining.value, 0);
      expect(controller.gameState.value, ChessGameState.checkmate);
      expect(controller.endReason.value, ChessEndReason.timeout);
      controller.onClose();
    });
  });

  test('flag fall is a draw when the opponent has only a king', () {
    fakeAsync((async) {
      final controller = _controller();
      controller.timerEnabled.value = true;
      controller.startNewGame(ChessGameMode.local);
      controller.board.loadFen('4k3/8/8/8/8/8/8/4K3 w - - 0 1');
      controller.whiteTimeRemaining.value = 1;

      async.elapse(const Duration(seconds: 1));

      expect(controller.gameState.value, ChessGameState.draw);
      expect(
        controller.endReason.value,
        ChessEndReason.insufficientMaterial,
      );
      controller.onClose();
    });
  });

  test('controller does not run a phantom clock before mode selection', () {
    fakeAsync((async) {
      final controller = _controller(_LogicStorage(timerSetting: true));
      final initialWhite = controller.whiteTimeRemaining.value;

      async.elapse(const Duration(seconds: 3));

      expect(controller.gameState.value, ChessGameState.initial);
      expect(controller.whiteTimeRemaining.value, initialWhite);
      controller.onClose();
    });
  });

  test('resume is a no-op after a finished game', () {
    final controller = _controller();
    controller.forfeitGame();

    controller.resumeGame();

    expect(controller.gameState.value, ChessGameState.checkmate);
    expect(controller.isGamePaused.value, isFalse);
    expect(controller.endReason.value, ChessEndReason.resignation);
    controller.onClose();
  });

  test('saved match restores paused with its mode and clocks', () {
    final board = ChessBoard()..movePiece('e2', 'e4');
    final storage = _LogicStorage(
      savedState: board.toJson(),
      metadata: {
        'mode': 'ai',
        'timerEnabled': true,
        'timePerPlayer': 5,
        'whiteTimeRemaining': 287,
        'blackTimeRemaining': 294,
        'aiDifficulty': 3,
      },
    );
    final controller = _controller(storage);

    expect(controller.hasSavedMatch.value, isTrue);
    expect(controller.isGamePaused.value, isTrue);
    expect(controller.gameMode.value, ChessGameMode.ai);
    expect(controller.whiteTimeRemaining.value, 287);
    expect(controller.blackTimeRemaining.value, 294);

    controller.continueSavedGame();
    expect(controller.isGamePaused.value, isFalse);
    controller.onClose();
  });

  test('abruptly closed timed match charges elapsed wall time on restore', () {
    final board = ChessBoard()..movePiece('e2', 'e4');
    final storage = _LogicStorage(
      savedState: board.toJson(),
      metadata: {
        'mode': 'local',
        'timerEnabled': true,
        'timePerPlayer': 5,
        'whiteTimeRemaining': 287,
        'blackTimeRemaining': 294,
        'aiDifficulty': 2,
        'clockRunning': true,
        'savedAtEpochMs': DateTime.now().millisecondsSinceEpoch -
            const Duration(seconds: 5).inMilliseconds,
      },
    );

    final controller = _controller(storage);

    expect(controller.whiteTimeRemaining.value, 287);
    expect(controller.blackTimeRemaining.value, inInclusiveRange(288, 289));
    expect(controller.isGamePaused.value, isTrue);
    controller.onClose();
  });

  test('importing a terminal FEN updates result without recording stats', () {
    final storage = _LogicStorage();
    final controller = _controller(storage);

    controller.importFen('7k/6Q1/6K1/8/8/8/8/8 b - - 0 1');

    expect(controller.gameState.value, ChessGameState.checkmate);
    expect(controller.endReason.value, ChessEndReason.checkmate);
    expect(storage.results, isEmpty);
    controller.onClose();
  });

  testWidgets('pausing dismisses promotion and cannot apply a stale choice',
      (tester) async {
    final controller = _controller();
    controller.startNewGame(ChessGameMode.local);
    controller.board.loadFen('4k3/P7/8/8/8/8/8/4K3 w - - 0 1');
    controller.isWhiteTurn.value = true;
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));

    controller.makeMove('a7', 'a8');
    await tester.pumpAndSettle();
    expect(find.text('PAWN PROMOTION'), findsOneWidget);

    controller.pauseGame();
    await tester.pumpAndSettle();

    expect(find.text('PAWN PROMOTION'), findsNothing);
    expect(controller.board.getPieceAt('a7')?.type, PieceType.pawn);
    expect(controller.board.getPieceAt('a8'), isNull);
    controller.onClose();
  });
}

ChessGameController _controller([_LogicStorage? testStorage]) {
  final storage = Get.put<ChessStorageService>(testStorage ?? _LogicStorage());
  final sound = Get.put<ChessSoundService>(_SilentSound());
  Get.put(ChessAIService());
  return Get.put(ChessGameController(storage, sound));
}

class _LogicStorage extends ChessStorageService {
  _LogicStorage({this.savedState, this.metadata, this.timerSetting = false});
  final String? savedState;
  final Map<String, dynamic>? metadata;
  final bool timerSetting;
  final List<String> results = [];
  @override
  // ignore: must_call_super
  void onInit() {}
  @override
  String? loadSerializedGameState() => savedState;
  @override
  Map<String, dynamic>? loadSessionMetadata() => metadata;
  @override
  bool get showLegalMoves => true;
  @override
  bool get showLastMove => true;
  @override
  String get boardTheme => 'classic';
  @override
  bool get timerEnabled => timerSetting;
  @override
  int get timePerPlayer => 10;
  @override
  int get aiDifficulty => 2;
  @override
  Future<void> saveSerializedGameState(String serializedState) async {}
  @override
  Future<void> saveSessionMetadata(Map<String, dynamic> metadata) async {}
  @override
  Future<void> saveSession(
      String serializedBoard, Map<String, dynamic> metadata) async {}
  @override
  Future<void> clearSavedGame() async {}
  @override
  Future<void> updateGameStats({required String result}) async {
    results.add(result);
  }
}

class _SilentSound extends ChessSoundService {
  @override
  // ignore: must_call_super
  void onInit() {}
  @override
  Future<void> playMoveSound() async {}
  @override
  Future<void> playCaptureSound() async {}
  @override
  Future<void> playCheckSound() async {}
  @override
  Future<void> playCheckmateSound() async {}
  @override
  Future<void> playGameEndSound() async {}
  @override
  Future<void> playClockTickSound() async {}
  @override
  Future<void> playTimeUpSound() async {}
  @override
  Future<void> playErrorSound() async {}
}
