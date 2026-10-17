import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/widgets/mono_tag.dart';
import '../../../core/widgets/sc_button.dart';
import '../../../core/widgets/sc_text_field.dart';
import 'controllers/password_reset_controller.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_scaffold.dart';

/// `// recover 03` — the last step: choose the password and go back to Log In.
class ResetPasswordPage extends GetView<PasswordResetController> {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      footer: Obx(
        () => ScButton(
          label: controller.isLoading.value
              ? AppStrings.updatingPassword
              : AppStrings.resetPasswordLabel,
          enabled: !controller.isLoading.value,
          onPressed: controller.submitNewPassword,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(
            title: AppStrings.resetTitle,
            subtitle: AppStrings.resetBody,
            compact: true,
          ),
          SizedBox(height: AppDimens.gapXl.h),
          const MonoTag(AppStrings.monoRecover03),
          SizedBox(height: AppDimens.gapMd.h),
          Obx(
            () => ScTextField(
              controller: controller.passwordField,
              label: AppStrings.newPasswordLabel,
              hint: AppStrings.passwordCreateHint,
              error: controller.passwordError.value,
              obscure: controller.obscurePassword.value,
              onToggleObscure: controller.toggleObscurePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
            ),
          ),
          SizedBox(height: AppDimens.gapLg.h),
          Obx(
            () => ScTextField(
              controller: controller.confirmField,
              label: AppStrings.confirmPasswordLabel,
              hint: AppStrings.passwordRepeatHint,
              error: controller.confirmError.value,
              obscure: controller.obscureConfirm.value,
              onToggleObscure: controller.toggleObscureConfirm,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => controller.submitNewPassword(),
            ),
          ),
        ],
      ),
    );
  }
}
