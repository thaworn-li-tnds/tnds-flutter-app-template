import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tnds_flutter_app/src/features/expense/application/expense_service.dart';

part 'delete_expense_controller.g.dart';

/// Submit controller for delete. The use case returns nothing, so the state is
/// `bool?`: `null` = idle, `true` = deleted — the same null-is-idle convention
/// as `CreateExpenseController`, letting the screen tell a real result from the
/// initial build inside `ref.listen`. `AsyncValue.guard` routes any failure to
/// `AsyncError` for the inline error + logger.
@riverpod
class DeleteExpenseController extends _$DeleteExpenseController {
  @override
  Future<bool?> build() async => null;

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(expenseServiceProvider).deleteExpense(id);
      return true;
    });
  }
}
