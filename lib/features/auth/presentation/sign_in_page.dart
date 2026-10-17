import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/mono_tag.dart';
import '../../../core/widgets/sc_button.dart';
import '../../../core/widgets/sc_text_field.dart';
import 'controllers/sign_in_controller.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_tabs.dart';
import 'widgets/social_auth.dart';

/// `// access 01` — log in to an account that already exists.
class SignInPage extends GetView<SignInController> {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(
            title: AppStrings.signInTitle,
            subtitle: AppStrings.authSubtitle,
          ),
          SizedBox(height: AppDimens.gapXl.h),
          const MonoTag(AppStrings.monoAccess01),
          SizedBox(height: AppDimens.gapSm.h),
          AuthTabs(active: AuthTab.logIn, onSwitch: controller.goToSignUp),
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
              hint: AppStrings.passwordHint,
              error: controller.passwordError.value,
              obscure: controller.obscurePassword.value,
              onToggleObscure: controller.toggleObscure,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => controller.submit(),
            ),
          ),
          SizedBox(height: AppDimens.gapSm.h),
          Align(
            alignment: Alignment.centerRight,
            child: _ForgetPasswordLink(onTap: controller.goToForgotPassword),
          ),
          Obx(() => AuthFormError(message: controller.formError.value)),
          SizedBox(height: AppDimens.gapLg.h),
          Obx(
            () => ScButton(
              label: controller.isLoading.value
                  ? AppStrings.loggingIn
                  : AppStrings.logInLabel,
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

/// The one text link on the screen — orange, so it reads as an action rather
/// than as more of the body copy around it.
class _ForgetPasswordLink extends StatelessWidget {
  const _ForgetPasswordLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.gapXs.r),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppDimens.gapSm.h,
          horizontal: AppDimens.gapXs.w,
        ),
        child: Text(
          AppStrings.forgetPassword,
          style: AppTextStyles.bodyMedium(color: AppColors.accentSignal),
        ),
      ),
    );
  }
}
