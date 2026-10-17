import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/services/auth_service.dart';
import 'auth_form_controller.dart';

/// Drives all three recovery screens — enter email, enter code, set password.
///
/// One controller rather than three because the flow is one transaction: the
/// address typed on the first screen is what the second verifies and the third
/// writes against. It is put in place by the Forgot Password route and disposed
/// when that route leaves the stack, taking the half-finished reset with it.
class PasswordResetController extends GetxController {
  PasswordResetController({required AuthService authService})
    : _auth = authService;

  final AuthService _auth;

  /// How many digits the code has. Drives the box count on the verify screen.
  static const int codeLength = 6;

  final TextEditingController emailField = TextEditingController();
  final TextEditingController passwordField = TextEditingController();
  final TextEditingController confirmField = TextEditingController();

  final RxnString emailError = RxnString();
  final RxnString codeError = RxnString();
  final RxnString passwordError = RxnString();
  final RxnString confirmError = RxnString();

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirm = true.obs;

  final RxBool isLoading = false.obs;

  /// What the six boxes currently hold.
  final RxString code = ''.obs;

  /// The address the code was issued for — shown in the verify screen's copy.
  final RxString sentToEmail = ''.obs;

  bool get isCodeComplete => code.value.length == codeLength;

  void toggleObscurePassword() => obscurePassword.toggle();

  void toggleObscureConfirm() => obscureConfirm.toggle();

  @override
  void onInit() {
    super.onInit();
    // The sign-in screen hands over whatever was already typed there.
    final prefill = Get.arguments;
    if (prefill is String) emailField.text = prefill;
  }

  // ─── 01 · Email ──────────────────────────────────────────────────────────

  /// Issues a code for the typed address and opens the verify screen.
  Future<void> sendCode() async {
    emailError.value = Validators.email(emailField.text);
    if (emailError.value != null) return;

    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final result = await _auth.requestResetCode(emailField.text);
      if (result.error != null) {
        emailError.value = messageFor(result.error!);
        return;
      }

      sentToEmail.value = emailField.text.trim();
      code.value = '';
      codeError.value = null;
      _announceCode(result.code!);
      // Not awaited: the future only completes when the verify screen is
      // popped, and the `finally` below has to run now, not then.
      Get.toNamed<void>(AppRoutes.verifyCode);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 02 · Code ───────────────────────────────────────────────────────────

  void onCodeChanged(String value) {
    code.value = value;
    if (codeError.value != null) codeError.value = null;
  }

  /// Checks the six digits and moves on to the new-password screen.
  Future<void> verify() async {
    if (!isCodeComplete) {
      codeError.value = AppStrings.codeIncomplete;
      return;
    }

    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final error = await _auth.verifyResetCode(
        email: sentToEmail.value,
        code: code.value,
      );
      if (error != null) {
        codeError.value = messageFor(error);
        return;
      }
      Get.toNamed<void>(AppRoutes.resetPassword);
    } finally {
      isLoading.value = false;
    }
  }

  /// Issues a fresh code, invalidating the previous one.
  Future<void> resend() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final result = await _auth.requestResetCode(sentToEmail.value);
      if (result.error != null) {
        codeError.value = messageFor(result.error!);
        return;
      }
      code.value = '';
      codeError.value = null;
      _announceCode(result.code!);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 03 · New password ───────────────────────────────────────────────────

  /// Writes the new password and returns the user to Log In.
  Future<void> submitNewPassword() async {
    passwordError.value = Validators.newPassword(passwordField.text);
    confirmError.value = Validators.confirmPassword(
      confirmField.text,
      passwordField.text,
    );
    if (passwordError.value != null || confirmError.value != null) return;

    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final error = await _auth.resetPassword(
        email: sentToEmail.value,
        code: code.value,
        password: passwordField.text,
      );
      if (error != null) {
        // An expired or burned code can only be fixed back on the code screen.
        codeError.value = messageFor(error);
        passwordError.value = messageFor(error);
        return;
      }

      // Pop the three recovery screens off and land back on the Log In screen
      // the user started from. `offAllNamed` would build a second Log In while
      // the first is still unwinding, and the two would fight over the one
      // registered SignInController.
      Get.until((route) => route.settings.name == AppRoutes.signIn);
      showAuthSnack(
        AppStrings.forgotPasswordTitle,
        AppStrings.passwordResetDone,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Shows the freshly issued code.
  ///
  /// **Stub:** nothing emails it — there is no mail service in this build — so
  /// the flow would be untestable on device if the code stayed hidden.
  void _announceCode(String value) => showAuthSnack(
    'Verification code: $value',
    'Demo build — no email is sent. Enter this code to continue.',
  );

  @override
  void onClose() {
    emailField.dispose();
    passwordField.dispose();
    confirmField.dispose();
    super.onClose();
  }
}
