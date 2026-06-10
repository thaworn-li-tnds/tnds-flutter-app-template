import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tnds_flutter_app/generated/locale_keys.g.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_app_bar.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_button_widget.dart';
import 'package:tnds_flutter_app/src/constants/app_sizes.dart';
import 'package:tnds_flutter_app/src/features/expense/router/expense_router.dart';

/// Template home screen — a plain menu into the example features. Replace it
/// when building a real app from the template. Cross-feature it touches ONLY
/// the expense `router/` enum (navigation surface) — never another feature's
/// `application/` or `presentation/`.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        titleText: LocaleKeys.home_title.tr(),
        isShowIconLeft: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.kP16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              CommonButtonWidget(
                buttonKey: const Key('open_expense_button'),
                buttonText: LocaleKeys.expense_home_entry_button.tr(),
                onButtonPressed: () =>
                    context.pushNamed(ExpenseRouter.expenseList.name),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
