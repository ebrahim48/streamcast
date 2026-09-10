import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Where a stream originates. Determines how it plays and how it casts.
enum StreamPlatform { youtube, twitch, kick, vimeo, facebook, direct }

/// Playback state of a stream at the moment it is shown.
enum StreamStatus {
  /// Broadcasting right now — shows the `● Live` badge and a watcher count.
  live,

  /// Recorded — shows a duration chip and a view count.
  vod,

  /// The channel exists but isn't broadcasting.
  offline,

  /// The source could not be loaded.
  error,
}

extension StreamPlatformX on StreamPlatform {
  /// Human label as it appears under a card — "Facebook Live", not "facebook".
  String get label => switch (this) {
    StreamPlatform.youtube => 'YouTube',
    StreamPlatform.twitch => 'Twitch',
    StreamPlatform.kick => 'Kick',
    StreamPlatform.vimeo => 'Vimeo',
    StreamPlatform.facebook => 'Facebook Live',
    StreamPlatform.direct => 'Direct',
  };

  /// Short label used by the Explore filter chips.
  String get filterLabel =>
      this == StreamPlatform.facebook ? 'Facebook' : label;

  /// Whether the platform can be cast through its own SDK.
  ///
  /// YouTube ships its own cast button inside the embed. Everything else is
  /// relayed by StreamCast, which is the whole point of the product.
  bool get hasNativeCast => this == StreamPlatform.youtube;

  /// A lowercase token for the mono tags — `// kick:offline`.
  String get monoToken => name;
}

/// Detects the platform from a pasted URL.
///
/// Used by the Add-to-Feed sheet to label a link the moment it is pasted.
/// Returns null when nothing recognisable is present, which is what drives the
/// "no link detected" chip.
StreamPlatform? detectPlatform(String url) {
  final u = url.trim().toLowerCase();
  if (u.isEmpty) return null;
  if (!u.contains('.')) return null;

  if (u.contains('youtube.com') || u.contains('youtu.be')) {
    return StreamPlatform.youtube;
  }
  if (u.contains('twitch.tv')) return StreamPlatform.twitch;
  if (u.contains('kick.com')) return StreamPlatform.kick;
  if (u.contains('vimeo.com')) return StreamPlatform.vimeo;
  if (u.contains('facebook.com') || u.contains('fb.watch')) {
    return StreamPlatform.facebook;
  }
  if (u.endsWith('.mp4') || u.endsWith('.m3u8') || u.endsWith('.webm')) {
    return StreamPlatform.direct;
  }
  return null;
}

/// A single entry in the feed — live broadcast or recorded video.
///
/// The same model backs every surface (home rail, grid, explore results, watch
/// page, library rows), so a card built for one screen reads correctly on all
/// of them.
@immutable
class StreamItem {
  const StreamItem({
    required this.id,
    required this.title,
    required this.channelName,
    required this.platform,
    required this.status,
    this.channelSubscribers = '482K subscribers',
    this.thumbnailSeed,
    this.sourceUrl = '',
    this.duration,
    this.viewersLive,
    this.views,
    this.publishedAt,
    this.isSponsored = false,
  });

  final String id;
  final String title;
  final String channelName;

  /// Display string, e.g. "482K subscribers".
  final String channelSubscribers;

  final StreamPlatform platform;
  final StreamStatus status;

  /// Stable seed for the placeholder thumbnail service.
  ///
  /// Phase 1 has no CDN behind it, so thumbnails are fetched by seed and the
  /// same card always shows the same image. Swapping in a real
  /// `thumbnailUrl` later is a change in [StreamThumbnail] alone.
  final String? thumbnailSeed;

  /// The original link the admin posted.
  final String sourceUrl;

  /// Runtime for a VOD, e.g. "14:02". Null while live.
  final String? duration;

  /// Concurrent viewers while [status] is [StreamStatus.live].
  final int? viewersLive;

  /// Lifetime view count for a VOD.
  final int? views;

  final DateTime? publishedAt;

  /// Renders as a "Sponsored" promo card instead of a normal entry.
  final bool isSponsored;

  bool get isLive => status == StreamStatus.live;

  /// Badge colour for the live pill.
  Color get badgeColor => AppColors.badgeLive;

  StreamItem copyWith({StreamStatus? status}) => StreamItem(
    id: id,
    title: title,
    channelName: channelName,
    channelSubscribers: channelSubscribers,
    platform: platform,
    status: status ?? this.status,
    thumbnailSeed: thumbnailSeed,
    sourceUrl: sourceUrl,
    duration: duration,
    viewersLive: viewersLive,
    views: views,
    publishedAt: publishedAt,
    isSponsored: isSponsored,
  );

  /// Parses a feed entry from the API shape described in `api_constants.dart`.
  ///
  /// Unused in Phase 1 — kept so the repositories can switch to the network
  /// without a model rewrite.
  factory StreamItem.fromJson(Map<String, dynamic> json) => StreamItem(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    channelName: json['channel_name'] as String? ?? '',
    channelSubscribers:
        json['channel_subscribers'] as String? ?? '0 subscribers',
    platform: StreamPlatform.values.firstWhere(
      (p) => p.name == json['platform'],
      orElse: () => StreamPlatform.direct,
    ),
    status: StreamStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => StreamStatus.vod,
    ),
    thumbnailSeed: json['thumbnail_seed'] as String?,
    sourceUrl: json['source_url'] as String? ?? '',
    duration: json['duration'] as String?,
    viewersLive: json['viewers_live'] as int?,
    views: json['views'] as int?,
    publishedAt: json['published_at'] == null
        ? null
        : DateTime.tryParse(json['published_at'] as String),
    isSponsored: json['is_sponsored'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'channel_name': channelName,
    'channel_subscribers': channelSubscribers,
    'platform': platform.name,
    'status': status.name,
    'thumbnail_seed': thumbnailSeed,
    'source_url': sourceUrl,
    'duration': duration,
    'viewers_live': viewersLive,
    'views': views,
    'published_at': publishedAt?.toIso8601String(),
    'is_sponsored': isSponsored,
  };

  @override
  bool operator ==(Object other) =>
      other is StreamItem && other.id == id && other.status == status;

  @override
  int get hashCode => Object.hash(id, status);
}
