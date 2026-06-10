import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tnds_flutter_app/generated/locale_keys.g.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_app_bar.dart';
import 'package:tnds_flutter_app/src/common_widgets/system_async_value_widget.dart';
import 'package:tnds_flutter_app/src/constants/app_sizes.dart';
import 'package:tnds_flutter_app/src/extensions/context_extension.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/expense_detail_controller.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/widgets/expense_category_icon.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/widgets/money_format.dart';

/// Detail screen — [expenseId] arrives via the route's queryParameters. An
/// unknown id makes the repository throw, which surfaces here as the default
/// error state of [SystemAsyncValueWidget]: bad deeplinks degrade, never
/// crash.
class ExpenseDetailScreen extends ConsumerWidget {
  const ExpenseDetailScreen({super.key, required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Family provider: state is scoped per expenseId.
    final expenseAsync = ref.watch(expenseDetailControllerProvider(expenseId));

    return Scaffold(
      appBar: CommonAppBar(titleText: LocaleKeys.expense_detail_title.tr()),
      body: SafeArea(
        child: SystemAsyncValueWidget<Expense>(
          value: expenseAsync,
          data: (expense) => _ExpenseDetailBody(expense: expense),
        ),
      ),
    );
  }
}

class _ExpenseDetailBody extends StatelessWidget {
  const _ExpenseDetailBody({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.kP16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(expense.category.icon, color: context.appColors.brand),
              kGapW12,
              Expanded(
                child: Text(
                  expense.title,
                  key: const Key('expense_detail_title'),
                  style: context.appTexts.titleLgBold,
                ),
              ),
            ],
          ),
          kGapH24,
          _DetailRow(
            valueKey: 'expense_detail_category',
            label: LocaleKeys.expense_detail_category.tr(),
            value: expense.category.labelKey.tr(),
          ),
          kGapH16,
          _DetailRow(
            valueKey: 'expense_detail_amount',
            label: LocaleKeys.expense_detail_amount.tr(),
            value: expense.money.formatted,
          ),
          kGapH16,
          _DetailRow(
            valueKey: 'expense_detail_date',
            label: LocaleKeys.expense_detail_date.tr(),
            value: expense.date,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.valueKey,
    required this.label,
    required this.value,
  });

  final String valueKey;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.appTexts.bodySmRegular.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        kGapH4,
        Text(value, key: Key(valueKey), style: context.appTexts.bodyLgRegular),
      ],
    );
  }
}
