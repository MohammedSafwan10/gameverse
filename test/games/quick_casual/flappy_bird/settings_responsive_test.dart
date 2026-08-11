import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:gameverse/games/quick_casual/flappy_bird/controllers/settings_controller.dart';
import 'package:gameverse/games/quick_casual/flappy_bird/screens/settings_screen.dart';

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
    storageDirectory = Directory.systemTemp.createTempSync('flappy-settings-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => storageDirectory.path,
    );
    await GetStorage.init('flappy_settings_test');
  });

  tearDown(() => Get.reset());

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'), null);
    try {
      storageDirectory.deleteSync(recursive: true);
    } on FileSystemException {
      // GetStorage can briefly retain a Windows handle after the test.
    }
  });

  Future<void> pumpSettings(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Get.put(FlappyBirdSettingsController());
    await tester.pumpWidget(
      GetMaterialApp(
        theme: ThemeData(fontFamily: 'BarlowCondensed'),
        home: const FlappyBirdSettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final size in const [
    Size(320, 568),
    Size(360, 800),
    Size(390, 844),
    Size(430, 932),
  ]) {
    testWidgets('settings is overflow-free at ${size.width}x${size.height}',
        (tester) async {
      await pumpSettings(tester, size);
      expect(find.byKey(const Key('flappy-settings-sound')), findsOneWidget);
      expect(find.byKey(const Key('flappy-settings-music')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('settings controls react and Cyber transforms the screen',
      (tester) async {
    await pumpSettings(tester, const Size(390, 844));
    final controller = Get.find<FlappyBirdSettingsController>();
    final originalSound = controller.soundEnabled.value;

    await tester.tap(find.byKey(const Key('flappy-settings-sound')));
    await tester.tap(find.byKey(const Key('flappy-settings-cyber')));
    await tester.pumpAndSettle();

    expect(controller.soundEnabled.value, !originalSound);
    expect(controller.currentTheme.value, FlappyBirdTheme.cyberpunk);
    expect(find.text('TUNE YOUR NEON RUN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
