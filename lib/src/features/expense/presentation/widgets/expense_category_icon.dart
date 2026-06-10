import 'package:flutter/material.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';

/// Flutter-typed behavior for the pure-Dart enum. `IconData` would break
/// domain purity, so the icon mapping lives here in presentation — the
/// deliberate counterpart of `ExpenseCategory.labelKey`.
extension ExpenseCategoryPresentation on ExpenseCategory {
  IconData get icon => switch (this) {
    ExpenseCategory.food => Icons.restaurant,
    ExpenseCategory.transport => Icons.directions_bus,
    ExpenseCategory.shopping => Icons.shopping_bag,
    ExpenseCategory.entertainment => Icons.movie,
    ExpenseCategory.other => Icons.receipt_long,
  };
}
