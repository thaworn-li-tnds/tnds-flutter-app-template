import 'package:flutter/material.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_button_widget.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_circular_progress_widget.dart';
import 'package:tnds_flutter_app/src/constants/app_sizes.dart';
import 'package:tnds_flutter_app/src/extensions/context_extension.dart';
import 'package:tnds_flutter_app/src/features/sample_module/application/sample_module_controller.dart';
import 'package:tnds_flutter_app/src/features/sample_module/application/sample_screen_controller.dart';
import 'package:tnds_flutter_app/src/features/sample_module/router/sample_router.dart';
import 'package:tnds_flutter_app/src/shared/presentation/module_error_view.dart';
import 'package:tnds_flutter_app/src/shared/presentation/module_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Sample module screen (mock). Content + finish button live in the [ready]
/// branch; loading / failed / not-launched states are handled uniformly (and
/// escapably) by [ModuleScaffold].
class SampleScreen extends ConsumerWidget {
  const SampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(sampleModuleControllerProvider.notifier);
    final messageAsync = ref.watch(sampleScreenControllerProvider);

    return ModuleScaffold(
      title: 'Sample Screen 1',
      controllerProvider: sampleModuleControllerProvider,
      ready: (context, onErrorClose) => messageAsync.when(
        loading: () => const Center(child: CommonCircularProgressWidget()),
        error: (error, _) =>
            ModuleErrorView(error: error, onClose: onErrorClose),
        data: (message) => Padding(
          padding: const EdgeInsets.all(Sizes.kP16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                style: context.appTexts.bodyMdRegular,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CommonButtonWidget(
                buttonText: 'ไปหน้า 2',
                buttonStyleType: ButtonStyleType.secondary,
                onButtonPressed: () =>
                    context.pushNamed(SampleModuleRouter.screen2.name),
              ),
              kGapH16,
              CommonButtonWidget(
                buttonText: 'เสร็จ (ส่งผลกลับ caller)',
                // Passive: report completion only — the caller (onResult) owns
                // navigation away. The screen must NOT pop here, or it would
                // race the caller's own navigation.
                onButtonPressed: controller.complete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
