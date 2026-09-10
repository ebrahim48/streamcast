import '../../../../core/models/stream_item.dart';
import '../../data/repositories/add_link_repository.dart';

/// Turns a pasted URL into a feed entry.
class LinkParserService {
  LinkParserService({required AddLinkRepository addLinkRepository})
    : _repository = addLinkRepository;

  final AddLinkRepository _repository;

  /// The platform a URL belongs to, or null when nothing is recognised.
  StreamPlatform? detect(String url) => detectPlatform(url);

  /// How the link will behave once it is in the feed.
  ///
  /// This is the sheet's helper copy, resolved per platform rather than shown
  /// as one paragraph that covers every case at once.
  String playbackNote(StreamPlatform? platform) => switch (platform) {
    StreamPlatform.youtube =>
      'Plays in the YouTube embed — casts with YouTube\'s own button.',
    StreamPlatform.vimeo => 'Plays in the Vimeo embed.',
    StreamPlatform.kick =>
      'Kick embeds live channels only — VODs open on Kick.',
    StreamPlatform.twitch => 'Plays in the official Twitch player.',
    StreamPlatform.facebook => 'Plays in the Facebook Live embed.',
    StreamPlatform.direct => 'Direct video file — gets a Cast-to-TV button.',
    null =>
      'Paste a link from YouTube, Twitch, Kick, Vimeo or Facebook — or a\n'
          'direct video file.',
  };

  List<StreamItem> saved() => _repository.getAll();

  /// Builds and stores a feed entry. Assumes the URL has already been
  /// validated by the controller.
  Future<StreamItem> add({
    required String url,
    required String title,
    required String channelName,
  }) async {
    final platform = detect(url) ?? StreamPlatform.direct;

    final item = StreamItem(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      channelName: channelName.trim(),
      platform: platform,
      // A newly posted link is treated as a recording until the platform says
      // otherwise; live detection needs the platform API.
      status: StreamStatus.vod,
      thumbnailSeed: 'user${DateTime.now().millisecondsSinceEpoch}',
      sourceUrl: url.trim(),
      views: 0,
      publishedAt: DateTime.now(),
    );

    await _repository.save(item);
    return item;
  }
}
