import '../../../../core/data/mock_data.dart';
import '../../../../core/models/team_member.dart';

/// The team roster with posting access to the feed.
///
/// **Phase 1:** held in memory for the session. The roster belongs on the admin
/// backend, so this is the first thing that moves when it lands.
class TeamRepository {
  TeamRepository();

  final List<TeamMember> _moderators = [];

  TeamMember getManager() => MockData.manager;

  List<TeamMember> getModerators() => List.unmodifiable(_moderators);

  TeamMember addModerator(String name) {
    final member = TeamMember(
      id: 'mod_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      role: TeamRole.moderator,
    );
    _moderators.add(member);
    return member;
  }

  void removeModerator(String id) => _moderators.removeWhere((m) => m.id == id);
}
