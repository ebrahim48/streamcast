import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/mono_tag.dart';
import '../../../core/widgets/sc_button.dart';
import 'controllers/password_reset_controller.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/otp_code_field.dart';

/// `// recover 02` — the six digits that prove the mailbox belongs to you.
class VerifyCodePage extends GetView<PasswordResetController> {
  const VerifyCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      footer: Obx(
        () => ScButton(
          label: controller.isLoading.value
              ? AppStrings.verifying
              : AppStrings.verifyLabel,
          enabled: !controller.isLoading.value,
          onPressed: controller.verify,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => AuthHeader(
              title: AppStrings.verifyTitle,
              subtitle: AppStrings.verifyBody(controller.sentToEmail.value),
              compact: true,
            ),
          ),
          SizedBox(height: AppDimens.gapXl.h),
          const MonoTag(AppStrings.monoRecover02),
          SizedBox(height: AppDimens.gapMd.h),
          Obx(
            () => OtpCodeField(
              length: PasswordResetController.codeLength,
              hasError: controller.codeError.value != null,
              onChanged: controller.onCodeChanged,
              onCompleted: controller.verify,
            ),
          ),
          Obx(() => AuthFormError(message: controller.codeError.value)),
          SizedBox(height: AppDimens.gapXl.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  AppStrings.didntReceiveCode,
                  style: AppTextStyles.bodyMedium(color: AppColors.textDim),
                ),
              ),
              Obx(
                () => _ResendLink(
                  enabled: !controller.isLoading.value,
                  onTap: controller.resend,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Issues a fresh code. Underlined, because it is the only thing on the screen
/// that is tappable but isn't a button.
class _ResendLink extends StatelessWidget {
  const _ResendLink({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppDimens.gapXs.r),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppDimens.gapSm.h,
          horizontal: AppDimens.gapXs.w,
        ),
        child: Text(
          AppStrings.resendCode,
          style: AppTextStyles.bodyMedium(
            color: enabled ? AppColors.accentSignal : AppColors.textDim,
          ).copyWith(decoration: TextDecoration.underline),
        ),
      ),
    );
  }
}
