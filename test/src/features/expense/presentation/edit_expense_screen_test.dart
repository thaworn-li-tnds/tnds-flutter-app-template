import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';
import 'package:tnds_flutter_app/src/features/expense/data/fake/fake_expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';

import '../../../robot.dart';
import '../expense_robot.dart';

void main() {
  testWidgets('prefills the form from the loaded expense', (tester) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpEditExpenseScreen('exp-1');

    // kFakeExpenses[exp-1] = Lunch with the team, 320.5, food.
    r.expectFieldText('expense_title_field', 'Lunch with the team');
    r.expectFieldText('expense_amount_field', '320.5');
  });

  testWidgets('an unknown id degrades to the not-found error, never a crash', (
    tester,
  ) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpEditExpenseScreen('no-such-id');

    r.expectNotFoundError();
  });

  testWidgets('saving submits the updated domain params and pops', (
    tester,
  ) async {
    final fakeRepository = FakeExpenseRepository();
    final r = ExpenseRobot(Robot(tester));
    await r.pumpEditExpenseScreen('exp-1', repository: fakeRepository);

    await r.enterTitle('Lunch with the whole team');
    await r.enterAmount('512.00');
    await r.pickCategory(ExpenseCategory.shopping);
    await r.tapUpdate();

    final updated = fakeRepository.updatedRequests.single;
    expect(updated.id, 'exp-1');
    expect(updated.request.title, 'Lunch with the whole team');
    expect(updated.request.amount, '512.00');
    expect(updated.request.category, 'SHOPPING');
    r.verifyPopped();
  });

  testWidgets('a failing update surfaces the inline error', (tester) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpEditExpenseScreen(
      'exp-1',
      // Read succeeds (form prefills); only the update fails.
      repository: FakeExpenseRepository(writeError: UnknownException()),
    );

    await r.enterTitle('Lunch updated');
    await r.tapUpdate();

    r.expectInlineEditError();
  });
}
