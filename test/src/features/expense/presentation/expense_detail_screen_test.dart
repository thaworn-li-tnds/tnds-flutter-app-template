import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';
import 'package:tnds_flutter_app/src/features/expense/data/fake/fake_expense_repository.dart';

import '../../../robot.dart';
import '../expense_robot.dart';

void main() {
  testWidgets('renders the expense fields for a known id', (tester) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpExpenseDetailScreen('exp-1');

    r.expectDetailValue('expense_detail_title', 'Lunch with the team');
    r.expectDetailValue('expense_detail_category', 'Food');
    r.expectDetailValue('expense_detail_amount', 'THB 320.50');
    r.expectDetailValue('expense_detail_date', '2026-06-08');
  });

  testWidgets(
    'an unknown id degrades to the typed not-found error, never a crash',
    (tester) async {
      final r = ExpenseRobot(Robot(tester));
      await r.pumpExpenseDetailScreen('no-such-id');

      r.expectNotFoundError();
    },
  );

  testWidgets('the edit action navigates to the edit route with the id', (
    tester,
  ) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpExpenseDetailScreen('exp-1');

    await r.tapEditAction();

    r.verifyPushedEdit('exp-1');
  });

  testWidgets('delete asks for confirmation, then deletes and pops', (
    tester,
  ) async {
    final fakeRepository = FakeExpenseRepository();
    final r = ExpenseRobot(Robot(tester));
    await r.pumpExpenseDetailScreen('exp-1', repository: fakeRepository);

    await r.tapDelete();
    r.expectDeleteDialog();

    await r.confirmDelete();

    expect(fakeRepository.deletedIds, ['exp-1']);
    r.verifyPopped();
  });

  testWidgets('cancelling the confirm dialog deletes nothing', (tester) async {
    final fakeRepository = FakeExpenseRepository();
    final r = ExpenseRobot(Robot(tester));
    await r.pumpExpenseDetailScreen('exp-1', repository: fakeRepository);

    await r.tapDelete();
    await r.cancelDelete();

    r.expectNoDeleteDialog();
    expect(fakeRepository.deletedIds, isEmpty);
  });

  testWidgets('a failing delete surfaces the inline error', (tester) async {
    final r = ExpenseRobot(Robot(tester));
    await r.pumpExpenseDetailScreen(
      'exp-1',
      // Detail loads fine; only the delete mutation fails.
      repository: FakeExpenseRepository(writeError: UnknownException()),
    );

    await r.tapDelete();
    await r.confirmDelete();

    r.expectInlineDeleteError();
  });
}
