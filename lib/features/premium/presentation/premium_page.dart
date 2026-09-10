import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/models/premium_plan.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/mono_tag.dart';
import '../../../core/widgets/sc_button.dart';
import 'controllers/premium_controller.dart';

/// `// tier:premium` — the upgrade pitch.
///
/// This is the one screen that trades the brand orange for amber; the premium
/// tier owns that colour throughout the app.
class PremiumPage extends GetView<PremiumController> {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppDimens.screenPadding.w,
                  AppDimens.gapLg.h,
                  AppDimens.screenPadding.w,
                  AppDimens.gapXl.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MonoTag('// tier:premium'),
                    SizedBox(height: 2.h),
                    Text(
                      'Go Premium',
                      style: AppTextStyles.h1(
                        color: AppColors.badgePremium,
                      ).copyWith(fontSize: 28.sp),
                    ),
                    SizedBox(height: AppDimens.gapSm.h),
                    Text(
                      'Remove ads, cast without limits, unlock every '
                      'platform.',
                      style: AppTextStyles.body(color: AppColors.textDim),
                    ),
                    SizedBox(height: AppDimens.gapXl.h),
                    Obx(
                      () => _PlanRow(
                        controller: controller,
                        selectedId: controller.selectedPlan.value.id,
                      ),
                    ),
                    SizedBox(height: AppDimens.gapXl.h),
                    _FeatureCard(features: controller.features),
                    SizedBox(height: AppDimens.gapLg.h),
                    Center(
                      child: Obx(
                        () => MonoTag(
                          controller.billingNote,
                          color: AppColors.textDim,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _StickyCta(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.controller, required this.selectedId});

  final PremiumController controller;

  /// Passed in rather than read here: this build runs outside the parent's Obx
  /// closure, so a read at this point would not be tracked.
  final String selectedId;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight so the three cards share the tallest card's height —
    // `stretch` alone asks for infinite height inside the scroll view.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final plan in controller.plans) ...[
            Expanded(
              child: _PlanCard(
                plan: plan,
                selected: selectedId == plan.id,
                onTap: () => controller.selectPlan(plan),
              ),
            ),
            if (plan != controller.plans.last)
              SizedBox(width: AppDimens.gapSm.w),
          ],
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final PremiumPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? AppColors.badgePremium : AppColors.borderLine;

    return Material(
      color: AppColors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCard.r),
        side: BorderSide(color: accent, width: selected ? 1.4 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The popular plan carries a filled tab across the card's top edge.
            if (plan.isPopular)
              Container(
                width: double.infinity,
                color: AppColors.badgePremium,
                padding: EdgeInsets.symmetric(vertical: 3.h),
                child: Text(
                  'Most Popular',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.mono(color: AppColors.onAccent),
                ),
              )
            else
              SizedBox(height: 19.h),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimens.gapSm.w,
                AppDimens.gapMd.h,
                AppDimens.gapSm.w,
                AppDimens.gapMd.h,
              ),
              child: Column(
                children: [
                  Text(
                    plan.label,
                    style: AppTextStyles.bodyMedium(color: AppColors.textDim),
                  ),
                  SizedBox(height: AppDimens.gapSm.h),
                  FittedBox(
                    child: Text(
                      plan.price,
                      style: AppTextStyles.h2(
                        color: selected
                            ? AppColors.badgePremium
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(plan.period, style: AppTextStyles.caption()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.features});

  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimens.gapLg.w),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard.r),
        border: Border.all(color: AppColors.borderLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final feature in features) ...[
            Row(
              children: [
                Container(
                  width: 18.r,
                  height: 18.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: AppColors.badgePremium),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 13.r,
                    color: AppColors.badgePremium,
                  ),
                ),
                SizedBox(width: AppDimens.gapMd.w),
                Text(feature, style: AppTextStyles.body()),
              ],
            ),
            if (feature != features.last) SizedBox(height: AppDimens.gapLg.h),
          ],
        ],
      ),
    );
  }
}

class _StickyCta extends StatelessWidget {
  const _StickyCta({required this.controller});

  final PremiumController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        border: Border(top: BorderSide(color: AppColors.borderLine)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimens.screenPadding.w),
        child: Obx(
          () => ScButton(
            label: controller.isPurchasing.value
                ? 'Processing...'
                : controller.ctaLabel,
            variant: ScButtonVariant.premium,
            enabled:
                !controller.isPurchasing.value && !controller.isPremium.value,
            onPressed: controller.upgrade,
          ),
        ),
      ),
    );
  }
}
