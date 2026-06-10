import 'package:tnds_flutter_app/generated/locale_keys.g.dart';

/// Enum with behavior — the wire value and label key live ON the enum, so no
/// switch statements get duplicated at call sites. `LocaleKeys` is generated
/// pure-Dart constants, legal in domain; calling `.tr()` on [labelKey] happens
/// only in presentation. The category icon is deliberately NOT here:
/// `IconData` is a Flutter type, so it lives in
/// `presentation/widgets/expense_category_icon.dart` to keep domain pure.
enum ExpenseCategory {
  food('FOOD', LocaleKeys.expense_category_food),
  transport('TRANSPORT', LocaleKeys.expense_category_transport),
  shopping('SHOPPING', LocaleKeys.expense_category_shopping),
  entertainment('ENTERTAINMENT', LocaleKeys.expense_category_entertainment),
  other('OTHER', LocaleKeys.expense_category_other);

  const ExpenseCategory(this.wireValue, this.labelKey);

  /// Backend representation — used by DTO mapping, never shown to users.
  final String wireValue;

  /// Locale key resolved with `.tr()` in presentation.
  final String labelKey;

  /// Tolerant parsing: an unknown/missing wire value degrades to [other]
  /// instead of crashing on new backend categories.
  static ExpenseCategory from(String? value) => values.firstWhere(
    (category) => category.wireValue == value,
    orElse: () => other,
  );
}
