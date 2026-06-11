import 'package:tnds_flutter_app/src/features/expense/domain/budget.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';

/// Read model — one category's plan vs actuals, a node in the domain object
/// graph. It holds the real [Budget] and [Expense] objects, not the id/code
/// strings the wire used to relate them; `BudgetService` resolves those
/// relationships. Unlike the entities it composes, this object has no
/// identity of its own and exists only to answer the budget-overview query.
///
/// Where computation lives (the line juniors must see): folding a COLLECTION
/// (summing [expenses] into [spent]) is use-case logic and happens in the
/// Service — same rule as `ExpenseSummary`. Deriving a value from fields this
/// object ALREADY holds ([remaining], [utilization], [isOverBudget]) is
/// intrinsic behavior and belongs here — same rule as `Money.+`.
class CategoryBudgetStatus {
  const CategoryBudgetStatus({
    this.category = ExpenseCategory.other,
    this.budget,
    this.expenses = const [],
    this.spent = const Money(),
  });

  final ExpenseCategory category;

  /// Deliberately nullable (deviating from the non-nullable-with-default
  /// rule): `null` is the meaningful state "money was spent with no plan" —
  /// a default `Budget()` would silently read as a zero-limit plan instead.
  final Budget? budget;

  /// The month's expenses for this category — real objects, ready for a
  /// drill-down UI, not ids to re-fetch.
  final List<Expense> expenses;

  /// Folded by `BudgetService` from [expenses]; never present on the wire.
  final Money spent;

  bool get hasBudget => budget != null;

  /// Negative when over budget; null when there is no plan to compare with.
  Money? get remaining {
    final budget = this.budget;
    if (budget == null) return null;
    return budget.limit - spent;
  }

  /// `spent / limit` (1.0 = at the limit, > 1.0 = over). Null when there is
  /// no budget or the limit is zero — never a division by zero.
  double? get utilization {
    final budget = this.budget;
    if (budget == null || budget.limit.amount == 0) return null;
    return spent.amount / budget.limit.amount;
  }

  /// Strictly over — spending exactly the limit is still within plan. A
  /// zero-limit budget is over as soon as anything is spent.
  bool get isOverBudget {
    final budget = this.budget;
    if (budget == null) return false;
    return spent.amount > budget.limit.amount;
  }
}
