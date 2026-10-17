import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../../../../core/models/auth_account.dart';
import '../../../../core/services/storage_service.dart';

/// Account storage.
///
/// **Phase 1 note:** StreamCast has no auth backend yet, so accounts, the
/// session and the password-reset challenge all live in [StorageService] on
/// this device. Every method here already has the shape its networked
/// replacement will have, so wiring a real API is a change inside this class.
class AuthRepository {
  AuthRepository({required StorageService storageService})
    : _storage = storageService;

  final StorageService _storage;

  final Random _random = Random.secure();

  // ─── Accounts ────────────────────────────────────────────────────────────

  /// Every registered account, keyed by lowercased email.
  Map<String, AuthAccount> readAccounts() {
    final raw = _storage.getString(StorageKeys.authAccounts);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (email, json) => MapEntry(
          email,
          AuthAccount.fromJson(json as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      // A corrupt blob should log the user out, not crash the sign-in screen.
      return {};
    }
  }

  AuthAccount? findAccount(String email) => readAccounts()[normalize(email)];

  Future<void> saveAccount(AuthAccount account) async {
    final accounts = readAccounts()..[account.email] = account;
    await _storage.setString(
      StorageKeys.authAccounts,
      jsonEncode(accounts.map((email, a) => MapEntry(email, a.toJson()))),
    );
  }

  // ─── Session ─────────────────────────────────────────────────────────────

  String? get sessionEmail => _storage.getString(StorageKeys.authSession);

  Future<void> openSession(String email) =>
      _storage.setString(StorageKeys.authSession, normalize(email));

  Future<void> closeSession() => _storage.remove(StorageKeys.authSession);

  // ─── Password reset ──────────────────────────────────────────────────────

  /// Stores the six-digit challenge issued for [email] and returns it.
  ///
  /// Nothing is emailed — there is no mail service behind this build — so the
  /// caller surfaces the code to the user instead.
  Future<String> issueResetCode(String email, {required Duration validFor}) async {
    final code = (100000 + _random.nextInt(900000)).toString();
    await _storage.setString(
      StorageKeys.authResetChallenge,
      jsonEncode({
        'email': normalize(email),
        'code': code,
        'expiresAt': DateTime.now()
            .add(validFor)
            .millisecondsSinceEpoch,
      }),
    );
    return code;
  }

  /// The outstanding challenge, or null when none was issued.
  ({String email, String code, DateTime expiresAt})? readResetChallenge() {
    final raw = _storage.getString(StorageKeys.authResetChallenge);
    if (raw == null || raw.isEmpty) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (
        email: json['email'] as String,
        code: json['code'] as String,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          json['expiresAt'] as int,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearResetChallenge() =>
      _storage.remove(StorageKeys.authResetChallenge);

  // ─── Hashing ─────────────────────────────────────────────────────────────

  /// A fresh 16-byte salt, base64-encoded.
  String newSalt() => base64Url.encode(
    List<int>.generate(16, (_) => _random.nextInt(256)),
  );

  String hashPassword(String password, String salt) =>
      sha256.convert(utf8.encode('$salt|$password')).toString();

  /// Emails are compared case-insensitively, so they are stored that way too.
  static String normalize(String email) => email.trim().toLowerCase();
}
