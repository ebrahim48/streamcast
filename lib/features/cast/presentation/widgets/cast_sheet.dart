import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/models/cast_device.dart';
import '../../../../core/models/stream_item.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/mono_tag.dart';
import '../../../../core/widgets/sc_button.dart';
import '../../domain/services/cast_service.dart';
import '../controllers/cast_controller.dart';

/// `// signal:out` — the device picker.
///
/// One sheet, four states driven by [CastState]: scanning, empty, the device
/// list, and connected. They share a header so the sheet doesn't jump as
/// discovery progresses.
class CastSheet extends StatefulWidget {
  const CastSheet({super.key, this.item});

  /// The stream to start on the receiver once one is picked.
  ///
  /// Null when the sheet is opened from the feed rather than a player — the
  /// user is choosing a device ahead of picking something to watch.
  final StreamItem? item;

  /// Opens the sheet and kicks off discovery.
  static Future<void> show({StreamItem? item}) => Get.bottomSheet<void>(
    CastSheet(item: item),
    isScrollControlled: true,
    backgroundColor: AppColors.bgSurface,
  );

  @override
  State<CastSheet> createState() => _CastSheetState();
}

class _CastSheetState extends State<CastSheet> {
  final CastController controller = Get.find<CastController>();

  @override
  void initState() {
    super.initState();
    controller.startDiscovery();
  }

  @override
  void dispose() {
    // Tied to the widget's lifetime, not the route's future. The future
    // completes as soon as pop() is called, while the sheet is still animating
    // out — resetting the state there blanked the sheet's contents before it
    // had finished sliding away.
    controller.dismissSheet();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return SafeArea(
      top: false,
      child: Padding(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MonoTag('// signal:out'),
                      SizedBox(height: 2.h),
                      Text('Cast to device', style: AppTextStyles.h2()),
                    ],
                  ),
                ),
                _CloseButton(onTap: () => Get.back<void>()),
              ],
            ),
            if (item != null) ...[
              SizedBox(height: AppDimens.gapMd.h),
              _AvailabilityNote(
                availability: controller.availabilityFor(item),
                platform: item.platform,
              ),
            ],
            SizedBox(height: AppDimens.gapXl.h),
            Obx(() => _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() => switch (controller.state.value) {
    CastState.searching => const _Searching(),
    CastState.notFound => _NotFound(
      onRetry: controller.startDiscovery,
      unsupported: !controller.isSupported,
    ),
    CastState.found || CastState.connected => _DeviceList(
      controller: controller,
      item: widget.item,
    ),
    CastState.idle => const SizedBox.shrink(),
  };
}

/// Says up front how this stream will reach the TV, so a viewer isn't left
/// wondering why a Twitch stream behaves differently from a YouTube one.
class _AvailabilityNote extends StatelessWidget {
  const _AvailabilityNote({required this.availability, required this.platform});

  final CastAvailability availability;
  final StreamPlatform platform;

  @override
  Widget build(BuildContext context) {
    final (text, tone) = switch (availability) {
      CastAvailability.castable => (
        'Ready to cast — StreamCast sends the stream straight to your TV.',
        AppColors.textDim,
      ),
      CastAvailability.nativeOnly => (
        '${platform.label} casts from its own button inside the player.',
        AppColors.textDim,
      ),
      CastAvailability.needsRelay => (
        "${platform.label} has no castable stream URL of its own. The "
            'StreamCast relay that converts it is not switched on yet, so this '
            'one will connect but not play.',
        AppColors.accentSignal,
      ),
    };

    return Text(text, style: AppTextStyles.caption(color: tone));
  }
}

class _Searching extends StatelessWidget {
  const _Searching();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimens.gapXl.h),
      child: Row(
        children: [
          SizedBox(
            width: 18.r,
            height: 18.r,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accentSignal,
            ),
          ),
          SizedBox(width: AppDimens.gapMd.w),
          Flexible(
            child: Text(
              'Searching for devices...',
              style: AppTextStyles.body(color: AppColors.textDim),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onRetry, this.unsupported = false});

  final VoidCallback onRetry;

  /// True on a platform with no Cast SDK at all — desktop, or a test run.
  final bool unsupported;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimens.gapXl.h),
      child: Column(
        children: [
          Icon(
            Icons.desktop_windows_outlined,
            color: AppColors.textDim,
            size: 30.r,
          ),
          SizedBox(height: AppDimens.gapMd.h),
          Text(
            unsupported
                ? 'Casting is available on Android and iOS.'
                : 'No devices found — make sure your TV is on the same Wi-Fi '
                      'network.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.textDim),
          ),
          if (!unsupported) ...[
            SizedBox(height: AppDimens.gapLg.h),
            ScButton(
              label: 'Search again',
              variant: ScButtonVariant.outline,
              expand: false,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}

class _DeviceList extends StatelessWidget {
  const _DeviceList({required this.controller, this.item});

  final CastController controller;
  final StreamItem? item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final device in controller.devices.toList())
          _DeviceRow(
            device: device,
            isConnected: controller.connectedDevice.value?.id == device.id,
            onTap: () async {
              await controller.connect(device, item: item);
              Get.back<void>();
            },
          ),
        SizedBox(height: AppDimens.gapMd.h),
        Text(
          "Don't see your device?",
          style: AppTextStyles.body(color: AppColors.textDim),
        ),
      ],
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.device,
    required this.isConnected,
    required this.onTap,
  });

  final CastDevice device;
  final bool isConnected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusCard.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.gapMd.h),
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.bgSurfaceElevated,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.borderLine),
              ),
              child: Icon(
                Icons.tv_rounded,
                size: 19.r,
                color: AppColors.accentSignal,
              ),
            ),
            SizedBox(width: AppDimens.gapMd.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name, style: AppTextStyles.h3()),
                  SizedBox(height: 2.h),
                  Text(device.subtitle, style: AppTextStyles.mono()),
                ],
              ),
            ),
            if (isConnected)
              Icon(
                Icons.check_rounded,
                size: 20.r,
                color: AppColors.accentSignal,
              ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22.r,
      child: Container(
        width: 32.r,
        height: 32.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.bgSurfaceElevated,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderLine),
        ),
        child: Icon(Icons.close_rounded, size: 17.r),
      ),
    );
  }
}
