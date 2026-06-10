import 'package:flutter/material.dart';

/// Design-token color set exposed to widgets via `context.appColors`.
/// Per-app palettes implement this as a [ThemeExtension]; widgets never use
/// raw `Color(0xFF...)` literals.
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    this.brand = const Color(0xFF1A73E8),
    this.background = const Color(0xFFF7F8FA),
    this.surface = Colors.white,
    this.textPrimary = const Color(0xFF1F1F1F),
    this.textSecondary = const Color(0xFF5F6368),
    this.error = const Color(0xFFD93025),
    this.success = const Color(0xFF188038),
  });

  final Color brand;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color error;
  final Color success;

  @override
  AppColorsExtension copyWith({
    Color? brand,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? error,
    Color? success,
  }) {
    return AppColorsExtension(
      brand: brand ?? this.brand,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      brand: Color.lerp(brand, other.brand, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}
