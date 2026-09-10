import '../../../../core/models/premium_plan.dart';
import '../../data/repositories/premium_repository.dart';

/// Subscription business logic.
class PremiumService {
  PremiumService({required PremiumRepository premiumRepository})
    : _repository = premiumRepository;

  final PremiumRepository _repository;

  List<PremiumPlan> get plans => _repository.getPlans();

  List<String> get features => _repository.getFeatures();

  bool get isPremium => _repository.isPremium();

  String? get activePlanId => _repository.activePlanId();

  /// The plan the picker opens on: the active one, else the popular one.
  PremiumPlan get defaultPlan {
    final active = activePlanId;
    return plans.firstWhere(
      (p) => p.id == active,
      orElse: () =>
          plans.firstWhere((p) => p.isPopular, orElse: () => plans.first),
    );
  }

  Future<void> purchase(String planId) => _repository.purchase(planId);

  Future<void> cancel() => _repository.cancel();
}
