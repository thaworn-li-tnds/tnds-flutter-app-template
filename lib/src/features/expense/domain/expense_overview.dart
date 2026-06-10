import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_summary.dart';

/// What the expense list renders: the expenses plus their summary — a named
/// domain noun instead of an anonymous record, so the controller exposes one
/// well-known type.
class ExpenseOverview {
  const ExpenseOverview({
    this.expenses = const [],
    this.summary = const ExpenseSummary(),
  });

  final List<Expense> expenses;
  final ExpenseSummary summary;
}
