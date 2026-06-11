import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';
import 'package:tnds_flutter_app/src/features/expense/data/fake/fake_budget_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/data/fake/fake_expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/budget.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';

import '../../../robot.dart';
import '../expense_robot.dart';

void main() {
  testWidgets('renders the joined graph: budgeted, budget-only, and '
      'unplanned categories together', (tester) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpBudgetOverviewScreen();

    r.expectBudgetMonth('2026-06');
    // food: budget + spending — derived remaining, none of it on the wire.
    r.expectBudgetCard(ExpenseCategory.food);
    r.expectBudgetSpent(ExpenseCategory.food, 'THB 320.50');
    r.expectBudgetRemaining(ExpenseCategory.food, 'THB 1,179.50 left');
    // shopping: a plan with no spending still shows.
    r.expectBudgetCard(ExpenseCategory.shopping);
    r.expectBudgetRemaining(ExpenseCategory.shopping, 'THB 2,000.00 left');
    // entertainment: spending with no plan.
    r.expectBudgetCard(ExpenseCategory.entertainment);
    r.expectBudgetUnplanned(ExpenseCategory.entertainment);
    // other: neither side of the join.
    r.expectNoBudgetCard(ExpenseCategory.other);
  });

  testWidgets('an over-budget category surfaces the overage', (tester) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpBudgetOverviewScreen(
      budgetRepository: FakeBudgetRepository(
        budgets: [
          const Budget(
            category: ExpenseCategory.transport,
            limit: Money(amount: 50.00),
            month: '2026-06',
          ),
        ],
      ),
    );

    r.expectBudgetSpent(ExpenseCategory.transport, 'THB 62.00');
    r.expectBudgetOver(ExpenseCategory.transport, 'Over by THB 12.00');
  });

  testWidgets('shows the empty state when there is nothing to plan or show', (
    tester,
  ) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpBudgetOverviewScreen(
      budgetRepository: FakeBudgetRepository(budgets: []),
      expenseRepository: FakeExpenseRepository(expenses: []),
    );

    r.expectBudgetEmptyState();
  });

  testWidgets('a typed failure from ONE of the two parallel fetches renders '
      'its own localized copy, not the generic fallback', (tester) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpBudgetOverviewScreen(
      budgetRepository: FakeBudgetRepository(
        errorToThrow: ExpenseNotFoundException(),
      ),
    );

    r.expectNotFoundError();
  });
}
