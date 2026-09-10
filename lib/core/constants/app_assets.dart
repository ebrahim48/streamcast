/// Asset paths, so no widget hard-codes a string that a file rename can break.
class AppAssets {
  AppAssets._();

  static const String _img = 'assets/images';
  static const String _icon = 'assets/icons';

  // ─── Images ──────────────────────────────────────────────────────────────

  /// Circular ring artwork behind the splash wordmark.
  static const String splashCircular = '$_img/streamcostcircularsplash.png';

  /// Onboarding hero — open line rings.
  static const String onboardingHero = '$_img/onboarding.png';

  /// Onboarding hero — lit variant, used for the error state.
  static const String onboardingHeroLit = '$_img/onboarding1.png';

  // ─── Icons ───────────────────────────────────────────────────────────────

  static const String iconHome = '$_icon/home.svg';
  static const String iconExplore = '$_icon/explore.svg';
  static const String iconPremium = '$_icon/premium.svg';
  static const String iconLibrary = '$_icon/mylibray.svg';
  static const String iconSearch = '$_icon/search.svg';
  static const String iconAdd = '$_icon/add.svg';
  static const String iconPlay = '$_icon/play.svg';
  static const String iconCircle = '$_icon/circle.svg';
  static const String iconCast = '$_icon/net.svg';
  static const String iconMessage = '$_icon/message.svg';
}
