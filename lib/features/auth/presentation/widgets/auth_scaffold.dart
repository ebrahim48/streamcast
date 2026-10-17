import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Shared chrome for the five auth screens.
///
/// Two body shapes come out of one widget: pass [footer] and the screen keeps
/// its action pinned to the bottom edge with the content scrolling above it
/// (the recovery screens, which are mostly empty space); leave it null and the
/// whole column scrolls as one (the credential forms, which are not).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.footer,
    this.showBack = false,
  });

  final Widget child;
  final Widget? footer;

  /// Adds the back arrow used by the screens reached from Log In.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.fromLTRB(
      AppDimens.screenPadding.w,
      showBack ? AppDimens.gapSm.h : AppDimens.gapXl.h,
      AppDimens.screenPadding.w,
      AppDimens.gapXl.h,
    );

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: showBack
          ? AppBar(
              backgroundColor: AppColors.bgPrimary,
              leading: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(Icons.chevron_left_rounded, size: 30.r),
              ),
            )
          : null,
      body: SafeArea(
        top: !showBack,
        child: footer == null
            ? SingleChildScrollView(padding: padding, child: child)
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: padding.copyWith(bottom: AppDimens.gapLg.h),
                      child: child,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppDimens.screenPadding.w,
                      0,
                      AppDimens.screenPadding.w,
                      AppDimens.gapXl.h,
                    ),
                    child: footer,
                  ),
                ],
              ),
      ),
    );
  }
}

/// The form-wide error line — the one that belongs to the whole form rather
/// than to a single field. Renders nothing when [message] is null, so callers
/// can drop it into a column unconditionally.
class AuthFormError extends StatelessWidget {
  const AuthFormError({super.key, required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: AppDimens.gapMd.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 16.r,
            color: AppColors.accentSignal,
          ),
          SizedBox(width: AppDimens.gapSm.w),
          Expanded(
            child: Text(
              message!,
              style: AppTextStyles.bodyMedium(color: AppColors.accentSignal),
            ),
          ),
        ],
      ),
    );
  }
}
