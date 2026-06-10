import 'package:tnds_flutter_app/src/features/sample_module/data/sample_repository.dart';
import 'package:tnds_flutter_app/src/features/sample_module/domain/sample_launch_params.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sample_module_service.g.dart';

/// **Module-control** service — only the functions that drive the module's
/// session lifecycle (open + finish). Carries `Module` for that reason (rule 09).
/// Feature work (content load, feature actions) lives in [SampleScreenService].
class SampleModuleService {
  SampleModuleService(this.ref);

  final Ref ref;

  SampleRepository get _repo => ref.read(sampleRepositoryProvider);

  /// Opens the session and returns the module/session token (`sampleToken`).
  Future<String> startSample(SampleLaunchParams params) =>
      _repo.startSample(params.title);

  /// Finalizes the session and returns the module's result value.
  Future<String> finish() => _repo.finish();
}

@riverpod
SampleModuleService sampleModuleService(Ref ref) => SampleModuleService(ref);
