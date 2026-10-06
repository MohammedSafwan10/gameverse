import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/screens/achievements/achievements_screen.dart';
import 'package:gameverse/screens/profile/profile_screen.dart';
import 'package:gameverse/screens/settings/settings_screen.dart';
import 'package:get/get.dart';
import 'package:gameverse/services/player_progress.dart';
import 'package:gameverse/services/app_info.dart';
import 'package:gameverse/theme/app_theme.dart';
import '../../support/offline_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadOfflineFonts);

  setUp(() {
    Get.testMode = true;
    PlayerProgressStore.instance.value = PlayerProgress();
    AppInfo.version.value = '1.0.0 (1)';
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
      'utility screens have no layout exceptions at ${size.width}x${size.height}',
      (tester) async {
        _setSize(tester, size);

        for (final screen in const <Widget>[
          AchievementsScreen(),
          ProfileScreen(),
          SettingsScreen(),
        ]) {
          await tester.pumpWidget(
            GetMaterialApp(
              theme: AppTheme.lightTheme,
              debugShowCheckedModeBanner: false,
              home: screen,
              getPages: [
                GetPage(
                  name: '/settings',
                  page: () => const SettingsScreen(),
                ),
                GetPage(
                  name: '/achievements',
                  page: () => const AchievementsScreen(),
                ),
              ],
            ),
          );
          await tester.pump();

          expect(
            tester.takeException(),
            isNull,
            reason: '${screen.runtimeType} overflowed at $size',
          );
          expect(find.byType(CustomScrollView), findsOneWidget);

          await tester.drag(
              find.byType(CustomScrollView), const Offset(0, -1200));
          await tester.pump();
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  testWidgets('profile opens real destinations and omits removed mock links',
      (tester) async {
    _setSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: const ProfileScreen(),
        getPages: [
          GetPage(
            name: '/settings',
            page: () => const Scaffold(body: Text('Settings destination')),
          ),
          GetPage(
            name: '/achievements',
            page: () => const Scaffold(body: Text('Achievements destination')),
          ),
        ],
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('profile-settings-button')));
    await tester.pumpAndSettle();
    expect(find.text('Settings destination'), findsOneWidget);

    Get.back<void>();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile-achievements-row')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('profile-achievements-row')));
    await tester.pumpAndSettle();
    expect(find.text('Achievements destination'), findsOneWidget);

    Get.back<void>();
    await tester.pumpAndSettle();
    expect(find.text('Game History'), findsNothing);
    expect(find.text('Support Center'), findsNothing);
    expect(find.text('#42'), findsNothing);
    expect(find.textContaining('XP'), findsNothing);
    expect(find.textContaining('NEXDARK'), findsNothing);
  });

  testWidgets('settings contains no developer attribution', (tester) async {
    _setSize(tester, const Size(390, 844));
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const SettingsScreen()));
    await tester.pump();

    expect(find.text('Contact Us'), findsOneWidget);
    expect(find.text('Rate Game'), findsNothing);
    expect(find.text('Storage'), findsNothing);
    expect(find.text('1.0.0 (1)'), findsOneWidget);
    expect(find.textContaining('NEXDARK'), findsNothing);
    expect(find.textContaining('Built with'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('achievement summary refreshes from real progress',
      (tester) async {
    _setSize(tester, const Size(390, 844));
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme, home: const AchievementsScreen()));
    expect(find.text('0 / 9'), findsOneWidget);
    PlayerProgressStore.instance.value = PlayerProgress(wins: 1, quizzes: 1);
    await tester.pump();
    expect(find.text('2 / 9'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final entry in <String, Widget>{
    'achievements': const AchievementsScreen(),
    'profile': const ProfileScreen(),
    'settings': const SettingsScreen(),
  }.entries) {
    testWidgets('${entry.key} matches approved direction at 390x844',
        (tester) async {
      _setSize(tester, const Size(390, 844));
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: entry.value,
        ),
      );
      await tester.pump();

      await expectLater(
        find.byWidget(entry.value),
        matchesGoldenFile('goldens/${entry.key}_390x844.png'),
      );
    });
  }
}

void _setSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
