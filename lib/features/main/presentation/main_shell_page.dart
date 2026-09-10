import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/sc_bottom_nav.dart';
import '../../explore/presentation/explore_page.dart';
import '../../home/presentation/home_page.dart';
import '../../library/presentation/library_page.dart';
import '../../premium/presentation/premium_page.dart';
import 'controllers/main_shell_controller.dart';

/// Host for the four bottom-nav destinations.
///
/// Tabs live in an [IndexedStack] so each keeps its scroll position and
/// controller state as the user moves between them — switching back to Home
/// should not re-fetch the feed or lose the user's place in it.
class MainShellPage extends GetView<MainShellController> {
  const MainShellPage({super.key});

  static const List<Widget> _tabs = [
    HomePage(),
    ExplorePage(),
    PremiumPage(),
    LibraryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Obx(() => IndexedStack(index: controller.index, children: _tabs)),
      bottomNavigationBar: Obx(
        () => ScBottomNav(
          currentIndex: controller.index,
          onTap: controller.select,
        ),
      ),
    );
  }
}
