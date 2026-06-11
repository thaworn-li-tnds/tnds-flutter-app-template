// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_expense_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deleteExpenseControllerHash() =>
    r'1ef537085d5676c68a02c25ef8a502ecc262d214';

/// Submit controller for delete. The use case returns nothing, so the state is
/// `bool?`: `null` = idle, `true` = deleted — the same null-is-idle convention
/// as `CreateExpenseController`, letting the screen tell a real result from the
/// initial build inside `ref.listen`. `AsyncValue.guard` routes any failure to
/// `AsyncError` for the inline error + logger.
///
/// Copied from [DeleteExpenseController].
@ProviderFor(DeleteExpenseController)
final deleteExpenseControllerProvider =
    AutoDisposeAsyncNotifierProvider<DeleteExpenseController, bool?>.internal(
      DeleteExpenseController.new,
      name: r'deleteExpenseControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deleteExpenseControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeleteExpenseController = AutoDisposeAsyncNotifier<bool?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
