import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/budget.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/category_budget_status.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';

void main() {
  const food = ExpenseCategory.food;

  Budget budgetOf(double limit) => Budget(
    category: food,
    limit: Money(amount: limit),
    month: '2026-06',
  );

  test('no budget — the semantic null: nothing to compare against', () {
    const status = CategoryBudgetStatus(
      category: food,
      spent: Money(amount: 320.50),
    );

    expect(status.hasBudget, isFalse);
    expect(status.remaining, isNull);
    expect(status.utilization, isNull);
    expect(status.isOverBudget, isFalse);
  });

  test('under budget — positive remaining, utilization below 1', () {
    final status = CategoryBudgetStatus(
      category: food,
      budget: budgetOf(1500),
      spent: const Money(amount: 320.50),
    );

    expect(status.remaining, const Money(amount: 1179.50));
    expect(status.utilization, closeTo(0.2136, 0.0001));
    expect(status.isOverBudget, isFalse);
  });

  test('exactly at the limit is NOT over budget', () {
    final status = CategoryBudgetStatus(
      category: food,
      budget: budgetOf(1500),
      spent: const Money(amount: 1500),
    );

    expect(status.remaining, const Money());
    expect(status.utilization, 1.0);
    expect(status.isOverBudget, isFalse);
  });

  test('over budget — negative remaining, utilization above 1', () {
    final status = CategoryBudgetStatus(
      category: food,
      budget: budgetOf(50),
      spent: const Money(amount: 62),
    );

    expect(status.remaining, const Money(amount: -12));
    expect(status.utilization, closeTo(1.24, 0.0001));
    expect(status.isOverBudget, isTrue);
  });

  test('zero-limit budget — no utilization (never divide by zero), '
      'over as soon as anything is spent', () {
    final unspent = CategoryBudgetStatus(category: food, budget: budgetOf(0));
    expect(unspent.utilization, isNull);
    expect(unspent.isOverBudget, isFalse);

    final spent = CategoryBudgetStatus(
      category: food,
      budget: budgetOf(0),
      spent: const Money(amount: 1),
    );
    expect(spent.utilization, isNull);
    expect(spent.isOverBudget, isTrue);
  });
}
