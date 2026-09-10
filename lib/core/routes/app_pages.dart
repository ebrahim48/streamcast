import 'package:get/get.dart';

import '../../features/main/presentation/main_shell_page.dart';
import '../../features/onboarding/presentation/controllers/onboarding_controller.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../services/storage_service.dart';
import 'app_routes.dart';

/// Every route in the app, mapped to its page and binding.
///
/// Passed to `GetMaterialApp(getPages: ...)` in `app.dart`. Controllers that
/// belong to a single route are registered in that route's [Bindings] so GetX
/// disposes them on the way out; app-wide services live in
/// `DependencyInjection.init()` instead.
abstract class AppPages {
  AppPages._();

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainShellPage(),
      transition: Transition.fadeIn,
    ),

    // ─── Added as each build step lands ────────────────────────────────────
    // GetPage(name: AppRoutes.watch,          page: () => const WatchPage()),
    // GetPage(name: AppRoutes.premiumSuccess, page: () => const PremiumSuccessPage()),
    // GetPage(name: AppRoutes.editProfile,    page: () => const EditProfilePage()),
    // GetPage(name: AppRoutes.creatorStudio,  page: () => const CreatorStudioPage()),
  ];
}

/// Route-scoped dependencies for [OnboardingPage].
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(storageService: Get.find<StorageService>()),
    );
  }
}
