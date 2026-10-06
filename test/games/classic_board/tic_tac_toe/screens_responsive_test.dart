import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/controllers/game_controller.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/controllers/settings_controller.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/controllers/stats_controller.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/game_stats.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/game_mode.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/screens/mode_selection_screen.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/screens/game_screen.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/screens/stats_screen.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/screens/settings_screen.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/services/ai_service.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/services/storage_service.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/services/navigation_service.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/widgets/tactile_ui.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/game_difficulty.dart';

class _Storage extends StorageService {
  @override
  Future<GameStats> loadStats() async => const GameStats();
  @override
  Future<void> saveStats(GameStats stats) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Barlow')
          ..addFont(rootBundle.load('assets/fonts/Barlow-SemiBold.ttf')))
        .load();
    await (FontLoader('BarlowCondensed')
          ..addFont(
              rootBundle.load('assets/fonts/BarlowCondensed-SemiBold.ttf'))
          ..addFont(
              rootBundle.load('assets/fonts/BarlowCondensed-ExtraBold.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  setUp(() async {
    Get.testMode = true;
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => 'D:/Dev/freela/gameverse/.dart_tool/test_storage');
    final storage = _Storage();
    final stats = Get.put(TicTacToeStatsController(storage));
    await stats.ready;
    Get.put(TicTacToeSettingsController());
    final nav = Get.put(TicTacToeNavigationService());
    Get.put(TicTacToeGameController(nav, AIService()));
  });
  tearDown(Get.reset);
  const sizes = [
    Size(320, 568),
    Size(360, 800),
    Size(390, 844),
    Size(430, 932)
  ];
  final pages = <String, Widget Function()>{
    'mode': () => const ModeSelectionScreen(),
    'game': () => const TicTacToeGameScreen(),
    'stats': () => const TicTacToeStatsScreen(),
    'settings': () => const TicTacToeSettingsScreen(),
    'help': () => const TactileHelpPage(),
    'difficulty': () => TactileDifficultyPage(
        initial: GameDifficulty.medium, onSelected: (_) {}),
  };
  for (final size in sizes) {
    for (final page in pages.entries) {
      testWidgets('${page.key} at $size', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(GetMaterialApp(home: page.value()));
        await _loadImages(tester);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (size == const Size(390, 844)) {
          await expectLater(find.byType(TactilePage).first,
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
        Get.find<TicTacToeSettingsController>()
            .updateGameMode(GameMode.multiPlayer);
        final controller = Get.find<TicTacToeGameController>()..resetGame();
        await tester.runAsync(() async {
          for (final i
              in draw ? [0, 1, 2, 4, 3, 5, 7, 6, 8] : [0, 1, 4, 2, 8]) {
            await controller.makeMove(i);
          }
        });
        await tester
            .pumpWidget(const GetMaterialApp(home: TicTacToeGameScreen()));
        await _loadImages(tester);
        await tester.pumpAndSettle();
        expect(
            find.text(draw ? "IT'S A DRAW" : 'PLAYER 1 WINS!'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (size == const Size(390, 844)) {
          await expectLater(
              find.byType(TactilePage),
              matchesGoldenFile(
                  'goldens/${draw ? 'draw' : 'win'}_390x844.png'));
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
  testWidgets('restart and leave confirmations remain usable on compact phone',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const GetMaterialApp(home: TicTacToeGameScreen()));
    await tester.pumpAndSettle();
    for (final tooltip in ['Restart game', 'Leave game']) {
      await tester.tap(find.byTooltip(tooltip));
      await tester.pumpAndSettle();
      expect(find.text('KEEP PLAYING'), findsOneWidget);
      expect(Get.find<TicTacToeGameController>().isSuspended, isTrue);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('KEEP PLAYING'));
      await tester.pumpAndSettle();
      expect(Get.find<TicTacToeGameController>().isSuspended, isFalse);
    }
  });
  testWidgets('large text fits settings on compact phone', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(GetMaterialApp(
        home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
            child: const TicTacToeSettingsScreen())));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final size in sizes) {
    testWidgets(
        'mode fits one viewport with phone insets and 115% text at $size',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const GetMaterialApp(
          home: MediaQuery(
              data: MediaQueryData(
                  padding: EdgeInsets.only(top: 24, bottom: 24),
                  textScaler: TextScaler.linear(1.15)),
              child: ModeSelectionScreen())));
      await _loadImages(tester);
      for (final element in find.byType(Scrollable).evaluate()) {
        expect((element as StatefulElement).state is ScrollableState, isTrue);
        expect((element.state as ScrollableState).position.maxScrollExtent, 0);
      }
      final help = tester.getRect(find.text('HOW TO PLAY'));
      expect(help.bottom, lessThanOrEqualTo(size.height - 24));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
  testWidgets('compact achievements retain their full details on tap',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const GetMaterialApp(home: TicTacToeStatsScreen()));
    await _loadImages(tester);
    await tester.tap(find.text('First Victory'));
    await tester.pumpAndSettle();
    expect(find.text('Win your first game'), findsOneWidget);
    expect(find.text('Not unlocked yet'), findsOneWidget);
    await tester.tap(find.text('CLOSE'));
    await tester.pumpAndSettle();
    expect(find.text('Not unlocked yet'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  for (final page in pages.entries.where((p) => p.key != 'mode')) {
    testWidgets('${page.key} phone viewport has no unnecessary scrolling',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(GetMaterialApp(
          home: MediaQuery(
              data: const MediaQueryData(
                  padding: EdgeInsets.only(top: 24, bottom: 24),
                  textScaler: TextScaler.linear(1.15)),
              child: page.value())));
      await _loadImages(tester);
      expect(tester.takeException(), isNull);
      final scrollables = find.byType(Scrollable).evaluate();
      for (final element in scrollables) {
        final state = (element as StatefulElement).state as ScrollableState;
        expect(state.position.maxScrollExtent, 0, reason: '${page.key} extent');
      }
      if (page.key == 'game') expect(find.text('HOW TO PLAY'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}

Future<void> _loadImages(WidgetTester tester) async {
  final context = tester.element(find.byType(TactilePage).first);
  await tester.runAsync(() async {
    for (final name in [
      'cream-background',
      'x-piece',
      'o-piece',
      'hero-board',
      'paired-pieces'
    ]) {
      await precacheImage(AssetImage('$tttAssets$name.png'), context);
    }
    await precacheImage(
        const AssetImage('assets/images/games/memory_match/trophy_v1.png'),
        context);
  });
  await tester.pumpAndSettle();
}
