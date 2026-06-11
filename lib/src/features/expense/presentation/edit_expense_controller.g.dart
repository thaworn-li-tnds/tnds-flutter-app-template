// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_expense_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$editExpenseControllerHash() =>
    r'2dd0775432ecb9786de01efd885419f336580d06';

/// Submit controller for editing — same shape as `CreateExpenseController`:
/// `build()` returns null (idle), [submit] drives loading → data/error through
/// `AsyncValue.guard`. The screen reacts to the resulting `AsyncData(expense)`
/// to refresh the list/detail and pop. Auto-disposed with the edit screen.
///
/// Copied from [EditExpenseController].
@ProviderFor(EditExpenseController)
final editExpenseControllerProvider =
    AutoDisposeAsyncNotifierProvider<EditExpenseController, Expense?>.internal(
      EditExpenseController.new,
      name: r'editExpenseControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$editExpenseControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EditExpenseController = AutoDisposeAsyncNotifier<Expense?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
