import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'app_text_theme.dart';

abstract class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light, error: AppColors.error));
  static ThemeData get dark => _build(ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.dark, error: AppColors.error));

  static ThemeData _build(ColorScheme scheme) {
    final ThemeData base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: scheme.brightness);
    return base.copyWith(
      textTheme: AppTextTheme.build(base.textTheme, scheme.onSurface),
      appBarTheme: AppBarTheme(backgroundColor: scheme.surface, foregroundColor: scheme.onSurface, elevation: 0, centerTitle: true),
      cardTheme: CardThemeData(elevation: 0, color: scheme.surfaceContainer, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceM, vertical: AppDimensions.spaceM),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)), minimumSize: const Size.fromHeight(AppDimensions.minTouchTarget)),
      ),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: scheme.surfaceContainer, indicatorColor: scheme.primaryContainer),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM))),
    );
  }
}
