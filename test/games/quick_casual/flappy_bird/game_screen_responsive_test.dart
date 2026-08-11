import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:gameverse/games/quick_casual/flappy_bird/controllers/game_controller.dart';
import 'package:gameverse/games/quick_casual/flappy_bird/controllers/settings_controller.dart';
import 'package:gameverse/games/quick_casual/flappy_bird/screens/game_screen.dart';
import 'package:gameverse/games/quick_casual/flappy_bird/services/score_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory storageDirectory;

  setUpAll(() async {
    Get.testMode = true;
    storageDirectory =
        Directory.systemTemp.createTempSync('flappy-game-screen-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => storageDirectory.path,
    );
    await GetStorage.init('flappy_game_screen_test');
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    try {
      storageDirectory.deleteSync(recursive: true);
    } on FileSystemException {
      // GetStorage can briefly retain a Windows file handle.
    }
  });

  tearDown(Get.reset);

  Future<void> pumpGame(
    WidgetTester tester,
    Size size,
    FlappyBirdTheme theme,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final settings = Get.put(FlappyBirdSettingsController());
    settings.setTheme(theme);
    await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
    await tester.pump();
    Get.put(FlappyBirdGameController(scoreService: ScoreService()));
    await tester.pumpWidget(
      const GetMaterialApp(home: FlappyBirdGameScreen()),
    );
    await tester.pump(const Duration(milliseconds: 500));
  }

  for (final size in const [
    Size(320, 568),
    Size(360, 800),
    Size(390, 844),
    Size(430, 932),
  ]) {
    testWidgets(
      'ready and pause states fit ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        await pumpGame(tester, size, FlappyBirdTheme.classic);
        expect(find.text('TAP TO FLY'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('TAP TO FLY'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.bySemanticsLabel('Pause'));
        await tester.pump();

        expect(find.text('FLIGHT PAUSED'), findsOneWidget);
        expect(find.text('RESUME'), findsOneWidget);
        expect(find.text('RESTART'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Cyber flight uses the same gameplay controls', (tester) async {
    await pumpGame(tester, const Size(390, 844), FlappyBirdTheme.cyberpunk);
    expect(find.text('TAP TO FLY'), findsOneWidget);
    expect(find.bySemanticsLabel('Pause'), findsOneWidget);
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
