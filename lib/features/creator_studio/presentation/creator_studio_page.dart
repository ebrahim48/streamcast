import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/models/team_member.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/dashed_empty_box.dart';
import '../../../core/widgets/mono_tag.dart';
import '../../../core/widgets/sc_app_bar.dart';
import '../../../core/widgets/sc_avatar.dart';
import '../../add_link/presentation/widgets/add_link_sheet.dart';
import 'controllers/creator_studio_controller.dart';

/// `// role:manager` — post links and manage who else can.
///
/// This is the admin surface behind the curated feed: regular users never
/// reach it.
class CreatorStudioPage extends GetView<CreatorStudioController> {
  const CreatorStudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: const ScBackAppBar(title: 'Creator Studio', condensed: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppDimens.screenPadding.w,
          AppDimens.gapSm.h,
          AppDimens.screenPadding.w,
          AppDimens.gapXl.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MonoTag('// ROLE:MANAGER'),
            SizedBox(height: AppDimens.gapMd.h),
            _AddLinkCard(onTap: () => AddLinkSheet.show()),
            SizedBox(height: AppDimens.gapXl.h),
            const MonoTag('// TEAM:ACCESS'),
            SizedBox(height: AppDimens.gapSm.h),
            Text('MANAGE TEAM', style: AppTextStyles.sectionHeaderCondensed()),
            SizedBox(height: AppDimens.gapMd.h),
            _ManagerCard(manager: controller.manager),
            SizedBox(height: AppDimens.gapLg.h),
            Text(
              'Moderators',
              style: AppTextStyles.body(color: AppColors.textDim),
            ),
            SizedBox(height: AppDimens.gapSm.h),
            Obx(
              () => controller.moderators.isEmpty
                  ? const DashedEmptyBox(
                      message: 'No moderators yet — add one below',
                    )
                  : Column(
                      children: [
                        for (final m in controller.moderators.toList())
                          _ModeratorRow(
                            member: m,
                            onRemove: () => controller.removeModerator(m.id),
                          ),
                      ],
                    ),
            ),
            SizedBox(height: AppDimens.gapLg.h),
            _AddModeratorRow(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _AddLinkCard extends StatelessWidget {
  const _AddLinkCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCard.r),
        side: const BorderSide(color: AppColors.borderLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppDimens.gapLg.w),
          child: Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.ctaDefault,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 21.r,
                  color: AppColors.onAccent,
                ),
              ),
              SizedBox(width: AppDimens.gapMd.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add a new link', style: AppTextStyles.h3()),
                    SizedBox(height: 2.h),
                    Text(
                      'Post a live stream or video to the feed',
                      style: AppTextStyles.caption(),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.r,
                color: AppColors.textDim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManagerCard extends StatelessWidget {
  const _ManagerCard({required this.manager});

  final TeamMember manager;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimens.gapMd.w),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard.r),
        border: Border.all(color: AppColors.accentSignal),
      ),
      child: Row(
        children: [
          ScAvatar(
            size: 38,
            letter: manager.name[0],
            background: AppColors.accentSignalDim,
            foreground: AppColors.textPrimary,
          ),
          SizedBox(width: AppDimens.gapMd.w),
          Expanded(child: Text(manager.name, style: AppTextStyles.h3())),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.ctaDefault,
              borderRadius: BorderRadius.circular(AppDimens.radiusPill.r),
            ),
            child: Text(
              manager.role.label,
              style: AppTextStyles.caption(
                color: AppColors.onAccent,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeratorRow extends StatelessWidget {
  const _ModeratorRow({required this.member, required this.onRemove});

  final TeamMember member;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimens.gapSm.h),
      padding: EdgeInsets.all(AppDimens.gapMd.w),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard.r),
        border: Border.all(color: AppColors.borderLine),
      ),
      child: Row(
        children: [
          ScAvatar(size: 34, letter: member.name[0]),
          SizedBox(width: AppDimens.gapMd.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurfaceElevated,
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: AppColors.borderLine),
                  ),
                  child: Text(
                    member.role.label,
                    style: AppTextStyles.caption(),
                  ),
                ),
              ],
            ),
          ),
          InkResponse(
            onTap: onRemove,
            radius: 20.r,
            child: Icon(
              Icons.more_vert_rounded,
              size: 19.r,
              color: AppColors.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddModeratorRow extends StatelessWidget {
  const _AddModeratorRow({required this.controller});

  final CreatorStudioController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46.h,
            child: TextField(
              controller: controller.moderatorField,
              style: AppTextStyles.body(),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => controller.addModerator(),
              decoration: InputDecoration(
                hintText: 'Channel / creator name',
                hintStyle: AppTextStyles.body(color: AppColors.textDim),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppDimens.gapLg.w,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AppDimens.gapSm.w),
        Material(
          color: AppColors.ctaDefault,
          borderRadius: BorderRadius.circular(AppDimens.radiusButton.r),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: controller.addModerator,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.gapXl.w,
                vertical: 13.h,
              ),
              child: Text('Add', style: AppTextStyles.button()),
            ),
          ),
        ),
      ],
    );
  }
}
