import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/widgets/guarded_exit.dart';

void main() {
  testWidgets('guarded exit pops mode selection route without Get.back',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (routeContext) => Scaffold(
                      body: ElevatedButton(
                        onPressed: () => popAfterConfirmation(
                          routeContext,
                          confirmExit: () async => true,
                        ),
                        child: const Text('exit'),
                      ),
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('exit'));
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget);
  });
}
