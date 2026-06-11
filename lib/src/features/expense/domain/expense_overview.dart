import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_summary.dart';

/// Read model — what the expense list renders: the expenses plus their
/// summary, composed by `ExpenseService` to answer ONE query. Not an entity:
/// it has no identity of its own, is never persisted or sent to the wire,
/// and exists only as a named answer (instead of an anonymous record). True
/// UI state (the selected filter, form inputs) is NOT domain — it lives in
/// controllers.
class ExpenseOverview {
  const ExpenseOverview({
    this.expenses = const [],
    this.summary = const ExpenseSummary(),
  });

  final List<Expense> expenses;
  final ExpenseSummary summary;
}
