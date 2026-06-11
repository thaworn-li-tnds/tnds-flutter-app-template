import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tnds_flutter_app/generated/locale_keys.g.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_app_bar.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_button_widget.dart';
import 'package:tnds_flutter_app/src/common_widgets/system_async_value_widget.dart';
import 'package:tnds_flutter_app/src/constants/app_sizes.dart';
import 'package:tnds_flutter_app/src/extensions/context_extension.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_overview.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/expense_filter_controller.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/expense_list_controller.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/widgets/expense_category_icon.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/widgets/money_format.dart';
import 'package:tnds_flutter_app/src/features/expense/router/expense_router.dart';

/// List screen. The screen itself only gates the initial load
/// ([SystemAsyncValueWidget]); [_SummaryHeader] and [_ExpenseListView] each
/// `ref.watch` [filteredExpenseOverviewProvider], so one tap on a filter chip
/// updates BOTH — single source of truth, no widget-to-widget syncing.
class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(expenseListControllerProvider);

    return Scaffold(
      appBar: CommonAppBar(
        titleText: LocaleKeys.expense_list_title.tr(),
        isShowIconRight: true,
        // Default rightIcon is Icons.close — always override for an action.
        rightIcon: Icons.savings_outlined,
        onClickIconRight: () =>
            context.pushNamed(ExpenseRouter.budgetOverview.name),
      ),
      body: SafeArea(
        child: SystemAsyncValueWidget<ExpenseOverview>(
          value: overviewAsync,
          onRefresh: () => ref.refresh(expenseListControllerProvider.future),
          data: (_) => const _ExpenseListBody(),
        ),
      ),
    );
  }
}

class _ExpenseListBody extends ConsumerWidget {
  const _ExpenseListBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.kP16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SummaryHeader(),
          kGapH16,
          const _CategoryFilterChips(),
          kGapH8,
          const Expanded(child: _ExpenseListView()),
          kGapH16,
          CommonButtonWidget(
            buttonKey: const Key('add_expense_button'),
            buttonText: LocaleKeys.expense_list_add_button.tr(),
            onButtonPressed: () =>
                context.pushNamed(ExpenseRouter.createExpense.name),
          ),
        ],
      ),
    );
  }
}

class _SummaryHeader extends ConsumerWidget {
  const _SummaryHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches the same derived provider as _ExpenseListView — both rebuild
    // together when the filter or the list changes.
    final overview =
        ref.watch(filteredExpenseOverviewProvider).valueOrNull ??
        const ExpenseOverview();

    return Container(
      padding: const EdgeInsets.all(Sizes.kP16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: const BorderRadius.all(kRadius12),
        boxShadow: kShadowXs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.expense_list_total.tr(),
            style: context.appTexts.bodySmRegular.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          kGapH4,
          Text(
            overview.summary.total.formatted,
            key: const Key('expense_total_label'),
            style: context.appTexts.titleLgBold,
          ),
          if (overview.summary.totalByCategory.isNotEmpty) kGapH8,
          for (final entry in overview.summary.totalByCategory.entries)
            Text(
              '${entry.key.labelKey.tr()}  ${entry.value.formatted}',
              style: context.appTexts.bodySmRegular.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryFilterChips extends ConsumerWidget {
  const _CategoryFilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(expenseFilterControllerProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            key: const Key('expense_filter_chip_all'),
            label: Text(LocaleKeys.expense_filter_all.tr()),
            selected: selected == null,
            // ref.read in a callback — one state write here fans out to every
            // watcher of filteredExpenseOverviewProvider.
            onSelected: (_) =>
                ref.read(expenseFilterControllerProvider.notifier).select(null),
          ),
          for (final category in ExpenseCategory.values) ...[
            kGapW8,
            ChoiceChip(
              key: Key('expense_filter_chip_${category.name}'),
              label: Text(category.labelKey.tr()),
              selected: selected == category,
              onSelected: (_) => ref
                  .read(expenseFilterControllerProvider.notifier)
                  .select(category),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpenseListView extends ConsumerWidget {
  const _ExpenseListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses =
        ref.watch(filteredExpenseOverviewProvider).valueOrNull?.expenses ??
        const <Expense>[];

    if (expenses.isEmpty) return const _EmptyExpenseList();

    return ListView.separated(
      key: const Key('expense_list'),
      itemCount: expenses.length,
      separatorBuilder: (_, _) => kGapH8,
      itemBuilder: (context, index) => _ExpenseTile(expense: expenses[index]),
    );
  }
}

class _EmptyExpenseList extends StatelessWidget {
  const _EmptyExpenseList();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        LocaleKeys.expense_list_empty.tr(),
        key: const Key('expense_empty_state'),
        style: context.appTexts.bodyMdRegular.copyWith(
          color: context.appColors.textSecondary,
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('expense_tile_${expense.id}'),
      tileColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(kRadius8),
      ),
      leading: Icon(expense.category.icon, color: context.appColors.brand),
      title: Text(expense.title, style: context.appTexts.bodyMdBold),
      subtitle: Text(
        expense.date,
        style: context.appTexts.bodySmRegular.copyWith(
          color: context.appColors.textSecondary,
        ),
      ),
      trailing: Text(
        expense.money.formatted,
        style: context.appTexts.bodyMdBold,
      ),
      onTap: () => context.pushNamed(
        ExpenseRouter.expenseDetail.name,
        queryParameters: {'id': expense.id},
      ),
    );
  }
}
