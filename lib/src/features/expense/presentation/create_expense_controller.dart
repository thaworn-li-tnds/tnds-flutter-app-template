import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tnds_flutter_app/src/features/expense/application/expense_service.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';

part 'create_expense_controller.g.dart';

/// Submit controller — `build()` returns null (idle); [submit] drives the
/// state through loading → data/error. `AsyncValue.guard` is mandatory: it
/// funnels any thrown error into `AsyncError` so the screen's
/// `.when(error:)` / `ref.listen` sees it — never a bare try/catch that
/// swallows it.
@riverpod
class CreateExpenseController extends _$CreateExpenseController {
  @override
  Future<Expense?> build() async => null;

  Future<void> submit({
    required String title,
    required ExpenseCategory category,
    required String amount,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(expenseServiceProvider)
          .createExpense(title: title, category: category, amount: amount),
    );
  }
}
