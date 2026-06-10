import 'package:tnds_flutter_app/src/features/sample_module/application/sample_module_controller.dart';
import 'package:tnds_flutter_app/src/features/sample_module/domain/sample_launch_params.dart';
import 'package:tnds_flutter_app/src/features/sample_module/domain/sample_result.dart';
import 'package:tnds_flutter_app/src/features/sample_module/router/sample_router.dart';
import 'package:tnds_flutter_app/src/router/app_router.dart';
import 'package:tnds_flutter_app/src/shared/application/launchable_module.dart';
import 'package:tnds_flutter_app/src/shared/application/module_controller_mixin.dart';
import 'package:tnds_flutter_app/src/shared/application/module_launcher_base.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sample_module_launcher.g.dart';

/// Adapter exposing the sample module through the neutral [LaunchableModule]
/// contract. The shared [ModuleLauncherBase] owns the `launch` wiring; this
/// class only maps the context/result and navigates to the module's own screen
/// — so a caller never references the concrete module types or its route.
class _SampleModuleLauncher
    extends ModuleLauncherBase<SampleLaunchParams, SampleResult> {
  _SampleModuleLauncher(super.ref);

  @override
  ModuleControllerMixin<SampleLaunchParams, SampleResult> get controller =>
      ref.read(sampleModuleControllerProvider.notifier);

  @override
  SampleLaunchParams mapParams(ModuleLaunchContext context) =>
      SampleLaunchParams(
        title: context.args['title'] as String? ?? '',
        id: context.args['id'] as String? ?? '',
      );

  @override
  ModuleResult mapResult(SampleResult result) =>
      ModuleResult(status: ModuleResultStatus.completed, token: result.value);

  @override
  void onEnter(ModuleLaunchContext context) {
    ref
        .read(goRouterProvider)
        .enterModule(
          SampleModuleRouter.home.name,
          context.navOptions.entryMode,
        );
  }
}

@Riverpod(keepAlive: true)
LaunchableModule sampleModuleLauncher(Ref ref) => _SampleModuleLauncher(ref);
