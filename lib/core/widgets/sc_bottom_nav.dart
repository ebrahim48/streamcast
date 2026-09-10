import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';
import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';

/// One entry in the bottom bar.
class ScNavItem {
  const ScNavItem({required this.label, required this.icon});

  final String label;
  final String icon;
}

/// The four-tab bottom bar: Home · Explore · Premium · My Library.
///
/// The SVGs ship with a hard-coded muted stroke, so both states are tinted
/// through a [ColorFilter] rather than shipping two files per icon.
class ScBottomNav extends StatelessWidget {
  const ScBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<ScNavItem> items = [
    ScNavItem(label: 'Home', icon: AppAssets.iconHome),
    ScNavItem(label: 'Explore', icon: AppAssets.iconExplore),
    ScNavItem(label: 'Premium', icon: AppAssets.iconPremium),
    ScNavItem(label: 'My Library', icon: AppAssets.iconLibrary),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(top: BorderSide(color: AppColors.borderLine)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppDimens.bottomNavHeight.h,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavTab(
                    item: items[i],
                    // Premium is the one tab that keeps its own amber identity.
                    activeColor: i == 2
                        ? AppColors.badgePremium
                        : AppColors.accentSignal,
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  final ScNavItem item;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : AppColors.textDim;

    return InkWell(
      onTap: onTap,
      splashColor: AppColors.transparent,
      highlightColor: AppColors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            item.icon,
            width: 21.r,
            height: 21.r,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          SizedBox(height: 5.h),
          Text(item.label, style: AppTextStyles.caption(color: color)),
        ],
      ),
    );
  }
}
