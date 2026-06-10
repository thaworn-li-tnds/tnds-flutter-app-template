import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tnds_flutter_app/src/features/expense/application/expense_service.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_overview.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/expense_filter_controller.dart';

part 'expense_list_controller.g.dart';

/// Read/Fetch controller — `build()` performs the load on screen entry; the
/// screen just watches the resulting `AsyncValue`. Auto-disposed when the
/// screen pops. Talks to the Service only, never the repository.
@riverpod
class ExpenseListController extends _$ExpenseListController {
  @override
  Future<ExpenseOverview> build() =>
      ref.read(expenseServiceProvider).getExpenseOverview();
}

/// Derived provider — composes other providers with `ref.watch` (no
/// repository access, so this is NOT a forbidden function provider). When
/// either input changes (filter tapped, list reloaded), Riverpod recomputes
/// this once and every watching widget rebuilds together.
@riverpod
AsyncValue<ExpenseOverview> filteredExpenseOverview(Ref ref) {
  final overviewAsync = ref.watch(expenseListControllerProvider);
  final filter = ref.watch(expenseFilterControllerProvider);

  return overviewAsync.whenData((overview) {
    if (filter == null) return overview;
    final filtered = overview.expenses
        .where((expense) => expense.category == filter)
        .toList();
    return ExpenseOverview(
      expenses: filtered,
      // Same service logic as the unfiltered summary — computed once here,
      // not duplicated in each widget that shows a total.
      summary: ref.watch(expenseServiceProvider).summarize(filtered),
    );
  });
}
