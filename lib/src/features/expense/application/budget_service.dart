// Prefixed on purpose: flutter_riverpod exports its own `AsyncError`, and a
// package import shadows a conflicting `dart:` name — an unprefixed catch
// clause would silently reify the WRONG AsyncError type and never match.
import 'dart:async' as async;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tnds_flutter_app/src/features/expense/data/budget_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/data/expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/budget.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/budget_overview.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/category_budget_status.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';

part 'budget_service.g.dart';

/// Builds the budget object graph from TWO endpoints. This is the layer
/// where wire relationships become object relationships: the repositories
/// return flat lists (budgets, expenses), and THIS class joins them per
/// category, scopes expenses to the budget month, and folds the totals.
/// Neither response looks like [BudgetOverview] — that shape exists only
/// here. A service may read several repository providers; the rule is
/// "every repository access goes through a service", not "one repo each".
class BudgetService {
  BudgetService(this.ref);

  final Ref ref;

  BudgetRepository get _budgetRepo => ref.read(budgetRepositoryProvider);
  ExpenseRepository get _expenseRepo => ref.read(expenseRepositoryProvider);

  Future<BudgetOverview> getBudgetOverview() async {
    final (budgets, expenses) = await _fetchBoth();

    // No budgets defined → no month to scope by; show all spending unplanned.
    final month = budgets.firstOrNull?.month ?? '';

    // The temporal half of the join. ISO-8601 makes "in this month" a plain
    // prefix check ('2026-06-08' starts with '2026-06') — this property does
    // NOT generalize to other date formats.
    final monthExpenses = expenses.where(
      (expense) => expense.date.startsWith(month),
    );

    // Group + fold in one pass — collection aggregation is use-case logic,
    // so it lives here, not in a domain getter (same rule as `summarize`).
    final expensesByCategory = <ExpenseCategory, List<Expense>>{};
    final spentByCategory = <ExpenseCategory, Money>{};
    for (final expense in monthExpenses) {
      expensesByCategory.putIfAbsent(expense.category, () => []).add(expense);
      spentByCategory[expense.category] =
          (spentByCategory[expense.category] ?? const Money()) + expense.money;
    }

    final budgetByCategory = {
      for (final budget in budgets) budget.category: budget,
    };

    // UNION of both sides of the join: a budget with no spending must show
    // (it answers "how much is left?") and spending with no budget must show
    // (it answers "what did we forget to plan?"). Inner-joining would
    // silently drop both.
    final categories = {...budgetByCategory.keys, ...expensesByCategory.keys};

    final statuses = [
      for (final category in categories)
        CategoryBudgetStatus(
          category: category,
          budget: budgetByCategory[category],
          expenses: expensesByCategory[category] ?? const [],
          spent: spentByCategory[category] ?? const Money(),
        ),
    ]..sort(_compareStatuses);

    return BudgetOverview(month: month, statuses: statuses);
  }

  /// Budgets and expenses are independent, so fetch them in PARALLEL with
  /// the record `.wait`. The caveat every junior hits: `.wait` wraps
  /// failures in [ParallelWaitError], so without this unwrap a typed
  /// repository exception would reach `AppException.parse` as an unknown
  /// error and the UI would lose its specific, localized copy.
  Future<(List<Budget>, List<Expense>)> _fetchBoth() async {
    try {
      return await (_budgetRepo.getBudgets(), _expenseRepo.getExpenses()).wait;
    } on async.ParallelWaitError<
      (List<Budget>?, List<Expense>?),
      (async.AsyncError?, async.AsyncError?)
    > catch (e) {
      final firstFailure = e.errors.$1 ?? e.errors.$2;
      if (firstFailure == null) rethrow;
      Error.throwWithStackTrace(firstFailure.error, firstFailure.stackTrace);
    }
  }

  /// Display order is a use-case decision, made once here — never re-sorted
  /// in widgets: budgeted categories first, hottest utilization on top;
  /// unplanned spending after, biggest first. Category name breaks ties so
  /// the order is fully deterministic.
  static int _compareStatuses(CategoryBudgetStatus a, CategoryBudgetStatus b) {
    if (a.hasBudget != b.hasBudget) return a.hasBudget ? -1 : 1;
    final byPrimary = a.hasBudget
        ? (b.utilization ?? 0).compareTo(a.utilization ?? 0)
        : b.spent.amount.compareTo(a.spent.amount);
    if (byPrimary != 0) return byPrimary;
    return a.category.name.compareTo(b.category.name);
  }
}

@riverpod
BudgetService budgetService(Ref ref) => BudgetService(ref);
