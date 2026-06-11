import 'package:tnds_flutter_app/src/features/expense/data/budget_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/budget.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';

/// Deterministic fixture shared by the fake and test assertions. Pairs with
/// [kFakeExpenses]: food has a budget AND spending, shopping has a budget
/// with NO spending, entertainment/transport spending has NO budget here —
/// so the service's union join is observable from tests.
const kFakeBudgets = <Budget>[
  Budget(
    category: ExpenseCategory.food,
    limit: Money(amount: 1500.00),
    month: '2026-06',
  ),
  Budget(
    category: ExpenseCategory.shopping,
    limit: Money(amount: 2000.00),
    month: '2026-06',
  ),
];

/// `implements` (never `extends`) the concrete repository — same public
/// surface, canned data. Injected in tests via
/// `overrideRepos: [budgetRepositoryProvider.overrideWith(...)]`.
class FakeBudgetRepository implements BudgetRepository {
  FakeBudgetRepository({
    this.addDelay = false,
    List<Budget>? budgets,
    this.errorToThrow,
  }) : _budgets = budgets ?? kFakeBudgets;

  final bool addDelay;
  final List<Budget> _budgets;

  /// When set, every method throws it — for error-state tests.
  final Object? errorToThrow;

  Future<void> _maybeThrow() async {
    if (addDelay) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<List<Budget>> getBudgets() async {
    await _maybeThrow();
    return _budgets;
  }
}
