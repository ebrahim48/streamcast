import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';

/// Visual variants of [ScButton].
enum ScButtonVariant {
  /// Filled orange, black label — the default call to action.
  primary,

  /// Filled amber, black label — premium surfaces.
  premium,

  /// Transparent with an orange 1px outline — `Subscribe`, `Search again`.
  outline,
}

/// The app's one button.
///
/// Disabled state is not greyed out — per the design it drops to the dim
/// orange [AppColors.ctaPressed] with a muted label, which is also what the
/// pressed state looks like.
class ScButton extends StatelessWidget {
  const ScButton({
    super.key,
    required this.label,
    this.onPressed,
    this.onDisabledTap,
    this.variant = ScButtonVariant.primary,
    this.enabled = true,
    this.expand = true,
    this.height = AppDimens.buttonHeight,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Fired when the button is tapped while [enabled] is false.
  ///
  /// A dim button with no response leaves the user guessing; hooking this up
  /// lets the screen explain itself — the onboarding form uses it to surface
  /// its "Please enter a name to continue." line.
  final VoidCallback? onDisabledTap;

  final ScButtonVariant variant;

  /// When false the button paints its dim state and refuses [onPressed].
  final bool enabled;

  /// Stretch to the available width (default) or hug the label.
  final bool expand;

  final double height;
  final Widget? icon;

  Color get _fill {
    if (variant == ScButtonVariant.outline) return AppColors.transparent;
    if (!enabled) return AppColors.ctaPressed;
    return variant == ScButtonVariant.premium
        ? AppColors.badgePremium
        : AppColors.ctaDefault;
  }

  Color get _labelColor {
    if (variant == ScButtonVariant.outline) {
      return enabled ? AppColors.accentSignal : AppColors.textDim;
    }
    return enabled
        ? AppColors.onAccent
        : AppColors.textPrimary.withValues(alpha: 0.45);
  }

  BorderSide get _side => variant == ScButtonVariant.outline
      ? BorderSide(
          color: enabled ? AppColors.accentSignal : AppColors.borderLine,
        )
      : BorderSide.none;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[icon!, SizedBox(width: AppDimens.gapSm.w)],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.button(color: _labelColor),
          ),
        ),
      ],
    );

    return SizedBox(
      width: expand ? double.infinity : null,
      height: height.h,
      child: Material(
        color: _fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusButton.r),
          side: _side,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : onDisabledTap,
          splashColor: AppColors.black.withValues(alpha: 0.08),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.gapLg.w),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
