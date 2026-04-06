import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/widgets/guarded_exit.dart';

void main() {
  testWidgets('popAfterConfirmation pops current route after confirmation',
      (tester) async {
    final observer = _NavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (routeContext) => Scaffold(
                        body: Center(
                          child: ElevatedButton(
                            onPressed: () => popAfterConfirmation(
                              routeContext,
                              confirmExit: () async => true,
                            ),
                            child: const Text('exit'),
                          ),
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
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('exit'), findsOneWidget);

    await tester.tap(find.text('exit'));
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget);
    expect(observer.popCount, 1);
  });
}

class _NavigatorObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
    super.didPop(route, previousRoute);
  }
}
