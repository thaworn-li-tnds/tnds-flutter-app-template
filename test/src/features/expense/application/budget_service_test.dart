import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';
import 'package:tnds_flutter_app/src/features/expense/application/budget_service.dart';
import 'package:tnds_flutter_app/src/features/expense/data/budget_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/data/expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/data/fake/fake_budget_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/data/fake/fake_expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/budget_overview.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/category_budget_status.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';

void main() {
  ProviderContainer makeContainer({
    FakeBudgetRepository? budgetRepository,
    FakeExpenseRepository? expenseRepository,
  }) {
    final container = ProviderContainer(
      overrides: [
        budgetRepositoryProvider.overrideWith(
          (ref) => budgetRepository ?? FakeBudgetRepository(),
        ),
        expenseRepositoryProvider.overrideWith(
          (ref) => expenseRepository ?? FakeExpenseRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<BudgetOverview> overviewOf(ProviderContainer container) =>
      container.read(budgetServiceProvider).getBudgetOverview();

  CategoryBudgetStatus statusOf(
    BudgetOverview overview,
    ExpenseCategory category,
  ) => overview.statuses.singleWhere((s) => s.category == category);

  test('joins the two endpoints into one graph — the union of both sides: '
      'budget+spending, budget-only, and spending-only all appear', () async {
    final overview = await overviewOf(makeContainer());

    expect(overview.month, '2026-06');
    // food: both sides of the join.
    final food = statusOf(overview, ExpenseCategory.food);
    expect(food.hasBudget, isTrue);
    expect(food.spent, const Money(amount: 320.50));
    expect(food.expenses.single.id, 'exp-1');
    // shopping: a plan with no spending — must NOT be dropped.
    final shopping = statusOf(overview, ExpenseCategory.shopping);
    expect(shopping.hasBudget, isTrue);
    expect(shopping.spent, const Money());
    expect(shopping.expenses, isEmpty);
    // entertainment/transport: spending with no plan — must NOT be dropped.
    expect(statusOf(overview, ExpenseCategory.entertainment).budget, isNull);
    expect(statusOf(overview, ExpenseCategory.transport).budget, isNull);
    // other: neither side — must not appear.
    expect(
      overview.statuses.map((s) => s.category),
      isNot(contains(ExpenseCategory.other)),
    );
  });

  test('excludes expenses outside the budget month from the fold', () async {
    final overview = await overviewOf(
      makeContainer(
        expenseRepository: FakeExpenseRepository(
          expenses: [
            ...kFakeExpenses,
            const Expense(
              id: 'exp-may',
              title: 'Last month dinner',
              category: ExpenseCategory.food,
              money: Money(amount: 999.00),
              date: '2026-05-28',
            ),
          ],
        ),
      ),
    );

    final food = statusOf(overview, ExpenseCategory.food);
    expect(food.spent, const Money(amount: 320.50));
    expect(food.expenses.map((e) => e.id), isNot(contains('exp-may')));
  });

  test('orders deterministically: budgeted by utilization desc, then '
      'unbudgeted by spent desc', () async {
    final overview = await overviewOf(makeContainer());

    expect(overview.statuses.map((s) => s.category).toList(), const [
      ExpenseCategory.food, // budgeted, 320.50/1500
      ExpenseCategory.shopping, // budgeted, 0/2000
      ExpenseCategory.entertainment, // unbudgeted, 280.00
      ExpenseCategory.transport, // unbudgeted, 62.00
    ]);
  });

  test('no budgets at all — empty month, every category unplanned', () async {
    final overview = await overviewOf(
      makeContainer(budgetRepository: FakeBudgetRepository(budgets: [])),
    );

    expect(overview.month, '');
    expect(overview.statuses.every((s) => !s.hasBudget), isTrue);
    expect(overview.statuses.map((s) => s.category).toList(), const [
      ExpenseCategory.food, // 320.50
      ExpenseCategory.entertainment, // 280.00
      ExpenseCategory.transport, // 62.00
    ]);
  });

  test('no expenses at all — budgeted statuses at zero, ordered by name '
      '(utilization tie-break)', () async {
    final overview = await overviewOf(
      makeContainer(expenseRepository: FakeExpenseRepository(expenses: [])),
    );

    expect(overview.statuses.map((s) => s.category).toList(), const [
      ExpenseCategory.food,
      ExpenseCategory.shopping,
    ]);
    expect(overview.statuses.every((s) => s.spent == const Money()), isTrue);
  });

  group('a typed failure from either parallel fetch surfaces as itself, '
      'never as ParallelWaitError/UnknownException', () {
    test('budget endpoint fails', () {
      final container = makeContainer(
        budgetRepository: FakeBudgetRepository(
          errorToThrow: ExpenseNotFoundException(),
        ),
      );

      expect(
        () => overviewOf(container),
        throwsA(isA<ExpenseNotFoundException>()),
      );
    });

    test('expense endpoint fails', () {
      final container = makeContainer(
        expenseRepository: FakeExpenseRepository(
          errorToThrow: ExpenseNotFoundException(),
        ),
      );

      expect(
        () => overviewOf(container),
        throwsA(isA<ExpenseNotFoundException>()),
      );
    });
  });
}
