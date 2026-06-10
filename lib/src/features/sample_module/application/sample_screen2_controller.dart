import 'package:tnds_flutter_app/src/features/sample_module/application/sample_module_controller.dart';
import 'package:tnds_flutter_app/src/features/sample_module/application/sample_screen_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sample_screen2_controller.g.dart';

/// Controller สำหรับหน้าที่ 2 ของ sample module — auto-disposed เมื่อหน้าจอ
/// ถูก pop. เป็น feature work (ไม่ใช่ module-control) จึงไม่มี `Module` ในชื่อ
/// (rule 09). ต่างจาก content controller ตรงที่ไม่ได้โหลดตอนเข้าหน้า แต่ยิง API
/// เมื่อผู้ใช้กดปุ่ม โดยอ่าน session token แบบ one-shot จาก
/// [SampleModuleController] ตอนนั้น.
@riverpod
class SampleScreen2Controller extends _$SampleScreen2Controller {
  @override
  Future<String?> build() async => null;

  /// ยิง mock API โดยใช้ session token. อ่าน `moduleToken` แบบ one-shot ตอนถูกกด
  /// (session เป็น Ready แน่นอนเพราะมาถึงหน้า 2 ในโมดูลแล้ว) แล้วเรียกผ่าน service
  /// ตามลำดับ Controller → Service → Repository.
  Future<void> run() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      final token =
          ref.read(sampleModuleControllerProvider.notifier).moduleToken;
      return ref.read(sampleScreenServiceProvider).doAction(token);
    });
  }
}
