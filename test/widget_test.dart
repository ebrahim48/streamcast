import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamcast_app/core/di/dependency_injection.dart';
import 'package:streamcast_app/core/models/stream_item.dart';
import 'package:streamcast_app/core/routes/app_routes.dart';
import 'package:streamcast_app/core/services/storage_service.dart';
import 'package:streamcast_app/core/utils/formatters.dart';
import 'package:streamcast_app/features/auth/data/repositories/auth_repository.dart';
import 'package:streamcast_app/features/auth/domain/services/auth_service.dart';

import 'support/entry_flow.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    DependencyInjection.clear();
    await DependencyInjection.init();
  });

  group('entry flow', () {
    testWidgets('splash shows the wordmark and establishing-signal caption', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.pump();

      expect(find.text('STREAMCAST'), findsOneWidget);
      expect(find.text('Every Stream. One Screen.'), findsOneWidget);
      expect(find.text('// establishing signal'), findsOneWidget);

      // Let the hand-off timer fire so it isn't pending at teardown.
      await tester.pumpAndSettle(pastSplash);
    });

    testWidgets('splash hands off to onboarding when no name is stored', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.pumpAndSettle(pastSplash);

      expect(find.text('// setup 01'), findsOneWidget);
      expect(find.text('Enter your name'), findsOneWidget);
    });

    testWidgets('a blank name keeps the user on onboarding with an error', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.pumpAndSettle(pastSplash);

      // Whitespace passes the "has text" gate that enables the CTA but not the
      // trimmed check in submit(), so this is the path that shows the error.
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a name to continue.'), findsOneWidget);
      expect(find.text('// setup 01'), findsOneWidget);
    });

    testWidgets('a valid name hands off to Sign Up, not the feed', (
      tester,
    ) async {
      await pumpToSignUp(tester);

      expect(find.text('Sign up now'), findsOneWidget);
      expect(find.text('// access 02'), findsOneWidget);
      expect(find.text('Live Now'), findsNothing);
    });
  });

  group('auth', () {
    testWidgets('sign up refuses a bad email and a mismatched password', (
      tester,
    ) async {
      await pumpToSignUp(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'you@example.com'),
        'not-an-email',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'At least 8 characters'),
        'supersecret',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Repeat your password'),
        'something-else',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(InkWell, 'Sign Up').last);
      await tester.pumpAndSettle();

      expect(find.text("That email address doesn't look right."), findsOneWidget);
      expect(find.text('Both passwords must match.'), findsOneWidget);
      expect(find.text('Sign up now'), findsOneWidget);
    });

    testWidgets('a short password is rejected before any call is made', (
      tester,
    ) async {
      await pumpToSignUp(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'you@example.com'),
        'ryan@streamcast.app',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'At least 8 characters'),
        'short',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Repeat your password'),
        'short',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(InkWell, 'Sign Up').last);
      await tester.pumpAndSettle();

      expect(find.text('Use at least 8 characters.'), findsOneWidget);
    });

    testWidgets('the tabs swap between Log In and Sign Up', (tester) async {
      await pumpToSignUp(tester);

      await tester.tap(find.widgetWithText(InkWell, 'Log In').first);
      await tester.pumpAndSettle();

      expect(find.text('Sign in now'), findsOneWidget);
      expect(find.text('// access 01'), findsOneWidget);
      expect(find.text('Forget password'), findsOneWidget);

      await tester.tap(find.widgetWithText(InkWell, 'Sign Up').first);
      await tester.pumpAndSettle();

      expect(find.text('Sign up now'), findsOneWidget);
    });

    testWidgets('signing up opens a session and lands on the feed', (
      tester,
    ) async {
      await pumpToHome(tester);

      expect(find.text('Live Now'), findsOneWidget);
      expect(find.text('Sign up now'), findsNothing);
    });

    testWidgets('an unknown account cannot log in', (tester) async {
      await pumpToSignUp(tester);
      await tester.tap(find.widgetWithText(InkWell, 'Log In').first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'you@example.com'),
        'nobody@streamcast.app',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Your password'),
        'supersecret',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(InkWell, 'Log In').last);
      await tester.pumpAndSettle(pastNetwork);

      expect(find.text('Email or password is incorrect.'), findsOneWidget);
      expect(find.text('Sign in now'), findsOneWidget);
    });

    testWidgets('Continue with Google goes straight through to the feed', (
      tester,
    ) async {
      await pumpToSignUp(tester);

      await tester.ensureVisible(find.text('Continue with Google'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle(pastNetwork);

      expect(find.text('Live Now'), findsOneWidget);
    });

    testWidgets('forgot password walks code → new password → log in', (
      tester,
    ) async {
      await pumpToHome(tester);
      // Restart into a signed-out session so the flow starts at Log In.
      await Get.find<AuthService>().signOut();
      Get.offAllNamed<void>(AppRoutes.signIn);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Forget password'));
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'you@example.com'),
        'ryan@streamcast.app',
      );
      await tester.pump();
      await tester.tap(find.text('Send Code'));
      await tester.pumpAndSettle(pastNetwork);

      expect(find.text('// recover 02'), findsOneWidget);

      // The code is never emailed in this build, so read it back from the
      // repository the same way the snackbar does.
      final code = AuthRepository(
        storageService: Get.find<StorageService>(),
      ).readResetChallenge()!.code;

      for (var i = 0; i < code.length; i++) {
        await tester.enterText(find.byType(TextField).at(i), code[i]);
        await tester.pump();
      }
      await tester.pumpAndSettle(pastNetwork);

      expect(find.text('// recover 03'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'At least 8 characters'),
        'brand-new-pass',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Repeat your password'),
        'brand-new-pass',
      );
      await tester.pump();
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle(pastNetwork);

      expect(find.text('Sign in now'), findsOneWidget);

      // The new password is the one that works now.
      await tester.enterText(
        find.widgetWithText(TextField, 'you@example.com'),
        'ryan@streamcast.app',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Your password'),
        'brand-new-pass',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(InkWell, 'Log In').last);
      await tester.pumpAndSettle(pastNetwork);

      expect(find.text('Live Now'), findsOneWidget);
    });
  });

  group('main shell', () {
    testWidgets('a valid name lands on Home with both feed sections', (
      tester,
    ) async {
      await pumpToHome(tester);

      expect(find.text('Live Now'), findsOneWidget);
      expect(find.text('Recommended'), findsOneWidget);
      expect(find.text('// signal:live'), findsOneWidget);
      expect(find.text('// feed:curated'), findsOneWidget);
      expect(find.text('5 channels'), findsOneWidget);
    });

    testWidgets('free tier gets a sponsored slot in the grid', (tester) async {
      await pumpToHome(tester);

      expect(find.text('Sponsored'), findsWidgets);
      expect(find.text('Ad · 7-day trial'), findsOneWidget);
    });

    testWidgets('the nav switches to Explore and filters by platform', (
      tester,
    ) async {
      await pumpToHome(tester);

      await tester.tap(find.text('Explore').last);
      await tester.pumpAndSettle(pastNetwork);

      expect(find.text('All Results'), findsOneWidget);
      expect(find.text('11 items'), findsOneWidget);

      // The filter row scrolls horizontally; under the test font the chips are
      // wider than on device, so bring the target into view before tapping.
      await tester.ensureVisible(find.text('Kick'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kick'));
      await tester.pumpAndSettle(pastNetwork);

      expect(find.text('Kick'), findsWidgets);
      expect(find.text('2 items'), findsOneWidget);
    });

    testWidgets('Premium shows all three plans and the monthly CTA', (
      tester,
    ) async {
      await pumpToHome(tester);

      await tester.tap(find.text('Premium').last);
      await tester.pumpAndSettle();

      expect(find.text('Go Premium'), findsOneWidget);
      expect(find.text('Most Popular'), findsOneWidget);
      expect(find.text(r'$2.99'), findsOneWidget);
      expect(find.text(r'$6.99'), findsOneWidget);
      expect(find.text(r'$39.99'), findsOneWidget);
      expect(find.text(r'Upgrade — Monthly $6.99'), findsOneWidget);
    });

    testWidgets('My Library shows the seeded rails and an empty queue', (
      tester,
    ) async {
      await pumpToHome(tester);

      await tester.tap(find.text('My Library').last);
      await tester.pumpAndSettle();

      expect(find.text('History'), findsOneWidget);
      expect(find.text('Liked'), findsOneWidget);
      expect(find.text('Watch Later'), findsOneWidget);
      expect(find.text('Nothing here yet'), findsOneWidget);
      expect(find.text('Ryan'), findsOneWidget);
    });
  });

  group('watch page', () {
    /// Opens the first card in the Live Now rail.
    Future<void> openFirstLiveStream(WidgetTester tester) async {
      await pumpToHome(tester);
      await tester.tap(find.text('VCT Grand Finals — Map 4 Overtime'));
      await tester.pumpAndSettle(pastNetwork);
    }

    testWidgets('a live stream shows its chat, meta and up-next', (
      tester,
    ) async {
      await openFirstLiveStream(tester);

      expect(find.text('Twitch · 184K watching now'), findsOneWidget);
      expect(find.text('NovaEsports'), findsWidgets);
      expect(find.text('482K subscribers'), findsOneWidget);
      expect(find.text('// live'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Comments'), findsOneWidget);
      expect(
        find.textContaining('stream quality is clean tonight'),
        findsOneWidget,
      );
      expect(find.text('// up:next'), findsOneWidget);
    });

    testWidgets('subscribing flips the button and persists', (tester) async {
      await openFirstLiveStream(tester);

      expect(find.text('Subscribe'), findsOneWidget);
      await tester.tap(find.text('Subscribe'));
      await tester.pumpAndSettle();

      expect(find.text('Subscribed'), findsOneWidget);
    });

    testWidgets('switching to Comments swaps the list and the composer hint', (
      tester,
    ) async {
      await openFirstLiveStream(tester);

      await tester.tap(find.text('Comments'));
      await tester.pumpAndSettle();

      expect(find.text('Add a comment...'), findsOneWidget);
      expect(find.text('214 likes'), findsOneWidget);
      expect(
        find.textContaining('stream quality is clean tonight'),
        findsNothing,
      );
    });

    testWidgets('a sent chat message appears in the list', (tester) async {
      await openFirstLiveStream(tester);

      final composer = find.widgetWithText(TextField, 'Send a message...');
      await tester.enterText(composer, 'casting this now');
      await tester.pump();

      // Under the test font the chat list is tall enough to push the composer
      // past the bottom edge; bring the send button into view before tapping.
      final send = find.byIcon(Icons.send_rounded);
      await tester.ensureVisible(send);
      await tester.pumpAndSettle();
      await tester.tap(send);
      await tester.pumpAndSettle();

      // The composer clears, and the message is now a chat line — two matches
      // would mean the tap missed and the text merely stayed in the field.
      expect(find.textContaining('casting this now'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller?.text,
        isEmpty,
      );
    });

    testWidgets('watching a stream records it in the library', (tester) async {
      await openFirstLiveStream(tester);
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('My Library').last);
      await tester.pumpAndSettle();

      // The watched stream is now the first entry in History.
      expect(find.text('VCT Grand Finals — Map 4 Overtime'), findsWidgets);
    });
  });

  group('casting', () {
    testWidgets('the sheet reports that casting needs a phone', (tester) async {
      await pumpToHome(tester);

      await tester.tap(find.bySemanticsLabel('Cast to device'));
      await tester.pumpAndSettle();

      // The Cast SDK binds only on Android and iOS. Under `flutter test` the
      // repository reports no support rather than throwing, and the sheet says
      // so instead of spinning on a scan that can never finish.
      expect(find.text('Cast to device'), findsWidgets);
      expect(
        find.text('Casting is available on Android and iOS.'),
        findsOneWidget,
      );
      expect(find.text('Search again'), findsNothing);
    });

    testWidgets('the sheet explains how a stream will reach the TV', (
      tester,
    ) async {
      await pumpToHome(tester);
      await tester.tap(find.text('VCT Grand Finals — Map 4 Overtime'));
      await tester.pumpAndSettle(pastNetwork);

      await tester.tap(find.bySemanticsLabel('Cast to device'));
      await tester.pumpAndSettle();

      // Twitch is a web-only player, and the relay is not configured, so the
      // sheet says up front that this one will not play.
      expect(
        find.textContaining('has no castable stream URL of its own'),
        findsOneWidget,
      );
    });
  });

  group('premium', () {
    testWidgets('upgrading confirms, then clears the ads from the feed', (
      tester,
    ) async {
      await pumpToHome(tester);

      await tester.tap(find.text('Premium').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(r'Upgrade — Monthly $6.99'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text("You're Premium!"), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle(pastNetwork);

      await tester.tap(find.text('Home').last);
      await tester.pumpAndSettle(pastNetwork);

      expect(find.text('Ad · 7-day trial'), findsNothing);
    });

    testWidgets('a selected plan drives the CTA and the billing note', (
      tester,
    ) async {
      await pumpToHome(tester);

      await tester.tap(find.text('Premium').last);
      await tester.pumpAndSettle();

      expect(find.text('// cancel anytime · billed month'), findsOneWidget);

      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();

      expect(find.text(r'Upgrade — Weekly $2.99'), findsOneWidget);
      expect(find.text('// cancel anytime · billed week'), findsOneWidget);
    });
  });

  group('creator studio', () {
    testWidgets('adding a moderator replaces the empty state', (tester) async {
      await pumpToHome(tester);

      await tester.tap(find.text('My Library').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Creator Studio'));
      await tester.pumpAndSettle();

      expect(find.text('MANAGE TEAM'), findsOneWidget);
      expect(find.text('Ryan Coley'), findsOneWidget);
      expect(find.text('MANAGER'), findsOneWidget);
      expect(find.text('No moderators yet — add one below'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Channel / creator name'),
        'Al Jamil',
      );
      await tester.pump();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Al Jamil'), findsOneWidget);
      expect(find.text('Moderator'), findsOneWidget);
      expect(find.text('No moderators yet — add one below'), findsNothing);
    });
  });

  group('add to feed', () {
    testWidgets('a pasted link is labelled with its platform', (tester) async {
      await pumpToHome(tester);

      await tester.tap(find.text('Add Link'));
      await tester.pumpAndSettle();

      expect(find.text('ADD TO FEED'), findsOneWidget);
      expect(find.text('no link detected'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(
          TextField,
          'Paste a video link (YouTube, Kick, Vimeo, Twitch...)',
        ),
        'https://www.youtube.com/watch?v=mKCieTImjvU',
      );
      await tester.pumpAndSettle();

      expect(find.text('YouTube'), findsWidgets);
      expect(find.text('no link detected'), findsNothing);
    });
  });

  group('formatters', () {
    test('compactCount matches the design labels', () {
      expect(Formatters.compactCount(184000), '184K');
      expect(Formatters.compactCount(12400), '12.4K');
      expect(Formatters.compactCount(2100000), '2.1M');
      expect(Formatters.compactCount(512000), '512K');
      expect(Formatters.compactCount(51), '51');
    });

    test('timeAgo produces the design phrasing', () {
      final now = DateTime(2026, 9, 10);
      expect(
        Formatters.timeAgo(now.subtract(const Duration(days: 2)), now: now),
        '2 days ago',
      );
      expect(
        Formatters.timeAgo(now.subtract(const Duration(days: 8)), now: now),
        '1 week ago',
      );
      expect(
        Formatters.timeAgo(now.subtract(const Duration(days: 35)), now: now),
        '1 month ago',
      );
    });
  });

  group('platform detection', () {
    test('recognises each supported host', () {
      expect(
        detectPlatform('https://youtu.be/mKCieTImjvU'),
        StreamPlatform.youtube,
      );
      expect(
        detectPlatform('https://www.twitch.tv/novaesports'),
        StreamPlatform.twitch,
      );
      expect(detectPlatform('https://kick.com/kaiplays'), StreamPlatform.kick);
      expect(detectPlatform('https://vimeo.com/123'), StreamPlatform.vimeo);
      expect(
        detectPlatform('https://cdn.example.com/clip.m3u8'),
        StreamPlatform.direct,
      );
    });

    test('returns null for anything unrecognised', () {
      expect(detectPlatform(''), isNull);
      expect(detectPlatform('not a link'), isNull);
    });
  });
}
