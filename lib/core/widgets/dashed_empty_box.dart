import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';

/// Dashed-outline placeholder used for empty collections — the Watch Later
/// queue and the moderator list.
///
/// Flutter has no dashed border, so the outline is stroked by a painter rather
/// than faked with a dotted image.
class DashedEmptyBox extends StatelessWidget {
  const DashedEmptyBox({super.key, required this.message, this.height = 96});

  final String message;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(radius: AppDimens.radiusCard.r),
      child: SizedBox(
        width: double.infinity,
        height: height.h,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.gapLg.w),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(color: AppColors.textDim),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.radius});

  final double radius;

  static const double _dash = 5;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.borderLine;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + _dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.radius != radius;
}
