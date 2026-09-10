import '../../../../core/models/stream_item.dart';

/// How a given stream is actually rendered on screen.
enum PlaybackMode {
  /// A platform web player inside a WebView — YouTube, Vimeo, Kick, Twitch,
  /// Facebook. Each ships its own controls.
  embed,

  /// An MP4/HLS URL played by the native video player.
  native,

  /// Nothing to play: the channel is offline, the source failed, or the link
  /// can't be embedded.
  none,
}

/// Turns a source link into something playable.
///
/// Every platform here refuses to be played from a bare URL — each needs its
/// own embed form, and most refuse to embed at all without a `parent` or
/// origin. That per-platform knowledge lives here rather than in the widget.
class PlaybackService {
  PlaybackService();

  /// Host declared to Twitch/Kick as the embedding parent.
  ///
  /// Twitch rejects embeds whose `parent` doesn't match the requesting origin.
  /// The in-app WebView reports `localhost` for a data/HTML document, so that
  /// is what is declared; a production build served from a real domain must
  /// list that domain here and in the Twitch developer console.
  static const String embedParent = 'localhost';

  PlaybackMode modeFor(StreamItem item) {
    if (item.status == StreamStatus.offline ||
        item.status == StreamStatus.error) {
      return PlaybackMode.none;
    }
    if (item.platform == StreamPlatform.direct) return PlaybackMode.native;
    return embedUrl(item) == null ? PlaybackMode.none : PlaybackMode.embed;
  }

  /// The URL to load in the WebView, or null when the link can't be embedded.
  String? embedUrl(StreamItem item) {
    final id = _sourceId(item);
    if (id == null) return null;

    return switch (item.platform) {
      // `playsinline` keeps playback in the page on iOS; the YouTube embed
      // carries its own cast button, which is how YouTube content casts.
      StreamPlatform.youtube =>
        'https://www.youtube.com/embed/$id?playsinline=1&rel=0&modestbranding=1',
      StreamPlatform.vimeo =>
        'https://player.vimeo.com/video/$id?playsinline=1&dnt=1',
      StreamPlatform.twitch =>
        item.isLive
            ? 'https://player.twitch.tv/?channel=$id&parent=$embedParent'
            : 'https://player.twitch.tv/?video=$id&parent=$embedParent',
      // Kick only embeds live channels; its VODs have no embed player.
      StreamPlatform.kick => item.isLive ? 'https://player.kick.com/$id' : null,
      StreamPlatform.facebook =>
        'https://www.facebook.com/plugins/video.php?href='
            '${Uri.encodeComponent(item.sourceUrl)}&show_text=false',
      StreamPlatform.direct => null,
    };
  }

  /// The channel name or video id inside a source URL.
  ///
  /// Returns null when the link doesn't carry one, which is what makes
  /// [modeFor] fall through to [PlaybackMode.none] rather than loading a page
  /// that will only show an error.
  String? _sourceId(StreamItem item) {
    final uri = Uri.tryParse(item.sourceUrl);
    if (uri == null || item.sourceUrl.isEmpty) return null;

    switch (item.platform) {
      case StreamPlatform.youtube:
        // Both the watch?v= and the youtu.be/<id> forms.
        final v = uri.queryParameters['v'];
        if (v != null && v.isNotEmpty) return v;
        return uri.pathSegments.isEmpty ? null : uri.pathSegments.last;

      case StreamPlatform.vimeo:
      case StreamPlatform.kick:
        return uri.pathSegments.isEmpty ? null : uri.pathSegments.first;

      case StreamPlatform.twitch:
        if (uri.pathSegments.isEmpty) return null;
        // twitch.tv/videos/<id> for a VOD, twitch.tv/<channel> when live.
        if (uri.pathSegments.first == 'videos') {
          return uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        }
        return uri.pathSegments.first;

      case StreamPlatform.facebook:
        return item.sourceUrl;

      case StreamPlatform.direct:
        return item.sourceUrl;
    }
  }

  /// Wraps [url] in a page that fills the frame with no scroll or margin.
  ///
  /// Loading the embed URL directly leaves the platform's own page padding
  /// around the player; this hosts the iframe at exactly the frame's size.
  String embedHtml(String url) =>
      '''
<!doctype html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<style>
  html,body{margin:0;padding:0;height:100%;background:#0B0E14;overflow:hidden}
  iframe{border:0;width:100%;height:100%;display:block}
</style>
</head>
<body>
<iframe src="$url" allow="autoplay; encrypted-media; picture-in-picture; fullscreen" allowfullscreen></iframe>
</body>
</html>
''';
}
