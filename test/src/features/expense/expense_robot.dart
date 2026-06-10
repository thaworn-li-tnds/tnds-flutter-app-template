import 'package:mocktail/mocktail.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_error_widget.dart';
import 'package:tnds_flutter_app/src/features/expense/data/expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/data/fake/fake_expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/create_expense_screen.dart';
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

  void expectValidationMessage(String message) => robot.expectText(message);

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

  // ---- navigation verification ----------------------------------------------

  void verifyPushedDetail(String id) => verify(
    () => robot.goRouter.pushNamed(
      ExpenseRouter.expenseDetail.name,
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

  void verifyPopped() => verify(() => robot.goRouter.pop()).called(1);
}
