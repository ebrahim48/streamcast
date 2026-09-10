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

  Future<void> openSheetAndFill(WidgetTester tester) async {
    await tester.tap(find.text('Add Link'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(
        TextField,
        'Paste a video link (YouTube, Kick, Vimeo, Twitch...)',
      ),
      'https://www.youtube.com/watch?v=mKCieTImjvU',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'Casting explained',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Creator / channel name'),
      'Signal Desk',
    );
    await tester.pumpAndSettle();
  }

  testWidgets('submitting the sheet closes it without disposing live widgets',
      (tester) async {
    await pumpToHome(tester);
    await openSheetAndFill(tester);

    await tester.tap(find.text('Add to Feed'));
    // The sheet's exit transition has to finish before its controller — and
    // the text controllers it owns — are torn down.
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);
    expect(find.text('ADD TO FEED'), findsNothing);
  });

  testWidgets('dismissing the sheet without submitting is also clean',
      (tester) async {
    await pumpToHome(tester);
    await openSheetAndFill(tester);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);
    expect(find.text('ADD TO FEED'), findsNothing);
  });

  testWidgets('the sheet can be opened again after being submitted',
      (tester) async {
    await pumpToHome(tester);
    await openSheetAndFill(tester);
    await tester.tap(find.text('Add to Feed'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.text('Add Link'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('ADD TO FEED'), findsOneWidget);
    // A fresh sheet starts empty rather than reusing the last submission.
    expect(find.text('no link detected'), findsOneWidget);
  });
}
