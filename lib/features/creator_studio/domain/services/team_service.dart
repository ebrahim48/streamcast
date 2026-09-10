import '../../../../core/models/team_member.dart';
import '../../data/repositories/team_repository.dart';

/// Team-management rules.
class TeamService {
  TeamService({required TeamRepository teamRepository})
    : _repository = teamRepository;

  final TeamRepository _repository;

  TeamMember get manager => _repository.getManager();

  List<TeamMember> get moderators => _repository.getModerators();

  /// Adds a moderator, refusing blanks and duplicates.
  ///
  /// Returns null when the name can't be added, so the caller can leave the
  /// field's contents alone rather than silently clearing them.
  TeamMember? addModerator(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    final exists = moderators.any(
      (m) => m.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) return null;

    return _repository.addModerator(trimmed);
  }

  void removeModerator(String id) => _repository.removeModerator(id);
}
