import 'package:flutter_test/flutter_test.dart';

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
}
