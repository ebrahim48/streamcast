import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/mono_tag.dart';
import '../../../../core/widgets/sc_button.dart';
import '../controllers/cast_controller.dart';

/// The strip that sits above the app bar while a receiver is connected.
///
/// Collapsed it names the device; expanded (`// remote`) it becomes the
/// transport — play/pause, volume, disconnect. It renders nothing at all when
/// no session is active, so screens can mount it unconditionally.
class CastingBanner extends StatelessWidget {
  const CastingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CastController>();

    return Obx(() {
      final device = controller.connectedDevice.value;
      if (device == null) return const SizedBox.shrink();

      return SafeArea(
        bottom: false,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.bgSurface,
            border: Border(bottom: BorderSide(color: AppColors.borderLine)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: controller.toggleRemote,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPadding.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7.r,
                        height: 7.r,
                        decoration: const BoxDecoration(
                          color: AppColors.accentSignal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: AppDimens.gapSm.w),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'Casting to ',
                            style: AppTextStyles.bodyMedium(),
                            children: [
                              TextSpan(
                                text: device.name,
                                style: AppTextStyles.bodyMedium().copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AnimatedRotation(
                        turns: controller.remoteExpanded.value ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 22.r,
                          color: AppColors.textDim,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState: controller.remoteExpanded.value
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity),
                secondChild: _RemotePanel(controller: controller),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _RemotePanel extends StatelessWidget {
  const _RemotePanel({required this.controller});

  final CastController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.screenPadding.w,
        0,
        AppDimens.screenPadding.w,
        AppDimens.gapLg.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MonoTag('// remote', color: AppColors.textDim),
          SizedBox(height: AppDimens.gapMd.h),
          Row(
            children: [
              Material(
                color: AppColors.ctaDefault,
                borderRadius: BorderRadius.circular(8.r),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: controller.togglePlayPause,
                  child: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Icon(
                      controller.isPaused.value
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      size: 20.r,
                      color: AppColors.onAccent,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppDimens.gapMd.w),
              Icon(
                Icons.volume_up_rounded,
                size: 18.r,
                color: AppColors.textDim,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3.h,
                    activeTrackColor: AppColors.textDim,
                    inactiveTrackColor: AppColors.borderLine,
                    thumbColor: AppColors.textPrimary,
                    overlayShape: SliderComponentShape.noOverlay,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                  ),
                  child: Slider(
                    value: controller.volume.value.toDouble(),
                    max: 100,
                    onChanged: (v) => controller.setVolume(v.round()),
                  ),
                ),
              ),
              Text(
                '${controller.volume.value}',
                style: AppTextStyles.caption(),
              ),
            ],
          ),
          SizedBox(height: AppDimens.gapMd.h),
          ScButton(
            label: 'Disconnect',
            variant: ScButtonVariant.outline,
            height: 46,
            onPressed: controller.disconnect,
          ),
        ],
      ),
    );
  }
}
