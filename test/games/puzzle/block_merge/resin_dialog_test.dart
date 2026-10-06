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
import 'package:gameverse/games/puzzle/block_merge/models/block.dart';
import 'package:gameverse/games/puzzle/block_merge/models/game_state.dart';
import 'package:gameverse/games/puzzle/block_merge/screens/game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final path =
        Directory.systemTemp.createTempSync('gameverse-resin-dialogs-').path;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => path);
    await GetStorage.init();
    for (final entry in {
      'BlockResin': 'assets/fonts/Barlow-ExtraBold.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf'
    }.entries) {
      final font = FontLoader(entry.key)..addFont(rootBundle.load(entry.value));
      if (entry.key == 'BlockResin') {
        font.addFont(rootBundle.load('assets/fonts/Barlow-SemiBold.ttf'));
      }
      await font.load();
    }
  });
  for (final size in [const Size(320, 568), const Size(390, 844)]) {
    for (final dialog in [
      'pause',
      'restart',
      'leave',
      'won',
      'blocked',
      'expired'
    ]) {
      testWidgets('$dialog dialog works at $size', (tester) async {
        Get.testMode = true;
        await GetStorage().erase();
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        BlockMergeBinding().dependencies();
        final game = Get.find<BlockMergeController>();
        game.settings.showTutorial.value = false;
        game.settings.soundEnabled.value = false;
        final key = GlobalKey();
        await tester.pumpWidget(GetMaterialApp(
            builder: (c, child) => RepaintBoundary(key: key, child: child!),
            home: const BlockMergeGameScreen()));
        await tester.pump();
        switch (dialog) {
          case 'pause':
            await tester.tap(find.byTooltip('Pause'));
          case 'restart':
            await tester.tap(find.text('RESTART'));
          case 'leave':
            await tester.tap(find.byTooltip('Back'));
          case 'won':
            game.grid.value = List.generate(
                4,
                (y) => List.generate(
                    4,
                    (x) => y == 0 && x < 2
                        ? Block(value: 1024, position: Position(x, y))
                        : null));
            game.moveLeft();
          case 'blocked':
            game.isGameOver.value = true;
            game.gameState.value =
                game.gameState.value.copyWith(status: GameStatus.gameOver);
          case 'expired':
            game.settings.setGameMode(BlockMergeMode.timeChallenge);
            game.timeRemaining.value = 0;
            game.isGameOver.value = true;
            game.gameState.value =
                game.gameState.value.copyWith(status: GameStatus.gameOver);
        }
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pump(const Duration(milliseconds: 350));
        await tester.runAsync(() async =>
            Future<void>.delayed(const Duration(milliseconds: 100)));
        await tester.pump();
        expect(tester.takeException(), isNull);
        final title = switch (dialog) {
          'pause' => 'GAME PAUSED',
          'restart' => 'START AGAIN?',
          'leave' => 'LEAVE THIS GAME?',
          'won' => '2048!',
          'blocked' => 'NO MOVES LEFT',
          _ => 'TIME’S UP',
        };
        expect(find.text(title), findsOneWidget);
        if (dialog == 'expired') {
          expect(find.text('UNDO LAST MOVE'), findsNothing);
        }
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
                  '.dart_tool/block_merge_${dialog}_${size.width.toInt()}.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        final action = dialog == 'pause'
            ? 'RESUME'
            : dialog == 'won'
                ? 'KEEP PLAYING'
                : dialog == 'restart' || dialog == 'leave'
                    ? 'KEEP PLAYING'
                    : dialog == 'expired'
                        ? 'PLAY AGAIN'
                        : 'TRY AGAIN';
        final button = find.text(action);
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.text(title), findsNothing);
        expect(game.isPaused.value, false);
        if (dialog == 'won') expect(game.hasWon.value, false);
        if (dialog == 'blocked' || dialog == 'expired') {
          expect(game.isGameOver.value, false);
        }
        await tester.pumpWidget(const SizedBox.shrink());
        game.onClose();
        Get.reset();
      });
    }
  }
}
