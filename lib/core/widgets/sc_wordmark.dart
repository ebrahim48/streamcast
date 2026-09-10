import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_strings.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// Size presets for [ScWordmark].
enum WordmarkSize {
  /// App bar mark — 18sp, mixed case ("StreamCast").
  sm,

  /// Onboarding hero — 24sp, uppercase.
  md,

  /// Splash — 34sp, uppercase.
  lg,
}

/// The `● StreamCast` lockup: an orange signal dot followed by the wordmark.
///
/// [glow] adds the soft orange halo used on the splash and onboarding hero.
/// The small preset renders mixed case as it appears in the app bar; the larger
/// presets render UPPERCASE Roboto Condensed as in the design.
class ScWordmark extends StatelessWidget {
  const ScWordmark({super.key, this.size = WordmarkSize.sm, this.glow = false});

  final WordmarkSize size;
  final bool glow;

  double get _fontSize => switch (size) {
    WordmarkSize.sm => 18,
    WordmarkSize.md => 24,
    WordmarkSize.lg => 34,
  };

  double get _dotSize => switch (size) {
    WordmarkSize.sm => 8,
    WordmarkSize.md => 11,
    WordmarkSize.lg => 15,
  };

  String get _label => size == WordmarkSize.sm
      ? AppStrings.appName
      : AppStrings.appName.toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _dotSize.r,
          height: _dotSize.r,
          decoration: BoxDecoration(
            color: AppColors.accentSignal,
            shape: BoxShape.circle,
            boxShadow: glow
                ? [
                    BoxShadow(
                      color: AppColors.accentSignal.withValues(alpha: 0.55),
                      blurRadius: 14.r,
                      spreadRadius: 1.r,
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(width: (_dotSize * 0.8).w),
        Text(
          _label,
          style: AppTextStyles.wordmark(size: _fontSize).copyWith(
            shadows: glow
                ? [
                    Shadow(
                      color: AppColors.accentSignal.withValues(alpha: 0.30),
                      blurRadius: 22.r,
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }
}
