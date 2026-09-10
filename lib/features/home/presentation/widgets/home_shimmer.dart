import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';

/// Loading skeleton for the home feed — a live rail over a two-column grid,
/// laid out to the same metrics as the real content so nothing shifts when the
/// data lands.
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfacePanel,
      highlightColor: AppColors.surfacePanel2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPadding.w,
            ),
            child: const _Block(width: 140, height: 22),
          ),
          SizedBox(height: AppDimens.gapMd.h),
          SizedBox(
            height: 232.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.screenPadding.w,
              ),
              itemCount: 2,
              separatorBuilder: (_, _) => SizedBox(width: AppDimens.gapMd.w),
              itemBuilder: (_, _) => const _Block(width: 268, height: 232),
            ),
          ),
          SizedBox(height: AppDimens.gapXl.h),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPadding.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Block(width: 170, height: 22),
                SizedBox(height: AppDimens.gapMd.h),
                for (var row = 0; row < 2; row++) ...[
                  Row(
                    children: [
                      const Expanded(child: _Block(height: 196)),
                      SizedBox(width: AppDimens.gapMd.w),
                      const Expanded(child: _Block(height: 196)),
                    ],
                  ),
                  SizedBox(height: AppDimens.gapMd.h),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({this.width, required this.height});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width?.w,
      height: height.h,
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard.r),
      ),
    );
  }
}
