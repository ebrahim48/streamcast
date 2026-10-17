import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/services/auth_service.dart';
import 'auth_form_controller.dart';

/// Drives the Log In screen.
class SignInController extends AuthFormController {
  SignInController({required super.authService});

  final TextEditingController emailField = TextEditingController();
  final TextEditingController passwordField = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  final RxnString emailError = RxnString();
  final RxnString passwordError = RxnString();

  /// Password is masked until the eye is tapped.
  final RxBool obscurePassword = true.obs;

  void toggleObscure() => obscurePassword.toggle();

  /// Validates both fields, then asks [AuthService] to open a session.
  Future<void> submit() async {
    emailError.value = Validators.email(emailField.text);
    passwordError.value = Validators.loginPassword(passwordField.text);
    if (emailError.value != null || passwordError.value != null) {
      formError.value = null;
      return;
    }

    await runGuarded(
      () => auth.signIn(
        email: emailField.text,
        password: passwordField.text,
      ),
    );
  }

  /// Swaps this route for Sign Up rather than stacking it — the segmented
  /// control is a switch, not a drill-down.
  void goToSignUp() => Get.offNamed<void>(AppRoutes.signUp);

  /// Carries whatever is already typed into the recovery flow, so the user
  /// doesn't retype the address they just failed to log in with.
  void goToForgotPassword() =>
      Get.toNamed<void>(AppRoutes.forgotPassword, arguments: emailField.text);

  @override
  void onClose() {
    emailField.dispose();
    passwordField.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
