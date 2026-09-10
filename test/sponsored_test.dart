import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamcast_app/app.dart';
import 'package:streamcast_app/core/di/dependency_injection.dart';

const _pastSplash = Duration(seconds: 3);
const _pastFeedLoad = Duration(seconds: 2);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    DependencyInjection.clear();
    await DependencyInjection.init();
  });

  Future<void> pumpToHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const StreamCastApp());
    await tester.pumpAndSettle(_pastSplash);
    await tester.enterText(find.byType(TextField), 'Ryan');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle(_pastFeedLoad);
  }

  testWidgets('the grid promo on Home opens the Premium tab', (tester) async {
    await pumpToHome(tester);

    final promo = find.text('Cast to any TV, ad-free — try StreamCast Premium');
    await tester.ensureVisible(promo);
    await tester.pumpAndSettle();
    await tester.tap(promo);
    await tester.pumpAndSettle();

    expect(find.text('Go Premium'), findsOneWidget);
  });

  testWidgets('the promo row under Recommended opens Premium from the player',
      (tester) async {
    await pumpToHome(tester);
    await tester.tap(find.text('VCT Grand Finals — Map 4 Overtime'));
    await tester.pumpAndSettle(_pastFeedLoad);

    final promo = find.text('Watch ad-free and cast without limits');
    expect(promo, findsOneWidget, reason: 'the up-next promo should be present');

    await tester.ensureVisible(promo);
    await tester.pumpAndSettle();
    await tester.tap(promo);
    await tester.pumpAndSettle();

    // It has to leave the player behind, not stack Premium on top of it.
    expect(find.text('Go Premium'), findsOneWidget);
    expect(find.text('Chat'), findsNothing);
  });
}
