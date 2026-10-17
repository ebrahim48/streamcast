import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/widgets/mono_tag.dart';
import '../../../core/widgets/sc_button.dart';
import '../../../core/widgets/sc_text_field.dart';
import 'controllers/sign_up_controller.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_tabs.dart';
import 'widgets/social_auth.dart';

/// `// access 02` — create the account. Email and password only; the display
/// name was already taken during onboarding.
class SignUpPage extends GetView<SignUpController> {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(
            title: AppStrings.signUpTitle,
            subtitle: AppStrings.authSubtitle,
          ),
          SizedBox(height: AppDimens.gapXl.h),
          const MonoTag(AppStrings.monoAccess02),
          SizedBox(height: AppDimens.gapSm.h),
          AuthTabs(active: AuthTab.signUp, onSwitch: controller.goToSignIn),
          SizedBox(height: AppDimens.gapXl.h),
          Obx(
            () => ScTextField(
              controller: controller.emailField,
              focusNode: controller.emailFocus,
              label: AppStrings.emailLabel,
              hint: AppStrings.emailHint,
              error: controller.emailError.value,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              onSubmitted: (_) => controller.passwordFocus.requestFocus(),
            ),
          ),
          SizedBox(height: AppDimens.gapLg.h),
          Obx(
            () => ScTextField(
              controller: controller.passwordField,
              focusNode: controller.passwordFocus,
              label: AppStrings.passwordLabel,
              hint: AppStrings.passwordCreateHint,
              error: controller.passwordError.value,
              obscure: controller.obscurePassword.value,
              onToggleObscure: controller.toggleObscurePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              onSubmitted: (_) => controller.confirmFocus.requestFocus(),
            ),
          ),
          SizedBox(height: AppDimens.gapLg.h),
          Obx(
            () => ScTextField(
              controller: controller.confirmField,
              focusNode: controller.confirmFocus,
              label: AppStrings.confirmPasswordLabel,
              hint: AppStrings.passwordRepeatHint,
              error: controller.confirmError.value,
              obscure: controller.obscureConfirm.value,
              onToggleObscure: controller.toggleObscureConfirm,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => controller.submit(),
            ),
          ),
          Obx(() => AuthFormError(message: controller.formError.value)),
          SizedBox(height: AppDimens.gapXl.h),
          Obx(
            () => ScButton(
              label: controller.isLoading.value
                  ? AppStrings.creatingAccount
                  : AppStrings.signUpLabel,
              enabled: !controller.isLoading.value,
              onPressed: controller.submit,
            ),
          ),
          SizedBox(height: AppDimens.gapXl.h),
          const AuthDivider(),
          SizedBox(height: AppDimens.gapLg.h),
          Obx(
            () => GoogleAuthButton(
              enabled: !controller.isLoading.value,
              onPressed: controller.continueWithGoogle,
            ),
          ),
        ],
      ),
    );
  }
}
