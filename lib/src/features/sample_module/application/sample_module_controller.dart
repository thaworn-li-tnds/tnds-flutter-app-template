import 'package:tnds_flutter_app/src/features/sample_module/application/sample_module_service.dart';
import 'package:tnds_flutter_app/src/features/sample_module/domain/sample_launch_params.dart';
import 'package:tnds_flutter_app/src/features/sample_module/domain/sample_result.dart';
import 'package:tnds_flutter_app/src/shared/application/module_controller_mixin.dart';
import 'package:tnds_flutter_app/src/shared/application/module_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sample_module_controller.g.dart';

/// Session/lifecycle controller for the sample module — lives the whole feature
/// (keepAlive). The shared [ModuleControllerMixin] owns the session state,
/// callbacks and `start`/`complete`/`cancel`; this class only fills the two
/// service hooks: [openSession] calls `startSample` to get the session token
/// (exposed as `moduleToken`), [finishSession] finalizes. Screens read
/// [launchParams] for their content calls.
@Riverpod(keepAlive: true)
class SampleModuleController extends _$SampleModuleController
    with ModuleControllerMixin<SampleLaunchParams, SampleResult> {
  @override
  ModuleSession build() => const ModuleSessionIdle();

  @override
  Future<String> openSession(SampleLaunchParams params) =>
      // Exchanges the launch params for the module/session token (`sampleToken`),
      // exposed afterwards as `moduleToken` — mirrors startFR/startOTP.
      ref.read(sampleModuleServiceProvider).startSample(params);

  @override
  Future<SampleResult> finishSession() async =>
      SampleResult(value: await ref.read(sampleModuleServiceProvider).finish());
}
