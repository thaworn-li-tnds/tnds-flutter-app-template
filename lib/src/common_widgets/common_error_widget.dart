import 'package:flutter/material.dart';
import 'package:tnds_flutter_app/src/constants/app_sizes.dart';
import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';
import 'package:tnds_flutter_app/src/extensions/context_extension.dart';

/// Standard error state. Renders the localized title/description from the
/// [AppException] (raw errors are parsed first) — never raw `e.toString()`.
class CommonErrorWidget extends StatelessWidget {
  const CommonErrorWidget({super.key, this.exception, this.stackTrace});

  final Object? exception;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    final appException =
        AppException.parse(error: exception, stackTrace: stackTrace);

    return Padding(
      padding: const EdgeInsets.all(Sizes.kP16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: Sizes.kP48,
            color: context.appColors.error,
          ),
          kGapH16,
          Text(
            appException.title,
            style: context.appTexts.titleMdBold,
            textAlign: TextAlign.center,
          ),
          kGapH8,
          Text(
            appException.description,
            style: context.appTexts.bodyMdRegular
                .copyWith(color: context.appColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
