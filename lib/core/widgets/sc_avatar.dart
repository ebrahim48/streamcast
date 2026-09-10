import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// Round profile mark.
///
/// Falls back through three states: the picked photo, then an initial, then the
/// generic person glyph — so it always renders something deliberate whether or
/// not the user has set a picture.
class ScAvatar extends StatelessWidget {
  const ScAvatar({
    super.key,
    this.size = 40,
    this.imagePath,
    this.letter,
    this.background,
    this.foreground,
  });

  final double size;

  /// Local file path from the image picker.
  final String? imagePath;

  /// Single character shown when there is no photo.
  final String? letter;

  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? AppColors.textDim;

    Widget content;
    if (imagePath != null && imagePath!.isNotEmpty) {
      content = ClipOval(
        child: Image.file(
          File(imagePath!),
          width: size.r,
          height: size.r,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Icon(
            Icons.person_outline_rounded,
            size: (size * 0.5).r,
            color: fg,
          ),
        ),
      );
    } else if (letter != null && letter!.isNotEmpty) {
      content = Text(
        letter!.toUpperCase(),
        style: AppTextStyles.bodyMedium(
          color: fg,
        ).copyWith(fontWeight: FontWeight.w700, fontSize: (size * 0.36).sp),
      );
    } else {
      content = Icon(
        Icons.person_outline_rounded,
        size: (size * 0.5).r,
        color: fg,
      );
    }

    return Container(
      width: size.r,
      height: size.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? AppColors.bgSurfaceElevated,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLine),
      ),
      child: content,
    );
  }
}
