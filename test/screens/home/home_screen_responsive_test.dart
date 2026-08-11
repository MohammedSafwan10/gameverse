import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/screens/home/home_screen.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(360, 800),
    const Size(390, 844),
    const Size(430, 932),
  ]) {
    testWidgets('home has no layout exceptions at ${size.width}x${size.height}',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        GetMaterialApp(
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
          getPages: [
            GetPage(
              name: '/profile',
              page: () => const Scaffold(body: Text('Profile')),
            ),
          ],
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(const Key('gameverse-wordmark')), findsOneWidget);
      expect(find.byKey(const Key('featured-game-carousel')), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(
        find.text('ALL GAMES'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('ALL GAMES'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('mood selection filters the game grid', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const GetMaterialApp(home: HomeScreen()),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('SMART'));
    await tester.pumpAndSettle();

    expect(find.text('SMART GAMES'), findsOneWidget);
    expect(find.text('Flappy Bird'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('featured carousel auto-advances and opens the active game',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        home: const HomeScreen(),
        getPages: [
          GetPage(
            name: '/chess',
            page: () => const Scaffold(body: Text('Chess destination')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('featured-dot-0-selected')),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('featured-dot-1-selected')),
      findsOneWidget,
    );

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_chess_390x844.png'),
    );

    await tester.tap(find.byKey(const Key('featured-play-/chess')));
    await tester.pumpAndSettle();

    expect(find.text('Chess destination'), findsOneWidget);
  });

  testWidgets('home matches the selected visual direction at 390x844',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_390x844.png'),
    );
  });

  testWidgets('compact home stays organized at 320x568', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_320x568.png'),
    );
  });
}
