import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/mono_tag.dart';
import '../../../../core/widgets/sc_button.dart';
import '../../domain/services/ad_service.dart';
import '../controllers/ad_controller.dart';

/// The break that covers the player on the free tier.
///
/// It sits over the player frame only — the page underneath stays readable, so
/// chat and comments keep running through the break. Skipping unlocks after
/// [AdService.skipAfter]; the two ways out are the upgrade and the reward.
class AdOverlay extends StatelessWidget {
  const AdOverlay({super.key, required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdController>();

    return Obx(() {
      if (controller.showing.value == null) return const SizedBox.shrink();

      return Positioned.fill(
        child: ColoredBox(
          color: AppColors.black.withValues(alpha: 0.92),
          child: Padding(
            padding: EdgeInsets.all(AppDimens.gapLg.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const MonoTag('// ad:break'),
                    Text(
                      '${controller.remaining.value}s',
                      style: AppTextStyles.mono(color: AppColors.textDim),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  Icons.tv_rounded,
                  size: 30.r,
                  color: AppColors.badgePremium,
                ),
                SizedBox(height: AppDimens.gapMd.h),
                Text(
                  'Watch ad-free and cast without limits',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h3(),
                ),
                SizedBox(height: AppDimens.gapXs.h),
                Text(
                  'StreamCast Premium · from \$2.99',
                  style: AppTextStyles.caption(),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ScButton(
                        label: 'Go Premium',
                        variant: ScButtonVariant.premium,
                        height: 42,
                        onPressed: onUpgrade,
                      ),
                    ),
                    SizedBox(width: AppDimens.gapSm.w),
                    Expanded(
                      child: ScButton(
                        label: controller.canSkip.value
                            ? 'Skip'
                            : 'Skip in ${_skipIn(controller)}s',
                        variant: ScButtonVariant.outline,
                        height: 42,
                        enabled: controller.canSkip.value,
                        onPressed: controller.dismiss,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimens.gapSm.h),
                TextButton(
                  onPressed: controller.grantReward,
                  child: Text(
                    'Watch a reward ad for 30 ad-free minutes',
                    style: AppTextStyles.caption(color: AppColors.accentSignal),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  int _skipIn(AdController controller) {
    final elapsed =
        AdService.interstitialLength.inSeconds - controller.remaining.value;
    return (AdService.skipAfter.inSeconds - elapsed).clamp(0, 99);
  }
}
