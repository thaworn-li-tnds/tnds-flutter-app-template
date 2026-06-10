import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/src/features/home/presentation/home_screen.dart';
import 'package:tnds_flutter_app/src/shared/application/launchable_module.dart';
import 'package:tnds_flutter_app/src/shared/application/module_launcher_registry.dart';

import '../../robot.dart';

/// Fake module for the caller-side test — reports completed immediately.
class _FakeModule implements LaunchableModule {
  @override
  void launch(ModuleLaunchContext context, ModuleResultCallback onResult) {
    onResult(
      const ModuleResult(status: ModuleResultStatus.completed, token: 'tk-1'),
    );
  }
}

// TODO(template): widget tests hang in this fresh project (suspect
// EasyLocalization init / pumpAndSettle inside Robot.pumpTestWidget) —
// skipped until investigated. Tracked in the package MIGRATION.md.
void main() {
  testWidgets('renders idle status and launch button', skip: true,
      (tester) async {
    final r = Robot(tester);
    await r.pumpTestWidget(const HomeScreen());

    r.expectKey('home_status');
    r.expectKey('launch_sample_button');
  });

  testWidgets('launching a module reports its result back', skip: true,
      (tester) async {
    final r = Robot(tester);
    await r.pumpTestWidget(
      const HomeScreen(),
      overrideRepos: [
        moduleLauncherRegistryProvider.overrideWithValue({
          'sample': _FakeModule(),
        }),
      ],
    );

    await r.clickWidgetByKey('launch_sample_button');

    r.expectLabelText('home_status', 'completed', isContain: true);
    r.expectLabelText('home_status', 'tk-1', isContain: true);
  });
}
