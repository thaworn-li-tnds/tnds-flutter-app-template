import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tnds_flutter_app/src/features/expense/application/budget_service.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/budget_overview.dart';

part 'budget_overview_controller.g.dart';

/// Read/Fetch controller — same shape as `ExpenseListController`. The
/// two-endpoint join is invisible at this altitude: the controller asks the
/// service for one domain object and watches the result.
@riverpod
class BudgetOverviewController extends _$BudgetOverviewController {
  @override
  Future<BudgetOverview> build() =>
      ref.read(budgetServiceProvider).getBudgetOverview();
}
