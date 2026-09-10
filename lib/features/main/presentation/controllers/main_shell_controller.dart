import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';

/// The four bottom-nav destinations.
enum ShellTab { home, explore, premium, library }

/// Owns which tab the shell is showing.
///
/// The tabs are not routes — they are pages inside one [IndexedStack] — so
/// "go to Premium" from a card tap can't be a navigation call. Anything that
/// wants to move the user between tabs goes through here instead.
class MainShellController extends GetxController {
  final Rx<ShellTab> tab = ShellTab.home.obs;

  int get index => tab.value.index;

  void select(int index) => tab.value = ShellTab.values[index];

  void goTo(ShellTab next) => tab.value = next;

  /// Switches tabs from a page stacked above the shell — a watch page, say —
  /// by unwinding back to the shell first.
  void goToFromStack(ShellTab next) {
    Get.until((route) => route.settings.name == AppRoutes.main);
    tab.value = next;
  }
}
