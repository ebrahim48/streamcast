import 'package:flutter/foundation.dart';

/// One line in a live chat.
///
/// Chat is per-broadcast and ephemeral — unlike [CommentItem] it carries no
/// likes and is never persisted.
@immutable
class ChatMessage {
  const ChatMessage({
    required this.user,
    required this.text,
    required this.time,
    this.isMine = false,
  });

  /// Chat handle, shown in brand orange.
  final String user;

  final String text;

  /// Wall-clock stamp as displayed, e.g. "22:16".
  final String time;

  /// Messages the local user just sent, so they can be styled apart.
  final bool isMine;
}
