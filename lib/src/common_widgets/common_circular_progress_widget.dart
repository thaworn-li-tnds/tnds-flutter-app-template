import 'package:flutter/material.dart';
import 'package:tnds_flutter_app/src/extensions/context_extension.dart';

class CommonCircularProgressWidget extends StatelessWidget {
  const CommonCircularProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.appColors.brand),
    );
  }
}
