import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';
import 'package:tnds_flutter_app/src/features/expense/data/expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/data/fake/fake_expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/create_expense_controller.dart';

void main() {
  ProviderContainer makeContainer(FakeExpenseRepository repository) {
    final container = ProviderContainer(
      overrides: [expenseRepositoryProvider.overrideWith((ref) => repository)],
    );
    addTearDown(container.dispose);
    // Keep the auto-dispose provider alive for the duration of the test.
    container.listen(createExpenseControllerProvider, (_, _) {});
    return container;
  }

  test('starts idle (null), submit drives loading then data', () async {
    final fakeRepository = FakeExpenseRepository();
    final container = makeContainer(fakeRepository);

    await container.read(createExpenseControllerProvider.future);
    expect(container.read(createExpenseControllerProvider).value, isNull);

    final pending = container
        .read(createExpenseControllerProvider.notifier)
        .submit(
          title: 'Taxi',
          category: ExpenseCategory.transport,
          amount: '99.50',
        );
    expect(container.read(createExpenseControllerProvider).isLoading, isTrue);

    await pending;
    final state = container.read(createExpenseControllerProvider);
    expect(state.value?.id, 'exp-created');
    expect(fakeRepository.createdRequests.single.category, 'TRANSPORT');
  });

  test(
    'a thrown AppException lands in AsyncError via AsyncValue.guard',
    () async {
      final container = makeContainer(
        FakeExpenseRepository(errorToThrow: UnknownException()),
      );

      await container.read(createExpenseControllerProvider.future);
      await container
          .read(createExpenseControllerProvider.notifier)
          .submit(
            title: 'Taxi',
            category: ExpenseCategory.transport,
            amount: '99.50',
          );

      final state = container.read(createExpenseControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<UnknownException>());
    },
  );
}
