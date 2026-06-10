import 'package:flutter/material.dart';
import 'package:tnds_flutter_app/src/extensions/context_extension.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    this.titleText,
    this.isShowIconLeft = true,
    this.isShowIconRight = false,
    this.rightIcon = Icons.close,
    this.onClickIconRight,
  });

  final String? titleText;
  final bool isShowIconLeft;
  final bool isShowIconRight;
  final IconData rightIcon;
  final VoidCallback? onClickIconRight;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final text = titleText;
    return AppBar(
      backgroundColor: context.appColors.background,
      automaticallyImplyLeading: isShowIconLeft,
      title: text == null
          ? null
          : Text(text, style: context.appTexts.titleMdBold),
      centerTitle: true,
      actions: [
        if (isShowIconRight)
          IconButton(
            key: const Key('app_bar_right_icon'),
            icon: Icon(rightIcon),
            onPressed: onClickIconRight,
          ),
      ],
    );
  }
}
