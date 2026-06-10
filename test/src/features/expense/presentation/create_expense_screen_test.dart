import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';
import 'package:tnds_flutter_app/src/features/expense/data/fake/fake_expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';

import '../../../robot.dart';
import '../expense_robot.dart';

void main() {
  testWidgets('saving a valid form submits the domain params and pops', (
    tester,
  ) async {
    final fakeRepository = FakeExpenseRepository();
    final r = ExpenseRobot(Robot(tester));
    await r.pumpCreateExpenseScreen(repository: fakeRepository);

    await r.enterTitle('Taxi to the airport');
    await r.enterAmount('450.25');
    await r.pickCategory(ExpenseCategory.transport);
    await r.tapSave();

    final request = fakeRepository.createdRequests.single;
    expect(request.title, 'Taxi to the airport');
    expect(request.amount, '450.25');
    expect(request.category, 'TRANSPORT');
    expect(request.currency, 'THB');
    r.verifyPopped();
  });

  testWidgets('invalid form shows validation messages and never submits', (
    tester,
  ) async {
    final fakeRepository = FakeExpenseRepository();
    final r = ExpenseRobot(Robot(tester));
    await r.pumpCreateExpenseScreen(repository: fakeRepository);

    await r.tapSave();

    r.expectValidationMessage('Enter a title');
    r.expectValidationMessage('Enter a valid amount');
    expect(fakeRepository.createdRequests, isEmpty);
  });

  testWidgets('a failing submit surfaces the inline error', (tester) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpCreateExpenseScreen(
      repository: FakeExpenseRepository(errorToThrow: UnknownException()),
    );

    await r.enterTitle('Taxi');
    await r.enterAmount('99');
    await r.tapSave();

    r.expectInlineCreateError();
  });
}
