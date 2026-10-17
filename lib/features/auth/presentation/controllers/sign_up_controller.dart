import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/validators.dart';
import 'auth_form_controller.dart';

/// Drives the Sign Up screen.
///
/// There is no name field here — the display name was already chosen during
/// onboarding and lives in the profile; an account only adds credentials to it.
class SignUpController extends AuthFormController {
  SignUpController({required super.authService});

  final TextEditingController emailField = TextEditingController();
  final TextEditingController passwordField = TextEditingController();
  final TextEditingController confirmField = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmFocus = FocusNode();

  final RxnString emailError = RxnString();
  final RxnString passwordError = RxnString();
  final RxnString confirmError = RxnString();

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirm = true.obs;

  void toggleObscurePassword() => obscurePassword.toggle();

  void toggleObscureConfirm() => obscureConfirm.toggle();

  /// Validates the three fields, then registers the account and signs in.
  Future<void> submit() async {
    emailError.value = Validators.email(emailField.text);
    passwordError.value = Validators.newPassword(passwordField.text);
    confirmError.value = Validators.confirmPassword(
      confirmField.text,
      passwordField.text,
    );
    if (emailError.value != null ||
        passwordError.value != null ||
        confirmError.value != null) {
      formError.value = null;
      return;
    }

    await runGuarded(
      () => auth.signUp(
        email: emailField.text,
        password: passwordField.text,
      ),
    );
  }

  /// Swaps this route for Log In — see [SignInController.goToSignUp].
  void goToSignIn() => Get.offNamed<void>(AppRoutes.signIn);

  @override
  void onClose() {
    emailField.dispose();
    passwordField.dispose();
    confirmField.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmFocus.dispose();
    super.onClose();
  }
}
