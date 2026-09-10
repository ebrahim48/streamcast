import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_dimens.dart';

/// The wave-ring banner above the name prompt.
///
/// Two artworks ship for it: the open line-ring version, and a lit version with
/// an orange bloom that the screen swaps to when the name field errors — so the
/// hero reacts alongside the field instead of sitting inert.
class OnboardingHero extends StatelessWidget {
  const OnboardingHero({super.key, this.lit = false});

  /// Swap to the glowing artwork.
  final bool lit;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: ClipRRect(
        key: ValueKey(lit),
        borderRadius: BorderRadius.circular(AppDimens.radiusCard.r),
        child: Image.asset(
          lit
              ? 'assets/images/onboarding1.png'
              : 'assets/images/onboarding.png',
          width: double.infinity,
          height: 133.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
