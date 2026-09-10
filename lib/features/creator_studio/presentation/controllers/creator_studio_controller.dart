import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/models/team_member.dart';
import '../../domain/services/team_service.dart';

/// State for Creator Studio.
class CreatorStudioController extends GetxController {
  CreatorStudioController({required TeamService teamService})
    : _service = teamService;

  final TeamService _service;

  final TextEditingController moderatorField = TextEditingController();

  final RxList<TeamMember> moderators = <TeamMember>[].obs;

  TeamMember get manager => _service.manager;

  @override
  void onInit() {
    super.onInit();
    moderators.assignAll(_service.moderators);
  }

  void addModerator() {
    final added = _service.addModerator(moderatorField.text);
    if (added == null) return;

    moderators.assignAll(_service.moderators);
    moderatorField.clear();
  }

  void removeModerator(String id) {
    _service.removeModerator(id);
    moderators.assignAll(_service.moderators);
  }

  @override
  void onClose() {
    moderatorField.dispose();
    super.onClose();
  }
}
