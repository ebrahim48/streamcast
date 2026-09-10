import '../../../../core/data/mock_data.dart';
import '../../../../core/models/chat_message.dart';
import '../../../../core/models/comment_item.dart';
import '../../../../core/models/stream_item.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/repositories/watch_repository.dart';

/// Business rules for the watch screen.
class WatchService {
  WatchService({required WatchRepository watchRepository})
    : _repository = watchRepository;

  final WatchRepository _repository;

  /// Slot the promo row takes in the up-next list, for free-tier users.
  static const int sponsoredSlot = 2;

  Future<List<ChatMessage>> loadChat(String streamId) =>
      _repository.getChat(streamId);

  Future<List<CommentItem>> loadComments(String streamId) =>
      _repository.getComments(streamId);

  /// Up-next, with the premium promo woven in for free-tier users.
  Future<List<StreamItem>> loadUpNext(
    String streamId, {
    required bool isPremium,
  }) async {
    final items = await _repository.getUpNext(streamId);
    if (isPremium) return items;

    final withAd = [...items];
    withAd.insert(sponsoredSlot.clamp(0, withAd.length), MockData.sponsoredRow);
    return withAd;
  }

  /// Whether live chat applies. Recorded videos have comments only, so the
  /// Chat tab is disabled rather than shown empty.
  bool supportsChat(StreamItem item) => item.status != StreamStatus.vod;

  /// The metadata line under the player title.
  String headerMeta(StreamItem item) {
    final platform = item.platform.label;
    final watching = item.viewersLive;

    // Offline channels still show their audience — the design keeps the count
    // visible so the page doesn't lose its shape when a stream drops.
    if (watching != null && item.status != StreamStatus.vod) {
      return '$platform · ${Formatters.compactCount(watching)} watching now';
    }
    if (item.views != null) {
      return '$platform · ${Formatters.compactCount(item.views!)} views'
          '${item.publishedAt == null ? '' : ' · ${Formatters.timeAgo(item.publishedAt!)}'}';
    }
    return platform;
  }
}
