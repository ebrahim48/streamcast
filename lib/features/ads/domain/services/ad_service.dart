import 'dart:math';

/// What kind of break is being shown.
enum AdKind {
  /// The timed break free-tier viewers get every few minutes.
  interstitial,

  /// Opt-in ad that buys more uninterrupted watch or cast time.
  reward,
}

/// The ad-break schedule.
///
/// The product rule is "an ad every 3–4 minutes" for the free tier. Fixing it
/// at exactly one interval makes the app feel metronomic, so each break is
/// scheduled at a random point inside the window.
///
/// **Phase 1:** no ad network is wired. The scheduler, the countdown and the
/// skip gate are real; the creative is a house promo for Premium.
/// [AdController] is where an SDK's loaded ad would be shown instead.
class AdService {
  AdService({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const Duration minGap = Duration(minutes: 3);
  static const Duration maxGap = Duration(minutes: 4);

  /// How long a break runs before it can be dismissed.
  static const Duration interstitialLength = Duration(seconds: 15);

  /// Skipping is allowed after this much of the break has played.
  static const Duration skipAfter = Duration(seconds: 5);

  /// Uninterrupted time granted by watching a reward ad.
  static const Duration rewardGrant = Duration(minutes: 30);

  /// A gap somewhere in the 3–4 minute window.
  Duration nextGap() {
    final spread = maxGap.inSeconds - minGap.inSeconds;
    return Duration(seconds: minGap.inSeconds + _random.nextInt(spread + 1));
  }

  /// Whether this viewer should see breaks at all.
  bool shouldShowAds({required bool isPremium, required bool rewardActive}) =>
      !isPremium && !rewardActive;
}
