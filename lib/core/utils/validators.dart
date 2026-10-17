import '../constants/app_strings.dart';

/// Field-level checks for the auth forms.
///
/// Each returns the message to show under the field, or null when the value
/// passes. Keeping them here rather than in the controllers means sign-up,
/// sign-in and password reset all judge a password by the same rule.
class Validators {
  Validators._();

  /// Shortest password the app will accept.
  static const int minPasswordLength = 8;

  /// Deliberately loose: `something@something.tld`. Anything stricter starts
  /// rejecting addresses that are actually valid.
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? email(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return AppStrings.emailRequired;
    if (!_email.hasMatch(trimmed)) return AppStrings.emailInvalid;
    return null;
  }

  /// For the sign-in form, where an existing password is only ever checked
  /// against the stored digest — length rules would leak nothing but noise.
  static String? loginPassword(String value) =>
      value.isEmpty ? AppStrings.passwordRequired : null;

  /// For sign-up and reset, where the password is being created.
  static String? newPassword(String value) {
    if (value.isEmpty) return AppStrings.passwordRequired;
    if (value.length < minPasswordLength) return AppStrings.passwordTooShort;
    return null;
  }

  static String? confirmPassword(String value, String original) {
    if (value.isEmpty) return AppStrings.confirmRequired;
    if (value != original) return AppStrings.confirmMismatch;
    return null;
  }
}
