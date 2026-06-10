import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';

part 'error_logger.g.dart';

/// Single sink for error reporting. Wire a crash reporter (e.g. Crashlytics)
/// here per app — call sites stay unchanged. Never use `print()` in lib/src/.
class ErrorLogger {
  void logError(Object error, StackTrace? stackTrace) {
    developer.log('error', error: error, stackTrace: stackTrace, level: 1000);
  }

  void logAppException(AppException exception) {
    developer.log('appException', error: exception, level: 900);
  }
}

@Riverpod(keepAlive: true)
ErrorLogger errorLogger(Ref ref) => ErrorLogger();
