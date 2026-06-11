import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tnds_flutter_app/src/features/expense/application/expense_service.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';

part 'edit_expense_controller.g.dart';

/// Submit controller for editing — same shape as `CreateExpenseController`:
/// `build()` returns null (idle), [submit] drives loading → data/error through
/// `AsyncValue.guard`. The screen reacts to the resulting `AsyncData(expense)`
/// to refresh the list/detail and pop. Auto-disposed with the edit screen.
@riverpod
class EditExpenseController extends _$EditExpenseController {
  @override
  Future<Expense?> build() async => null;

  Future<void> submit({
    required String id,
    required String title,
    required ExpenseCategory category,
    required String amount,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(expenseServiceProvider)
          .updateExpense(
            id: id,
            title: title,
            category: category,
            amount: amount,
          ),
    );
  }
}
