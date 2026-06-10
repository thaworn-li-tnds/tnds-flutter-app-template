// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_module_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sampleModuleControllerHash() =>
    r'714183154dc856255fcae27e6eef4581f4f87a94';

/// Session/lifecycle controller for the sample module — lives the whole feature
/// (keepAlive). The shared [ModuleControllerMixin] owns the session state,
/// callbacks and `start`/`complete`/`cancel`; this class only fills the two
/// service hooks: [openSession] calls `startSample` to get the session token
/// (exposed as `moduleToken`), [finishSession] finalizes. Screens read
/// [launchParams] for their content calls.
///
/// Copied from [SampleModuleController].
@ProviderFor(SampleModuleController)
final sampleModuleControllerProvider =
    NotifierProvider<SampleModuleController, ModuleSession>.internal(
      SampleModuleController.new,
      name: r'sampleModuleControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sampleModuleControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SampleModuleController = Notifier<ModuleSession>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
