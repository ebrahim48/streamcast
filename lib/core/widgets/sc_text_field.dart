import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';

/// A labelled form field: `Email *` above the box, the error line below it.
///
/// The error is rendered under the field rather than through
/// [InputDecoration.errorText] so the box keeps its exact 52dp height and the
/// message carries the brand orange, matching the onboarding name field.
class ScTextField extends StatelessWidget {
  const ScTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.focusNode,
    this.error,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.showRequiredMark = true,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final FocusNode? focusNode;

  /// Message to show beneath the field; the outline turns orange while set.
  final String? error;

  /// Masks the text and shows the eye toggle — pass [onToggleObscure] with it.
  final bool obscure;
  final VoidCallback? onToggleObscure;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  /// Appends the orange `*` the design puts after every label.
  final bool showRequiredMark;

  final List<String>? autofillHints;
  final TextCapitalization textCapitalization;

  bool get _hasError => error != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: AppTextStyles.bodyMedium(),
            children: showRequiredMark
                ? [
                    TextSpan(
                      text: ' *',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.accentSignal,
                      ),
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: AppDimens.gapSm.h),
        SizedBox(
          height: AppDimens.inputHeight.h,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscure,
            obscuringCharacter: '•',
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            autofillHints: autofillHints,
            onSubmitted: onSubmitted,
            style: AppTextStyles.body(),
            cursorColor: AppColors.accentSignal,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.body(color: AppColors.textDim),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimens.gapLg.w,
              ),
              // The toggle has to sit inside the fixed 52dp box, so the icon
              // constraints are tightened rather than left at Material's 48dp.
              suffixIcon: onToggleObscure == null
                  ? null
                  : _ObscureToggle(obscure: obscure, onTap: onToggleObscure!),
              suffixIconConstraints: BoxConstraints(
                minWidth: 44.w,
                minHeight: AppDimens.inputHeight.h,
              ),
              enabledBorder: _border(
                _hasError ? AppColors.accentSignal : AppColors.borderLine,
              ),
              focusedBorder: _border(AppColors.accentSignal),
            ),
          ),
        ),
        if (_hasError) ...[
          SizedBox(height: 6.h),
          Text(
            error!,
            style: AppTextStyles.caption(color: AppColors.accentSignal),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppDimens.radiusInput.r),
    borderSide: BorderSide(color: color),
  );
}

/// The eye affordance that reveals a masked password.
class _ObscureToggle extends StatelessWidget {
  const _ObscureToggle({required this.obscure, required this.onTap});

  final bool obscure;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: obscure ? 'Show password' : 'Hide password',
      child: InkResponse(
        onTap: onTap,
        radius: 20.r,
        child: Padding(
          padding: EdgeInsets.only(right: AppDimens.gapMd.w),
          child: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20.r,
            color: AppColors.textDim,
          ),
        ),
      ),
    );
  }
}
