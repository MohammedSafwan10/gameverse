import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:gameverse/games/quick_casual/flappy_bird/controllers/settings_controller.dart';
import 'package:gameverse/games/quick_casual/flappy_bird/screens/mode_selection_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory storageDirectory;

  setUpAll(() async {
    Get.testMode = true;
    final fontLoader = FontLoader('BarlowCondensed')
      ..addFont(rootBundle.load('assets/fonts/BarlowCondensed-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/BarlowCondensed-Bold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/BarlowCondensed-ExtraBold.ttf'));
    await fontLoader.load();
    storageDirectory =
        Directory.systemTemp.createTempSync('flappy-mode-selection-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => storageDirectory.path,
    );
    await GetStorage.init('flappy_mode_selection_test');
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'), null);
    try {
      storageDirectory.deleteSync(recursive: true);
    } on FileSystemException {
      // GetStorage can briefly keep the Windows file handle open after tests.
    }
  });

  tearDown(() {
    Get.reset();
  });

  for (final size in const [
    Size(320, 568),
    Size(360, 800),
    Size(390, 844),
    Size(430, 932),
  ]) {
    testWidgets(
        'mode selection is overflow-free at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(fontFamily: 'BarlowCondensed'),
          home: const FlappyBirdModeSelectionScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('flappy-theme-classic')), findsOneWidget);
      expect(find.byKey(const Key('flappy-theme-cyber')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'selecting Cyber transforms the world without changing gameplay rules',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        theme: ThemeData(fontFamily: 'BarlowCondensed'),
        home: const FlappyBirdModeSelectionScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('flappy-theme-cyber')));
    await tester.pumpAndSettle();

    final settings = Get.find<FlappyBirdSettingsController>();
    expect(settings.currentTheme.value, FlappyBirdTheme.cyberpunk);
    expect(find.text('SELECT YOUR WORLD'), findsOneWidget);
    expect(find.text('LAUNCH FLIGHT'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final entry in const [
    (FlappyBirdTheme.classic, 'classic'),
    (FlappyBirdTheme.cyberpunk, 'cyber'),
  ]) {
    testWidgets('390x844 ${entry.$2} visual', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const captureKey = Key('flappy-mode-capture');

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(fontFamily: 'BarlowCondensed'),
          home: const RepaintBoundary(
            key: captureKey,
            child: FlappyBirdModeSelectionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Get.find<FlappyBirdSettingsController>().setTheme(entry.$1);
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(captureKey),
        matchesGoldenFile('goldens/flappy_mode_${entry.$2}_390x844.png'),
      );
    });
  }
}
