import 'package:tnds_flutter_app/src/features/expense/domain/category_budget_status.dart';

/// Read model — what the budget screen renders: the month plus one status
/// node per category, assembled by `BudgetService` from TWO endpoints
/// (budgets and expenses). No single response looks anything like this
/// object.
class BudgetOverview {
  const BudgetOverview({this.month = '', this.statuses = const []});

  final String month;
  final List<CategoryBudgetStatus> statuses;
}
