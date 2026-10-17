/// One registered account, as stored on the device.
///
/// The password is never kept in the clear — only a SHA-256 digest of
/// `salt|password`, with a per-account random [salt]. That is not a substitute
/// for a real backend, but it does mean a dump of SharedPreferences hands over
/// no usable password.
class AuthAccount {
  const AuthAccount({
    required this.email,
    required this.passwordHash,
    required this.salt,
    this.provider = AuthProvider.password,
  });

  /// Lowercased, trimmed — the map key accounts are stored under.
  final String email;

  final String passwordHash;
  final String salt;
  final AuthProvider provider;

  AuthAccount copyWith({String? passwordHash, String? salt}) => AuthAccount(
    email: email,
    passwordHash: passwordHash ?? this.passwordHash,
    salt: salt ?? this.salt,
    provider: provider,
  );

  Map<String, dynamic> toJson() => {
    'email': email,
    'passwordHash': passwordHash,
    'salt': salt,
    'provider': provider.name,
  };

  factory AuthAccount.fromJson(Map<String, dynamic> json) => AuthAccount(
    email: json['email'] as String,
    passwordHash: json['passwordHash'] as String? ?? '',
    salt: json['salt'] as String? ?? '',
    provider: AuthProvider.values.firstWhere(
      (p) => p.name == json['provider'],
      orElse: () => AuthProvider.password,
    ),
  );
}

/// How an account was created.
enum AuthProvider {
  /// Email + password, entered on the sign-up screen.
  password,

  /// Created through the Google button.
  google,
}
