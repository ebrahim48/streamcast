import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// The `● Live` pill that marks a broadcast in progress.
class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key, this.compact = false});

  /// Tighter padding for the small thumbnails in up-next and library rows.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dot = compact ? 4.0 : 5.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (compact ? 5 : 7).w,
        vertical: (compact ? 2 : 3).h,
      ),
      decoration: BoxDecoration(
        color: AppColors.badgeLive,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dot.r,
            height: dot.r,
            decoration: const BoxDecoration(
              color: AppColors.onAccent,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'Live',
            style: AppTextStyles.caption(color: AppColors.onAccent).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: (compact ? 9.5 : 10.5).sp,
            ),
          ),
        ],
      ),
    );
  }
}
