import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/sc_button.dart';

/// Purchase confirmation.
///
/// Deliberately bare — no nav bar, no distractions, one way forward.
class PremiumSuccessPage extends StatelessWidget {
  const PremiumSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.gapXl.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72.r,
                height: 72.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.badgePremium),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 34.r,
                  color: AppColors.badgePremium,
                ),
              ),
              SizedBox(height: AppDimens.gapXl.h),
              Text("You're Premium!", style: AppTextStyles.h1()),
              SizedBox(height: AppDimens.gapSm.h),
              Text(
                'Ads are gone, casting is unlimited.',
                style: AppTextStyles.body(color: AppColors.textDim),
              ),
              SizedBox(height: AppDimens.gapXxl.h),
              ScButton(
                label: 'Continue',
                variant: ScButtonVariant.premium,
                onPressed: () => Get.back<void>(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
