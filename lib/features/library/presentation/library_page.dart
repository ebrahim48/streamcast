import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/models/stream_item.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/dashed_empty_box.dart';
import '../../../core/widgets/mono_tag.dart';
import '../../../core/widgets/sc_avatar.dart';
import '../../../core/widgets/stream_cards.dart';
import '../../cast/presentation/widgets/casting_banner.dart';
import '../../profile/presentation/controllers/profile_controller.dart';
import 'controllers/library_controller.dart';

/// Everything the user has watched, liked, or queued — all stored locally.
class LibraryPage extends GetView<LibraryController> {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          const CastingBanner(),
          Expanded(
            child: SafeArea(
              bottom: false,
              child: ListView(
                padding: EdgeInsets.only(bottom: AppDimens.gapXl.h),
                children: [
                  const _ProfileHeader(),
                  const _StudioRow(),
                  const Divider(height: 1),
                  SizedBox(height: AppDimens.gapLg.h),
                  Obx(
                    () => _Rail(
                      tag: '// auto:usage-data',
                      title: 'History',
                      items: controller.history.toList(),
                      emptyMessage: 'Nothing watched yet',
                    ),
                  ),
                  SizedBox(height: AppDimens.gapXl.h),
                  Obx(
                    () => _Rail(
                      tag: '// saved:liked',
                      title: 'Liked',
                      items: controller.liked.toList(),
                      emptyMessage: 'Nothing liked yet',
                    ),
                  ),
                  SizedBox(height: AppDimens.gapXl.h),
                  Obx(
                    () => _Rail(
                      tag: '// saved:queue',
                      title: 'Watch Later',
                      items: controller.watchLater.toList(),
                      emptyMessage: 'Nothing here yet',
                    ),
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final profile = Get.find<ProfileController>();

    return InkWell(
      onTap: () {
        profile.beginEditing();
        Get.toNamed(AppRoutes.editProfile);
      },
      child: Padding(
        padding: EdgeInsets.all(AppDimens.screenPadding.w),
        child: Obx(
          () => Row(
            children: [
              ScAvatar(
                size: 44,
                imagePath: profile.avatarPath.value,
                letter: profile.name.value.isEmpty
                    ? null
                    : profile.name.value[0],
              ),
              SizedBox(width: AppDimens.gapMd.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name.value.isEmpty
                          ? 'Your profile'
                          : profile.name.value,
                      style: AppTextStyles.h2(),
                    ),
                    SizedBox(height: 2.h),
                    const MonoTag('// local profile', color: AppColors.textDim),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textDim,
                size: 22.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Entry point to Creator Studio.
///
/// Only managers and moderators post to the feed, so this is the admin door —
/// deliberately quiet, sitting under the profile rather than in the nav.
class _StudioRow extends StatelessWidget {
  const _StudioRow();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.creatorStudio),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimens.screenPadding.w,
          0,
          AppDimens.screenPadding.w,
          AppDimens.gapLg.h,
        ),
        child: Row(
          children: [
            Icon(
              Icons.dashboard_customize_outlined,
              size: 18.r,
              color: AppColors.accentSignal,
            ),
            SizedBox(width: AppDimens.gapMd.w),
            Expanded(
              child: Text('Creator Studio', style: AppTextStyles.body()),
            ),
            const MonoTag('// role:manager'),
            SizedBox(width: AppDimens.gapSm.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.r,
              color: AppColors.textDim,
            ),
          ],
        ),
      ),
    );
  }
}

/// A titled horizontal rail that collapses to a dashed empty box when the list
/// has nothing in it.
class _Rail extends StatelessWidget {
  const _Rail({
    required this.tag,
    required this.title,
    required this.items,
    required this.emptyMessage,
  });

  final String tag;
  final String title;
  final List<StreamItem> items;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.screenPadding.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MonoTag(tag),
              SizedBox(height: 2.h),
              Text(title, style: AppTextStyles.h2()),
            ],
          ),
        ),
        SizedBox(height: AppDimens.gapMd.h),
        if (items.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPadding.w,
            ),
            child: DashedEmptyBox(message: emptyMessage),
          )
        else
          SizedBox(
            height: 160.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.screenPadding.w,
              ),
              itemCount: items.length,
              separatorBuilder: (_, _) => SizedBox(width: AppDimens.gapMd.w),
              itemBuilder: (context, index) {
                final item = items[index];
                return StreamMiniCard(
                  item: item,
                  onTap: () => Get.toNamed(AppRoutes.watch, arguments: item),
                );
              },
            ),
          ),
      ],
    );
  }
}
