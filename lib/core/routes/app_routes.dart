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

  /// Bottom-nav shell hosting home / explore / premium / library.
  static const String main = '/main';

  // ─── Tabs ────────────────────────────────────────────────────────────────
  static const String home = '/home';
  static const String explore = '/explore';
  static const String premium = '/premium';
  static const String library = '/library';

  // ─── Stacked pages ───────────────────────────────────────────────────────
  static const String premiumSuccess = '/premium/success';
  static const String watch = '/watch';
  static const String editProfile = '/profile/edit';
  static const String creatorStudio = '/studio';
}
