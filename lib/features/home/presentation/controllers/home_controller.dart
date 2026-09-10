import 'package:get/get.dart';

import '../../../../core/models/stream_item.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../main/presentation/controllers/main_shell_controller.dart';
import '../../../premium/presentation/controllers/premium_controller.dart';
import '../../domain/services/home_service.dart';

/// State for the home feed.
class HomeController extends GetxController {
  HomeController({
    required HomeService homeService,
    required PremiumController premiumController,
  }) : _service = homeService,
       _premium = premiumController;

  final HomeService _service;
  final PremiumController _premium;

  final RxList<StreamItem> liveNow = <StreamItem>[].obs;
  final RxList<StreamItem> recommended = <StreamItem>[].obs;

  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();

  /// "5 channels" — the count beside the Live Now header.
  String get liveCountLabel {
    final n = liveNow.length;
    return '$n channel${n == 1 ? '' : 's'}';
  }

  @override
  void onInit() {
    super.onInit();
    load();

    // Upgrading mid-session removes the ad slot, so rebuild the grid when the
    // premium flag flips rather than leaving a stale promo in place.
    ever(_premium.isPremium, (_) => load());
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      final results = await Future.wait([
        _service.loadLiveNow(),
        _service.loadRecommended(isPremium: _premium.isPremium.value),
      ]);
      liveNow.assignAll(results[0]);
      recommended.assignAll(results[1]);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull-to-refresh handler. Named apart from GetxController.refresh(),
  /// which is the widget-rebuild trigger and returns void.
  Future<void> reload() => load();

  void openStream(StreamItem item) =>
      Get.toNamed(AppRoutes.watch, arguments: item);

  /// Premium is a sibling tab, not a route — move the shell instead of
  /// pushing a second copy of the page onto the stack.
  void openPremium() => Get.find<MainShellController>().goTo(ShellTab.premium);
}
