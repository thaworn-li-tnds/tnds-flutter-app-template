import 'package:mocktail/mocktail.dart';
import 'package:tnds_flutter_app/src/features/expense/router/expense_router.dart';
import 'package:tnds_flutter_app/src/features/home/presentation/home_screen.dart';

import '../../robot.dart';

/// Feature robot — semantic steps for the home menu, composing the core
/// [Robot]. Test bodies talk ONLY to robots; missing helpers get added here.
class HomeRobot {
  HomeRobot(this.robot);

  final Robot robot;

  Future<void> pumpHomeScreen() => robot.pumpTestWidget(const HomeScreen());

  void expectExpenseEntryButton() => robot.expectKey('open_expense_button');

  Future<void> tapExpenseEntryButton() =>
      robot.clickWidgetByKey('open_expense_button');

  void verifyPushedExpenseList() => verify(
    () => robot.goRouter.pushNamed(
      ExpenseRouter.expenseList.name,
      pathParameters: any(named: 'pathParameters'),
      queryParameters: any(named: 'queryParameters'),
      extra: any(named: 'extra'),
    ),
  ).called(1);
}
