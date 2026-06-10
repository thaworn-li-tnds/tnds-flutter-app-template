import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Discovered automatically by flutter_test; runs once per suite OUTSIDE the
/// fake-async zone of `testWidgets` — the only safe place to await
/// `EasyLocalization.ensureInitialized()`, which internally awaits
/// `SharedPreferences.getInstance()` and deadlocks inside a test body.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  EasyLocalization.logger.enableBuildModes = [];
  await EasyLocalization.ensureInitialized();
  await testMain();
}
