import 'package:tnds_flutter_app/src/features/sample_module/application/sample_screen_controller.dart';
import 'package:tnds_flutter_app/src/features/sample_module/application/sample_module_controller.dart';
import 'package:tnds_flutter_app/src/features/sample_module/domain/sample_launch_params.dart';
import 'package:tnds_flutter_app/src/features/sample_module/domain/sample_result.dart';
import 'package:tnds_flutter_app/src/shared/application/module_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Proves a non-auth module runs standalone: no auth, no registry, no router.

  test('start opens the session (ready); complete reports the result', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    SampleResult? result;
    final controller = container.read(sampleModuleControllerProvider.notifier);

    await controller.start(
      params: const SampleLaunchParams(title: 'hi'),
      onCompleted: (r) => result = r,
    );

    // Module controller holds session state only — ready once started.
    expect(
      container.read(sampleModuleControllerProvider),
      isA<ModuleSessionReady>(),
    );

    await controller.complete();

    expect(result, isNotNull);
    expect(result!.value, 'sample-result-value');
  });

  test('home controller loads its own content once the session is ready', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(sampleModuleControllerProvider.notifier)
        .start(
          params: const SampleLaunchParams(id: 'cp-1'),
          onCompleted: (_) {},
        );

    // Per-screen content lives in its own controller, not the module controller.
    final message = await container.read(sampleScreenControllerProvider.future);
    expect(message, contains('cp-1'));
  });

  test('cancel reports back through onCancelled and closes the session', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var cancelled = false;
    final controller = container.read(sampleModuleControllerProvider.notifier);
    await controller.start(
      params: const SampleLaunchParams(),
      onCompleted: (_) {},
      onCancelled: () => cancelled = true,
    );

    await controller.cancel();
    expect(cancelled, isTrue);
    expect(
      container.read(sampleModuleControllerProvider),
      isA<ModuleSessionClosed>(),
    );
  });

  test('terminal: complete runs once; a later complete/cancel is a no-op', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var completedCount = 0;
    var cancelled = false;
    final controller = container.read(sampleModuleControllerProvider.notifier);
    await controller.start(
      params: const SampleLaunchParams(title: 'hi'),
      onCompleted: (_) => completedCount++,
      onCancelled: () => cancelled = true,
    );

    await controller.complete();
    await controller.complete(); // double-tap / late tap from another screen
    await controller.cancel(); // back pressed after finishing

    expect(completedCount, 1);
    expect(cancelled, isFalse);
    expect(
      container.read(sampleModuleControllerProvider),
      isA<ModuleSessionClosed>(),
    );
  });
}
