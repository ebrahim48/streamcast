import '../../../../core/data/mock_data.dart';
import '../../../../core/models/chat_message.dart';
import '../../../../core/models/comment_item.dart';
import '../../../../core/models/stream_item.dart';

/// Data access for a single stream: its chat, its comments, and what plays
/// next.
class WatchRepository {
  WatchRepository();

  static const Duration _latency = Duration(milliseconds: 300);

  Future<List<ChatMessage>> getChat(String streamId) async {
    await Future.delayed(_latency);
    return MockData.chat;
  }

  Future<List<CommentItem>> getComments(String streamId) async {
    await Future.delayed(_latency);
    return MockData.comments;
  }

  /// Up-next candidates: everything else in the catalogue, live first.
  Future<List<StreamItem>> getUpNext(String streamId) async {
    await Future.delayed(_latency);
    final others = MockData.allStreams.where((s) => s.id != streamId).toList();
    others.sort((a, b) {
      if (a.isLive == b.isLive) return 0;
      return a.isLive ? -1 : 1;
    });
    return others;
  }
}
