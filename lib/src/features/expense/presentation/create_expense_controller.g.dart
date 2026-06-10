// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_expense_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$createExpenseControllerHash() =>
    r'f90be2cef0451bd45a561b53ea83c7bd6e64cf7a';

/// Submit controller — `build()` returns null (idle); [submit] drives the
/// state through loading → data/error. `AsyncValue.guard` is mandatory: it
/// funnels any thrown error into `AsyncError` so the screen's
/// `.when(error:)` / `ref.listen` sees it — never a bare try/catch that
/// swallows it.
///
/// Copied from [CreateExpenseController].
@ProviderFor(CreateExpenseController)
final createExpenseControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      CreateExpenseController,
      Expense?
    >.internal(
      CreateExpenseController.new,
      name: r'createExpenseControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$createExpenseControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CreateExpenseController = AutoDisposeAsyncNotifier<Expense?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
