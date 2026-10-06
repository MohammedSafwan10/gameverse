import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/screens/settings/privacy_policy_screen.dart';
import 'package:gameverse/screens/settings/settings_screen.dart';
import 'package:gameverse/theme/app_theme.dart';

void main() {
  testWidgets('Settings opens the bundled policy with the correct identity',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const SettingsScreen()),
    );
    await tester.scrollUntilVisible(find.text('Privacy Policy'), 200);
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
    expect(find.textContaining('NexDark Labs'), findsWidgets);
    expect(find.textContaining('nexdarksolutions@gmail.com'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Changes and contact'), 300);
    expect(tester.takeException(), isNull);
  });
}
