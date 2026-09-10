import 'package:flutter/foundation.dart';

/// A threaded comment under a stream.
///
/// Comments persist across sessions and carry a like count; live chat does not.
@immutable
class CommentItem {
  const CommentItem({
    required this.user,
    required this.text,
    required this.time,
    required this.likes,
    this.isMine = false,
  });

  final String user;
  final String text;

  /// Relative stamp as displayed, e.g. "2h", "1d".
  final String time;

  final int likes;
  final bool isMine;

  /// Initial shown in the avatar circle.
  String get avatarLetter => user.isEmpty ? '?' : user[0].toUpperCase();
}
