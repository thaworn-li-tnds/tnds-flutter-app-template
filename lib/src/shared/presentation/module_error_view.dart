import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tnds_flutter_app/generated/locale_keys.g.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_button_widget.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_error_widget.dart';
import 'package:tnds_flutter_app/src/constants/app_sizes.dart';

/// Escapable error view for a launchable module screen. Shows the standard
/// [CommonErrorWidget] plus a single Close action so the user is never trapped
/// — used by [ModuleScaffold] for the failed / not-launched states regardless
/// of the module's `backTarget`. No retry by design: a session/finish failure
/// already auto-reports `failed` to the caller (which unwinds the flow); Close
/// is just the in-screen escape.
class ModuleErrorView extends StatelessWidget {
  const ModuleErrorView({
    super.key,
    required this.onClose,
    this.error,
    this.closeText,
  });

  /// The failure cause (null when the screen was reached without a launch).
  final Object? error;
  final VoidCallback onClose;
  final String? closeText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.kP16),
      child: Column(
        children: [
          Expanded(
            child: Center(child: CommonErrorWidget(exception: error)),
          ),
          CommonButtonWidget(
            buttonText: closeText ?? LocaleKeys.common_close.tr(),
            onButtonPressed: onClose,
          ),
        ],
      ),
    );
  }
}
