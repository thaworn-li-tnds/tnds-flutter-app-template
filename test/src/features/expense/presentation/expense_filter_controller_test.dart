import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/src/features/expense/data/expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/data/fake/fake_expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/expense_filter_controller.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/expense_list_controller.dart';

void main() {
  test('selecting a category recomputes filteredExpenseOverview for every '
      'watcher — one write, all observers update', () async {
    final container = ProviderContainer(
      overrides: [
        expenseRepositoryProvider.overrideWith(
          (ref) => FakeExpenseRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(filteredExpenseOverviewProvider, (_, _) {});

    await container.read(expenseListControllerProvider.future);
    final unfiltered = container.read(filteredExpenseOverviewProvider).value!;
    expect(unfiltered.expenses.length, kFakeExpenses.length);
    expect(unfiltered.summary.total, const Money(amount: 662.50));

    container
        .read(expenseFilterControllerProvider.notifier)
        .select(ExpenseCategory.food);

    final filtered = container.read(filteredExpenseOverviewProvider).value!;
    expect(filtered.expenses.single.id, 'exp-1');
    expect(filtered.summary.total, const Money(amount: 320.50));

    container.read(expenseFilterControllerProvider.notifier).select(null);

    final restored = container.read(filteredExpenseOverviewProvider).value!;
    expect(restored.expenses.length, kFakeExpenses.length);
  });
}
