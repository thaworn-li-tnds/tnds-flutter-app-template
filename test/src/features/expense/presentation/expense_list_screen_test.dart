import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';
import 'package:tnds_flutter_app/src/features/expense/data/fake/fake_expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';

import '../../../robot.dart';
import '../expense_robot.dart';

void main() {
  testWidgets('renders expense tiles and the summary total', (tester) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpExpenseListScreen();

    r.expectExpenseTile('exp-1');
    r.expectExpenseTile('exp-2');
    r.expectExpenseTile('exp-3');
    r.expectTotal('THB 662.50');
  });

  testWidgets('one filter tap updates the list AND the total together '
      '(both watch the same provider)', (tester) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpExpenseListScreen();

    await r.tapFilterChip(ExpenseCategory.food);

    r.expectExpenseTile('exp-1');
    r.expectNoExpenseTile('exp-2');
    r.expectNoExpenseTile('exp-3');
    r.expectTotal('THB 320.50');

    await r.tapFilterAll();

    r.expectExpenseTile('exp-2');
    r.expectTotal('THB 662.50');
  });

  testWidgets('shows the empty state when there are no expenses', (
    tester,
  ) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpExpenseListScreen(
      repository: FakeExpenseRepository(expenses: []),
    );

    r.expectEmptyState();
  });

  testWidgets('shows the error widget when loading fails', (tester) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpExpenseListScreen(
      repository: FakeExpenseRepository(errorToThrow: UnknownException()),
    );

    r.expectErrorWidget();
  });

  testWidgets('tapping a tile pushes the detail route with the id', (
    tester,
  ) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpExpenseListScreen();

    await r.tapExpenseTile('exp-2');

    r.verifyPushedDetail('exp-2');
  });

  testWidgets('tapping add pushes the create route', (tester) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpExpenseListScreen();

    await r.tapAddExpense();

    r.verifyPushedCreate();
  });

  testWidgets('tapping the app-bar action pushes the budget overview', (
    tester,
  ) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpExpenseListScreen();

    await r.tapBudgetEntry();

    r.verifyPushedBudgetOverview();
  });
}
