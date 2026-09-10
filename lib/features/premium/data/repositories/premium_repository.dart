import '../../../../core/data/mock_data.dart';
import '../../../../core/models/premium_plan.dart';
import '../../../../core/services/storage_service.dart';

/// Reads and writes subscription state.
///
/// **Phase 1:** there is no billing integration — "upgrading" flips a local
/// flag so the ad-free and unlimited-casting behaviour can be exercised end to
/// end. Wiring a store SDK later replaces [purchase] alone.
class PremiumRepository {
  PremiumRepository({required StorageService storageService})
    : _storage = storageService;

  final StorageService _storage;

  List<PremiumPlan> getPlans() => MockData.plans;

  List<String> getFeatures() => MockData.premiumFeatures;

  bool isPremium() => _storage.getBool(StorageKeys.isPremium) ?? false;

  String? activePlanId() => _storage.getString(StorageKeys.premiumPlan);

  /// Grants premium locally. Returns once the flag is persisted.
  Future<void> purchase(String planId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    await _storage.setBool(StorageKeys.isPremium, true);
    await _storage.setString(StorageKeys.premiumPlan, planId);
  }

  Future<void> cancel() async {
    await _storage.setBool(StorageKeys.isPremium, false);
    await _storage.remove(StorageKeys.premiumPlan);
  }
}
