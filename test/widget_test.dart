import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamcast_app/app.dart';
import 'package:streamcast_app/core/di/dependency_injection.dart';

/// Long enough to clear the splash hold (1600ms) plus its progress animation.
const _pastSplash = Duration(seconds: 3);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    DependencyInjection.clear();
    await DependencyInjection.init();
  });

  /// The layouts are built for a phone; the default 800×600 test surface pushes
  /// the onboarding CTA outside the render tree and taps miss it.
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const StreamCastApp());
  }

  testWidgets('splash shows the wordmark and the establishing-signal caption',
      (tester) async {
    await pumpApp(tester);
    await tester.pump();

    expect(find.text('STREAMCAST'), findsOneWidget);
    expect(find.text('Every Stream. One Screen.'), findsOneWidget);
    expect(find.text('// establishing signal'), findsOneWidget);

    // Let the hand-off timer fire so it isn't left pending at teardown.
    await tester.pumpAndSettle(_pastSplash);
  });

  testWidgets('splash hands off to onboarding when no name is stored',
      (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle(_pastSplash);

    expect(find.text('// setup 01'), findsOneWidget);
    expect(find.text('Enter your name'), findsOneWidget);
  });

  testWidgets('a blank name keeps the user on onboarding with an inline error',
      (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle(_pastSplash);

    // Whitespace passes the "has text" gate that enables the CTA, but not the
    // trimmed check in submit() — so this is the path that shows the error.
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a name to continue.'), findsOneWidget);
    expect(find.text('// setup 01'), findsOneWidget);
  });

  testWidgets('a valid name lands the user on the main shell', (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle(_pastSplash);

    await tester.enterText(find.byType(TextField), 'Ryan');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Explore'), findsWidgets);
    expect(find.text('My Library'), findsWidgets);
  });
}
