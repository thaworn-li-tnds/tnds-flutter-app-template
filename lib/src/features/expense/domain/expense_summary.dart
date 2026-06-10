import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';

/// Aggregate over a list of expenses. It only HOLDS the result — the
/// computation (folding totals) is use-case logic and lives in
/// `ExpenseService.summarize`, not in the domain model.
class ExpenseSummary {
  const ExpenseSummary({
    this.total = const Money(),
    this.totalByCategory = const {},
  });

  final Money total;

  /// Spending total per category — the value is the category's summed
  /// [Money], not its expense list.
  final Map<ExpenseCategory, Money> totalByCategory;
}
