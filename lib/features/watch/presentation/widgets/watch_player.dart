import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/models/stream_item.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/sc_button.dart';
import '../../../ads/presentation/widgets/ad_overlay.dart';
import '../../domain/services/playback_service.dart';
import 'stream_player_view.dart';

/// The 16:9 player frame and its non-playing states.
///
/// Live and recorded sources hand off to [StreamPlayerView], which runs the
/// real engine. Offline and error replace the frame entirely, since there is
/// nothing to play behind them. The free-tier ad break is layered over the
/// frame so the page underneath stays readable while it runs.
class WatchPlayer extends StatelessWidget {
  const WatchPlayer({
    super.key,
    required this.item,
    required this.progress,
    required this.playbackService,
    required this.onBack,
    required this.onCast,
    required this.onRetry,
    required this.onUpgrade,
    this.adBreakShowing = false,
    this.onPlaybackStarted,
    this.onPlaybackFailed,
    this.isCasting = false,
  });

  final StreamItem item;

  /// Playback position, 0–1.
  final double progress;

  final PlaybackService playbackService;

  final VoidCallback onBack;
  final VoidCallback onCast;
  final VoidCallback onRetry;

  /// Opens Premium from the ad break.
  final VoidCallback onUpgrade;

  /// True while an ad break covers the frame; holds native playback.
  final bool adBreakShowing;

  final VoidCallback? onPlaybackStarted;
  final VoidCallback? onPlaybackFailed;

  final bool isCasting;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: switch (item.status) {
                StreamStatus.offline => _OfflineFrame(item: item),
                StreamStatus.error => _ErrorFrame(onRetry: onRetry),
                _ => StreamPlayerView(
                  item: item,
                  playbackService: playbackService,
                  paused: adBreakShowing,
                  onStarted: onPlaybackStarted,
                  onFailed: onPlaybackFailed,
                ),
              },
            ),
            AdOverlay(onUpgrade: onUpgrade),
            Positioned(
              top: AppDimens.gapMd.h,
              left: AppDimens.gapMd.w,
              child: _FrameButton(
                icon: Icons.chevron_left_rounded,
                label: 'Back',
                onTap: onBack,
              ),
            ),
            Positioned(
              top: AppDimens.gapMd.h,
              right: AppDimens.gapMd.w,
              child: _FrameButton(
                asset: AppAssets.iconCast,
                label: 'Cast to device',
                color: isCasting ? AppColors.accentSignal : null,
                onTap: onCast,
              ),
            ),
          ],
        ),
        if (item.status == StreamStatus.live || item.status == StreamStatus.vod)
          _ProgressBar(item: item, progress: progress),
      ],
    );
  }
}

/// The scrub line under the frame, with `// live` or the runtime on its right.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.item, required this.progress});

  final StreamItem item;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 3.h,
            child: Stack(
              children: [
                const ColoredBox(
                  color: AppColors.borderLine,
                  child: SizedBox.expand(),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: const ColoredBox(
                    color: AppColors.accentSignal,
                    child: SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.gapSm.w),
          child: item.isLive
              ? Text(
                  '// live',
                  style: AppTextStyles.mono(color: AppColors.accentSignal),
                )
              : Text(item.duration ?? '', style: AppTextStyles.caption()),
        ),
      ],
    );
  }
}

class _OfflineFrame extends StatelessWidget {
  const _OfflineFrame({required this.item});

  final StreamItem item;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bgSurfaceElevated,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.desktop_windows_outlined,
            size: 28.r,
            color: AppColors.textDim,
          ),
          SizedBox(height: AppDimens.gapMd.h),
          Text(
            "This channel isn't live right now.",
            style: AppTextStyles.body(color: AppColors.textDim),
          ),
          SizedBox(height: AppDimens.gapSm.h),
          Text(
            '// ${item.platform.monoToken}:offline',
            style: AppTextStyles.mono(color: AppColors.accentSignal),
          ),
        ],
      ),
    );
  }
}

class _ErrorFrame extends StatelessWidget {
  const _ErrorFrame({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bgSurfaceElevated,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Couldn't load this stream",
            style: AppTextStyles.body(color: AppColors.textDim),
          ),
          SizedBox(height: AppDimens.gapMd.h),
          ScButton(
            label: 'Retry',
            expand: false,
            height: 40,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

/// Circular control floating over the player frame.
class _FrameButton extends StatelessWidget {
  const _FrameButton({
    this.icon,
    this.asset,
    required this.label,
    this.color,
    required this.onTap,
  });

  final IconData? icon;
  final String? asset;

  /// Spoken name for the control.
  final String label;

  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: asset != null
                ? SvgPicture.asset(
                    asset!,
                    width: 20.r,
                    height: 20.r,
                    colorFilter: ColorFilter.mode(
                      color ?? AppColors.textPrimary,
                      BlendMode.srcIn,
                    ),
                  )
                : Icon(icon, size: 22.r, color: color ?? AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
