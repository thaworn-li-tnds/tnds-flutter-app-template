import 'package:flutter/material.dart';
import 'package:tnds_flutter_app/src/constants/app_sizes.dart';
import 'package:tnds_flutter_app/src/extensions/context_extension.dart';

enum ButtonStyleType { primary, secondary }

class CommonButtonWidget extends StatelessWidget {
  const CommonButtonWidget({
    super.key,
    required this.buttonText,
    required this.onButtonPressed,
    this.buttonStyleType = ButtonStyleType.primary,
    this.buttonKey,
  });

  final String buttonText;
  final VoidCallback? onButtonPressed;
  final ButtonStyleType buttonStyleType;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isPrimary = buttonStyleType == ButtonStyleType.primary;

    return SizedBox(
      width: double.infinity,
      height: Sizes.kP48,
      child: FilledButton(
        key: buttonKey,
        style: FilledButton.styleFrom(
          backgroundColor: isPrimary ? colors.brand : colors.surface,
          foregroundColor: isPrimary ? colors.surface : colors.brand,
          side: isPrimary ? null : BorderSide(color: colors.brand),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(kRadius8),
          ),
        ),
        onPressed: onButtonPressed,
        child: Text(buttonText, style: context.appTexts.bodyMdBold),
      ),
    );
  }
}
