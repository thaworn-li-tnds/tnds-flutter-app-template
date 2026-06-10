import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';

part 'expense_filter_controller.g.dart';

/// Synchronous UI-state controller (third controller shape next to
/// Read/Fetch and Submit): holds the selected category filter, `null` = all.
///
/// This is the single source of truth for the filter — widgets WRITE via
/// `ref.read(...notifier).select(...)` and every widget that `ref.watch`es
/// [filteredExpenseOverviewProvider] (summary header AND list) updates from
/// that one change. No widget syncs another widget.
@riverpod
class ExpenseFilterController extends _$ExpenseFilterController {
  @override
  ExpenseCategory? build() => null;

  void select(ExpenseCategory? category) => state = category;
}
