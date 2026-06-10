// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_filter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$expenseFilterControllerHash() =>
    r'41def1c0c2627dfb185d4df4e25de3a5e848a392';

/// Synchronous UI-state controller (third controller shape next to
/// Read/Fetch and Submit): holds the selected category filter, `null` = all.
///
/// This is the single source of truth for the filter — widgets WRITE via
/// `ref.read(...notifier).select(...)` and every widget that `ref.watch`es
/// [filteredExpenseOverviewProvider] (summary header AND list) updates from
/// that one change. No widget syncs another widget.
///
/// Copied from [ExpenseFilterController].
@ProviderFor(ExpenseFilterController)
final expenseFilterControllerProvider =
    AutoDisposeNotifierProvider<
      ExpenseFilterController,
      ExpenseCategory?
    >.internal(
      ExpenseFilterController.new,
      name: r'expenseFilterControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expenseFilterControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExpenseFilterController = AutoDisposeNotifier<ExpenseCategory?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
