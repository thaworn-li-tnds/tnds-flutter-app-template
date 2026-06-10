import 'package:flutter_test/flutter_test.dart';

import '../../robot.dart';
import 'home_robot.dart';

void main() {
  testWidgets('renders the expense entry button', (tester) async {
    final r = HomeRobot(Robot(tester));
    await r.pumpHomeScreen();

    r.expectExpenseEntryButton();
  });

  testWidgets('tapping the entry button pushes the expense list route', (
    tester,
  ) async {
    final r = HomeRobot(Robot(tester));
    await r.pumpHomeScreen();

    await r.tapExpenseEntryButton();

    r.verifyPushedExpenseList();
  });
}
