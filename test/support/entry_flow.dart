import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamcast_app/app.dart';

/// Long enough to clear the splash hold (1600ms) and its progress animation.
const pastSplash = Duration(seconds: 3);

/// Long enough for the mocked repository latency behind the home feed and the
/// simulated round-trip behind an auth call.
const pastNetwork = Duration(seconds: 2);

/// Mounts the app on a phone-sized surface.
///
/// The layouts are built for a phone; the default 800×600 test surface pushes
/// controls outside the render tree and taps miss them.
Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const StreamCastApp());
}

/// Runs splash → onboarding and stops on the Sign Up screen.
Future<void> pumpToSignUp(WidgetTester tester) async {
  await pumpApp(tester);
  await tester.pumpAndSettle(pastSplash);
  await tester.enterText(find.byType(TextField), 'Ryan');
  await tester.pump();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

/// Fills the Sign Up form with a valid account and submits it.
Future<void> registerAccount(
  WidgetTester tester, {
  String email = 'ryan@streamcast.app',
  String password = 'supersecret',
}) async {
  await tester.enterText(
    find.widgetWithText(TextField, 'you@example.com'),
    email,
  );
  await tester.enterText(
    find.widgetWithText(TextField, 'At least 8 characters'),
    password,
  );
  await tester.enterText(
    find.widgetWithText(TextField, 'Repeat your password'),
    password,
  );
  await tester.pump();
  await tester.tap(find.widgetWithText(InkWell, 'Sign Up').last);
}

/// Runs the whole entry flow — splash → onboarding → sign up — and lands on
/// Home with a session open.
Future<void> pumpToHome(WidgetTester tester) async {
  await pumpToSignUp(tester);
  await registerAccount(tester);
  await tester.pumpAndSettle(pastNetwork);
}
