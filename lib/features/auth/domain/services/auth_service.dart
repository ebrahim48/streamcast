import '../../../../core/models/auth_account.dart';
import '../../data/repositories/auth_repository.dart';

/// Why an auth call failed.
///
/// The service deals in reasons, not sentences; the controllers map these onto
/// the copy in `AppStrings` so all user-facing text stays in one file.
enum AuthError {
  /// Sign-up hit an address that is already registered.
  emailTaken,

  /// Sign-in: the email exists but the password does not match, or the email
  /// is unknown. Deliberately one reason — saying which half was wrong tells
  /// an attacker which addresses are registered.
  invalidCredentials,

  /// Password reset was asked for an address with no account.
  unknownEmail,

  /// The six-digit code does not match the outstanding challenge.
  codeInvalid,

  /// The challenge was issued more than [AuthService.codeValidity] ago.
  codeExpired,
}

/// Sign-in, sign-up and password recovery.
///
/// Registered permanently in [DependencyInjection] because the splash asks it
/// whether a session is already open before it decides where to send the user.
class AuthService {
  AuthService({required AuthRepository authRepository})
    : _repository = authRepository;

  final AuthRepository _repository;

  /// How long a reset code stays usable — matches the copy on the verify
  /// screen ("will expire in 10 minutes").
  static const Duration codeValidity = Duration(minutes: 10);

  /// Stands in for the round-trip a real backend would cost, so the buttons'
  /// loading state is something the user actually sees.
  static const Duration _latency = Duration(milliseconds: 600);

  /// The demo address the Google button signs in as.
  ///
  /// **Stub:** `google_sign_in` is not wired into this build; the button runs
  /// the same local flow as email sign-up against a fixed account.
  static const String googleDemoEmail = 'demo.user@gmail.com';

  // ─── Session ─────────────────────────────────────────────────────────────

  bool get isSignedIn => _repository.sessionEmail != null;

  String? get currentEmail => _repository.sessionEmail;

  Future<void> signOut() => _repository.closeSession();

  // ─── Email + password ────────────────────────────────────────────────────

  /// Registers [email] and opens a session for it.
  Future<AuthError?> signUp({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);

    final normalized = AuthRepository.normalize(email);
    if (_repository.findAccount(normalized) != null) {
      return AuthError.emailTaken;
    }

    final salt = _repository.newSalt();
    await _repository.saveAccount(
      AuthAccount(
        email: normalized,
        passwordHash: _repository.hashPassword(password, salt),
        salt: salt,
      ),
    );
    await _repository.openSession(normalized);
    return null;
  }

  /// Checks [password] against the stored digest and opens a session.
  Future<AuthError?> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);

    final account = _repository.findAccount(email);
    if (account == null) return AuthError.invalidCredentials;

    if (_repository.hashPassword(password, account.salt) !=
        account.passwordHash) {
      return AuthError.invalidCredentials;
    }

    await _repository.openSession(account.email);
    return null;
  }

  /// Signs in through the Google button.
  ///
  /// Creates the demo account on first use, then behaves like any other
  /// returning sign-in.
  Future<AuthError?> signInWithGoogle() async {
    await Future<void>.delayed(_latency);

    if (_repository.findAccount(googleDemoEmail) == null) {
      await _repository.saveAccount(
        const AuthAccount(
          email: googleDemoEmail,
          // No password to digest — this account can only be reached through
          // the Google button, never through the email form.
          passwordHash: '',
          salt: '',
          provider: AuthProvider.google,
        ),
      );
    }

    await _repository.openSession(googleDemoEmail);
    return null;
  }

  // ─── Password recovery ───────────────────────────────────────────────────

  /// Issues a reset code for [email].
  ///
  /// Returns the code alongside the error slot because nothing delivers it —
  /// the screen shows it to the user rather than sending an email.
  Future<({AuthError? error, String? code})> requestResetCode(
    String email,
  ) async {
    await Future<void>.delayed(_latency);

    if (_repository.findAccount(email) == null) {
      return (error: AuthError.unknownEmail, code: null);
    }

    final code = await _repository.issueResetCode(
      email,
      validFor: codeValidity,
    );
    return (error: null, code: code);
  }

  /// Checks [code] against the outstanding challenge for [email].
  Future<AuthError?> verifyResetCode({
    required String email,
    required String code,
  }) async {
    await Future<void>.delayed(_latency);

    final challenge = _repository.readResetChallenge();
    if (challenge == null ||
        challenge.email != AuthRepository.normalize(email)) {
      return AuthError.codeInvalid;
    }
    if (DateTime.now().isAfter(challenge.expiresAt)) {
      return AuthError.codeExpired;
    }
    if (challenge.code != code) return AuthError.codeInvalid;

    return null;
  }

  /// Writes a new password for [email] and burns the challenge.
  ///
  /// The code is re-checked here rather than trusted from the previous screen,
  /// so the reset cannot be reached by navigating straight to the route.
  Future<AuthError?> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    final invalid = await verifyResetCode(email: email, code: code);
    if (invalid != null) return invalid;

    final account = _repository.findAccount(email);
    if (account == null) return AuthError.unknownEmail;

    final salt = _repository.newSalt();
    await _repository.saveAccount(
      account.copyWith(
        salt: salt,
        passwordHash: _repository.hashPassword(password, salt),
      ),
    );
    await _repository.clearResetChallenge();
    return null;
  }
}
