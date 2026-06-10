import 'package:flutter/material.dart';

/// Design-token typography exposed to widgets via `context.appTexts`.
/// Widgets never declare inline `TextStyle(...)` — extend this set instead.
class AppTextExtension extends ThemeExtension<AppTextExtension> {
  const AppTextExtension({
    this.titleLgBold = const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    this.titleMdBold = const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    this.bodyLgRegular = const TextStyle(fontSize: 16),
    this.bodyMdRegular = const TextStyle(fontSize: 14),
    this.bodyMdBold = const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    this.bodySmRegular = const TextStyle(fontSize: 12),
  });

  final TextStyle titleLgBold;
  final TextStyle titleMdBold;
  final TextStyle bodyLgRegular;
  final TextStyle bodyMdRegular;
  final TextStyle bodyMdBold;
  final TextStyle bodySmRegular;

  @override
  AppTextExtension copyWith({
    TextStyle? titleLgBold,
    TextStyle? titleMdBold,
    TextStyle? bodyLgRegular,
    TextStyle? bodyMdRegular,
    TextStyle? bodyMdBold,
    TextStyle? bodySmRegular,
  }) {
    return AppTextExtension(
      titleLgBold: titleLgBold ?? this.titleLgBold,
      titleMdBold: titleMdBold ?? this.titleMdBold,
      bodyLgRegular: bodyLgRegular ?? this.bodyLgRegular,
      bodyMdRegular: bodyMdRegular ?? this.bodyMdRegular,
      bodyMdBold: bodyMdBold ?? this.bodyMdBold,
      bodySmRegular: bodySmRegular ?? this.bodySmRegular,
    );
  }

  @override
  AppTextExtension lerp(ThemeExtension<AppTextExtension>? other, double t) {
    if (other is! AppTextExtension) return this;
    return AppTextExtension(
      titleLgBold: TextStyle.lerp(titleLgBold, other.titleLgBold, t)!,
      titleMdBold: TextStyle.lerp(titleMdBold, other.titleMdBold, t)!,
      bodyLgRegular: TextStyle.lerp(bodyLgRegular, other.bodyLgRegular, t)!,
      bodyMdRegular: TextStyle.lerp(bodyMdRegular, other.bodyMdRegular, t)!,
      bodyMdBold: TextStyle.lerp(bodyMdBold, other.bodyMdBold, t)!,
      bodySmRegular: TextStyle.lerp(bodySmRegular, other.bodySmRegular, t)!,
    );
  }
}
