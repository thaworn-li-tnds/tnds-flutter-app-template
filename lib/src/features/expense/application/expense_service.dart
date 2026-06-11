import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tnds_flutter_app/src/features/expense/data/dto/request/create_expense_request.dart';
import 'package:tnds_flutter_app/src/features/expense/data/dto/request/update_expense_request.dart';
import 'package:tnds_flutter_app/src/features/expense/data/expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_overview.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_summary.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';
import 'package:tnds_flutter_app/src/shared/application/clock.dart';

part 'expense_service.g.dart';

/// The application layer: plain class holding [Ref], private `_repo` getter,
/// domain-typed methods, exactly one `@riverpod` provider. EVERY repository
/// call goes through here — controllers never read
/// `expenseRepositoryProvider`, and `@riverpod` function providers calling a
/// repository are forbidden. No Flutter imports at this altitude.
class ExpenseService {
  ExpenseService(this.ref);

  final Ref ref;

  ExpenseRepository get _repo => ref.read(expenseRepositoryProvider);

  Future<ExpenseOverview> getExpenseOverview() async {
    final expenses = await _repo.getExpenses();
    return ExpenseOverview(expenses: expenses, summary: summarize(expenses));
  }

  Future<Expense> getExpense(String id) => _repo.getExpense(id);

  /// Use-case logic lives at the service altitude — not in the repository
  /// (I/O mapping only) and not in widgets. Public so it is unit-testable and
  /// reusable (the filtered list re-summarizes through this same method).
  ExpenseSummary summarize(List<Expense> expenses) {
    var total = const Money();
    final totalByCategory = <ExpenseCategory, Money>{};
    for (final expense in expenses) {
      total = total + expense.money;
      totalByCategory[expense.category] =
          (totalByCategory[expense.category] ?? const Money()) + expense.money;
    }
    return ExpenseSummary(total: total, totalByCategory: totalByCategory);
  }

  /// Builds the request DTO HERE so presentation never sees DTO shapes —
  /// controllers pass domain-typed named params only.
  Future<Expense> createExpense({
    required String title,
    required ExpenseCategory category,
    required String amount,
    String? date,
  }) {
    final request = CreateExpenseRequest(
      title: title,
      category: category.wireValue,
      amount: amount,
      currency: Money.defaultCurrency,
      date: date ?? _today,
    );
    return _repo.createExpense(request);
  }

  /// Edit an existing expense. Like [createExpense] it builds the request DTO
  /// from domain-typed params here, so presentation never sees DTO shapes; the
  /// [id] addresses the resource and stays out of the request body.
  Future<Expense> updateExpense({
    required String id,
    required String title,
    required ExpenseCategory category,
    required String amount,
    String? date,
  }) {
    final request = UpdateExpenseRequest(
      title: title,
      category: category.wireValue,
      amount: amount,
      currency: Money.defaultCurrency,
      date: date ?? _today,
    );
    return _repo.updateExpense(id, request);
  }

  /// Delete by id. A thin pass-through today, but it still goes through the
  /// service so presentation never touches the repository — and any future
  /// rule (audit log, optimistic cache eviction) has one place to live.
  Future<void> deleteExpense(String id) => _repo.deleteExpense(id);

  /// `yyyy-MM-dd` of "today" from the injected [Clock] — never
  /// `DateTime.now()` directly, so the defaulting rule is testable with a
  /// pinned clock.
  String get _today =>
      ref.read(clockProvider).now().toIso8601String().split('T').first;
}

@riverpod
ExpenseService expenseService(Ref ref) => ExpenseService(ref);
