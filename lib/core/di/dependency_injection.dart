import 'package:get/get.dart';

import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/storage_service.dart';

/// App-wide dependency graph, wired with GetX.
///
/// Only things that must outlive a single route live here: the core services.
/// Feature repositories, domain services and controllers are registered in
/// their route's [Bindings] (see `app_pages.dart`) so GetX can dispose them
/// when the user leaves the screen.
///
/// **Phase 1 note:** [ApiService] is registered but unused — every feed reads
/// from the static mock source in `core/data/`. Repositories keep the same
/// signature, so switching a feature to the network later is a change inside
/// that one repository.
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await DependencyInjection.init();
///   runApp(const StreamCastApp());
/// }
/// ```
class DependencyInjection {
  DependencyInjection._();

  /// Registers core services. Call once, before `runApp`.
  static Future<void> init() async {
    // Lazy singletons — created on first `Get.find`, recreated if deleted.
    Get.lazyPut<CacheService>(() => CacheService(), fenix: true);
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<ConnectivityService>(() => ConnectivityService(), fenix: true);

    // Eager — SharedPreferences.getInstance() is async, and the splash reads
    // from storage on its first frame.
    final storageService = StorageService();
    await storageService.init();
    Get.put<StorageService>(storageService, permanent: true);
  }

  /// Drops every registered dependency. Useful between tests.
  static void clear() => Get.deleteAll(force: true);
}
