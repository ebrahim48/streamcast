import '../../../../core/models/stream_item.dart';
import '../../data/repositories/explore_repository.dart';

/// Search business logic, including the platform filter set.
class ExploreService {
  ExploreService({required ExploreRepository exploreRepository})
    : _repository = exploreRepository;

  final ExploreRepository _repository;

  /// Filter row order, matching the design. `null` is the leading "All" chip.
  static const List<StreamPlatform?> filters = [
    null,
    StreamPlatform.youtube,
    StreamPlatform.twitch,
    StreamPlatform.kick,
    StreamPlatform.vimeo,
    StreamPlatform.facebook,
  ];

  Future<List<StreamItem>> search({
    required String query,
    StreamPlatform? platform,
  }) {
    return _repository.search(query: query, platform: platform);
  }

  /// Heading over the results — "All Results", or the platform's own name.
  String resultsTitle(StreamPlatform? platform) =>
      platform == null ? 'All Results' : platform.filterLabel;
}
