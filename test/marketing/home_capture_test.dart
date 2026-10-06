import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/screens/home/home_screen.dart';
import 'package:gameverse/theme/app_theme.dart';
import 'package:get/get.dart';

import '../support/offline_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadOfflineFonts);
  testWidgets('marketing capture uses real app widgets and bundled fonts', (
    tester,
  ) async {
    Get.testMode = true;
    addTearDown(Get.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        builder: (context, child) => DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Inter'),
          child: child!,
        ),
        home: const HomeScreen(),
      ),
    );
    // Image decoding runs outside the fake widget clock. Wait for it, then
    // advance entrance animations in frames rather than one large jump.
    await tester.runAsync(() async {
      final context = tester.element(find.byType(HomeScreen));
      for (final image in tester.widgetList<Image>(find.byType(Image))) {
        await precacheImage(image.image, context);
      }
    });
    for (var frame = 0; frame < 20; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/app-home.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
