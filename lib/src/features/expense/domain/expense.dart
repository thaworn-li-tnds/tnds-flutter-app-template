import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';

/// Entity — identified by [id]; composes the [Money] value object and the
/// [ExpenseCategory] enum instead of carrying raw `double`/`String` fields.
/// Domain rules: noun name, const constructor, non-nullable fields with
/// defaults (DTO `toDomain` mapping fills gaps with these defaults).
class Expense {
  const Expense({
    this.id = '',
    this.title = '',
    this.category = ExpenseCategory.other,
    this.money = const Money(),
    this.date = '',
  });

  final String id;
  final String title;
  final ExpenseCategory category;
  final Money money;

  /// ISO-8601 date (`2026-06-10`) — kept as String so the constructor stays
  /// const; parse to DateTime at the edge that needs calendar math.
  final String date;
}
