import '../models/cast_device.dart';
import '../models/chat_message.dart';
import '../models/comment_item.dart';
import '../models/premium_plan.dart';
import '../models/stream_item.dart';
import '../models/team_member.dart';

/// The static content the app runs on in Phase 1.
///
/// The backend isn't wired yet, so every repository reads from here instead of
/// [ApiService]. Each repository keeps an async signature and an artificial
/// delay, so the loading states are real and switching a feature to the network
/// later touches only that repository.
///
/// Dates are expressed relative to [_now] so the "2 days ago" style labels stay
/// correct no matter when the app is opened.
class MockData {
  MockData._();

  static DateTime get _now => DateTime.now();
  static DateTime _daysAgo(int d) => _now.subtract(Duration(days: d));

  // ─── Live ────────────────────────────────────────────────────────────────

  static List<StreamItem> get liveNow => [
    StreamItem(
      id: 'live_vct',
      title: 'VCT Grand Finals — Map 4 Overtime',
      channelName: 'NovaEsports',
      platform: StreamPlatform.twitch,
      status: StreamStatus.live,
      thumbnailSeed: 'arena',
      sourceUrl: 'https://www.twitch.tv/novaesports',
      viewersLive: 184000,
    ),
    StreamItem(
      id: 'live_ranked',
      title: 'Late Night Ranked Grind — Road to Radiant',
      channelName: 'kaiplays',
      platform: StreamPlatform.kick,
      status: StreamStatus.live,
      thumbnailSeed: 'deskglow',
      sourceUrl: 'https://kick.com/kaiplays',
      viewersLive: 12400,
    ),
    StreamItem(
      id: 'live_warehouse',
      title: 'Warehouse Sessions 042 — Live DJ Set',
      channelName: 'SubFrequency',
      platform: StreamPlatform.youtube,
      status: StreamStatus.live,
      thumbnailSeed: 'djset',
      sourceUrl: 'https://www.youtube.com/watch?v=mKCieTImjvU',
      viewersLive: 38900,
    ),
    StreamItem(
      id: 'live_endurance',
      title: 'Endurance 12H — Night Stint Onboard',
      channelName: 'ApexRacingTV',
      platform: StreamPlatform.facebook,
      status: StreamStatus.live,
      thumbnailSeed: 'nightcircuit',
      sourceUrl: 'https://www.facebook.com/apexracingtv/live',
      viewersLive: 6100,
    ),
    StreamItem(
      id: 'live_control',
      title: 'The Control Room — Streaming Tech Talk',
      channelName: 'Signal Desk',
      platform: StreamPlatform.twitch,
      status: StreamStatus.live,
      thumbnailSeed: 'controlroom',
      sourceUrl: 'https://www.twitch.tv/signaldesk',
      viewersLive: 2300,
    ),
  ];

  // ─── Recorded ────────────────────────────────────────────────────────────

  static List<StreamItem> get recommended => [
    StreamItem(
      id: 'vod_clutch',
      title: 'Every Clutch From The Grand Final',
      channelName: 'NovaEsports',
      platform: StreamPlatform.youtube,
      status: StreamStatus.vod,
      thumbnailSeed: 'arena',
      sourceUrl: 'https://www.youtube.com/watch?v=mKCieTImjvU',
      duration: '14:02',
      views: 2100000,
      publishedAt: _daysAgo(2),
    ),
    StreamItem(
      id: 'vod_desk',
      title: 'Building A Broadcast Desk From Scratch',
      channelName: 'Signal Desk',
      platform: StreamPlatform.vimeo,
      status: StreamStatus.vod,
      thumbnailSeed: 'controlroom',
      sourceUrl: 'https://vimeo.com/signaldesk/broadcastdesk',
      duration: '22:47',
      views: 318000,
      publishedAt: _daysAgo(8),
    ),
    StreamItem(
      id: 'vod_circuit',
      title: 'Night Circuit Highlights — Round 7',
      channelName: 'ApexRacingTV',
      platform: StreamPlatform.youtube,
      status: StreamStatus.vod,
      thumbnailSeed: 'nightcircuit',
      sourceUrl: 'https://www.youtube.com/watch?v=mKCieTImjvU',
      duration: '08:19',
      views: 94000,
      publishedAt: _daysAgo(3),
    ),
    StreamItem(
      id: 'vod_warehouse41',
      title: 'Warehouse Sessions 041 — Full Replay',
      channelName: 'SubFrequency',
      platform: StreamPlatform.youtube,
      status: StreamStatus.vod,
      thumbnailSeed: 'djset',
      sourceUrl: 'https://www.youtube.com/watch?v=mKCieTImjvU',
      duration: '1:04:11',
      views: 512000,
      publishedAt: _daysAgo(5),
    ),
    StreamItem(
      id: 'vod_setup',
      title: 'Setup Tour: The 4AM Streamer Cave',
      channelName: 'kaiplays',
      platform: StreamPlatform.kick,
      status: StreamStatus.vod,
      thumbnailSeed: 'deskglow',
      sourceUrl: 'https://kick.com/kaiplays/videos/setup-tour',
      duration: '11:36',
      views: 77000,
      publishedAt: _daysAgo(15),
    ),
    StreamItem(
      id: 'vod_casting',
      title: 'How Casting Actually Works — Explained',
      channelName: 'Signal Desk',
      platform: StreamPlatform.youtube,
      status: StreamStatus.vod,
      thumbnailSeed: 'arena',
      sourceUrl: 'https://www.youtube.com/watch?v=mKCieTImjvU',
      duration: '09:54',
      views: 1300000,
      publishedAt: _daysAgo(35),
    ),
  ];

  /// Everything, live first — what Explore searches over.
  static List<StreamItem> get allStreams => [...liveNow, ...recommended];

  static StreamItem? byId(String id) {
    for (final s in allStreams) {
      if (s.id == id) return s;
    }
    return null;
  }

  // ─── Promos ──────────────────────────────────────────────────────────────

  /// The grid promo, injected into Recommended for free-tier users.
  static const StreamItem sponsoredGrid = StreamItem(
    id: 'ad_grid',
    title: 'Cast to any TV, ad-free — try StreamCast Premium',
    channelName: 'StreamCast Premium',
    platform: StreamPlatform.direct,
    status: StreamStatus.vod,
    isSponsored: true,
  );

  /// The narrower promo used in the watch page's up-next list.
  static const StreamItem sponsoredRow = StreamItem(
    id: 'ad_row',
    title: 'Watch ad-free and cast without limits',
    channelName: 'StreamCast Premium · from \$2.99',
    platform: StreamPlatform.direct,
    status: StreamStatus.vod,
    isSponsored: true,
  );

  // ─── Engagement ──────────────────────────────────────────────────────────

  static const List<ChatMessage> chat = [
    ChatMessage(
      user: 'kb_signal',
      text: 'stream quality is clean tonight',
      time: '22:16',
    ),
    ChatMessage(
      user: 'nocturne',
      text: 'map 4 is the best one so far',
      time: '22:16',
    ),
    ChatMessage(
      user: 'ren0',
      text: 'who else is watching from a phone',
      time: '22:17',
    ),
    ChatMessage(user: 'aya_tv', text: 'LETS GOOO', time: '22:17'),
    ChatMessage(user: 'volt_ax', text: 'that retake was insane', time: '22:14'),
    ChatMessage(
      user: 'mira_hz',
      text: 'casting this to the big screen rn',
      time: '22:14',
    ),
    ChatMessage(
      user: 'dropframe',
      text: 'no way he held that angle',
      time: '22:15',
    ),
  ];

  static const List<CommentItem> comments = [
    CommentItem(
      user: 'dropframe',
      text:
          'The production on this broadcast keeps getting better every '
          'season.',
      time: '2h',
      likes: 214,
    ),
    CommentItem(
      user: 'mira_hz',
      text:
          'Cast it to my TV in one tap from Twitch. Did not think that was '
          'possible.',
      time: '5h',
      likes: 98,
    ),
    CommentItem(
      user: 'kb_signal',
      text: 'Timestamp 08:42 is the play of the year, no debate.',
      time: '9h',
      likes: 51,
    ),
    CommentItem(
      user: 'nocturne',
      text: 'Anyone know when the VOD for map 3 drops?',
      time: '1d',
      likes: 12,
    ),
  ];

  // ─── Casting ─────────────────────────────────────────────────────────────

  static const List<CastDevice> castDevices = [
    CastDevice(
      id: 'living_room',
      name: 'Living Room TV',
      subtitle: 'Samsung · AirPlay 2',
      type: CastDeviceType.airplay,
    ),
    CastDevice(
      id: 'bedroom',
      name: 'Bedroom Chromecast',
      subtitle: 'Google Cast',
      type: CastDeviceType.chromecast,
    ),
    CastDevice(
      id: 'studio',
      name: 'Studio Display',
      subtitle: 'Apple TV 4K',
      type: CastDeviceType.appleTv,
    ),
  ];

  // ─── Monetization ────────────────────────────────────────────────────────

  static const List<PremiumPlan> plans = [
    PremiumPlan(
      id: 'weekly',
      label: 'Weekly',
      price: '\$2.99',
      period: '/week',
    ),
    PremiumPlan(
      id: 'monthly',
      label: 'Monthly',
      price: '\$6.99',
      period: '/month',
      isPopular: true,
    ),
    PremiumPlan(
      id: 'yearly',
      label: 'Yearly',
      price: '\$39.99',
      period: '/year',
    ),
  ];

  static const List<String> premiumFeatures = [
    'Remove ads',
    'Unlimited casting',
    'Priority streams',
  ];

  // ─── Team ────────────────────────────────────────────────────────────────

  static const TeamMember manager = TeamMember(
    id: 'ryan',
    name: 'Ryan Coley',
    role: TeamRole.manager,
  );
}
