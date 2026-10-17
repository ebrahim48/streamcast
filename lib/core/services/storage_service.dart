import 'package:shared_preferences/shared_preferences.dart';

/// A clean-architecture wrapper around [SharedPreferences] for persistent
/// key-value storage.
///
/// [StorageService] is registered as a singleton in [DependencyInjection]
/// and is available app-wide via `Get.find<StorageService>()`.
///
/// **Supported Types:** `String`, `int`, `double`, `bool`, `List<String>`
///
/// **Usage:**
/// ```dart
/// final storage = Get.find<StorageService>();
///
/// // Write
/// await storage.setString(StorageKeys.authToken, 'abc123');
/// await storage.setBool(StorageKeys.isLoggedIn, true);
///
/// // Read
/// final token = storage.getString(StorageKeys.authToken);
/// final isLoggedIn = storage.getBool(StorageKeys.isLoggedIn) ?? false;
///
/// // Remove
/// await storage.remove(StorageKeys.authToken);
///
/// // Clear all stored data
/// await storage.clear();
/// ```
///
/// **Initialization:**
/// Called automatically via [DependencyInjection.init()] before the app runs.
/// Do not call [init] manually unless in tests.
class StorageService {
  late SharedPreferences _prefs;

  /// Initializes the underlying [SharedPreferences] instance.
  ///
  /// This is called once during app startup via [DependencyInjection.init()].
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── String ──────────────────────────────────────────────────────────────

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  // ─── Int ─────────────────────────────────────────────────────────────────

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  int? getInt(String key) => _prefs.getInt(key);

  // ─── Double ──────────────────────────────────────────────────────────────

  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  double? getDouble(String key) => _prefs.getDouble(key);

  // ─── Bool ────────────────────────────────────────────────────────────────

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  // ─── List<String> ────────────────────────────────────────────────────────

  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  List<String>? getStringList(String key) => _prefs.getStringList(key);

  // ─── Utility ─────────────────────────────────────────────────────────────

  /// Returns `true` if [key] exists in storage.
  bool containsKey(String key) => _prefs.containsKey(key);

  /// Removes a single [key] from storage.
  Future<bool> remove(String key) => _prefs.remove(key);

  /// Removes all stored data. Use with caution.
  Future<bool> clear() => _prefs.clear();

  /// Returns every key currently stored.
  Set<String> getKeys() => _prefs.getKeys();
}

/// Predefined key constants for [StorageService].
///
/// Always use these constants instead of raw strings to avoid typos
/// and to have a single source of truth for all storage keys.
///
/// **Usage:**
/// ```dart
/// await storage.setString(StorageKeys.authToken, token);
/// final token = storage.getString(StorageKeys.authToken);
/// ```
///
/// Add new keys here as your feature set grows.
abstract class StorageKeys {
  StorageKeys._();

  // ─── Profile ─────────────────────────────────────────────────────────────

  /// Display name entered during onboarding. `String`
  static const String userName = 'sc_user_name';

  /// Local file path of the chosen avatar. `String`
  static const String userAvatarPath = 'sc_user_avatar_path';

  /// Whether onboarding has been completed. `bool`
  static const String onboarded = 'sc_onboarded';

  // ─── Auth ────────────────────────────────────────────────────────────────

  /// Registered accounts, keyed by lowercased email, as a JSON string.
  static const String authAccounts = 'sc_auth_accounts';

  /// Email of the signed-in account, absent when signed out. `String`
  static const String authSession = 'sc_auth_session';

  /// The in-flight password-reset challenge, as a JSON string.
  static const String authResetChallenge = 'sc_auth_reset_challenge';

  // ─── Monetization ────────────────────────────────────────────────────────

  /// Whether the premium tier is active. `bool`
  static const String isPremium = 'sc_is_premium';

  /// Active plan id — `weekly` | `monthly` | `yearly`. `String`
  static const String premiumPlan = 'sc_premium_plan';

  // ─── Library ─────────────────────────────────────────────────────────────

  /// Watched stream ids, most recent first. `List<String>`
  static const String history = 'sc_history';

  /// Liked stream ids. `List<String>`
  static const String liked = 'sc_liked';

  /// Watch-later queue. `List<String>`
  static const String watchLater = 'sc_watch_later';

  /// Subscribed channel names. `List<String>`
  static const String subscribed = 'sc_subscribed';

  // ─── Feed ────────────────────────────────────────────────────────────────

  /// Links added through the Add-to-Feed sheet, as a JSON string.
  static const String feedLinks = 'sc_feed_links';
}
