import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';

/// Drives the single onboarding step: pick a display name.
///
/// There is no account here — the name is written straight to
/// [StorageService] and never leaves the device.
class OnboardingController extends GetxController {
  OnboardingController({required ProfileController profileController})
    : _profile = profileController;

  final ProfileController _profile;

  final TextEditingController nameController = TextEditingController();
  final FocusNode nameFocus = FocusNode();

  /// Set once the user submits an empty field; cleared as soon as they type.
  final RxBool showEmptyError = false.obs;

  /// Whether the field currently holds a usable name — gates the CTA.
  final RxBool hasName = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final filled = nameController.text.trim().isNotEmpty;
    hasName.value = filled;
    if (filled && showEmptyError.value) showEmptyError.value = false;
  }

  /// Validates, persists the name, and moves on to the main shell.
  Future<void> submit() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      showEmptyError.value = true;
      nameFocus.requestFocus();
      return;
    }

    if (!await _profile.completeOnboarding(name)) {
      showEmptyError.value = true;
      return;
    }
    await Get.offAllNamed(AppRoutes.main);
  }

  @override
  void onClose() {
    nameController.removeListener(_onNameChanged);
    nameController.dispose();
    nameFocus.dispose();
    super.onClose();
  }
}
