import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';
import 'package:tnds_flutter_app/src/features/expense/data/expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/data/fake/fake_expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/edit_expense_controller.dart';

void main() {
  ProviderContainer makeContainer(FakeExpenseRepository repository) {
    final container = ProviderContainer(
      overrides: [expenseRepositoryProvider.overrideWith((ref) => repository)],
    );
    addTearDown(container.dispose);
    container.listen(editExpenseControllerProvider, (_, _) {});
    return container;
  }

  test('starts idle (null), submit drives loading then data', () async {
    final fakeRepository = FakeExpenseRepository();
    final container = makeContainer(fakeRepository);

    await container.read(editExpenseControllerProvider.future);
    expect(container.read(editExpenseControllerProvider).value, isNull);

    final pending = container
        .read(editExpenseControllerProvider.notifier)
        .submit(
          id: 'exp-1',
          title: 'Brunch',
          category: ExpenseCategory.food,
          amount: '400.00',
        );
    expect(container.read(editExpenseControllerProvider).isLoading, isTrue);

    await pending;
    final state = container.read(editExpenseControllerProvider);
    expect(state.value?.id, 'exp-1');
    expect(fakeRepository.updatedRequests.single.request.title, 'Brunch');
  });

  test(
    'a thrown AppException lands in AsyncError via AsyncValue.guard',
    () async {
      final container = makeContainer(
        FakeExpenseRepository(errorToThrow: UnknownException()),
      );

      await container.read(editExpenseControllerProvider.future);
      await container
          .read(editExpenseControllerProvider.notifier)
          .submit(
            id: 'exp-1',
            title: 'Brunch',
            category: ExpenseCategory.food,
            amount: '400.00',
          );

      final state = container.read(editExpenseControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<UnknownException>());
    },
  );
}
