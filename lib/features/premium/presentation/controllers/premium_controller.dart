import 'package:get/get.dart';

import '../../../../core/models/premium_plan.dart';
import '../../../../core/routes/app_routes.dart';
import '../../domain/services/premium_service.dart';

/// Holds subscription state for the whole app.
///
/// Registered permanently rather than per-route: Home hides its ad slot, Watch
/// hides its promo row and the nav tab all read [isPremium], so the flag has to
/// outlive the Premium page itself.
class PremiumController extends GetxController {
  PremiumController({required PremiumService premiumService})
    : _service = premiumService;

  final PremiumService _service;

  /// True once the user has upgraded — drives every ad-free behaviour.
  final RxBool isPremium = false.obs;

  /// The plan highlighted in the picker and named on the CTA.
  late final Rx<PremiumPlan> selectedPlan;

  /// True while the purchase is being processed.
  final RxBool isPurchasing = false.obs;

  List<PremiumPlan> get plans => _service.plans;

  List<String> get features => _service.features;

  @override
  void onInit() {
    super.onInit();
    isPremium.value = _service.isPremium;
    selectedPlan = _service.defaultPlan.obs;
  }

  void selectPlan(PremiumPlan plan) => selectedPlan.value = plan;

  /// CTA label — "Upgrade — Monthly $6.99".
  String get ctaLabel {
    final plan = selectedPlan.value;
    return 'Upgrade — ${plan.label} ${plan.price}';
  }

  /// Mono footnote under the feature list, matched to the selected period.
  String get billingNote {
    final period = selectedPlan.value.period.replaceFirst('/', '');
    return '// cancel anytime · billed $period';
  }

  Future<void> upgrade() async {
    if (isPurchasing.value) return;
    isPurchasing.value = true;
    try {
      await _service.purchase(selectedPlan.value.id);
      isPremium.value = true;
      await Get.toNamed(AppRoutes.premiumSuccess);
    } finally {
      isPurchasing.value = false;
    }
  }
}
