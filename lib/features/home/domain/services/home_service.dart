import '../../../../core/data/mock_data.dart';
import '../../../../core/models/stream_item.dart';
import '../../data/repositories/home_repository.dart';

/// Business rules for the home feed.
///
/// The one rule that matters here is ad placement: free-tier users get a
/// sponsored slot woven into the grid, premium users get an uninterrupted feed.
class HomeService {
  HomeService({required HomeRepository homeRepository})
    : _repository = homeRepository;

  final HomeRepository _repository;

  /// Slot index the grid promo occupies — the fourth card, as in the design.
  static const int sponsoredSlot = 3;

  Future<List<StreamItem>> loadLiveNow() => _repository.getLiveNow();

  /// The recommended grid, with the promo inserted for free-tier users.
  Future<List<StreamItem>> loadRecommended({required bool isPremium}) async {
    final items = await _repository.getRecommended();
    if (isPremium) return items;

    final withAd = [...items];
    final at = sponsoredSlot.clamp(0, withAd.length);
    withAd.insert(at, MockData.sponsoredGrid);
    return withAd;
  }
}
