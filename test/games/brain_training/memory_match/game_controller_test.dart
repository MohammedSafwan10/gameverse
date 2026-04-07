import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gameverse/games/brain_training/memory_match/controllers/game_controller.dart';
import 'package:gameverse/games/brain_training/memory_match/models/card_model.dart';
import 'package:gameverse/games/brain_training/memory_match/models/game_mode.dart';
import 'package:gameverse/games/brain_training/memory_match/models/game_state.dart';
import 'package:gameverse/games/brain_training/memory_match/services/sound_service.dart';

class _FakeMemoryMatchSoundService extends MemoryMatchSoundService {
  @override
  Future<void> playCardFlip() async {}

  @override
  Future<void> playMatchSuccess() async {}

  @override
  Future<void> playMatchFail() async {}

  @override
  Future<void> playGameComplete() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put<MemoryMatchSoundService>(_FakeMemoryMatchSoundService());
  });

  MemoryMatchState completedState() {
    final cards = [
      MemoryCard(
        id: 1,
        emoji: 'A',
        backgroundColor: const Color(0xFF000001),
        isMatched: true,
        isFlipped: true,
      ),
      MemoryCard(
        id: 2,
        emoji: 'A',
        backgroundColor: const Color(0xFF000001),
        isMatched: true,
        isFlipped: true,
      ),
    ];

    return MemoryMatchState(
      cards: cards,
      mode: MemoryMatchMode.classic,
      difficulty: GameDifficulty.easy,
      startTime: DateTime.now(),
      status: GameStatus.completed,
      score: 100,
      matchCount: 1,
      bestCombo: 1,
      moves: 1,
    );
  }

  testWidgets('cleanupGame cancels pending completion navigation',
      (tester) async {
    final controller = MemoryMatchGameController()..onInit();
    addTearDown(controller.onClose);
    controller.state = completedState();

    controller.cleanupGame();
    await tester.pump(const Duration(milliseconds: 1000));

    expect(controller.state, isNull);
    controller.onClose();
  });

  testWidgets('restartGame cancels pending completion navigation',
      (tester) async {
    final controller = MemoryMatchGameController()..onInit();
    controller.state = completedState();

    controller.restartGame();
    final restartedState = controller.state;

    await tester.pump(const Duration(milliseconds: 1000));

    expect(controller.state, isNotNull);
    expect(identical(controller.state, restartedState), isFalse);
    expect(controller.state!.status, GameStatus.playing);
    controller.onClose();
  });
}
