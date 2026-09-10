import '../../data/repositories/profile_repository.dart';

/// Profile business logic.
class ProfileService {
  ProfileService({required ProfileRepository profileRepository})
    : _repository = profileRepository;

  final ProfileRepository _repository;

  String get name => _repository.getName();

  String? get avatarPath => _repository.getAvatarPath();

  /// Rejects a blank rename — the name is the only identity the app has, so it
  /// is never allowed to become empty.
  Future<bool> saveName(String name) async {
    if (name.trim().isEmpty) return false;
    await _repository.saveName(name);
    return true;
  }

  Future<void> saveAvatarPath(String path) => _repository.saveAvatarPath(path);

  bool get isOnboarded => _repository.isOnboarded();

  /// Stores the name chosen during onboarding and marks setup complete.
  ///
  /// Returns false for a blank name, so the caller can surface its error
  /// instead of writing an empty profile.
  Future<bool> completeOnboarding(String name) async {
    if (!await saveName(name)) return false;
    await _repository.setOnboarded();
    return true;
  }
}
