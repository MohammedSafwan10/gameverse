import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gameverse/games/puzzle/block_merge/bindings/game_binding.dart';
import 'package:gameverse/games/puzzle/block_merge/controllers/game_controller.dart';
import 'package:gameverse/games/puzzle/block_merge/controllers/settings_controller.dart';
import 'package:gameverse/games/puzzle/block_merge/screens/mode_selection_screen.dart';
import 'package:gameverse/games/puzzle/block_merge/screens/game_screen.dart';
import 'package:gameverse/games/puzzle/block_merge/screens/settings_screen.dart';
import 'package:gameverse/games/puzzle/block_merge/screens/support_screens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final storageDirectory =
        Directory.systemTemp.createTempSync('gameverse-resin-tests-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => storageDirectory.path);
    await GetStorage.init();
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    for (final name in ['Barlow', 'BarlowCondensed']) {
      final loader = FontLoader(name == 'Barlow' ? 'BlockResin' : name);
      loader.addFont(rootBundle.load(name == 'Barlow'
          ? 'assets/fonts/Barlow-SemiBold.ttf'
          : 'assets/fonts/BarlowCondensed-ExtraBold.ttf'));
      if (name == 'Barlow') {
        loader.addFont(rootBundle.load('assets/fonts/Barlow-ExtraBold.ttf'));
      }
      await loader.load();
    }
  });
  setUp(() async {
    Get.testMode = true;
    await GetStorage().erase();
  });
  for (final size in [
    const Size(320, 568),
    const Size(360, 800),
    const Size(390, 844),
    const Size(430, 932)
  ]) {
    for (final screen in [
      'mode',
      'classic',
      'time',
      'zen',
      'settings',
      'help',
      'stats'
    ]) {
      testWidgets('$screen fits ${size.width.toInt()}x${size.height.toInt()}',
          (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        BlockMergeBinding().dependencies();
        final game = Get.find<BlockMergeController>();
        final settings = Get.find<BlockMergeSettingsController>();
        settings.showTutorial.value = false;
        settings.soundEnabled.value = false;
        if (screen == 'time') {
          settings.gameMode.value = BlockMergeMode.timeChallenge;
        }
        if (screen == 'zen') settings.gameMode.value = BlockMergeMode.zen;
        final Widget widget = switch (screen) {
          'mode' => const BlockMergeModeSelectionScreen(),
          'settings' => const BlockMergeSettingsScreen(),
          'help' => const BlockMergeHelpScreen(),
          'stats' => const BlockMergeStatisticsScreen(),
          _ => const BlockMergeGameScreen(),
        };
        final key = GlobalKey();
        await tester.pumpWidget(
            GetMaterialApp(home: RepaintBoundary(key: key, child: widget)));
        await tester.pump(const Duration(milliseconds: 350));
        // Decode production artwork before taking an actual rendered preview.
        await tester.runAsync(() async =>
            Future<void>.delayed(const Duration(milliseconds: 100)));
        await tester.pump();
        expect(tester.takeException(), isNull);
        if (screen == 'mode' && size.width == 390) {
          await expectLater(find.byKey(key),
              matchesGoldenFile('goldens/block_merge_mode_390.png'));
        }
        if (screen == 'mode') {
          expect(find.text('HOW TO PLAY'), findsOneWidget);
          expect(tester.getRect(find.text('HOW TO PLAY')).bottom,
              lessThanOrEqualTo(size.height));
        }
        if (size.width == 390 || size.width == 320) {
          await tester.runAsync(() async {
            final boundary = key.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            final file = File(
                '.dart_tool/block_merge_${screen}_${size.width.toInt()}.png');
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.pumpWidget(const SizedBox.shrink());
        game.onClose();
        Get.reset();
      });
    }
  }

  for (final screen in ['mode', 'game']) {
    testWidgets('$screen supports larger accessibility text without clipping',
        (tester) async {
      Get.testMode = true;
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      BlockMergeBinding().dependencies();
      final game = Get.find<BlockMergeController>();
      game.settings.showTutorial.value = false;
      game.settings.soundEnabled.value = false;
      await tester.pumpWidget(GetMaterialApp(
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!),
          home: screen == 'mode'
              ? const BlockMergeModeSelectionScreen()
              : const BlockMergeGameScreen()));
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull);
      final button = find.text(screen == 'mode' ? 'HOW TO PLAY' : 'RESTART');
      await tester.ensureVisible(button);
      expect(tester.getRect(button).bottom, lessThanOrEqualTo(568));
      await tester.pumpWidget(const SizedBox.shrink());
      game.onClose();
      Get.reset();
    });
  }
}
