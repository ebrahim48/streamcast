import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/sc_button.dart';
import '../../data/repositories/add_link_repository.dart';
import '../../domain/services/link_parser_service.dart';
import '../controllers/add_link_controller.dart';

/// `ADD TO FEED` — paste a link, name it, post it.
///
/// Only managers and moderators reach this sheet; regular users browse, watch,
/// cast and comment.
class AddLinkSheet extends StatefulWidget {
  const AddLinkSheet({super.key});

  static Future<void> show() => Get.bottomSheet<void>(
    const AddLinkSheet(),
    isScrollControlled: true,
    backgroundColor: AppColors.bgSurface,
  );

  @override
  State<AddLinkSheet> createState() => _AddLinkSheetState();
}

class _AddLinkSheetState extends State<AddLinkSheet> {
  /// Unique per sheet instance.
  ///
  /// Without a tag, reopening the sheet while the previous one is still
  /// animating out would have the old sheet's dispose delete the new sheet's
  /// controller.
  late final String _tag = 'add_link_${identityHashCode(this)}';

  /// Scoped to the sheet: it owns three text controllers that should die with
  /// it, not linger for the session.
  late final AddLinkController controller = Get.put(
    AddLinkController(
      linkParserService: LinkParserService(
        addLinkRepository: AddLinkRepository(
          storageService: Get.find<StorageService>(),
        ),
      ),
    ),
    tag: _tag,
  );

  @override
  void dispose() {
    // Tied to the widget's lifetime, not the route's future. The future
    // completes the moment pop() is called, but the sheet stays mounted
    // through its exit animation — disposing the text controllers at that
    // point is what threw "A TextEditingController was used after being
    // disposed".
    Get.delete<AddLinkController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Lift the sheet clear of the keyboard while the user types.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppDimens.screenPadding.w,
            AppDimens.gapMd.h,
            AppDimens.screenPadding.w,
            AppDimens.gapXl.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderLine,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              SizedBox(height: AppDimens.gapLg.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'ADD TO FEED',
                      style: AppTextStyles.sectionHeaderCondensed(),
                    ),
                  ),
                  InkResponse(
                    onTap: () => Get.back<void>(),
                    radius: 20.r,
                    child: Icon(
                      Icons.close_rounded,
                      size: 20.r,
                      color: AppColors.textDim,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimens.gapLg.h),
              _Field(
                controller: controller.urlController,
                hint: 'Paste a video link (YouTube, Kick, Vimeo, Twitch...)',
                maxLines: 2,
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: AppDimens.gapSm.h),
              Obx(
                () => _DetectionChip(
                  label: controller.detectionLabel,
                  detected: controller.platform.value != null,
                ),
              ),
              SizedBox(height: AppDimens.gapMd.h),
              _Field(controller: controller.titleController, hint: 'Title'),
              SizedBox(height: AppDimens.gapMd.h),
              _Field(
                controller: controller.channelController,
                hint: 'Creator / channel name',
              ),
              SizedBox(height: AppDimens.gapLg.h),
              Obx(
                () => Text(
                  controller.playbackNote,
                  style: AppTextStyles.caption(),
                ),
              ),
              SizedBox(height: AppDimens.gapXl.h),
              Obx(
                () => ScButton(
                  label: controller.isSaving.value
                      ? 'Adding...'
                      : 'Add to Feed',
                  enabled:
                      controller.canSubmit.value && !controller.isSaving.value,
                  onPressed: () async {
                    final item = await controller.submit();
                    if (item == null) return;
                    Get.back<void>();
                    Get.snackbar(
                      'Added to feed',
                      item.title,
                      backgroundColor: AppColors.bgSurfaceElevated,
                      colorText: AppColors.textPrimary,
                      margin: EdgeInsets.all(AppDimens.gapMd.w),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows what the pasted URL was recognised as — the sheet's only feedback
/// that a link is usable before the user commits to it.
class _DetectionChip extends StatelessWidget {
  const _DetectionChip({required this.label, required this.detected});

  /// Both values are passed in rather than read here: this build runs outside
  /// the parent's Obx closure, so reads at this point would not be tracked.
  final String label;
  final bool detected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.bgSurfaceElevated,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: detected ? AppColors.accentSignal : AppColors.borderLine,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.mono(
          color: detected ? AppColors.accentSignal : AppColors.textDim,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.body(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body(color: AppColors.textDim),
      ),
    );
  }
}
