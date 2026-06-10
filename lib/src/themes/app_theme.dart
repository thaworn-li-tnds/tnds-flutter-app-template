import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tnds_flutter_app/src/themes/app_colors_extension.dart';
import 'package:tnds_flutter_app/src/themes/app_text_extension.dart';

part 'app_theme.g.dart';

@riverpod
ThemeData lightTheme(Ref ref) {
  const colors = AppColorsExtension();
  const texts = AppTextExtension();

  return ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: colors.brand),
    scaffoldBackgroundColor: colors.background,
    extensions: const [colors, texts],
  );
}

extension AppThemeExtension on ThemeData {
  AppColorsExtension get appColors =>
      extension<AppColorsExtension>() ?? const AppColorsExtension();

  AppTextExtension get appTexts =>
      extension<AppTextExtension>() ?? const AppTextExtension();
}
