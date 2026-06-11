import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';
import 'package:tnds_flutter_app/src/features/expense/application/expense_service.dart';
import 'package:tnds_flutter_app/src/features/expense/data/expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/data/fake/fake_expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';
import 'package:tnds_flutter_app/src/shared/application/clock.dart';

/// Pinned [Clock] so the service's date-defaulting rule is deterministic.
class _FixedClock implements Clock {
  _FixedClock(this.fixed);

  final DateTime fixed;

  @override
  DateTime now() => fixed;
}

void main() {
  ({ProviderContainer container, FakeExpenseRepository repository})
  makeContainer() {
    final repository = FakeExpenseRepository();
    final container = ProviderContainer(
      overrides: [
        expenseRepositoryProvider.overrideWith((ref) => repository),
        clockProvider.overrideWith((ref) => _FixedClock(DateTime(2026, 6, 15))),
      ],
    );
    addTearDown(container.dispose);
    return (container: container, repository: repository);
  }

  test('summarize folds the total and groups per category', () {
    final (:container, repository: _) = makeContainer();
    final service = container.read(expenseServiceProvider);

    final summary = service.summarize(kFakeExpenses);

    expect(summary.total, const Money(amount: 662.50));
    expect(
      summary.totalByCategory[ExpenseCategory.food],
      const Money(amount: 320.50),
    );
    expect(
      summary.totalByCategory[ExpenseCategory.transport],
      const Money(amount: 62.00),
    );
    expect(
      summary.totalByCategory[ExpenseCategory.entertainment],
      const Money(amount: 280.00),
    );
    expect(
      summary.totalByCategory.containsKey(ExpenseCategory.shopping),
      isFalse,
    );
  });

  test('summarize of an empty list is the empty summary', () {
    final (:container, repository: _) = makeContainer();
    final service = container.read(expenseServiceProvider);

    final summary = service.summarize(const []);

    expect(summary.total, const Money());
    expect(summary.totalByCategory, isEmpty);
  });

  test('getExpense of an unknown id throws the typed exception', () async {
    final (:container, repository: _) = makeContainer();
    final service = container.read(expenseServiceProvider);

    // Type-check the failure mode — never string-match error messages.
    expect(
      () => service.getExpense('no-such-id'),
      throwsA(isA<ExpenseNotFoundException>()),
    );
  });

  test('getExpenseOverview returns the expenses with their summary', () async {
    final (:container, repository: _) = makeContainer();
    final service = container.read(expenseServiceProvider);

    final overview = await service.getExpenseOverview();

    expect(overview.expenses, kFakeExpenses);
    expect(overview.summary.total, const Money(amount: 662.50));
  });

  test(
    'createExpense builds the request DTO from domain-typed params',
    () async {
      final (:container, :repository) = makeContainer();
      final service = container.read(expenseServiceProvider);

      await service.createExpense(
        title: 'Concert ticket',
        category: ExpenseCategory.entertainment,
        amount: '1500.00',
        date: '2026-06-10',
      );

      final request = repository.createdRequests.single;
      expect(request.title, 'Concert ticket');
      expect(request.category, 'ENTERTAINMENT');
      expect(request.amount, '1500.00');
      expect(request.currency, 'THB');
      expect(request.date, '2026-06-10');
    },
  );

  test(
    "createExpense defaults the date to the injected clock's today",
    () async {
      final (:container, :repository) = makeContainer();
      final service = container.read(expenseServiceProvider);

      await service.createExpense(
        title: 'Coffee',
        category: ExpenseCategory.food,
        amount: '85.00',
      );

      expect(repository.createdRequests.single.date, '2026-06-15');
    },
  );

  test('updateExpense builds the request DTO and addresses the id', () async {
    final (:container, :repository) = makeContainer();
    final service = container.read(expenseServiceProvider);

    await service.updateExpense(
      id: 'exp-1',
      title: 'Brunch with the team',
      category: ExpenseCategory.food,
      amount: '400.00',
      date: '2026-06-12',
    );

    final updated = repository.updatedRequests.single;
    expect(updated.id, 'exp-1');
    expect(updated.request.title, 'Brunch with the team');
    expect(updated.request.category, 'FOOD');
    expect(updated.request.amount, '400.00');
    expect(updated.request.currency, 'THB');
    expect(updated.request.date, '2026-06-12');
  });

  test(
    "updateExpense defaults the date to the injected clock's today",
    () async {
      final (:container, :repository) = makeContainer();
      final service = container.read(expenseServiceProvider);

      await service.updateExpense(
        id: 'exp-1',
        title: 'Lunch',
        category: ExpenseCategory.food,
        amount: '120.00',
      );

      expect(repository.updatedRequests.single.request.date, '2026-06-15');
    },
  );

  test('deleteExpense passes the id through to the repository', () async {
    final (:container, :repository) = makeContainer();
    final service = container.read(expenseServiceProvider);

    await service.deleteExpense('exp-2');

    expect(repository.deletedIds, ['exp-2']);
  });

  test('deleteExpense of an unknown id throws the typed exception', () async {
    final (:container, repository: _) = makeContainer();
    final service = container.read(expenseServiceProvider);

    expect(
      () => service.deleteExpense('no-such-id'),
      throwsA(isA<ExpenseNotFoundException>()),
    );
  });
}
