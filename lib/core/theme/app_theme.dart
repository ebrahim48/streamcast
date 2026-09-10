import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';

/// The single dark theme StreamCast ships with.
///
/// The design has no light mode — every surface is painted from the `ink` ramp,
/// so the theme is built with [Brightness.dark] and explicit colors rather than
/// a generated scheme.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.accentSignal,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.accentAmber,
      onSecondary: AppColors.onAccent,
      surface: AppColors.surfacePanel,
      onSurface: AppColors.textPrimary,
      error: AppColors.accentSignal,
      onError: AppColors.onAccent,
      outline: AppColors.borderLine,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      canvasColor: AppColors.bgPrimary,
      fontFamily: 'Inter',
      splashFactory: InkRipple.splashFactory,
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLine,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgPrimary,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfacePanel,
        surfaceTintColor: AppColors.transparent,
        modalBackgroundColor: AppColors.surfacePanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusSheet),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: _inputBorder(AppColors.borderLine),
        enabledBorder: _inputBorder(AppColors.borderLine),
        focusedBorder: _inputBorder(AppColors.accentSignal),
        errorBorder: _inputBorder(AppColors.accentSignal),
        focusedErrorBorder: _inputBorder(AppColors.accentSignal),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.accentSignal,
        selectionColor: AppColors.accentSignalDim,
        selectionHandleColor: AppColors.accentSignal,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppDimens.radiusInput),
    borderSide: BorderSide(color: color, width: 1),
  );
}
