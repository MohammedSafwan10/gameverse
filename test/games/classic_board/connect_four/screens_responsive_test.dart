import 'package:flutter/material.dart';
import 'dart:math' show Point;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:gameverse/games/classic_board/connect_four/controllers/game_controller.dart';
import 'package:gameverse/games/classic_board/connect_four/controllers/settings_controller.dart';
import 'package:gameverse/games/classic_board/connect_four/controllers/stats_controller.dart';
import 'package:gameverse/games/classic_board/connect_four/models/board.dart';
import 'package:gameverse/games/classic_board/connect_four/services/sound_service.dart';
import 'package:gameverse/games/classic_board/connect_four/screens/mode_selection_screen.dart';
import 'package:gameverse/games/classic_board/connect_four/screens/game_screen.dart';
import 'package:gameverse/games/classic_board/connect_four/screens/settings_screen.dart';
import 'package:gameverse/games/classic_board/connect_four/screens/stats_screen.dart';
import 'package:gameverse/games/classic_board/connect_four/widgets/arcade_ui.dart';

class _Sound extends SoundService {
  @override
  Future<void> preload() async {}
  @override
  Future<void> playDropSound() async {}
  @override
  Future<void> playWinSound() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    Logger.level = Level.off;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => 'D:/Dev/freela/gameverse/.dart_tool/test_storage');
    await GetStorage.init();
    for (final (family, file) in [
      ('Barlow', 'assets/fonts/Barlow-SemiBold.ttf'),
      ('BarlowCondensed', 'assets/fonts/BarlowCondensed-ExtraBold.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf')
    ]) {
      await (FontLoader(family)..addFont(rootBundle.load(file))).load();
    }
  });
  setUp(() async {
    Get.testMode = true;
    Get.reset();
    await GetStorage().erase();
    final settings = Get.put(ConnectFourSettingsController());
    settings.isSoundEnabled.value = false;
    settings.isVibrationEnabled.value = false;
    settings.setGameMode(GameMode.pvp);
    Get.put<SoundService>(_Sound());
    Get.put(ConnectFourStatsController());
    Get.put(ConnectFourController());
  });
  tearDown(Get.reset);
  const sizes = [
    Size(320, 568),
    Size(360, 800),
    Size(390, 844),
    Size(430, 932)
  ];
  final pages = <String, Widget Function()>{
    'mode': () => const ConnectFourModeScreen(),
    'difficulty': () => const ConnectFourDifficultyScreen(),
    'game': () => const ConnectFourGameScreen(),
    'settings': () => const ConnectFourSettingsScreen(),
    'stats': () => const ConnectFourStatsScreen(),
    'help': () => const ConnectFourHelpScreen(),
  };
  Future<void> load(WidgetTester tester) async {
    final context = tester.element(find.byType(CFPage).first);
    await tester.runAsync(() async {
      for (final file in [
        'backdrop',
        'hero',
        'pair',
        'red-disc',
        'yellow-disc'
      ]) {
        await precacheImage(AssetImage('$cfAssets$file.png'), context);
      }
      await precacheImage(
          const AssetImage('assets/images/games/memory_match/trophy_v1.png'),
          context);
    });
    await tester.pumpAndSettle();
  }

  for (final size in sizes) {
    for (final page in pages.entries) {
      testWidgets('${page.key} at $size', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(GetMaterialApp(home: page.value()));
        await load(tester);
        expect(tester.takeException(), isNull);
        if (size == const Size(390, 844)) {
          await expectLater(find.byType(CFPage),
              matchesGoldenFile('goldens/${page.key}_390x844.png'));
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
    for (final draw in [false, true]) {
      testWidgets('result draw=$draw at $size', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final c = Get.find<ConnectFourController>();
        final rows = draw
            ? ['RRYYRRY', 'YYRRYYR', 'RRYYRRY', 'YYRRYYR', 'RRYYRRY', 'YYRRYYR']
            : [
                '.......',
                '.......',
                '.......',
                '.......',
                '.......',
                'RRRRYYY'
              ];
        c.board.value = Board(
            cells: rows
                .map((s) => s
                    .split('')
                    .map((v) => v == 'R'
                        ? CellState.player1
                        : v == 'Y'
                            ? CellState.player2
                            : CellState.empty)
                    .toList())
                .toList(),
            status: draw ? GameStatus.draw : GameStatus.player1Won,
            winningCells: draw ? [] : List.generate(4, (c) => Point(5, c)));
        await tester
            .pumpWidget(const GetMaterialApp(home: ConnectFourGameScreen()));
        await load(tester);
        expect(find.text(draw ? "IT'S A DRAW!" : 'RED WINS!'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (size == const Size(390, 844)) {
          await expectLater(
              find.byType(CFPage),
              matchesGoldenFile(
                  'goldens/${draw ? 'draw' : 'win'}_390x844.png'));
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
  for (final page in pages.entries) {
    testWidgets('large text ${page.key} fits compact phone', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(GetMaterialApp(
          home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
              child: page.value())));
      await load(tester);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('pause, restart and leave dialogs fit compact phones',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester
        .pumpWidget(const GetMaterialApp(home: ConnectFourGameScreen()));
    await load(tester);
    await tester.tap(find.byType(IconButton).at(2));
    await tester.pumpAndSettle();
    expect(find.text('GAME PAUSED'), findsOneWidget);
    expect(Get.find<ConnectFourController>().isPaused.value, true);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('RESUME'));
    await tester.pumpAndSettle();
    for (final index in [3, 0]) {
      await tester.tap(find.byType(IconButton).at(index));
      await tester.pumpAndSettle();
      expect(find.text('KEEP PLAYING'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('KEEP PLAYING'));
      await tester.pumpAndSettle();
      expect(Get.find<ConnectFourController>().isPaused.value, false);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
