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
import '../../../core/widgets/platform_chip.dart';
import '../../../core/widgets/stream_cards.dart';
import '../../cast/presentation/widgets/casting_banner.dart';
import 'controllers/explore_controller.dart';

/// Search across every platform in the feed, with a filter row on top.
class ExplorePage extends GetView<ExploreController> {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          const CastingBanner(),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimens.screenPadding.w,
                AppDimens.gapSm.h,
                AppDimens.screenPadding.w,
                AppDimens.gapMd.h,
              ),
              child: _SearchField(controller: controller),
            ),
          ),
          _FilterRow(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.results.isEmpty && !controller.isLoading.value) {
                return const _NoResults();
              }
              return _Results(controller: controller);
            }),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final ExploreController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.inputHeight.h,
      child: TextField(
        controller: controller.searchController,
        style: AppTextStyles.body(),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => controller.search(),
        decoration: InputDecoration(
          hintText: 'Search streams, channels, platforms',
          hintStyle: AppTextStyles.body(color: AppColors.textDim),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.gapMd.w),
            child: SvgPicture.asset(
              AppAssets.iconSearch,
              width: 18.r,
              height: 18.r,
              colorFilter: const ColorFilter.mode(
                AppColors.textDim,
                BlendMode.srcIn,
              ),
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 44.w),
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.controller});

  final ExploreController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: Obx(() {
        // Read the selection here, in the Obx closure — itemBuilder runs after
        // the closure returns, so a read inside it would never be tracked.
        final StreamPlatform? selected = controller.platform.value;

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppDimens.screenPadding.w),
          itemCount: controller.filters.length,
          separatorBuilder: (_, _) => SizedBox(width: AppDimens.gapSm.w),
          itemBuilder: (context, index) {
            final StreamPlatform? platform = controller.filters[index];
            return PlatformChip(
              label: platform?.filterLabel ?? 'All',
              selected: selected == platform,
              onTap: () => controller.selectPlatform(platform),
            );
          },
        );
      }),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.controller});

  final ExploreController controller;

  @override
  Widget build(BuildContext context) {
    // Snapshot for the sliver delegate, whose builder runs outside any Obx.
    final results = controller.results.toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppDimens.screenPadding.w,
            AppDimens.gapLg.h,
            AppDimens.screenPadding.w,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MonoTag('//query:results'),
                  SizedBox(height: 2.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          controller.resultsTitle,
                          style: AppTextStyles.h2(),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 3.h),
                        child: Text(
                          controller.countLabel,
                          style: AppTextStyles.caption(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
              childAspectRatio: 0.78,
            ),
            delegate: SliverChildBuilderDelegate(childCount: results.length, (
              context,
              index,
            ) {
              final item = results[index];
              return StreamGridCard(
                item: item,
                onTap: () => controller.openStream(item),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.gapXl.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MonoTag('//query:empty'),
            SizedBox(height: AppDimens.gapSm.h),
            Text(
              'Nothing matches that search.',
              style: AppTextStyles.body(color: AppColors.textDim),
            ),
          ],
        ),
      ),
    );
  }
}
