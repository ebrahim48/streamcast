import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/models/stream_item.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/mono_tag.dart';
import '../../../core/widgets/sc_avatar.dart';
import '../../../core/widgets/sc_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stream_cards.dart';
import '../../ads/presentation/controllers/ad_controller.dart';
import '../../cast/presentation/controllers/cast_controller.dart';
import '../../cast/presentation/widgets/cast_sheet.dart';
import '../../cast/presentation/widgets/casting_banner.dart';
import '../../library/presentation/controllers/library_controller.dart';
import 'controllers/watch_controller.dart';
import 'widgets/watch_engagement.dart';
import 'widgets/watch_player.dart';

/// The player, its metadata, the chat/comments split, and what's up next.
class WatchPage extends GetView<WatchController> {
  const WatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cast = Get.find<CastController>();
    final ads = Get.find<AdController>();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      // The player runs edge to edge with its own floating controls, so the
      // page — not an app bar — owns the status-bar inset. Without this the
      // back button sits under the notch.
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const CastingBanner(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => WatchPlayer(
                        item: controller.current,
                        progress: controller.progress.value,
                        playbackService: controller.playbackService,
                        isCasting: cast.isCasting,
                        onBack: () => Get.back<void>(),
                        onCast: () => CastSheet.show(item: controller.current),
                        onRetry: controller.retry,
                        onUpgrade: controller.openPremium,
                        adBreakShowing: ads.showing.value != null,
                        onPlaybackStarted: controller.onPlaybackStarted,
                        onPlaybackFailed: controller.onPlaybackFailed,
                      ),
                    ),
                    Obx(
                      () => controller.needsDirectCastButton
                          ? _DirectCastBlock(controller: controller)
                          : const SizedBox.shrink(),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppDimens.screenPadding.w,
                        AppDimens.gapLg.h,
                        AppDimens.screenPadding.w,
                        0,
                      ),
                      child: _TitleBlock(controller: controller),
                    ),
                    const Divider(height: 1),
                    _ChannelRow(controller: controller),
                    Obx(
                      () => WatchTabBar(
                        active: controller.tab.value,
                        chatEnabled: controller.supportsChat,
                        onSelect: controller.selectTab,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppDimens.screenPadding.w,
                        AppDimens.gapMd.h,
                        AppDimens.screenPadding.w,
                        AppDimens.gapMd.h,
                      ),
                      child: _TabBody(controller: controller),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimens.screenPadding.w,
                      ),
                      child: Obx(
                        () => WatchComposer(
                          controller: controller.composer,
                          hint: controller.composerHint,
                          onSend: controller.send,
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimens.gapLg.h),
                    const Divider(height: 1),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppDimens.screenPadding.w,
                        AppDimens.gapLg.h,
                        AppDimens.screenPadding.w,
                        AppDimens.gapXl.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(
                            tag: '// up:next',
                            title: 'Recommended',
                          ),
                          SizedBox(height: AppDimens.gapSm.h),
                          _UpNextList(controller: controller),
                        ],
                      ),
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

/// Full-width `Cast to TV` for direct video files, which have no player of
/// their own to cast from.
class _DirectCastBlock extends StatelessWidget {
  const _DirectCastBlock({required this.controller});

  final WatchController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.screenPadding.w,
        AppDimens.gapLg.h,
        AppDimens.screenPadding.w,
        AppDimens.gapSm.h,
      ),
      child: Column(
        children: [
          ScButton(
            label: 'Cast to TV',
            icon: SvgPicture.asset(
              AppAssets.iconCast,
              width: 18.r,
              height: 18.r,
              colorFilter: const ColorFilter.mode(
                AppColors.onAccent,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => CastSheet.show(item: controller.current),
          ),
          SizedBox(height: AppDimens.gapSm.h),
          MonoTag(controller.relayCaption, color: AppColors.textDim),
        ],
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.controller});

  final WatchController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  controller.current.title,
                  style: AppTextStyles.h2().copyWith(fontSize: 20.sp),
                ),
              ),
              InkResponse(
                onTap: () {},
                radius: 20.r,
                child: Icon(
                  Icons.more_vert_rounded,
                  size: 20.r,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimens.gapSm.h),
          Text(controller.headerMeta, style: AppTextStyles.mono()),
          SizedBox(height: AppDimens.gapLg.h),
        ],
      ),
    );
  }
}

class _ChannelRow extends StatelessWidget {
  const _ChannelRow({required this.controller});

  final WatchController controller;

  @override
  Widget build(BuildContext context) {
    final library = Get.find<LibraryController>();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenPadding.w,
        vertical: AppDimens.gapMd.h,
      ),
      child: Row(
        children: [
          const ScAvatar(size: 38),
          SizedBox(width: AppDimens.gapMd.w),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.current.channelName,
                    style: AppTextStyles.h3(),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    controller.current.channelSubscribers,
                    style: AppTextStyles.caption(),
                  ),
                ],
              ),
            ),
          ),
          // Reads the roster inside the Obx closure so the button flips the
          // moment the subscription changes.
          Obx(() {
            final subscribed = library.isSubscribed(
              controller.current.channelName,
            );
            return ScButton(
              label: subscribed ? 'Subscribed' : 'Subscribe',
              variant: subscribed
                  ? ScButtonVariant.primary
                  : ScButtonVariant.outline,
              expand: false,
              height: 40,
              onPressed: controller.toggleSubscribe,
            );
          }),
        ],
      ),
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({required this.controller});

  final WatchController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.tab.value == WatchTab.chat) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final message in controller.chat.toList())
              ChatLine(message: message),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final comment in controller.comments.toList())
            CommentRow(comment: comment),
        ],
      );
    });
  }
}

class _UpNextList extends StatelessWidget {
  const _UpNextList({required this.controller});

  final WatchController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          for (final StreamItem item in controller.upNext.toList())
            if (item.isSponsored)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimens.gapSm.h),
                child: SponsoredCard.row(onTap: controller.openPremium),
              )
            else
              StreamRowCard(
                item: item,
                onTap: () => controller.openStream(item),
              ),
        ],
      ),
    );
  }
}
