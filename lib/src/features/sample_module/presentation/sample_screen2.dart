import 'package:flutter/material.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_app_bar.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_button_widget.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_circular_progress_widget.dart';
import 'package:tnds_flutter_app/src/constants/app_sizes.dart';
import 'package:tnds_flutter_app/src/extensions/context_extension.dart';
import 'package:tnds_flutter_app/src/features/sample_module/application/sample_screen2_controller.dart';
import 'package:tnds_flutter_app/src/features/sample_module/application/sample_module_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// หน้าที่ 2 ของ sample module — เป็น **หน้าภายในโมดูล** ที่ navigate ต่อจาก
/// [SampleScreen]. ไม่ใช่ทางเข้าโมดูล จึง **ไม่ใช้ `ModuleScaffold`** — จัดการแบบ
/// screen ฟีเจอร์ปกติ (Scaffold + back ปกติที่ pop กลับหน้า 1 ไม่แตะ session).
/// เข้าถึงได้เฉพาะตอน session พร้อมแล้ว (push มาจากหน้า 1) จึงอ่าน `moduleToken`
/// ได้ตรง ๆ. การจบ module ยังเป็น passive: เรียก `controller.complete()` เฉย ๆ
/// แล้ว caller เป็นคน navigate ออก.
class SampleScreen2 extends ConsumerWidget {
  const SampleScreen2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(sampleModuleControllerProvider.notifier);
    final actionAsync = ref.watch(sampleScreen2ControllerProvider);

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: CommonAppBar(titleText: 'Sample หน้า 2', isShowIconLeft: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.kP16),
          child: Column(
            children: [
              Text(
                'หน้านี้ใช้ module token ตอนยิง API (mock)',
                style: context.appTexts.bodyMdRegular,
                textAlign: TextAlign.center,
              ),
              kGapH16,
              actionAsync.when(
                loading: () => const CommonCircularProgressWidget(),
                error: (error, _) => Text(
                  'ยิง API ไม่สำเร็จ: $error',
                  style: context.appTexts.bodyMdRegular,
                  textAlign: TextAlign.center,
                ),
                data: (result) => Text(
                  result ?? 'ยังไม่ได้ยิง API',
                  style: context.appTexts.bodyMdRegular,
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              CommonButtonWidget(
                buttonText: 'ยิง API (ใช้ module token)',
                buttonStyleType: ButtonStyleType.secondary,
                onButtonPressed: () =>
                    ref.read(sampleScreen2ControllerProvider.notifier).run(),
              ),
              kGapH16,
              CommonButtonWidget(
                buttonText: 'เสร็จ (complete module)',
                // Passive: report completion only — the caller (onResult) owns
                // exit navigation. The screen must NOT pop itself.
                onButtonPressed: controller.complete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
