import 'package:go_router/go_router.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/create_expense_screen.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/expense_detail_screen.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/expense_list_screen.dart';
import 'package:tnds_flutter_app/src/router/tnds_route.dart';

/// Route enum — `name` is derived by [TndsRouter] from [path], never
/// hand-written. Navigate with `context.pushNamed(ExpenseRouter.x.name)`.
enum ExpenseRouter with TndsRouter {
  expenseList,
  expenseDetail,
  createExpense;

  @override
  String get routerName => 'expense_router';

  @override
  String get path {
    switch (this) {
      case ExpenseRouter.expenseList:
        return '/expense';
      case ExpenseRouter.expenseDetail:
        return '/expense/detail';
      case ExpenseRouter.createExpense:
        return '/expense/create';
    }
  }
}

/// Spread into `lib/src/router/app_router.dart` — the app router never
/// defines feature screens inline.
final expenseRouter = <GoRoute>[
  GoRoute(
    path: ExpenseRouter.expenseList.path,
    name: ExpenseRouter.expenseList.name,
    builder: (context, state) => const ExpenseListScreen(),
  ),
  GoRoute(
    path: ExpenseRouter.expenseDetail.path,
    name: ExpenseRouter.expenseDetail.name,
    // queryParameters (not `extra`) so the route survives deeplink re-entry;
    // a missing id falls through to the controller's error state, no crash.
    builder: (context, state) =>
        ExpenseDetailScreen(expenseId: state.uri.queryParameters['id'] ?? ''),
  ),
  GoRoute(
    path: ExpenseRouter.createExpense.path,
    name: ExpenseRouter.createExpense.name,
    builder: (context, state) => const CreateExpenseScreen(),
  ),
];
