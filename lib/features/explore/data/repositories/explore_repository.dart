import '../../../../core/data/mock_data.dart';
import '../../../../core/models/stream_item.dart';

/// Search over the catalogue.
class ExploreRepository {
  ExploreRepository();

  Future<List<StreamItem>> search({
    required String query,
    StreamPlatform? platform,
  }) async {
    await Future.delayed(const Duration(milliseconds: 220));

    final q = query.trim().toLowerCase();
    return MockData.allStreams
        .where((item) {
          final matchesPlatform = platform == null || item.platform == platform;
          if (!matchesPlatform) return false;
          if (q.isEmpty) return true;
          return item.title.toLowerCase().contains(q) ||
              item.channelName.toLowerCase().contains(q) ||
              item.platform.label.toLowerCase().contains(q);
        })
        .toList(growable: false);
  }
}
