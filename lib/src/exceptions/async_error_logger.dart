import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';
import 'package:tnds_flutter_app/src/exceptions/error_logger.dart';

/// ProviderObserver that logs every provider landing in [AsyncError] —
/// so controllers only need `AsyncValue.guard`; no manual logging.
class AsyncErrorLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    final error = _findError(newValue);
    if (error == null) return;

    final logger = container.read(errorLoggerProvider);
    final exception = error.error;
    if (exception is AppException) {
      logger.logAppException(exception);
    } else {
      logger.logError(error.error, error.stackTrace);
    }
  }

  AsyncError<dynamic>? _findError(Object? value) =>
      value is AsyncError ? value : null;
}
