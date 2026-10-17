/// Route name constants for the entire application.
///
/// Use these constants everywhere instead of string literals — typos become
/// compile errors, and renaming a route is a single edit.
///
/// ```dart
/// Get.toNamed(AppRoutes.watch, arguments: stream);
/// Get.offAllNamed(AppRoutes.main);
/// ```
abstract class AppRoutes {
  AppRoutes._();

  static const String initial = '/';

  // ─── Entry flow ──────────────────────────────────────────────────────────
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  // ─── Auth ────────────────────────────────────────────────────────────────
  // Log In and Sign Up are two routes, not two tabs of one page. The segmented
  // control at the top of each replaces the current route with the other, so
  // toggling between them never grows the stack.
  static const String signIn = '/auth/sign-in';
  static const String signUp = '/auth/sign-up';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyCode = '/auth/verify-code';
  static const String resetPassword = '/auth/reset-password';

  /// Bottom-nav shell hosting home / explore / premium / library.
  static const String main = '/main';

  // The four tabs are pages inside the shell's IndexedStack, not routes — move
  // between them with MainShellController, not Get.toNamed.

  // ─── Stacked pages ───────────────────────────────────────────────────────
  static const String premiumSuccess = '/premium/success';
  static const String watch = '/watch';
  static const String editProfile = '/profile/edit';
  static const String creatorStudio = '/studio';
}
