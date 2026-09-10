import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';

/// Filter pill used by the Explore platform row.
///
/// Selected reads as a filled orange chip with black text; unselected as a
/// bordered panel chip.
class PlatformChip extends StatelessWidget {
  const PlatformChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ctaDefault : AppColors.bgSurfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill.r),
        side: BorderSide(
          color: selected ? AppColors.ctaDefault : AppColors.borderLine,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            label,
            style:
                AppTextStyles.bodyMedium(
                  color: selected ? AppColors.onAccent : AppColors.textPrimary,
                ).copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}
