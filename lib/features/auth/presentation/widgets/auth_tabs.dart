import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Which half of [AuthTabs] is the current screen.
enum AuthTab { logIn, signUp }

/// The `Log In | Sign Up` switch above both credential forms.
///
/// It is a navigation control, not a tab bar: each half is its own route, and
/// tapping the inactive half replaces the current one. The active half is the
/// lit panel; the inactive half stays flat so there is never a question about
/// which screen you are on.
class AuthTabs extends StatelessWidget {
  const AuthTabs({super.key, required this.active, required this.onSwitch});

  final AuthTab active;

  /// Fired only when the *inactive* half is tapped.
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimens.radiusButton.r),
        border: Border.all(color: AppColors.borderLine),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: AppStrings.tabLogIn,
              selected: active == AuthTab.logIn,
              onTap: onSwitch,
            ),
          ),
          Expanded(
            child: _Segment(
              label: AppStrings.tabSignUp,
              selected: active == AuthTab.signUp,
              onTap: onSwitch,
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? AppColors.bgSurfaceElevated : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.gapSm.r),
          border: Border.all(
            color: selected ? AppColors.accentSignal : AppColors.transparent,
          ),
        ),
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            // Tapping the half you are already on should do nothing rather
            // than re-push the route you are standing on.
            onTap: selected ? null : onTap,
            borderRadius: BorderRadius.circular(AppDimens.gapSm.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 11.h),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.button(
                  color: selected ? AppColors.textPrimary : AppColors.textDim,
                ).copyWith(fontSize: 14.sp),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
