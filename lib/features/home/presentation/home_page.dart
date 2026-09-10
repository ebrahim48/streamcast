import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/models/stream_item.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/widgets/sc_app_bar.dart';
import '../../../core/widgets/sc_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stream_cards.dart';
import '../../add_link/presentation/widgets/add_link_sheet.dart';
import '../../cast/presentation/controllers/cast_controller.dart';
import '../../cast/presentation/widgets/cast_sheet.dart';
import '../../cast/presentation/widgets/casting_banner.dart';
import '../../main/presentation/controllers/main_shell_controller.dart';
import 'controllers/home_controller.dart';
import 'widgets/home_shimmer.dart';

/// The curated feed: what's live right now, then everything else.
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cast = Get.find<CastController>();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          const CastingBanner(),
          Obx(
            () => ScHomeAppBar(
              isCasting: cast.isCasting,
              onAddLink: () => AddLinkSheet.show(),
              onSearch: () =>
                  Get.find<MainShellController>().goTo(ShellTab.explore),
              onCast: () => CastSheet.show(),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const HomeShimmer();
              if (controller.error.value != null) {
                return _FeedError(onRetry: controller.reload);
              }
              return _Feed(controller: controller);
            }),
          ),
        ],
      ),
    );
  }
}

class _Feed extends StatelessWidget {
  const _Feed({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.reload,
      color: AppColors.accentSignal,
      backgroundColor: AppColors.bgSurface,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppDimens.screenPadding.w,
              AppDimens.gapLg.h,
              AppDimens.screenPadding.w,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                tag: '// signal:live',
                title: 'Live Now',
                trailing: controller.liveCountLabel,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: AppDimens.gapMd.h),
              child: _LiveRail(controller: controller),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppDimens.screenPadding.w,
              AppDimens.gapXl.h,
              AppDimens.screenPadding.w,
              0,
            ),
            sliver: const SliverToBoxAdapter(
              child: SectionHeader(
                tag: '// feed:curated',
                title: 'Recommended',
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppDimens.screenPadding.w,
              AppDimens.gapMd.h,
              AppDimens.screenPadding.w,
              AppDimens.gapXl.h,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppDimens.gapMd.h,
                crossAxisSpacing: AppDimens.gapMd.w,
                // Thumbnail plus three text lines; tuned so two-line titles fit
                // without the card clipping.
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate(
                childCount: controller.recommended.length,
                (context, index) {
                  final item = controller.recommended[index];
                  if (item.isSponsored) {
                    return SponsoredCard.grid(onTap: controller.openPremium);
                  }
                  return StreamGridCard(
                    item: item,
                    onTap: () => controller.openStream(item),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveRail extends StatelessWidget {
  const _LiveRail({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 236.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppDimens.screenPadding.w),
        itemCount: controller.liveNow.length,
        separatorBuilder: (_, _) => SizedBox(width: AppDimens.gapMd.w),
        itemBuilder: (context, index) {
          final StreamItem item = controller.liveNow[index];
          return StreamLiveCard(
            item: item,
            onTap: () => controller.openStream(item),
          );
        },
      ),
    );
  }
}

class _FeedError extends StatelessWidget {
  const _FeedError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.gapXl.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, color: AppColors.textDim, size: 34.r),
            SizedBox(height: AppDimens.gapMd.h),
            ScButton(label: 'Retry', expand: false, onPressed: () => onRetry()),
          ],
        ),
      ),
    );
  }
}
