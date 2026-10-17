import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamcast_app/core/di/dependency_injection.dart';

import 'support/entry_flow.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    DependencyInjection.clear();
    await DependencyInjection.init();
  });

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
    await tester.pumpAndSettle(pastNetwork);

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
