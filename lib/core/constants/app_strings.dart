/// All user-facing copy, in one place.
///
/// Grouped by screen so a string is easy to find, and so the whole file can be
/// swapped for generated localizations later without touching widgets.
class AppStrings {
  AppStrings._();

  // ─── Brand ───────────────────────────────────────────────────────────────
  static const String appName = 'StreamCast';
  static const String tagline = 'Every Stream. One Screen.';

  // ─── Splash ──────────────────────────────────────────────────────────────
  static const String monoEstablishingSignal = '// establishing signal';

  // ─── Onboarding ──────────────────────────────────────────────────────────
  static const String monoSetup01 = '// setup 01';
  static const String onboardingTitle = 'What should we\ncall you?';
  static const String onboardingBody =
      'Your name is stored on this device only. No email, no password, ever.';
  static const String nameHint = 'Enter your name';
  static const String nameEmptyError = 'Please enter a name to continue.';
  static const String continueLabel = 'Continue';

  // ─── Common ──────────────────────────────────────────────────────────────
  static const String retry = 'Retry';
  static const String save = 'Save';
}
