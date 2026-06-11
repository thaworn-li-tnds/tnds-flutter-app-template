import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tnds_flutter_app/generated/locale_keys.g.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_app_bar.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_button_widget.dart';
import 'package:tnds_flutter_app/src/common_widgets/system_async_value_widget.dart';
import 'package:tnds_flutter_app/src/constants/app_sizes.dart';
import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';
import 'package:tnds_flutter_app/src/extensions/context_extension.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/delete_expense_controller.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/expense_detail_controller.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/expense_list_controller.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/widgets/expense_category_icon.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/widgets/money_format.dart';
import 'package:tnds_flutter_app/src/features/expense/router/expense_router.dart';

/// Detail screen — [expenseId] arrives via the route's queryParameters. An
/// unknown id makes the repository throw, which surfaces here as the default
/// error state of [SystemAsyncValueWidget]: bad deeplinks degrade, never
/// crash. This is also where the two write actions live: edit (app-bar action,
/// re-uses the read path by passing the id forward) and delete (a confirmed
/// destructive action in the body).
class ExpenseDetailScreen extends ConsumerWidget {
  const ExpenseDetailScreen({super.key, required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A successful delete refreshes the list (its watcher reloads itself) and
    // leaves this screen. `bool?` state: null = idle build, true = deleted.
    ref.listen(deleteExpenseControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (deleted) {
          if (deleted != true) return;
          ref.invalidate(expenseListControllerProvider);
          context.pop();
        },
      );
    });

    // Family provider: state is scoped per expenseId.
    final expenseAsync = ref.watch(expenseDetailControllerProvider(expenseId));

    return Scaffold(
      appBar: CommonAppBar(
        titleText: LocaleKeys.expense_detail_title.tr(),
        isShowIconRight: true,
        rightIcon: Icons.edit_outlined,
        onClickIconRight: () => context.pushNamed(
          ExpenseRouter.editExpense.name,
          queryParameters: {'id': expenseId},
        ),
      ),
      body: SafeArea(
        child: SystemAsyncValueWidget<Expense>(
          value: expenseAsync,
          data: (expense) => _ExpenseDetailBody(expense: expense),
        ),
      ),
    );
  }
}

class _ExpenseDetailBody extends ConsumerWidget {
  const _ExpenseDetailBody({required this.expense});

  final Expense expense;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('delete_expense_dialog'),
        title: Text(LocaleKeys.expense_detail_delete_confirm_title.tr()),
        content: Text(LocaleKeys.expense_detail_delete_confirm_message.tr()),
        actions: [
          TextButton(
            key: const Key('delete_expense_cancel'),
            // Dismiss the dialog via its own Navigator, not go_router's pop.
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(LocaleKeys.common_cancel.tr()),
          ),
          TextButton(
            key: const Key('delete_expense_confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(LocaleKeys.expense_detail_delete_button.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(deleteExpenseControllerProvider.notifier).delete(expense.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deleteState = ref.watch(deleteExpenseControllerProvider);

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
          const Spacer(),
          if (deleteState.hasError)
            Padding(
              padding: const EdgeInsets.only(bottom: Sizes.kP12),
              child: Text(
                AppException.parse(error: deleteState.error).description,
                key: const Key('delete_expense_error'),
                style: context.appTexts.bodyMdRegular.copyWith(
                  color: context.appColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          CommonButtonWidget(
            buttonKey: const Key('delete_expense_button'),
            buttonStyleType: ButtonStyleType.secondary,
            buttonText: LocaleKeys.expense_detail_delete_button.tr(),
            onButtonPressed: deleteState.isLoading
                ? null
                : () => _confirmDelete(context, ref),
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
