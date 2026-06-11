import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_error_widget.dart';
import 'package:tnds_flutter_app/src/features/expense/data/budget_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/data/expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/data/fake/fake_budget_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/data/fake/fake_expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/budget_overview_screen.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/create_expense_screen.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/edit_expense_screen.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/expense_detail_screen.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/expense_list_screen.dart';
import 'package:tnds_flutter_app/src/features/expense/router/expense_router.dart';

import '../../robot.dart';

/// Feature robot — semantic steps for the expense screens, composing the core
/// [Robot]. Test bodies talk ONLY to robots; missing helpers get added here.
class ExpenseRobot {
  ExpenseRobot(this.robot);

  final Robot robot;

  // ---- pumping --------------------------------------------------------------

  Future<void> pumpExpenseListScreen({FakeExpenseRepository? repository}) =>
      robot.pumpTestWidget(
        const ExpenseListScreen(),
        overrideRepos: [
          expenseRepositoryProvider.overrideWith(
            (ref) => repository ?? FakeExpenseRepository(),
          ),
        ],
      );

  Future<void> pumpExpenseDetailScreen(
    String expenseId, {
    FakeExpenseRepository? repository,
  }) => robot.pumpTestWidget(
    ExpenseDetailScreen(expenseId: expenseId),
    overrideRepos: [
      expenseRepositoryProvider.overrideWith(
        (ref) => repository ?? FakeExpenseRepository(),
      ),
    ],
  );

  Future<void> pumpCreateExpenseScreen({FakeExpenseRepository? repository}) =>
      robot.pumpTestWidget(
        const CreateExpenseScreen(),
        overrideRepos: [
          expenseRepositoryProvider.overrideWith(
            (ref) => repository ?? FakeExpenseRepository(),
          ),
        ],
      );

  Future<void> pumpEditExpenseScreen(
    String expenseId, {
    FakeExpenseRepository? repository,
  }) => robot.pumpTestWidget(
    EditExpenseScreen(expenseId: expenseId),
    overrideRepos: [
      expenseRepositoryProvider.overrideWith(
        (ref) => repository ?? FakeExpenseRepository(),
      ),
    ],
  );

  /// The budget screen joins TWO endpoints, so both fakes are injected.
  Future<void> pumpBudgetOverviewScreen({
    FakeBudgetRepository? budgetRepository,
    FakeExpenseRepository? expenseRepository,
  }) => robot.pumpTestWidget(
    const BudgetOverviewScreen(),
    overrideRepos: [
      budgetRepositoryProvider.overrideWith(
        (ref) => budgetRepository ?? FakeBudgetRepository(),
      ),
      expenseRepositoryProvider.overrideWith(
        (ref) => expenseRepository ?? FakeExpenseRepository(),
      ),
    ],
  );

  // ---- assertions -----------------------------------------------------------

  void expectExpenseTile(String id) => robot.expectKey('expense_tile_$id');

  void expectNoExpenseTile(String id) =>
      robot.expectKey('expense_tile_$id', n: 0);

  void expectTotal(String formatted) =>
      robot.expectLabelText('expense_total_label', formatted);

  void expectEmptyState() => robot.expectKey('expense_empty_state');

  void expectErrorWidget() => robot.expectType(CommonErrorWidget);

  /// Asserts the typed [ExpenseNotFoundException] surfaced with ITS OWN
  /// localized copy (fixture text from TestAssetLoader) — not the generic
  /// unknown-error fallback.
  void expectNotFoundError() {
    robot.expectType(CommonErrorWidget);
    robot.expectText('Expense not found');
  }

  void expectDetailValue(String key, String value) =>
      robot.expectLabelText(key, value);

  void expectInlineCreateError() => robot.expectKey('create_expense_error');

  void expectInlineEditError() => robot.expectKey('edit_expense_error');

  void expectInlineDeleteError() => robot.expectKey('delete_expense_error');

  void expectDeleteDialog() => robot.expectKey('delete_expense_dialog');

  void expectNoDeleteDialog() => robot.expectKey('delete_expense_dialog', n: 0);

  /// Asserts a form field is prefilled with [value] (edit screen seeds inputs
  /// from the loaded expense).
  void expectFieldText(String key, String value) {
    final finder = find.byKey(Key(key));
    expect(finder, findsOneWidget);
    final TextField field = robot.tester.widget<TextField>(
      find.descendant(of: finder, matching: find.byType(TextField)),
    );
    expect(field.controller?.text, value);
  }

  void expectValidationMessage(String message) => robot.expectText(message);

  void expectBudgetMonth(String month) =>
      robot.expectLabelText('budget_month_label', month);

  void expectBudgetCard(ExpenseCategory category) =>
      robot.expectKey('budget_card_${category.name}');

  void expectNoBudgetCard(ExpenseCategory category) =>
      robot.expectKey('budget_card_${category.name}', n: 0);

  void expectBudgetSpent(ExpenseCategory category, String formatted) =>
      robot.expectLabelText('budget_spent_label_${category.name}', formatted);

  void expectBudgetRemaining(ExpenseCategory category, String text) =>
      robot.expectLabelText('budget_remaining_label_${category.name}', text);

  void expectBudgetOver(ExpenseCategory category, String text) =>
      robot.expectLabelText('budget_over_label_${category.name}', text);

  void expectBudgetUnplanned(ExpenseCategory category) =>
      robot.expectKey('budget_no_budget_label_${category.name}');

  void expectBudgetEmptyState() => robot.expectKey('budget_empty_state');

  // ---- interactions -----------------------------------------------------------

  Future<void> tapFilterChip(ExpenseCategory category) =>
      robot.clickWidgetByKey('expense_filter_chip_${category.name}');

  Future<void> tapFilterAll() =>
      robot.clickWidgetByKey('expense_filter_chip_all');

  Future<void> tapExpenseTile(String id) =>
      robot.clickWidgetByKey('expense_tile_$id');

  Future<void> tapAddExpense() => robot.clickWidgetByKey('add_expense_button');

  Future<void> enterTitle(String text) =>
      robot.enterTextByKey('expense_title_field', text);

  Future<void> enterAmount(String text) =>
      robot.enterTextByKey('expense_amount_field', text);

  Future<void> pickCategory(ExpenseCategory category) =>
      robot.clickWidgetByKey('expense_category_chip_${category.name}');

  Future<void> tapSave() => robot.clickWidgetByKey('save_expense_button');

  /// The detail screen's app-bar action (edit) — CommonAppBar's right icon.
  Future<void> tapEditAction() => robot.clickWidgetByKey('app_bar_right_icon');

  Future<void> tapUpdate() => robot.clickWidgetByKey('update_expense_button');

  Future<void> tapDelete() => robot.clickWidgetByKey('delete_expense_button');

  Future<void> confirmDelete() =>
      robot.clickWidgetByKey('delete_expense_confirm');

  Future<void> cancelDelete() =>
      robot.clickWidgetByKey('delete_expense_cancel');

  /// The list screen's app-bar action (CommonAppBar's built-in right icon).
  Future<void> tapBudgetEntry() => robot.clickWidgetByKey('app_bar_right_icon');

  // ---- navigation verification ----------------------------------------------

  void verifyPushedDetail(String id) => verify(
    () => robot.goRouter.pushNamed(
      ExpenseRouter.expenseDetail.name,
      pathParameters: any(named: 'pathParameters'),
      queryParameters: {'id': id},
      extra: any(named: 'extra'),
    ),
  ).called(1);

  void verifyPushedEdit(String id) => verify(
    () => robot.goRouter.pushNamed(
      ExpenseRouter.editExpense.name,
      pathParameters: any(named: 'pathParameters'),
      queryParameters: {'id': id},
      extra: any(named: 'extra'),
    ),
  ).called(1);

  void verifyPushedCreate() => verify(
    () => robot.goRouter.pushNamed(
      ExpenseRouter.createExpense.name,
      pathParameters: any(named: 'pathParameters'),
      queryParameters: any(named: 'queryParameters'),
      extra: any(named: 'extra'),
    ),
  ).called(1);

  void verifyPushedBudgetOverview() => verify(
    () => robot.goRouter.pushNamed(
      ExpenseRouter.budgetOverview.name,
      pathParameters: any(named: 'pathParameters'),
      queryParameters: any(named: 'queryParameters'),
      extra: any(named: 'extra'),
    ),
  ).called(1);

  void verifyPopped() => verify(() => robot.goRouter.pop()).called(1);
}
