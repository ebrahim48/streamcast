import '../../../../core/services/storage_service.dart';

/// The local profile — a name and an optional photo, both device-only.
///
/// StreamCast has no accounts by design, so this never touches the network.
class ProfileRepository {
  ProfileRepository({required StorageService storageService})
    : _storage = storageService;

  final StorageService _storage;

  String getName() => _storage.getString(StorageKeys.userName) ?? '';

  String? getAvatarPath() => _storage.getString(StorageKeys.userAvatarPath);

  Future<void> saveName(String name) =>
      _storage.setString(StorageKeys.userName, name.trim());

  Future<void> saveAvatarPath(String path) =>
      _storage.setString(StorageKeys.userAvatarPath, path);

  bool isOnboarded() => _storage.getBool(StorageKeys.onboarded) ?? false;

  Future<void> setOnboarded() => _storage.setBool(StorageKeys.onboarded, true);
}
