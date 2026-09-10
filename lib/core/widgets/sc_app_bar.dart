import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';
import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';
import 'sc_wordmark.dart';

/// Home's top bar: the wordmark, the `Add Link +` pill, search and cast.
class ScHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ScHomeAppBar({
    super.key,
    this.onAddLink,
    this.onSearch,
    this.onCast,
    this.isCasting = false,
  });

  final VoidCallback? onAddLink;
  final VoidCallback? onSearch;
  final VoidCallback? onCast;

  /// Tints the cast icon orange while a receiver is connected.
  final bool isCasting;

  @override
  Size get preferredSize => Size.fromHeight(AppDimens.appBarHeight.h);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: AppDimens.appBarHeight.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.screenPadding.w),
          child: Row(
            children: [
              // Scales down rather than overflowing when the wordmark, the
              // pill and both icons can't all sit at natural width.
              const Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: ScWordmark(),
                ),
              ),
              SizedBox(width: AppDimens.gapSm.w),
              const Spacer(),
              _AddLinkPill(onTap: onAddLink),
              SizedBox(width: AppDimens.gapMd.w),
              _IconAction(
                asset: AppAssets.iconSearch,
                label: 'Search',
                onTap: onSearch,
              ),
              SizedBox(width: AppDimens.gapMd.w),
              _IconAction(
                asset: AppAssets.iconCast,
                label: 'Cast to device',
                onTap: onCast,
                color: isCasting ? AppColors.accentSignal : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddLinkPill extends StatelessWidget {
  const _AddLinkPill({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ctaDefault,
      borderRadius: BorderRadius.circular(6.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Link',
                style: AppTextStyles.bodyMedium(
                  color: AppColors.onAccent,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 5.w),
              Icon(Icons.add_rounded, size: 15.r, color: AppColors.onAccent),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.asset,
    required this.label,
    this.onTap,
    this.color,
  });

  final String asset;

  /// Spoken name for the icon, which carries no text of its own.
  final String label;

  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 22.r,
        child: SvgPicture.asset(
          asset,
          width: 21.r,
          height: 21.r,
          colorFilter: ColorFilter.mode(
            color ?? AppColors.textPrimary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

/// Back-arrow bar used by the stacked pages (Edit Profile, Creator Studio).
class ScBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ScBackAppBar({
    super.key,
    required this.title,
    this.condensed = false,
    this.onBack,
  });

  final String title;

  /// Renders the title as an uppercase condensed header, as Creator Studio
  /// does, instead of the sentence-case style used by Edit Profile.
  final bool condensed;

  final VoidCallback? onBack;

  @override
  Size get preferredSize => Size.fromHeight(AppDimens.appBarHeight.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: condensed ? AppColors.bgPrimary : AppColors.bgSurface,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        icon: Icon(
          condensed ? Icons.arrow_back_rounded : Icons.chevron_left_rounded,
          size: condensed ? 22.r : 30.r,
        ),
      ),
      title: Text(
        condensed ? title.toUpperCase() : title,
        style: condensed
            ? AppTextStyles.sectionHeaderCondensed()
            : AppTextStyles.h3().copyWith(fontSize: 18.sp),
      ),
      bottom: condensed
          ? null
          : const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1),
            ),
    );
  }
}
