import '../../../../core/data/mock_data.dart';
import '../../../../core/models/stream_item.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/connectivity_service.dart';

/// Data access for the home feed.
///
/// **Phase 1:** reads from [MockData]. The API surface is already described in
/// `api_constants.dart` — when the backend lands, only the bodies here change;
/// the service and controller above are unaffected.
///
/// The artificial delay is deliberate: it keeps the shimmer states on a real
/// code path instead of leaving them untested until the network arrives.
class HomeRepository {
  HomeRepository({
    required CacheService cacheService,
    required ConnectivityService connectivityService,
  }) : _cache = cacheService,
       _connectivity = connectivityService;

  // ignore: unused_field — used once the feed is served over the network.
  final CacheService _cache;
  // ignore: unused_field — used once the feed is served over the network.
  final ConnectivityService _connectivity;

  static const Duration _latency = Duration(milliseconds: 450);

  /// Channels broadcasting right now, ordered by watcher count.
  Future<List<StreamItem>> getLiveNow() async {
    await Future.delayed(_latency);
    final items = [...MockData.liveNow]
      ..sort((a, b) => (b.viewersLive ?? 0).compareTo(a.viewersLive ?? 0));
    return items;
  }

  /// The curated recorded feed.
  Future<List<StreamItem>> getRecommended() async {
    await Future.delayed(_latency);
    return MockData.recommended;
  }
}
