import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_text_styles.dart';

/// The row of single-digit boxes on the verification screen.
///
/// Typing advances to the next box, backspace on an empty box steps back, and
/// a pasted code fills the whole row at once — so the fastest way to enter a
/// code (copy it from the message) works as well as tapping it in.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    super.key,
    required this.length,
    required this.onChanged,
    this.onCompleted,
    this.hasError = false,
  });

  final int length;

  /// Fired with the concatenated digits on every edit.
  final ValueChanged<String> onChanged;

  /// Fired once the last box is filled.
  final VoidCallback? onCompleted;

  /// Paints every box's outline orange.
  final bool hasError;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  late final List<TextEditingController> _controllers = List.generate(
    widget.length,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _focusNodes = List.generate(
    widget.length,
    (_) => FocusNode(),
  );

  String get _code => _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    // A paste (or an SMS autofill) arrives as one long string in one box;
    // spread it across the row from here on rather than dropping the rest.
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = index; i < widget.length; i++) {
        final digit = i - index;
        _controllers[i].text = digit < digits.length ? digits[digit] : '';
      }
      _focusNodes[(index + digits.length).clamp(0, widget.length - 1)]
          .requestFocus();
    } else if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    setState(() {});
    widget.onChanged(_code);
    if (_code.length == widget.length) {
      _focusNodes[index].unfocus();
      widget.onCompleted?.call();
    }
  }

  /// Backspace in an empty box clears and focuses the one before it, which is
  /// what every other code field does and what thumbs expect.
  KeyEventResult _onKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.backspace ||
        _controllers[index].text.isNotEmpty ||
        index == 0) {
      return KeyEventResult.ignored;
    }

    _controllers[index - 1].clear();
    _focusNodes[index - 1].requestFocus();
    setState(() {});
    widget.onChanged(_code);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, _box),
    );
  }

  Widget _box(int index) {
    final filled = _controllers[index].text.isNotEmpty;

    return SizedBox(
      width: 48.w,
      height: 56.h,
      child: Focus(
        onKeyEvent: (_, event) => _onKey(index, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.h2(),
          cursorColor: AppColors.accentSignal,
          showCursor: false,
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            enabledBorder: _border(
              widget.hasError
                  ? AppColors.accentSignal
                  : filled
                  ? AppColors.textDim
                  : AppColors.borderLine,
            ),
            focusedBorder: _border(AppColors.accentSignal),
          ),
          onChanged: (value) => _onChanged(index, value),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppDimens.radiusInput.r),
    borderSide: BorderSide(color: color),
  );
}
