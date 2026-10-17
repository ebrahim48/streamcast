import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/mono_tag.dart';
import '../../../core/widgets/sc_wordmark.dart';
import '../../../core/widgets/signal_rings.dart';
import '../../auth/domain/services/auth_service.dart';
import '../../profile/presentation/controllers/profile_controller.dart';

/// First frame the user sees: expanding signal rings behind the wordmark, with
/// a determinate bar that fills over 1.5s while the app settles.
///
/// After [_holdDuration] it hands off to whichever step is still outstanding:
/// onboarding when there is no name yet, the sign-in screen when there is a
/// name but no open session, and the feed when both are already in place.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const Duration _holdDuration = Duration(milliseconds: 1600);
  static const Duration _barDuration = Duration(milliseconds: 1500);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  /// Drives the wordmark's fade + scale-in.
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  )..forward();

  /// Drives the bottom progress bar, 8% → 100%.
  late final AnimationController _bar = AnimationController(
    vsync: this,
    duration: SplashPage._barDuration,
  )..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(SplashPage._holdDuration, _goNext);
  }

  void _goNext() {
    if (!mounted) return;

    final hasProfile = Get.find<ProfileController>().name.value.isNotEmpty;
    if (!hasProfile) {
      Get.offAllNamed<void>(AppRoutes.onboarding);
      return;
    }

    // A returning user lands on Log In, not Sign Up — they already have an
    // account, they just aren't carrying a session.
    final isSignedIn = Get.find<AuthService>().isSignedIn;
    Get.offAllNamed<void>(isSignedIn ? AppRoutes.main : AppRoutes.signIn);
  }

  @override
  void dispose() {
    _entry.dispose();
    _bar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringSize = 1.sw * 1.12;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Rings are allowed to bleed past the screen edge, as in the design.
          Center(
            child: SignalRings(
              size: ringSize,
              backdrop: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  'assets/images/streamcostcircularsplash.png',
                  width: ringSize,
                  height: ringSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _entry,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _entry,
                    curve: const Cubic(0.23, 1, 0.32, 1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ScWordmark(size: WordmarkSize.lg, glow: true),
                    SizedBox(height: AppDimens.gapMd.h),
                    Text(
                      AppStrings.tagline,
                      style: AppTextStyles.bodyMedium(color: AppColors.textDim),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 96.h,
            child: Column(
              children: [
                SizedBox(
                  width: 150.w,
                  height: 3.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999.r),
                    child: Stack(
                      children: [
                        const ColoredBox(
                          color: AppColors.borderLine,
                          child: SizedBox.expand(),
                        ),
                        AnimatedBuilder(
                          animation: _bar,
                          builder: (context, _) => FractionallySizedBox(
                            widthFactor: 0.08 + 0.92 * _bar.value,
                            child: const ColoredBox(
                              color: AppColors.accentSignal,
                              child: SizedBox.expand(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                const MonoTag(
                  AppStrings.monoEstablishingSignal,
                  color: AppColors.textDim,
                  size: 9.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
