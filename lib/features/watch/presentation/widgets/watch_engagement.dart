import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/models/chat_message.dart';
import '../../../../core/models/comment_item.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/sc_avatar.dart';
import '../controllers/watch_controller.dart';

/// The Chat / Comments tab strip.
///
/// The Chat tab is dimmed for recorded videos, where there is no broadcast to
/// chat alongside.
class WatchTabBar extends StatelessWidget {
  const WatchTabBar({
    super.key,
    required this.active,
    required this.chatEnabled,
    required this.onSelect,
  });

  final WatchTab active;
  final bool chatEnabled;
  final ValueChanged<WatchTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLine)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Tab(
              label: 'Chat',
              selected: active == WatchTab.chat,
              enabled: chatEnabled,
              onTap: () => onSelect(WatchTab.chat),
            ),
          ),
          Expanded(
            child: _Tab(
              label: 'Comments',
              selected: active == WatchTab.comments,
              onTap: () => onSelect(WatchTab.comments),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? AppColors.textDim.withValues(alpha: 0.45)
        : selected
        ? AppColors.textPrimary
        : AppColors.textDim;

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.accentSignal : AppColors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.body(color: color).copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

/// One live-chat line: timestamp, orange handle, message — all on one run so
/// it wraps like chat rather than sitting in rigid columns.
class ChatLine extends StatelessWidget {
  const ChatLine({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${message.time}  ',
              style: AppTextStyles.mono(color: AppColors.textDim),
            ),
            TextSpan(
              text: '${message.user} ',
              style: AppTextStyles.bodyMedium(
                color: message.isMine
                    ? AppColors.accentAmber
                    : AppColors.accentSignal,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: message.text, style: AppTextStyles.bodyMedium()),
          ],
        ),
      ),
    );
  }
}

/// A comment with its avatar, age and like count.
class CommentRow extends StatelessWidget {
  const CommentRow({super.key, required this.comment});

  final CommentItem comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimens.gapSm.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScAvatar(size: 30, letter: comment.avatarLetter),
          SizedBox(width: AppDimens.gapMd.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: comment.user,
                        style: AppTextStyles.bodyMedium(
                          color: comment.isMine
                              ? AppColors.accentAmber
                              : AppColors.accentSignal,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: '· ${comment.time}',
                        style: AppTextStyles.caption(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                Text(comment.text, style: AppTextStyles.bodyMedium()),
                SizedBox(height: 3.h),
                Text('${comment.likes} likes', style: AppTextStyles.caption()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The shared composer under both tabs.
class WatchComposer extends StatelessWidget {
  const WatchComposer({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSend,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: TextField(
              controller: controller,
              style: AppTextStyles.bodyMedium(),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodyMedium(color: AppColors.textDim),
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
            onTap: onSend,
            child: SizedBox(
              width: 44.h,
              height: 44.h,
              child: Icon(
                Icons.send_rounded,
                size: 19.r,
                color: AppColors.onAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
