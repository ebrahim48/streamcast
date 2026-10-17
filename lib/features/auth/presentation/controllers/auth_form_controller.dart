import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/services/auth_service.dart';

/// What the two credential screens — Log In and Sign Up — have in common:
/// a busy flag, a form-level error line, the Google button, and the hand-off
/// into the app once a session is open.
abstract class AuthFormController extends GetxController {
  AuthFormController({required AuthService authService}) : auth = authService;

  @protected
  final AuthService auth;

  /// True while a call is in flight; dims the CTA and blocks a second tap.
  final RxBool isLoading = false.obs;

  /// Error that belongs to the form as a whole rather than to one field —
  /// "Email or password is incorrect.", for instance, which is true of the
  /// pair and not of either box.
  final RxnString formError = RxnString();

  /// Runs [action] with [isLoading] held, and shows whatever reason comes back
  /// as the form-level error.
  @protected
  Future<void> runGuarded(Future<AuthError?> Function() action) async {
    if (isLoading.value) return;

    isLoading.value = true;
    formError.value = null;
    try {
      final error = await action();
      if (error == null) {
        enterApp();
        return;
      }
      formError.value = messageFor(error);
    } finally {
      isLoading.value = false;
    }
  }

  /// Signs in through the Google button.
  Future<void> continueWithGoogle() => runGuarded(auth.signInWithGoogle);

  /// Leaves the auth stack for the feed. Nothing can navigate back into it.
  ///
  /// Not awaited by the caller, and it must not be: the future GetX hands back
  /// only completes when the *new* route is popped, so awaiting it would hold
  /// [isLoading] true for as long as the user stays in the app.
  @protected
  void enterApp() => Get.offAllNamed<void>(AppRoutes.main);
}

/// Copy for each failure reason, kept out of [AuthService] so every string the
/// user can read still lives in [AppStrings].
String messageFor(AuthError error) => switch (error) {
  AuthError.emailTaken => AppStrings.emailTaken,
  AuthError.invalidCredentials => AppStrings.wrongCredentials,
  AuthError.unknownEmail => AppStrings.unknownEmail,
  AuthError.codeInvalid => AppStrings.codeWrong,
  AuthError.codeExpired => AppStrings.codeExpired,
};

/// The app's one snackbar shape, so auth feedback matches the rest of the app.
void showAuthSnack(String title, String message) => Get.snackbar(
  title,
  message,
  backgroundColor: AppColors.bgSurfaceElevated,
  colorText: AppColors.textPrimary,
  margin: const EdgeInsets.all(12),
  duration: const Duration(seconds: 6),
);
