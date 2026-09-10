import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/stream_item.dart';
import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';
import '../utils/formatters.dart';
import 'stream_thumbnail.dart';

/// Wide card for the Live Now rail on Home.
class StreamLiveCard extends StatelessWidget {
  const StreamLiveCard({super.key, required this.item, this.onTap});

  final StreamItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 268.w,
      child: _CardShell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamThumbnail(
              seed: item.thumbnailSeed,
              isLive: true,
              liveLabelText: item.viewersLive == null
                  ? null
                  : Formatters.compactCount(item.viewersLive!),
              radius: AppDimens.radiusCard,
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(AppDimens.gapMd.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h3(),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      '${item.channelName}  ·  ${item.platform.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two-per-row card for Recommended and Explore results.
class StreamGridCard extends StatelessWidget {
  const StreamGridCard({super.key, required this.item, this.onTap});

  final StreamItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamThumbnail(
            seed: item.thumbnailSeed,
            showPlayButton: true,
            isLive: item.isLive,
            duration: item.duration,
          ),
          Flexible(
            child: Padding(
              padding: EdgeInsets.all(AppDimens.gapMd.w - 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium().copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    item.channelName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    Formatters.metaLine(
                      isLive: item.isLive,
                      viewersLive: item.viewersLive,
                      views: item.views,
                      publishedAt: item.publishedAt,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal row used by the watch page's up-next list.
class StreamRowCard extends StatelessWidget {
  const StreamRowCard({super.key, required this.item, this.onTap});

  final StreamItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusCard.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.gapSm.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120.w,
              child: StreamThumbnail(
                seed: item.thumbnailSeed,
                isLive: item.isLive,
                duration: item.duration,
                radius: 8,
              ),
            ),
            SizedBox(width: AppDimens.gapMd.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(item.channelName, style: AppTextStyles.caption()),
                  SizedBox(height: 2.h),
                  Text(
                    Formatters.metaLine(
                      isLive: item.isLive,
                      viewersLive: item.viewersLive,
                      views: item.views,
                      publishedAt: item.publishedAt,
                    ),
                    style: AppTextStyles.caption(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact card for the Library's History and Liked rails.
class StreamMiniCard extends StatelessWidget {
  const StreamMiniCard({super.key, required this.item, this.onTap});

  final StreamItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148.w,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamThumbnail(
              seed: item.thumbnailSeed,
              isLive: item.isLive,
              radius: 8,
            ),
            SizedBox(height: AppDimens.gapSm.h),
            Flexible(
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium().copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(item.platform.label, style: AppTextStyles.caption()),
          ],
        ),
      ),
    );
  }
}

/// Shared card chrome: panel fill, hairline border, ink ripple.
class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCard.r),
        side: const BorderSide(color: AppColors.borderLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: child),
    );
  }
}

/// The promo card that replaces a feed slot for free-tier users.
///
/// Two shapes ship: [SponsoredCard.grid] sits in the Recommended grid,
/// [SponsoredCard.row] in the watch page's up-next list. Both open Premium.
///
/// The card is the one place in a feed that isn't content, so it carries the
/// premium amber instead of the brand orange — the chip, the icon and a warmed
/// border set it apart from the streams around it without shouting.
class SponsoredCard extends StatelessWidget {
  const SponsoredCard.grid({super.key, this.onTap}) : _isRow = false;
  const SponsoredCard.row({super.key, this.onTap}) : _isRow = true;

  final bool _isRow;

  /// Opens Premium. Wired on every surface the card appears.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCard.r),
        side: BorderSide(color: AppColors.badgePremium.withValues(alpha: 0.32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.badgePremium.withValues(alpha: 0.12),
        child: Padding(
          padding: EdgeInsets.all(AppDimens.gapMd.w),
          child: _isRow ? _rowBody() : _gridBody(),
        ),
      ),
    );
  }

  Widget _gridBody() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      const _SponsoredChip(),
      SizedBox(height: AppDimens.gapMd.h),
      Center(
        child: Icon(
          Icons.tv_rounded,
          color: AppColors.badgePremium,
          size: 34.r,
        ),
      ),
      SizedBox(height: AppDimens.gapMd.h),
      Text(
        'Cast to any TV, ad-free — try StreamCast Premium',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyMedium().copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 13.5.sp,
        ),
      ),
      SizedBox(height: 5.h),
      Text('Ad · 7-day trial', style: AppTextStyles.caption()),
    ],
  );

  Widget _rowBody() => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        width: 46.r,
        height: 46.r,
        decoration: BoxDecoration(
          color: AppColors.bgSurfaceElevated,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: AppColors.badgePremium.withValues(alpha: 0.55),
          ),
        ),
        child: Icon(
          Icons.desktop_windows_outlined,
          color: AppColors.badgePremium,
          size: 22.r,
        ),
      ),
      SizedBox(width: AppDimens.gapMd.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SponsoredChip(),
            SizedBox(height: 5.h),
            Text(
              'Watch ad-free and cast without limits',
              style: AppTextStyles.body().copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 3.h),
            Text(
              'StreamCast Premium · from \$2.99',
              style: AppTextStyles.mono(),
            ),
          ],
        ),
      ),
    ],
  );
}

/// The amber `Sponsored` pill. Labels the card as an ad, in the premium tier's
/// own colour rather than the muted grey used for stream metadata.
class _SponsoredChip extends StatelessWidget {
  const _SponsoredChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.badgePremium.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: AppColors.badgePremium.withValues(alpha: 0.65),
        ),
      ),
      child: Text(
        'Sponsored',
        style: AppTextStyles.caption(color: AppColors.badgePremium),
      ),
    );
  }
}
