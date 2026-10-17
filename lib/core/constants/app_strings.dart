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
      'This is the name your profile carries. You\'ll secure it with an '
      'account on the next screen.';
  static const String nameHint = 'Enter your name';
  static const String nameEmptyError = 'Please enter a name to continue.';
  static const String continueLabel = 'Continue';

  // ─── Auth ────────────────────────────────────────────────────────────────
  static const String monoAccess01 = '// access 01';
  static const String monoAccess02 = '// access 02';
  static const String monoRecover01 = '// recover 01';
  static const String monoRecover02 = '// recover 02';
  static const String monoRecover03 = '// recover 03';

  static const String signInTitle = 'Sign in now';
  static const String signUpTitle = 'Sign up now';
  static const String authSubtitle =
      'Create an account or log in to pull every stream into one screen.';

  static const String tabLogIn = 'Log In';
  static const String tabSignUp = 'Sign Up';

  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String newPasswordLabel = 'New Password';

  static const String emailHint = 'you@example.com';
  static const String passwordHint = 'Your password';
  static const String passwordCreateHint = 'At least 8 characters';
  static const String passwordRepeatHint = 'Repeat your password';

  static const String forgetPassword = 'Forget password';
  static const String logInLabel = 'Log In';
  static const String signUpLabel = 'Sign Up';
  static const String orLoginWith = 'Or login with';

  // Busy labels — the CTA swaps its text while a call is in flight.
  static const String loggingIn = 'Logging in...';
  static const String creatingAccount = 'Creating account...';
  static const String sendingCode = 'Sending code...';
  static const String verifying = 'Verifying...';
  static const String updatingPassword = 'Updating...';
  static const String continueWithGoogle = 'Continue with Google';

  static const String forgotPasswordTitle = 'Forgot Password';
  static const String forgotPasswordBody =
      'Enter email address to reset your password.';
  static const String sendCode = 'Send Code';

  static const String verifyTitle = 'Enter verification\ncode';

  /// Body of the verification screen, naming the address the code went to.
  static String verifyBody(String email) =>
      "We've sent a verification code to $email that will expire in 10 "
      'minutes. Please enter the code to continue';

  static const String didntReceiveCode = "Didn't receive the code?";
  static const String resendCode = 'Resend Code';
  static const String verifyLabel = 'Verify';

  static const String resetTitle = 'Set a new\npassword';
  static const String resetBody =
      "Choose a password you haven't used before. You'll use it the next time "
      'you log in.';
  static const String resetPasswordLabel = 'Reset Password';
  static const String passwordResetDone =
      'Password updated — log in with your new one.';

  // ─── Auth errors ─────────────────────────────────────────────────────────
  static const String emailRequired = 'Enter your email address.';
  static const String emailInvalid = "That email address doesn't look right.";
  static const String passwordRequired = 'Enter your password.';
  static const String passwordTooShort = 'Use at least 8 characters.';
  static const String confirmRequired = 'Repeat your password.';
  static const String confirmMismatch = 'Both passwords must match.';
  static const String emailTaken = 'An account already uses that email.';
  static const String wrongCredentials = 'Email or password is incorrect.';
  static const String unknownEmail = 'No account found for that email.';
  static const String codeIncomplete = 'Enter all six digits.';
  static const String codeWrong = "That code isn't correct.";
  static const String codeExpired = 'That code has expired. Send a new one.';

  // ─── Common ──────────────────────────────────────────────────────────────
  static const String retry = 'Retry';
  static const String save = 'Save';
}
