import 'package:tnds_flutter_app/src/features/sample_module/application/sample_module_controller.dart';
import 'package:tnds_flutter_app/src/features/sample_module/application/sample_screen_service.dart';
import 'package:tnds_flutter_app/src/shared/application/module_screen_content.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sample_screen_controller.g.dart';

/// Per-screen controller for the sample module's first screen — auto-disposed
/// when the screen pops. Loads its own content once the module session is
/// ready, using the launch params held by [SampleModuleController].
@riverpod
class SampleScreenController extends _$SampleScreenController {
  @override
  Future<String> build() => loadWhenSessionReady(
    ref,
    sampleModuleControllerProvider,
    () => ref
        .read(sampleScreenServiceProvider)
        .loadData(
          ref.read(sampleModuleControllerProvider.notifier).launchParams.id,
        ),
  );
}
