// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_launcher_registry.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$moduleLauncherRegistryHash() =>
    r'df3c8efbd1341fe602782b567a83c1a2c3d957a4';

/// Generic, auth-free registry of launchable modules keyed by a string id.
///
/// Lets any feature launch any other module without importing it: the caller
/// reads `moduleLauncherRegistry[id]` (depending only on `shared/`) and calls
/// [LaunchableModule.launch]. The real entries are injected at the app
/// composition root (`lib/src/router/module_registry.dart`).
///
/// This is the non-auth counterpart of `authFactorRegistry` — same neutral
/// contract, but with no start-link/advance semantics; the caller decides
/// which module to launch and handles the [ModuleResult] itself.
///
/// Copied from [moduleLauncherRegistry].
@ProviderFor(moduleLauncherRegistry)
final moduleLauncherRegistryProvider =
    Provider<Map<String, LaunchableModule>>.internal(
      moduleLauncherRegistry,
      name: r'moduleLauncherRegistryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$moduleLauncherRegistryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ModuleLauncherRegistryRef = ProviderRef<Map<String, LaunchableModule>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
