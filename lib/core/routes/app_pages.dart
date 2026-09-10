import 'package:get/get.dart';

import '../../features/ads/presentation/controllers/ad_controller.dart';
import '../../features/cast/domain/services/cast_service.dart';
import '../../features/creator_studio/data/repositories/team_repository.dart';
import '../../features/creator_studio/domain/services/team_service.dart';
import '../../features/creator_studio/presentation/controllers/creator_studio_controller.dart';
import '../../features/creator_studio/presentation/creator_studio_page.dart';
import '../../features/explore/data/repositories/explore_repository.dart';
import '../../features/explore/domain/services/explore_service.dart';
import '../../features/explore/presentation/controllers/explore_controller.dart';
import '../../features/home/data/repositories/home_repository.dart';
import '../../features/home/domain/services/home_service.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/library/presentation/controllers/library_controller.dart';
import '../../features/main/presentation/controllers/main_shell_controller.dart';
import '../../features/main/presentation/main_shell_page.dart';
import '../../features/onboarding/presentation/controllers/onboarding_controller.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/premium/presentation/controllers/premium_controller.dart';
import '../../features/premium/presentation/premium_success_page.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../../features/profile/presentation/edit_profile_page.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/watch/data/repositories/watch_repository.dart';
import '../../features/watch/domain/services/playback_service.dart';
import '../../features/watch/domain/services/watch_service.dart';
import '../../features/watch/presentation/controllers/watch_controller.dart';
import '../../features/watch/presentation/watch_page.dart';
import '../models/stream_item.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import 'app_routes.dart';

/// Every route in the app, mapped to its page and binding.
///
/// Passed to `GetMaterialApp(getPages: ...)` in `app.dart`. Controllers scoped
/// to one route are registered in that route's [Bindings] so GetX disposes them
/// on the way out; the session-wide ones live in `DependencyInjection.init()`.
abstract class AppPages {
  AppPages._();

  static final List<GetPage> routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainShellPage(),
      binding: MainShellBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.watch,
      page: () => const WatchPage(),
      binding: WatchBinding(),
    ),
    GetPage(
      name: AppRoutes.premiumSuccess,
      page: () => const PremiumSuccessPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfilePage()),
    GetPage(
      name: AppRoutes.creatorStudio,
      page: () => const CreatorStudioPage(),
      binding: CreatorStudioBinding(),
    ),
  ];
}

/// Route-scoped dependencies for the onboarding step.
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(
        profileController: Get.find<ProfileController>(),
      ),
    );
  }
}

/// Dependencies for the four bottom-nav tabs.
///
/// Home and Explore are registered together because the shell keeps all four
/// tabs alive in an [IndexedStack]; Premium and Library controllers are already
/// permanent.
class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MainShellController>(MainShellController());

    Get.lazyPut<HomeController>(
      () => HomeController(
        homeService: HomeService(
          homeRepository: HomeRepository(
            cacheService: Get.find<CacheService>(),
            connectivityService: Get.find<ConnectivityService>(),
          ),
        ),
        premiumController: Get.find<PremiumController>(),
      ),
    );

    Get.lazyPut<ExploreController>(
      () => ExploreController(
        exploreService: ExploreService(exploreRepository: ExploreRepository()),
      ),
    );
  }
}

/// Dependencies for a single stream's watch page.
///
/// The stream itself arrives as a route argument, so the controller is built
/// per navigation rather than lazily reused.
class WatchBinding extends Bindings {
  @override
  void dependencies() {
    final item = Get.arguments as StreamItem;

    Get.put<WatchController>(
      WatchController(
        watchService: WatchService(watchRepository: WatchRepository()),
        castService: Get.find<CastService>(),
        playback: PlaybackService(),
        adController: Get.find<AdController>(),
        libraryController: Get.find<LibraryController>(),
        premiumController: Get.find<PremiumController>(),
        initialItem: item,
      ),
    );
  }
}

/// Dependencies for Creator Studio.
class CreatorStudioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreatorStudioController>(
      () => CreatorStudioController(
        teamService: TeamService(teamRepository: TeamRepository()),
      ),
    );
  }
}
