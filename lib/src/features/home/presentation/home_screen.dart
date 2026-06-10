import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_app_bar.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_button_widget.dart';
import 'package:tnds_flutter_app/src/constants/app_sizes.dart';
import 'package:tnds_flutter_app/src/extensions/context_extension.dart';
import 'package:tnds_flutter_app/src/localization/string_hardcoded.dart';
import 'package:tnds_flutter_app/src/shared/application/launchable_module.dart';
import 'package:tnds_flutter_app/src/shared/application/module_launcher_registry.dart';

/// Template home screen. Demonstrates the caller side of the launchable-module
/// framework: launches `sample_module` generically through
/// [moduleLauncherRegistry] by id — importing ONLY `shared/`, never the target
/// module. Replace this screen when building a real app from the template.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _status = 'Module not launched yet'.hardcoded;

  void _launchSample() {
    final sample = ref.read(moduleLauncherRegistryProvider)['sample'];

    sample?.launch(
      ModuleLaunchContext(
        args: {
          'title': 'Launched from home'.hardcoded,
          'id': 'sample-id-123',
        },
        navOptions: const ModuleNavOptions(
          entryMode: ModuleEntryMode.push,
          backTarget: ModuleBackTarget.opener,
        ),
      ),
      (result) {
        setState(() {
          _status =
              'result: ${result.status.name} token: ${result.token}'.hardcoded;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        titleText: 'TNDS Flutter App'.hardcoded,
        isShowIconLeft: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.kP16),
          child: Column(
            children: [
              Text(
                _status,
                key: const Key('home_status'),
                style: context.appTexts.bodyMdRegular,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CommonButtonWidget(
                buttonKey: const Key('launch_sample_button'),
                buttonText: 'Launch sample module'.hardcoded,
                onButtonPressed: _launchSample,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
