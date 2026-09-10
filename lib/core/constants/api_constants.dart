/// Backend endpoints for the admin-curated feed.
///
/// **Phase 1: not in use.** Every feed currently reads from the static source
/// in `core/data/`, so nothing here is hit at runtime — [ApiService] only reads
/// [baseUrl] and [headers] when it builds its Dio instance. The shapes are kept
/// in the tree so switching a repository to the network later is a local change
/// inside that repository.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.streamcast.app';

  // ─── Feed ────────────────────────────────────────────────────────────────
  static const String liveNow = '/v1/streams/live';
  static const String recommended = '/v1/streams/recommended';
  static const String addLink = '/v1/streams';

  static String search(String query, {String platform = 'all'}) =>
      '/v1/search?q=$query&platform=$platform';

  static String streamDetail(String id) => '/v1/streams/$id';

  // ─── Engagement ──────────────────────────────────────────────────────────
  static String comments(String streamId) => '/v1/streams/$streamId/comments';
  static String chat(String streamId) => '/v1/streams/$streamId/chat';

  // ─── Team ────────────────────────────────────────────────────────────────
  static const String moderators = '/v1/team/moderators';

  static Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // ─── Cache keys ──────────────────────────────────────────────────────────
  static const String cacheLiveNow = 'live_now';
  static const String cacheRecommended = 'recommended';
  static const String cacheSearch = 'search';
}
