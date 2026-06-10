import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tnds_flutter_app/src/features/expense/application/expense_service.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';

part 'expense_detail_controller.g.dart';

/// Read/Fetch controller with a family parameter — each [expenseId] gets its
/// own provider instance, so two detail screens never share state.
@riverpod
class ExpenseDetailController extends _$ExpenseDetailController {
  @override
  Future<Expense> build(String expenseId) =>
      ref.read(expenseServiceProvider).getExpense(expenseId);
}
