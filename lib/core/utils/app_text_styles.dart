import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// StreamCast type scale.
///
/// Three families, one job each:
/// - **Roboto Condensed Bold, UPPERCASE** — the wordmark and every section
///   header. Loud, compressed, structural.
/// - **Inter** — all body copy, titles and metadata.
/// - **JetBrains Mono** — the `// signal:live` tags that label each section.
///
/// Roboto Condensed and JetBrains Mono are pulled through `google_fonts`
/// (cached after first fetch); Inter is bundled in `assets/fonts/`.
class AppTextStyles {
  AppTextStyles._();

  // ─── Display / Wordmark ──────────────────────────────────────────────────

  /// `STREAMCAST` — Roboto Condensed Bold, 26sp, UPPERCASE, -1% tracking.
  static TextStyle wordmark({double size = 26, Color? color}) =>
      GoogleFonts.robotoCondensed(
        fontSize: size.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -size * 0.01,
        height: 1.1,
        color: color ?? AppColors.textHeading,
      );

  /// `SECTION HEADER` — Roboto Condensed Bold, 19sp, UPPERCASE.
  static TextStyle sectionHeaderCondensed({Color? color}) =>
      GoogleFonts.robotoCondensed(
        fontSize: 19.sp,
        fontWeight: FontWeight.w700,
        height: 1.15,
        color: color ?? AppColors.textHeading,
      );

  // ─── Headings (Inter) ────────────────────────────────────────────────────

  /// Screen title — 30sp bold. e.g. "What should we call you?"
  static TextStyle h1({Color? color}) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 30.sp,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: color ?? AppColors.textHeading,
  );

  /// Section title — 22sp bold. e.g. "Live Now", "Recommended".
  static TextStyle h2({Color? color}) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: color ?? AppColors.textHeading,
  );

  /// Card / player title — 16sp bold.
  static TextStyle h3({Color? color}) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: color ?? AppColors.textHeading,
  );

  // ─── Body (Inter) ────────────────────────────────────────────────────────

  /// Body — Inter Regular 14sp.
  static TextStyle body({Color? color}) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: color ?? AppColors.textHeading,
  );

  /// Body emphasis — Inter Medium 13sp.
  static TextStyle bodyMedium({Color? color}) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: color ?? AppColors.textHeading,
  );

  /// Muted caption / metadata — Inter Regular 11.5sp.
  static TextStyle caption({Color? color}) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 11.5.sp,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: color ?? AppColors.textBodyMuted,
  );

  /// Button label — Inter Bold 15sp.
  static TextStyle button({Color? color}) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 15.sp,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: color ?? AppColors.onAccent,
  );

  // ─── Mono ────────────────────────────────────────────────────────────────

  /// `// signal:live` — JetBrains Mono 10.5sp, +3% tracking.
  static TextStyle mono({double size = 10.5, Color? color}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: size * 0.03,
        height: 1.3,
        color: color ?? AppColors.textBodyMuted,
      );
}
