import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_text_styles.dart';

/// The masthead every auth screen opens with: the signal artwork, the screen
/// title, and one line of explanation under it.
///
/// The artwork is the same `onboarding.png` the name screen uses, so the auth
/// stack reads as a continuation of setup rather than a different app.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.compact = false,
  });

  final String title;
  final String? subtitle;

  /// Shrinks the artwork for the screens that carry a back bar above it.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard.r),
          child: Image.asset(
            AppAssets.onboardingHero,
            height: (compact ? 108 : 133).h,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: AppDimens.gapXl.h),
        Text(title, textAlign: TextAlign.center, style: AppTextStyles.h1()),
        if (subtitle != null) ...[
          SizedBox(height: AppDimens.gapMd.h),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.textDim),
          ),
        ],
      ],
    );
  }
}
