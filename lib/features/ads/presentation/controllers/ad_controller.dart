import 'dart:async';

import 'package:get/get.dart';

import '../../../premium/presentation/controllers/premium_controller.dart';
import '../../domain/services/ad_service.dart';

/// Runs the free tier's ad clock.
///
/// The clock only advances while something is actually playing — [start] is
/// called when playback begins and [stop] when it ends or the page is left —
/// so a viewer who opens a stream and never presses play is never interrupted,
/// and time spent reading comments doesn't count toward the next break.
///
/// Registered permanently so watch time carries across streams within a
/// session rather than resetting on every navigation.
class AdController extends GetxController {
  AdController({
    required AdService adService,
    required PremiumController premiumController,
  }) : _service = adService,
       _premium = premiumController;

  final AdService _service;
  final PremiumController _premium;

  /// The break currently on screen, or null.
  final Rxn<AdKind> showing = Rxn<AdKind>();

  /// Seconds left in the current break.
  final RxInt remaining = 0.obs;

  /// Whether the break can be dismissed yet.
  final RxBool canSkip = false.obs;

  /// True while a reward grant is suppressing breaks.
  final RxBool rewardActive = false.obs;

  Timer? _scheduler;
  Timer? _countdown;
  Timer? _rewardExpiry;

  bool get adsEnabled => _service.shouldShowAds(
    isPremium: _premium.isPremium.value,
    rewardActive: rewardActive.value,
  );

  /// Starts (or resumes) the clock. Call when playback begins.
  void start() {
    if (!adsEnabled || _scheduler != null) return;
    _scheduleNext();
  }

  /// Pauses the clock. Call when playback stops or the viewer leaves.
  void stop() {
    _scheduler?.cancel();
    _scheduler = null;
  }

  void _scheduleNext() {
    _scheduler?.cancel();
    _scheduler = Timer(_service.nextGap(), _present);
  }

  void _present() {
    if (!adsEnabled) return;

    showing.value = AdKind.interstitial;
    canSkip.value = false;
    remaining.value = AdService.interstitialLength.inSeconds;

    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining.value -= 1;

      final elapsed = AdService.interstitialLength.inSeconds - remaining.value;
      if (elapsed >= AdService.skipAfter.inSeconds) canSkip.value = true;

      if (remaining.value <= 0) dismiss();
    });
  }

  /// Closes the break and re-arms the clock.
  void dismiss() {
    _countdown?.cancel();
    _countdown = null;
    showing.value = null;
    if (adsEnabled) _scheduleNext();
  }

  /// Grants an ad-free window in exchange for watching a reward ad.
  ///
  /// The grant is deliberately session-only: it is not written to storage, so
  /// it can't be farmed across launches.
  void grantReward() {
    rewardActive.value = true;
    stop();
    dismiss();

    _rewardExpiry?.cancel();
    _rewardExpiry = Timer(AdService.rewardGrant, () {
      rewardActive.value = false;
      start();
    });
  }

  @override
  void onClose() {
    _scheduler?.cancel();
    _countdown?.cancel();
    _rewardExpiry?.cancel();
    super.onClose();
  }
}
