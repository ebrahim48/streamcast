/// Shared spacing, radius and sizing constants.
///
/// Values are design-pixels against the 375×812 reference frame; wrap them in
/// `.w` / `.h` / `.r` from `flutter_screenutil` at the call site.
class AppDimens {
  AppDimens._();

  // ─── Spacing ─────────────────────────────────────────────────────────────
  static const double gapXs = 4;
  static const double gapSm = 8;
  static const double gapMd = 12;
  static const double gapLg = 16;
  static const double gapXl = 24;
  static const double gapXxl = 32;

  /// Horizontal page gutter.
  static const double screenPadding = 16;

  // ─── Radius ──────────────────────────────────────────────────────────────
  static const double radiusCard = 12;
  static const double radiusButton = 12;
  static const double radiusInput = 12;
  static const double radiusSheet = 20;
  static const double radiusPill = 999;

  // ─── Sizing ──────────────────────────────────────────────────────────────
  static const double buttonHeight = 52;
  static const double inputHeight = 52;
  static const double bottomNavHeight = 64;
  static const double appBarHeight = 56;
}
