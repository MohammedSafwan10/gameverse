import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/brain_training/memory_match/bindings/game_binding.dart';
import 'package:gameverse/games/brain_training/memory_match/controllers/game_controller.dart';
import 'package:gameverse/games/brain_training/memory_match/models/game_mode.dart';
import 'package:gameverse/games/brain_training/memory_match/models/game_state.dart';
import 'package:gameverse/games/brain_training/memory_match/screens/completion_screen.dart';
import 'package:gameverse/games/brain_training/memory_match/screens/game_screen.dart';
import 'package:gameverse/games/brain_training/memory_match/screens/mode_selection_screen.dart';
import 'package:gameverse/games/brain_training/memory_match/services/sound_service.dart';
import 'package:get/get.dart';

class _SilentSoundService extends MemoryMatchSoundService {
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
    Get.put<MemoryMatchSoundService>(_SilentSoundService());
    MemoryMatchBinding.initDependencies();
  });

  tearDown(Get.reset);

  const sizes = <Size>[
    Size(320, 568),
    Size(360, 800),
    Size(390, 844),
    Size(430, 932),
  ];

  for (final size in sizes) {
    testWidgets(
      'mode selection has no layout exceptions at ${size.width}x${size.height}',
      (tester) async {
        _setSize(tester, size);
        await tester.pumpWidget(
          const GetMaterialApp(home: MemoryMatchModeSelectionScreen()),
        );
        await tester.pump();

        expect(find.text('MEMORY\nMATCH'), findsOneWidget);
        expect(find.text('CLASSIC'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (size == const Size(390, 844)) {
          await expectLater(
            find.byType(MemoryMatchModeSelectionScreen),
            matchesGoldenFile('goldens/mode_selection_390x844.png'),
          );
        }
      },
    );

    testWidgets(
      'game board has no layout exceptions at ${size.width}x${size.height}',
      (tester) async {
        _setSize(tester, size);
        await tester.pumpWidget(
          const GetMaterialApp(
            home: MemoryMatchGameScreen(
              mode: MemoryMatchMode.classic,
              difficulty: GameDifficulty.hard,
            ),
          ),
        );
        await tester.pump();

        expect(find.byKey(const ValueKey('memory-card-19')), findsOneWidget);
        expect(find.text('0 OF 10 PAIRS'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (size == const Size(390, 844)) {
          await expectLater(
            find.byType(MemoryMatchGameScreen),
            matchesGoldenFile('goldens/game_hard_390x844.png'),
          );
        }
        Get.find<MemoryMatchGameController>().cleanupGame();
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      'result has no layout exceptions at ${size.width}x${size.height}',
      (tester) async {
        _setSize(tester, size);
        await tester.pumpWidget(
          const GetMaterialApp(
            home: GameCompletionScreen(
              mode: MemoryMatchMode.classic,
              difficulty: GameDifficulty.medium,
              score: 2450,
              moves: 14,
              timeElapsed: 73,
              combo: 5,
              starRating: 3,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('BRILLIANT!'), findsOneWidget);
        expect(find.text('PLAY AGAIN'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (size == const Size(390, 844)) {
          await expectLater(
            find.byType(GameCompletionScreen),
            matchesGoldenFile('goldens/completion_390x844.png'),
          );
        }
      },
    );
  }

  testWidgets('difficulty sheet remains usable on a compact phone',
      (tester) async {
    _setSize(tester, const Size(320, 568));
    await tester.pumpWidget(
      const GetMaterialApp(home: MemoryMatchModeSelectionScreen()),
    );

    await tester.tap(find.text('CLASSIC'));
    await tester.pumpAndSettle();

    expect(find.text('PICK A DIFFICULTY'), findsOneWidget);
    expect(find.text('HARD'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(BottomSheet),
      matchesGoldenFile('goldens/difficulty_320x568.png'),
    );
  });

  testWidgets('time-up result shows retry guidance', (tester) async {
    _setSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      const GetMaterialApp(
        home: GameCompletionScreen(
          mode: MemoryMatchMode.timeTrial,
          difficulty: GameDifficulty.easy,
          score: 800,
          moves: 12,
          timeElapsed: 60,
          combo: 2,
          starRating: 0,
          isTimeUp: true,
        ),
      ),
    );

    expect(find.text('TIME’S UP!'), findsOneWidget);
    expect(find.text('PLAY AGAIN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _setSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
