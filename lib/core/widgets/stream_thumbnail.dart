import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';
import 'live_badge.dart';

/// Thumbnail artwork with the overlays every card shares: the live badge, a
/// watcher count, a centred play button and a duration chip.
///
/// **Phase 1 sourcing:** there is no media CDN yet, so the image is fetched by
/// [seed] from a placeholder service. The seed is stable per stream, so a card
/// always shows the same picture. When real artwork lands, only [_imageUrl]
/// changes.
class StreamThumbnail extends StatelessWidget {
  const StreamThumbnail({
    super.key,
    this.seed,
    this.aspectRatio = 16 / 9,
    this.radius = AppDimens.radiusCard,
    this.showPlayButton = false,
    this.playButtonSize = 40,
    this.isLive = false,
    this.liveLabelText,
    this.duration,
    this.overlayFooter,
  });

  /// Stable key for the placeholder image.
  final String? seed;

  final double aspectRatio;
  final double radius;

  /// Draws the translucent circular play control used on recorded cards.
  final bool showPlayButton;
  final double playButtonSize;

  /// Draws the `● Live` pill in the top-left corner.
  final bool isLive;

  /// Watcher count rendered bottom-left, e.g. "184K".
  final String? liveLabelText;

  /// Runtime chip rendered bottom-right, e.g. "14:02".
  final String? duration;

  /// Extra overlay pinned to the bottom of the frame.
  final Widget? overlayFooter;

  String get _imageUrl =>
      'https://picsum.photos/seed/${seed ?? 'streamcast'}/640/360';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius.r),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: _imageUrl,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 180),
              placeholder: (_, _) => const _ThumbFallback(),
              errorWidget: (_, _, _) => const _ThumbFallback(),
            ),

            // Darken the lower half so overlaid text stays readable over any
            // image the placeholder service happens to return.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.transparent, Color(0x99000000)],
                ),
              ),
            ),

            if (isLive)
              Positioned(
                top: AppDimens.gapSm.h,
                left: AppDimens.gapSm.w,
                child: const LiveBadge(),
              ),

            if (liveLabelText != null)
              Positioned(
                left: AppDimens.gapSm.w,
                bottom: AppDimens.gapSm.h,
                child: Text(
                  liveLabelText!,
                  style: AppTextStyles.bodyMedium(color: AppColors.textPrimary),
                ),
              ),

            if (duration != null)
              Positioned(
                right: AppDimens.gapSm.w,
                bottom: AppDimens.gapSm.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    duration!,
                    style: AppTextStyles.caption(color: AppColors.textPrimary),
                  ),
                ),
              ),

            if (showPlayButton)
              Center(
                child: Container(
                  width: playButtonSize.r,
                  height: playButtonSize.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.black.withValues(alpha: 0.42),
                    border: Border.all(
                      color: AppColors.textPrimary.withValues(alpha: 0.85),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: (playButtonSize * 0.6).r,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

            if (overlayFooter != null)
              Positioned(left: 0, right: 0, bottom: 0, child: overlayFooter!),
          ],
        ),
      ),
    );
  }
}

/// Shown while the image loads and whenever it fails — including offline, where
/// it is the only thing the user sees, so it has to look intentional.
class _ThumbFallback extends StatelessWidget {
  const _ThumbFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfacePanel2, AppColors.surfacePanel],
        ),
      ),
      child: Center(
        child: Icon(Icons.tv_rounded, color: AppColors.borderLine, size: 28),
      ),
    );
  }
}
