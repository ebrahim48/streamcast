import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// The small monospace label that precedes every section — `// signal:live`,
/// `// setup 01`, `// up:next`.
///
/// Defaults to the brand orange; pass [color] for the muted variants such as
/// `// establishing signal` on the splash.
class MonoTag extends StatelessWidget {
  const MonoTag(
    this.text, {
    super.key,
    this.color = AppColors.accentSignal,
    this.size = 10.5,
    this.textAlign,
  });

  final String text;
  final Color color;
  final double size;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: AppTextStyles.mono(size: size, color: color),
    );
  }
}
