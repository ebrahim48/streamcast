import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/mono_tag.dart';
import '../../../core/widgets/sc_button.dart';
import '../../../core/widgets/sc_wordmark.dart';
import 'controllers/onboarding_controller.dart';
import 'widgets/onboarding_hero.dart';

/// `// setup 01` — the only thing standing between the user and the feed.
class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        titleSpacing: AppDimens.screenPadding.w,
        title: const ScWordmark(),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppDimens.screenPadding.w,
            AppDimens.gapSm.h,
            AppDimens.screenPadding.w,
            AppDimens.gapXl.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => OnboardingHero(lit: controller.showEmptyError.value)),
              SizedBox(height: AppDimens.gapXl.h),
              const MonoTag(AppStrings.monoSetup01),
              SizedBox(height: AppDimens.gapSm.h),
              Text(AppStrings.onboardingTitle, style: AppTextStyles.h1()),
              SizedBox(height: AppDimens.gapMd.h),
              Text(
                AppStrings.onboardingBody,
                style: AppTextStyles.body(color: AppColors.textDim),
              ),
              SizedBox(height: AppDimens.gapXl.h),
              _NameField(controller: controller),
              SizedBox(height: AppDimens.gapLg.h),
              Obx(
                () => ScButton(
                  label: AppStrings.continueLabel,
                  enabled: controller.hasName.value,
                  onPressed: controller.submit,
                  // Tapping the dim button is how the user asks "why not?" —
                  // answer with the inline error rather than nothing.
                  onDisabledTap: controller.submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Name input plus its inline error line.
///
/// The error is rendered below the field rather than through
/// [InputDecoration.errorText] so the field keeps its exact 52dp height and the
/// message can carry the brand orange from the design.
class _NameField extends StatelessWidget {
  const _NameField({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasError = controller.showEmptyError.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: AppDimens.inputHeight.h,
            child: TextField(
              controller: controller.nameController,
              focusNode: controller.nameFocus,
              style: AppTextStyles.body(),
              cursorColor: AppColors.accentSignal,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              maxLength: 32,
              inputFormatters: [LengthLimitingTextInputFormatter(32)],
              onSubmitted: (_) => controller.submit(),
              decoration: InputDecoration(
                counterText: '',
                hintText: AppStrings.nameHint,
                hintStyle: AppTextStyles.body(color: AppColors.textDim),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppDimens.gapLg.w,
                ),
                enabledBorder: _border(
                  hasError ? AppColors.accentSignal : AppColors.borderLine,
                ),
                focusedBorder: _border(AppColors.accentSignal),
              ),
            ),
          ),
          if (hasError) ...[
            SizedBox(height: AppDimens.gapSm.h),
            Text(
              AppStrings.nameEmptyError,
              style: AppTextStyles.bodyMedium(color: AppColors.accentSignal),
            ),
          ],
        ],
      );
    });
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppDimens.radiusInput.r),
    borderSide: BorderSide(color: color),
  );
}
