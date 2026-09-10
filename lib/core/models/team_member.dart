import 'package:flutter/foundation.dart';

/// What a team member is allowed to do in Creator Studio.
enum TeamRole {
  /// Owns the feed and the team roster.
  manager,

  /// Can post links, but not manage the team.
  moderator,
}

extension TeamRoleX on TeamRole {
  String get label => this == TeamRole.manager ? 'MANAGER' : 'Moderator';
}

/// A person with posting access to the curated feed.
@immutable
class TeamMember {
  const TeamMember({required this.id, required this.name, required this.role});

  final String id;
  final String name;
  final TeamRole role;
}
