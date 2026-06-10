// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$expenseDetailControllerHash() =>
    r'2e888606a264ae892687887be1c07435b1fef4d1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ExpenseDetailController
    extends BuildlessAutoDisposeAsyncNotifier<Expense> {
  late final String expenseId;

  FutureOr<Expense> build(String expenseId);
}

/// Read/Fetch controller with a family parameter — each [expenseId] gets its
/// own provider instance, so two detail screens never share state.
///
/// Copied from [ExpenseDetailController].
@ProviderFor(ExpenseDetailController)
const expenseDetailControllerProvider = ExpenseDetailControllerFamily();

/// Read/Fetch controller with a family parameter — each [expenseId] gets its
/// own provider instance, so two detail screens never share state.
///
/// Copied from [ExpenseDetailController].
class ExpenseDetailControllerFamily extends Family<AsyncValue<Expense>> {
  /// Read/Fetch controller with a family parameter — each [expenseId] gets its
  /// own provider instance, so two detail screens never share state.
  ///
  /// Copied from [ExpenseDetailController].
  const ExpenseDetailControllerFamily();

  /// Read/Fetch controller with a family parameter — each [expenseId] gets its
  /// own provider instance, so two detail screens never share state.
  ///
  /// Copied from [ExpenseDetailController].
  ExpenseDetailControllerProvider call(String expenseId) {
    return ExpenseDetailControllerProvider(expenseId);
  }

  @override
  ExpenseDetailControllerProvider getProviderOverride(
    covariant ExpenseDetailControllerProvider provider,
  ) {
    return call(provider.expenseId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'expenseDetailControllerProvider';
}

/// Read/Fetch controller with a family parameter — each [expenseId] gets its
/// own provider instance, so two detail screens never share state.
///
/// Copied from [ExpenseDetailController].
class ExpenseDetailControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<ExpenseDetailController, Expense> {
  /// Read/Fetch controller with a family parameter — each [expenseId] gets its
  /// own provider instance, so two detail screens never share state.
  ///
  /// Copied from [ExpenseDetailController].
  ExpenseDetailControllerProvider(String expenseId)
    : this._internal(
        () => ExpenseDetailController()..expenseId = expenseId,
        from: expenseDetailControllerProvider,
        name: r'expenseDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$expenseDetailControllerHash,
        dependencies: ExpenseDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            ExpenseDetailControllerFamily._allTransitiveDependencies,
        expenseId: expenseId,
      );

  ExpenseDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.expenseId,
  }) : super.internal();

  final String expenseId;

  @override
  FutureOr<Expense> runNotifierBuild(
    covariant ExpenseDetailController notifier,
  ) {
    return notifier.build(expenseId);
  }

  @override
  Override overrideWith(ExpenseDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ExpenseDetailControllerProvider._internal(
        () => create()..expenseId = expenseId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        expenseId: expenseId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ExpenseDetailController, Expense>
  createElement() {
    return _ExpenseDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseDetailControllerProvider &&
        other.expenseId == expenseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, expenseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ExpenseDetailControllerRef
    on AutoDisposeAsyncNotifierProviderRef<Expense> {
  /// The parameter `expenseId` of this provider.
  String get expenseId;
}

class _ExpenseDetailControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ExpenseDetailController,
          Expense
        >
    with ExpenseDetailControllerRef {
  _ExpenseDetailControllerProviderElement(super.provider);

  @override
  String get expenseId => (origin as ExpenseDetailControllerProvider).expenseId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
