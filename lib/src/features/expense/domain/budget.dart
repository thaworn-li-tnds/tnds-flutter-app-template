import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';

/// Entity — the spending plan for one category in one month; its identity is
/// the ([category], [month]) pair. Note what is NOT here:
/// the wire carries `month` once at the response root and references the
/// category by a code string — the DTO mapper flattens the month into each
/// [Budget] and resolves the code to [ExpenseCategory]. The domain shape is
/// designed for the use case, never copied from the response layout.
class Budget {
  const Budget({
    this.category = ExpenseCategory.other,
    this.limit = const Money(),
    this.month = '',
  });

  final ExpenseCategory category;
  final Money limit;

  /// ISO-8601 month (`2026-06`) — String for the same const-constructor
  /// rationale as `Expense.date`.
  final String month;
}
