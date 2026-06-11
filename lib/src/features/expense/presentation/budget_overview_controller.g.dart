// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_overview_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$budgetOverviewControllerHash() =>
    r'b30199ebef9a547c16b6dd7ac0d18a129f459292';

/// Read/Fetch controller — same shape as `ExpenseListController`. The
/// two-endpoint join is invisible at this altitude: the controller asks the
/// service for one domain object and watches the result.
///
/// Copied from [BudgetOverviewController].
@ProviderFor(BudgetOverviewController)
final budgetOverviewControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      BudgetOverviewController,
      BudgetOverview
    >.internal(
      BudgetOverviewController.new,
      name: r'budgetOverviewControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$budgetOverviewControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BudgetOverviewController = AutoDisposeAsyncNotifier<BudgetOverview>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
