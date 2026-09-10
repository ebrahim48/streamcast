import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/services/profile_service.dart';

/// Backs the profile header in My Library and the Edit Profile page.
///
/// Registered permanently so a rename shows up in the library header the
/// instant it is saved.
class ProfileController extends GetxController {
  ProfileController({required ProfileService profileService})
    : _service = profileService;

  final ProfileService _service;

  final RxString name = ''.obs;
  final RxnString avatarPath = RxnString();

  /// Draft name being edited — committed to [name] only on save.
  final TextEditingController nameField = TextEditingController();

  final RxBool showNameError = false.obs;

  @override
  void onInit() {
    super.onInit();
    name.value = _service.name;
    avatarPath.value = _service.avatarPath;
  }

  /// Records the name chosen during onboarding.
  ///
  /// The onboarding step writes through here rather than straight to storage:
  /// this controller is permanent, so a direct write would leave the library
  /// header showing a stale, empty name for the rest of the session.
  Future<bool> completeOnboarding(String value) async {
    if (!await _service.completeOnboarding(value)) return false;
    name.value = value.trim();
    return true;
  }

  /// Loads the stored name into the editor. Call when opening Edit Profile.
  void beginEditing() {
    nameField.text = name.value;
    showNameError.value = false;
  }

  Future<void> pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 720,
      imageQuality: 85,
    );
    if (picked == null) return;

    await _service.saveAvatarPath(picked.path);
    avatarPath.value = picked.path;
  }

  /// Persists the draft name. Returns false when it is blank.
  Future<bool> save() async {
    final saved = await _service.saveName(nameField.text);
    if (!saved) {
      showNameError.value = true;
      return false;
    }
    name.value = nameField.text.trim();
    showNameError.value = false;
    return true;
  }

  @override
  void onClose() {
    nameField.dispose();
    super.onClose();
  }
}
