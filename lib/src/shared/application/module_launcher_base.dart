import 'package:tnds_flutter_app/src/shared/application/launchable_module.dart';
import 'package:tnds_flutter_app/src/shared/application/module_controller_mixin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Shared structure for a launchable module's adapter — the [LaunchableModule]
/// boilerplate every module repeats. Extend it and fill in the mapping hooks:
///
/// ```dart
/// class _XModuleLauncher extends ModuleLauncherBase<XLaunchParams, XResult> {
///   _XModuleLauncher(super.ref);
///   @override
///   XModuleController get controller => ref.read(xModuleControllerProvider.notifier);
///   @override
///   XLaunchParams mapParams(ModuleLaunchContext c) => ...;
///   @override
///   ModuleResult mapResult(XResult r) => ...;
///   // optional: override onEnter to navigate to the module's entry screen.
/// }
/// ```
///
/// `launch` is enforced: it drives the controller's [ModuleControllerMixin.start]
/// and translates the typed result/cancel into a neutral [ModuleResult]. A
/// module never re-implements that wiring.
abstract class ModuleLauncherBase<P, R> implements LaunchableModule {
  ModuleLauncherBase(this.ref);

  final Ref ref;

  /// The module's session controller (mixes in [ModuleControllerMixin]).
  ModuleControllerMixin<P, R> get controller;

  /// Map the neutral launch context into this module's params.
  P mapParams(ModuleLaunchContext context);

  /// Map this module's typed result into the neutral [ModuleResult].
  ModuleResult mapResult(R result);

  /// Optional entry navigation. Default: none — an orchestrator owns the route
  /// (e.g. auth factors). Override to push/replace to the module's own screen.
  void onEnter(ModuleLaunchContext context) {}

  @override
  void launch(ModuleLaunchContext context, ModuleResultCallback onResult) {
    controller.start(
      params: mapParams(context),
      onCompleted: (result) => onResult(mapResult(result)),
      onCancelled: () =>
          onResult(const ModuleResult(status: ModuleResultStatus.cancelled)),
      onFailed: (error, _) => onResult(
        ModuleResult(status: ModuleResultStatus.failed, error: error),
      ),
      navOptions: context.navOptions,
    );
    onEnter(context);
  }
}

/// Navigates to a module's entry route honouring [ModuleEntryMode] — replaces
/// the duplicated push/replace switch each launcher used to inline.
extension ModuleEntryNav on GoRouter {
  void enterModule(String routeName, ModuleEntryMode mode) => switch (mode) {
    ModuleEntryMode.push => pushNamed(routeName),
    ModuleEntryMode.replace => goNamed(routeName),
  };
}
