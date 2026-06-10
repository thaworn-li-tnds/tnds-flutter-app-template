import 'dart:convert';
import 'dart:io';

/// สร้างไฟล์ locale_keys.g.dart จาก JSON translation files
///
/// อ่านไฟล์ JSON ทั้งหมดใน assets/translations/th/ แล้วสร้าง constant keys
/// โดยเติม prefix จากชื่อไฟล์ (เช่น common.json -> common_key_name)
///
/// ตัวอย่าง:
/// - common.json มี key "camera.title" -> LocaleKeys.common_camera_title = 'common.camera.title'
/// - home.json มี key "welcome" -> LocaleKeys.home_welcome = 'home.welcome'
Future<void> main() async {
  const baseDir = 'assets/translations/th';
  const outDir = 'lib/generated';
  const outFile = 'locale_keys.g.dart';

  final dir = Directory(baseDir);
  if (!await dir.exists()) {
    throw Exception('Missing folder: $baseDir');
  }

  final files = await dir
      .list()
      .where((e) => e is File && e.path.toLowerCase().endsWith('.json'))
      .cast<File>()
      .toList();

  files.sort((a, b) => a.path.compareTo(b.path));

  // fullKey => constName
  final fullKeys = <String, String>{};
  final usedConstNames = <String>{};

  for (final file in files) {
    final prefix = _filePrefix(file); // common.json -> common
    final map = await _readJsonMap(file);

    // ✅ flatten nested keys: camera.title, camera.description, ...
    final flat = _flatten(map);

    for (final rawKey in flat.keys) {
      final k = rawKey; // e.g. camera.title OR app_logo_icon_path

      // ✅ เติม prefix ตามชื่อไฟล์ (ถ้า key ยังไม่มี prefix)
      final fullKey = k.contains('.') ? '$prefix.$k' : '$prefix.$k';
      // หมายเหตุ: ถึงจะเป็น flat key ก็จะได้ prefix.key ถูกอยู่

      final constName = _toConstName(fullKey); // dot -> underscore

      if (fullKeys.containsKey(fullKey)) {
        throw Exception(
          'Duplicate full key "$fullKey" found again in ${file.path}',
        );
      }
      if (usedConstNames.contains(constName)) {
        throw Exception('Const name collision: "$constName" (from "$fullKey")');
      }

      fullKeys[fullKey] = constName;
      usedConstNames.add(constName);
    }
  }

  final sorted = fullKeys.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  final out = Directory(outDir);
  await out.create(recursive: true);

  final dartFile = File('${out.path}/$outFile');
  await dartFile.writeAsString(_generateDart(sorted));

  stdout.writeln('✅ Generated ${dartFile.path} (${sorted.length} keys)');
}

/// ดึงชื่อไฟล์ (ไม่มี extension) เพื่อใช้เป็น prefix
///
/// ตัวอย่าง:
/// - common.json -> 'common'
/// - sme_th.json -> 'sme_th'
String _filePrefix(File file) {
  final name = file.uri.pathSegments.last; // common.json
  final dot = name.lastIndexOf('.');
  return dot == -1 ? name : name.substring(0, dot); // common
}

/// อ่านไฟล์ JSON และแปลงเป็น `Map<String, dynamic>`
///
/// throws Exception ถ้าไฟล์ไม่ใช่ valid JSON map
Future<Map<String, dynamic>> _readJsonMap(File file) async {
  final raw = await file.readAsString();
  final decoded = json.decode(raw);
  if (decoded is! Map) {
    throw Exception('Invalid JSON map: ${file.path}');
  }
  return decoded.map((k, v) => MapEntry('$k', v));
}

/// แปลง nested JSON structure เป็น flat map โดยใช้ dot notation
///
/// ตัวอย่าง:
/// Input:
/// ```json
/// {
///   "camera": {
///     "title": "Camera",
///     "settings": {
///       "brightness": "Brightness"
///     }
///   }
/// }
/// ```
///
/// Output:
/// ```dart
/// {
///   "camera.title": "Camera",
///   "camera.settings.brightness": "Brightness"
/// }
/// ```
///
/// [input] - JSON map ที่ต้องการ flatten
/// [parent] - prefix สำหรับ nested keys (ใช้ภายใน recursion)
Map<String, dynamic> _flatten(Map<String, dynamic> input, {String? parent}) {
  final out = <String, dynamic>{};
  for (final e in input.entries) {
    final key = parent == null ? e.key : '$parent.${e.key}';
    final v = e.value;

    if (v is Map) {
      // ensure keys are String
      final casted = v.map((k, v2) => MapEntry('$k', v2));
      out.addAll(_flatten(casted, parent: key));
    } else {
      out[key] = v;
    }
  }
  return out;
}

/// สร้าง Dart code สำหรับไฟล์ locale_keys.g.dart
///
/// สร้าง abstract class LocaleKeys ที่มี static const สำหรับแต่ละ translation key
///
/// ตัวอย่าง output:
/// ```dart
/// abstract class LocaleKeys {
///   static const common_camera_title = 'common.camera.title';
///   static const home_welcome = 'home.welcome';
/// }
/// ```
///
/// [items] - List ของ key pairs (fullKey -> constName)
String _generateDart(List<MapEntry<String, String>> items) {
  final b = StringBuffer();
  b.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  b.writeln('// ignore_for_file: constant_identifier_names');
  b.writeln();
  b.writeln('abstract class LocaleKeys {');

  for (final e in items) {
    final fullKey = e.key; // common.camera.title
    final constName = e.value; // common_camera_title
    b.writeln("  static const $constName = '$fullKey';");
  }

  b.writeln('}');
  return b.toString();
}

/// แปลง translation key เป็นชื่อ constant ที่ valid ใน Dart
///
/// การแปลง:
/// 1. แทนที่ dot (.) ด้วย underscore (_)
/// 2. เอาตัวอักษรที่ไม่ใช่ alphanumeric หรือ underscore ออก
/// 3. รวม underscore ที่ติดกันเป็นตัวเดียว
/// 4. เอา underscore ที่อยู่หัว/ท้ายออก
/// 5. ถ้าขึ้นต้นด้วยตัวเลข ให้เติม 'k_' ข้างหน้า
///
/// ตัวอย่าง:
/// - 'common.camera.title' -> 'common_camera_title'
/// - 'home.user-name' -> 'home_user_name'
/// - 'test.123' -> 'k_test_123'
///
/// [fullKey] - translation key แบบเต็ม (มี prefix แล้ว)
String _toConstName(String fullKey) {
  // common.camera.title -> common_camera_title
  var s = fullKey.replaceAll('.', '_');
  s = s.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  s = s.replaceAll(RegExp(r'_+'), '_');
  s = s.replaceAll(RegExp(r'^_+|_+$'), '');
  if (RegExp(r'^[0-9]').hasMatch(s)) s = 'k_$s';
  return s;
}
