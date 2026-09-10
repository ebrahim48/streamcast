import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';
import 'mono_tag.dart';

/// A mono tag stacked over a section title, with optional right-aligned meta.
///
/// This pairing is the app's structural rhythm — `// signal:live` over "Live
/// Now", `// feed:curated` over "Recommended" — so it lives in one widget
/// rather than being reassembled on each screen.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.tag,
    required this.title,
    this.trailing,
    this.titleColor,
  });

  /// The mono label, e.g. `// signal:live`.
  final String tag;

  final String title;

  /// Muted text on the right of the title row, e.g. "5 channels".
  final String? trailing;

  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonoTag(tag),
        SizedBox(height: 2.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(title, style: AppTextStyles.h2(color: titleColor)),
            ),
            if (trailing != null)
              Padding(
                padding: EdgeInsets.only(left: AppDimens.gapSm.w, bottom: 3.h),
                child: Text(
                  trailing!,
                  style: AppTextStyles.caption(color: AppColors.textDim),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
