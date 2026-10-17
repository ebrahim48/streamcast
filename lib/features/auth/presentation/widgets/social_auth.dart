import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_text_styles.dart';

/// The `———— Or login with ————` rule between the form and the social button.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.gapMd.w),
          child: Text(
            AppStrings.orLoginWith,
            style: AppTextStyles.caption(color: AppColors.textDim),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// `Continue with Google` — an outlined panel rather than a filled CTA, so it
/// never competes with the orange primary button above it.
class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({super.key, this.onPressed, this.enabled = true});

  final VoidCallback? onPressed;

  /// False while another auth call is in flight.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SizedBox(
        height: AppDimens.buttonHeight.h,
        child: Material(
          color: AppColors.bgSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusButton.r),
            side: const BorderSide(color: AppColors.borderLine),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppAssets.iconGoogle,
                  width: 20.r,
                  height: 20.r,
                ),
                SizedBox(width: AppDimens.gapMd.w),
                Text(
                  AppStrings.continueWithGoogle,
                  style: AppTextStyles.button(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
