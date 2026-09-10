import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/mono_tag.dart';
import '../../../core/widgets/sc_bottom_nav.dart';

/// Host for the four bottom-nav destinations.
///
/// Tabs are kept in an [IndexedStack] so each one holds its scroll position
/// and controller state when the user moves between them.
///
/// **Step 1 scaffold:** the tab bodies are placeholders. Home lands in step 2,
/// Explore in step 5, Premium in step 6, My Library in step 7 — each replaces
/// one entry in [_tabs].
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  late final List<Widget> _tabs = const [
    _ComingSoon(tag: '// feed:curated', title: 'Home', step: 'Step 2'),
    _ComingSoon(tag: '// query:results', title: 'Explore', step: 'Step 5'),
    _ComingSoon(tag: '// tier:premium', title: 'Premium', step: 'Step 6'),
    _ComingSoon(tag: '// saved:queue', title: 'My Library', step: 'Step 7'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: ScBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// Temporary tab body — replaced screen by screen as the build progresses.
class _ComingSoon extends StatelessWidget {
  const _ComingSoon({
    required this.tag,
    required this.title,
    required this.step,
  });

  final String tag;
  final String title;
  final String step;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MonoTag(tag),
            SizedBox(height: AppDimens.gapSm.h),
            Text(title, style: AppTextStyles.h2()),
            SizedBox(height: AppDimens.gapSm.h),
            Text(
              '$step — coming next',
              style: AppTextStyles.caption(),
            ),
          ],
        ),
      ),
    );
  }
}
