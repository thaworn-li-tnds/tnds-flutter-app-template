import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';
import 'package:tnds_flutter_app/src/features/expense/data/expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/data/fake/fake_expense_repository.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/delete_expense_controller.dart';

void main() {
  ProviderContainer makeContainer(FakeExpenseRepository repository) {
    final container = ProviderContainer(
      overrides: [expenseRepositoryProvider.overrideWith((ref) => repository)],
    );
    addTearDown(container.dispose);
    container.listen(deleteExpenseControllerProvider, (_, _) {});
    return container;
  }

  test('starts idle (null), delete drives loading then true', () async {
    final fakeRepository = FakeExpenseRepository();
    final container = makeContainer(fakeRepository);

    await container.read(deleteExpenseControllerProvider.future);
    expect(container.read(deleteExpenseControllerProvider).value, isNull);

    final pending = container
        .read(deleteExpenseControllerProvider.notifier)
        .delete('exp-1');
    expect(container.read(deleteExpenseControllerProvider).isLoading, isTrue);

    await pending;
    final state = container.read(deleteExpenseControllerProvider);
    expect(state.value, isTrue);
    expect(fakeRepository.deletedIds, ['exp-1']);
  });

  test('a failed delete lands in AsyncError via AsyncValue.guard', () async {
    final container = makeContainer(
      FakeExpenseRepository(errorToThrow: UnknownException()),
    );

    await container.read(deleteExpenseControllerProvider.future);
    await container
        .read(deleteExpenseControllerProvider.notifier)
        .delete('exp-1');

    final state = container.read(deleteExpenseControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<UnknownException>());
  });
}
