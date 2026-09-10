import 'package:flutter/material.dart';

/// StreamCast color palette.
///
/// Two layers, exactly as defined in the design system:
/// - **Primitives** — the raw brand ramp (`ink`, `signal`, `amber`, …)
/// - **Semantic aliases** — role-based names the UI should prefer
///   (`bgPrimary`, `ctaDefault`, `badgeLive`, …)
///
/// Always reach for a semantic alias in feature code; primitives exist so the
/// ramp can be retuned in one place.
///
/// ```dart
/// Container(
///   color: AppColors.bgSurface,
///   child: Text('Live Now', style: TextStyle(color: AppColors.textHeading)),
/// )
/// ```
class AppColors {
  AppColors._();

  // ─── Primitives ──────────────────────────────────────────────────────────

  /// App background. `#0B0E14`
  static const Color ink = Color(0xFF0B0E14);

  /// Cards, panels, bottom nav. `#12161F`
  static const Color surfacePanel = Color(0xFF12161F);

  /// Elevated surface — inputs, sheets, chips. `#181D29`
  static const Color surfacePanel2 = Color(0xFF181D29);

  /// Dividers, borders, outlines. `#232938`
  static const Color borderLine = Color(0xFF232938);

  /// Primary text. `#F2EFE9`
  static const Color textPrimary = Color(0xFFF2EFE9);

  /// Muted metadata text. `#8B93A6`
  static const Color textDim = Color(0xFF8B93A6);

  /// Brand orange — CTA, live badge, active nav. `#FF6B35`
  static const Color accentSignal = Color(0xFFFF6B35);

  /// Pressed / disabled orange. `#7A3A21`
  static const Color accentSignalDim = Color(0xFF7A3A21);

  /// Premium tier amber. `#E8B84B`
  static const Color accentAmber = Color(0xFFE8B84B);

  /// Reserved accent. `#3E6259`
  static const Color accentTeal = Color(0xFF3E6259);

  // ─── Semantic aliases ────────────────────────────────────────────────────

  static const Color bgPrimary = ink;
  static const Color bgSurface = surfacePanel;
  static const Color bgSurfaceElevated = surfacePanel2;

  static const Color textHeading = textPrimary;
  static const Color textBodyMuted = textDim;

  static const Color ctaDefault = accentSignal;
  static const Color ctaPressed = accentSignalDim;

  static const Color badgeLive = accentSignal;
  static const Color badgePremium = accentAmber;

  // ─── Utility ─────────────────────────────────────────────────────────────

  static const Color transparent = Colors.transparent;
  static const Color black = Color(0xFF000000);

  /// Text that sits on top of a filled [ctaDefault] / [badgePremium] surface.
  static const Color onAccent = Color(0xFF0B0E14);

  static Color shadowSoft = Colors.black.withValues(alpha: 0.35);
  static Color scrimStrong = Colors.black.withValues(alpha: 0.72);
}
