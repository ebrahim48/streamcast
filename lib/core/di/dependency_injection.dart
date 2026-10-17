import 'dart:async';

import 'package:get/get.dart';

import '../../features/ads/domain/services/ad_service.dart';
import '../../features/ads/presentation/controllers/ad_controller.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/domain/services/auth_service.dart';
import '../../features/cast/data/repositories/cast_repository.dart';
import '../../features/cast/domain/services/cast_service.dart';
import '../../features/cast/presentation/controllers/cast_controller.dart';
import '../../features/library/data/repositories/library_repository.dart';
import '../../features/library/domain/services/library_service.dart';
import '../../features/library/presentation/controllers/library_controller.dart';
import '../../features/premium/data/repositories/premium_repository.dart';
import '../../features/premium/domain/services/premium_service.dart';
import '../../features/premium/presentation/controllers/premium_controller.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/domain/services/profile_service.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/storage_service.dart';

/// App-wide dependency graph, wired with GetX.
///
/// Two tiers live here:
///
/// - **Core services** — API, cache, connectivity, storage.
/// - **Session controllers** — auth, cast, premium, library, profile and ads.
///   These are permanent because their state crosses screens: the splash needs
///   the auth session before its first frame, a cast survives
///   navigation, the premium flag hides ads on three different pages, a watch
///   recorded on the player must already be in the library rail, a rename has
///   to reach the library header, and ad watch-time accrues across streams
///   rather than resetting on every navigation.
///
/// Everything else — home, explore, watch, creator studio — is route-scoped and
/// registered in its route's [Bindings] (see `app_pages.dart`), so GetX
/// disposes it when the user leaves.
///
/// **Phase 1 note:** [ApiService] is registered but never called; every feed
/// reads from `core/data/mock_data.dart`. Repositories keep their signatures,
/// so moving a feature onto the network is a change inside that repository.
class DependencyInjection {
  DependencyInjection._();

  /// Registers core services and session controllers. Call once before
  /// `runApp`.
  static Future<void> init() async {
    // ─── Core services ─────────────────────────────────────────────────────
    Get.lazyPut<CacheService>(() => CacheService(), fenix: true);
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<ConnectivityService>(() => ConnectivityService(), fenix: true);

    // Eager — SharedPreferences.getInstance() is async, and the splash reads
    // from storage on its first frame.
    final storageService = StorageService();
    await storageService.init();
    Get.put<StorageService>(storageService, permanent: true);

    // ─── Auth ──────────────────────────────────────────────────────────────
    // Permanent because the splash asks it whether a session is already open
    // before it decides between onboarding, the sign-in screen and the feed.
    Get.put<AuthService>(
      AuthService(
        authRepository: AuthRepository(storageService: storageService),
      ),
      permanent: true,
    );

    // ─── Casting ───────────────────────────────────────────────────────────
    // The service is registered too, not just the controller: the watch page
    // asks it how a given platform casts, and must consult the same instance
    // that owns the live session.
    final castService = CastService(castRepository: CastRepository());
    Get.put<CastService>(castService, permanent: true);
    Get.put<CastController>(
      CastController(castService: castService),
      permanent: true,
    );
    // Bring up the Cast context now so the first tap on the cast icon starts
    // discovering rather than initialising. No-ops off Android/iOS.
    unawaited(castService.init());

    // ─── Premium ───────────────────────────────────────────────────────────
    Get.put<PremiumController>(
      PremiumController(
        premiumService: PremiumService(
          premiumRepository: PremiumRepository(storageService: storageService),
        ),
      ),
      permanent: true,
    );

    // ─── Library ───────────────────────────────────────────────────────────
    Get.put<LibraryController>(
      LibraryController(
        libraryService: LibraryService(
          libraryRepository: LibraryRepository(storageService: storageService),
        ),
      ),
      permanent: true,
    );

    // ─── Profile ───────────────────────────────────────────────────────────
    Get.put<ProfileController>(
      ProfileController(
        profileService: ProfileService(
          profileRepository: ProfileRepository(storageService: storageService),
        ),
      ),
      permanent: true,
    );

    // ─── Ads ───────────────────────────────────────────────────────────────
    Get.put<AdController>(
      AdController(
        adService: AdService(),
        premiumController: Get.find<PremiumController>(),
      ),
      permanent: true,
    );
  }

  /// Drops every registered dependency. Useful between tests.
  static void clear() => Get.deleteAll(force: true);
}
