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

/// `// recover 01` — name the account to send a code to.
class ForgotPasswordPage extends GetView<PasswordResetController> {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      footer: Obx(
        () => ScButton(
          label: controller.isLoading.value
              ? AppStrings.sendingCode
              : AppStrings.sendCode,
          enabled: !controller.isLoading.value,
          onPressed: controller.sendCode,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(
            title: AppStrings.forgotPasswordTitle,
            subtitle: AppStrings.forgotPasswordBody,
            compact: true,
          ),
          SizedBox(height: AppDimens.gapXl.h),
          const MonoTag(AppStrings.monoRecover01),
          SizedBox(height: AppDimens.gapMd.h),
          Obx(
            () => ScTextField(
              controller: controller.emailField,
              label: AppStrings.emailLabel,
              hint: AppStrings.emailHint,
              error: controller.emailError.value,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              onSubmitted: (_) => controller.sendCode(),
            ),
          ),
        ],
      ),
    );
  }
}
