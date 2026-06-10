import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tnds_flutter_app/generated/locale_keys.g.dart';

/// Server-driven directives attached to an error response. Orchestrating code
/// (controllers/services — never widgets) switches on these.
enum ActionCodeType {
  none(''),
  exitFlow('EXIT_FLOW');

  final String value;
  const ActionCodeType(this.value);

  static ActionCodeType from(String? value) {
    return ActionCodeType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ActionCodeType.none,
    );
  }
}

/// Base of every error in the app. All raw errors are translated through
/// [AppException.parse] — the single entry point — so the rest of the app
/// only ever handles typed exceptions. Add a subclass per failure mode that
/// needs distinct handling; never string-match messages at call sites.
sealed class AppException implements Exception {
  AppException(
    this.code,
    this.title,
    this.description, {
    String? actionCode,
    this.data,
  }) : _actionCode = actionCode ?? '';

  final String code;
  final String title;
  final String description;
  final dynamic data;

  final String _actionCode;
  ActionCodeType get actionCode => ActionCodeType.from(_actionCode);

  @override
  String toString() => description;

  static AppException parse({Object? error, StackTrace? stackTrace}) {
    if (error is AppException) return error;

    if (error is DioException) {
      // Per-backend translation (error envelope → typed exception) belongs
      // here once the app has a real API contract.
      return UnknownException(stackTrace);
    }

    return UnknownException(stackTrace);
  }
}

class UnknownException extends AppException {
  UnknownException([StackTrace? stackTrace])
      : super(
          '',
          LocaleKeys.common_error_title.tr(),
          LocaleKeys.common_error_description.tr(),
          data: stackTrace,
        );
}
