import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/mono_tag.dart';
import '../../../core/widgets/sc_app_bar.dart';
import '../../../core/widgets/sc_avatar.dart';
import '../../../core/widgets/sc_button.dart';
import 'controllers/profile_controller.dart';

/// Change the display name and photo. Both stay on the device.
class EditProfilePage extends GetView<ProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: const ScBackAppBar(title: 'Edit Profile'),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppDimens.screenPadding.w,
          AppDimens.gapXl.h,
          AppDimens.screenPadding.w,
          AppDimens.gapXl.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Obx(
                () => _AvatarPicker(
                  imagePath: controller.avatarPath.value,
                  letter: controller.name.value.isEmpty
                      ? null
                      : controller.name.value[0],
                  onTap: controller.pickAvatar,
                ),
              ),
            ),
            SizedBox(height: AppDimens.gapMd.h),
            const Center(
              child: MonoTag(
                '// tap to choose photo',
                color: AppColors.textDim,
              ),
            ),
            SizedBox(height: AppDimens.gapXl.h),
            const MonoTag('// display name'),
            SizedBox(height: AppDimens.gapSm.h),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: AppDimens.inputHeight.h,
                    child: TextField(
                      controller: controller.nameField,
                      style: AppTextStyles.body(),
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppDimens.gapLg.w,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusInput.r,
                          ),
                          borderSide: BorderSide(
                            color: controller.showNameError.value
                                ? AppColors.accentSignal
                                : AppColors.borderLine,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (controller.showNameError.value) ...[
                    SizedBox(height: AppDimens.gapSm.h),
                    Text(
                      AppStrings.nameEmptyError,
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.accentSignal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: AppDimens.gapLg.h),
            ScButton(
              label: AppStrings.save,
              onPressed: () async {
                if (await controller.save()) Get.back<void>();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar with the orange camera affordance clipped to its lower-right.
class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.imagePath,
    required this.letter,
    required this.onTap,
  });

  final String? imagePath;
  final String? letter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 60.r,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ScAvatar(size: 96, imagePath: imagePath, letter: letter),
          Positioned(
            right: 0,
            bottom: 2.h,
            child: Container(
              width: 30.r,
              height: 30.r,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.ctaDefault,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_camera_rounded,
                size: 16.r,
                color: AppColors.onAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
