// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredExpenseOverviewHash() =>
    r'6b8f95042b059c4bcfd23039652b7fe75d3a0ba9';

/// Derived provider — composes other providers with `ref.watch` (no
/// repository access, so this is NOT a forbidden function provider). When
/// either input changes (filter tapped, list reloaded), Riverpod recomputes
/// this once and every watching widget rebuilds together.
///
/// Copied from [filteredExpenseOverview].
@ProviderFor(filteredExpenseOverview)
final filteredExpenseOverviewProvider =
    AutoDisposeProvider<AsyncValue<ExpenseOverview>>.internal(
      filteredExpenseOverview,
      name: r'filteredExpenseOverviewProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredExpenseOverviewHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredExpenseOverviewRef =
    AutoDisposeProviderRef<AsyncValue<ExpenseOverview>>;
String _$expenseListControllerHash() =>
    r'36114d7a68bf5927e5165381ba35fcd8d50bc1be';

/// Read/Fetch controller — `build()` performs the load on screen entry; the
/// screen just watches the resulting `AsyncValue`. Auto-disposed when the
/// screen pops. Talks to the Service only, never the repository.
///
/// Copied from [ExpenseListController].
@ProviderFor(ExpenseListController)
final expenseListControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      ExpenseListController,
      ExpenseOverview
    >.internal(
      ExpenseListController.new,
      name: r'expenseListControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expenseListControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExpenseListController = AutoDisposeAsyncNotifier<ExpenseOverview>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
