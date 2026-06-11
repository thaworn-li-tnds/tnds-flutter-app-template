import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tnds_flutter_app/generated/locale_keys.g.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_app_bar.dart';
import 'package:tnds_flutter_app/src/common_widgets/system_async_value_widget.dart';
import 'package:tnds_flutter_app/src/constants/app_sizes.dart';
import 'package:tnds_flutter_app/src/extensions/context_extension.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/budget_overview.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/category_budget_status.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/budget_overview_controller.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/widgets/expense_category_icon.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/widgets/money_format.dart';

/// Renders the joined object graph. Every number on this screen
/// ([CategoryBudgetStatus.spent], `remaining`, `utilization`) was DERIVED by
/// the service/domain — none of it exists on the wire.
class BudgetOverviewScreen extends ConsumerWidget {
  const BudgetOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(budgetOverviewControllerProvider);

    return Scaffold(
      appBar: CommonAppBar(titleText: LocaleKeys.expense_budget_title.tr()),
      body: SafeArea(
        child: SystemAsyncValueWidget<BudgetOverview>(
          value: overviewAsync,
          onRefresh: () => ref.refresh(budgetOverviewControllerProvider.future),
          data: (overview) => _BudgetOverviewBody(overview: overview),
        ),
      ),
    );
  }
}

class _BudgetOverviewBody extends StatelessWidget {
  const _BudgetOverviewBody({required this.overview});

  final BudgetOverview overview;

  @override
  Widget build(BuildContext context) {
    if (overview.statuses.isEmpty) return const _EmptyBudgetOverview();

    return ListView(
      key: const Key('budget_list'),
      padding: const EdgeInsets.all(Sizes.kP16),
      children: [
        if (overview.month.isNotEmpty) ...[
          Text(
            overview.month,
            key: const Key('budget_month_label'),
            style: context.appTexts.bodySmRegular.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          kGapH8,
        ],
        for (final status in overview.statuses) ...[
          _BudgetStatusCard(status: status),
          kGapH8,
        ],
      ],
    );
  }
}

class _EmptyBudgetOverview extends StatelessWidget {
  const _EmptyBudgetOverview();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        LocaleKeys.expense_budget_empty.tr(),
        key: const Key('budget_empty_state'),
        style: context.appTexts.bodyMdRegular.copyWith(
          color: context.appColors.textSecondary,
        ),
      ),
    );
  }
}

class _BudgetStatusCard extends StatelessWidget {
  const _BudgetStatusCard({required this.status});

  final CategoryBudgetStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('budget_card_${status.category.name}'),
      padding: const EdgeInsets.all(Sizes.kP16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: const BorderRadius.all(kRadius12),
        boxShadow: kShadowXs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(status.category.icon, color: context.appColors.brand),
              kGapW8,
              Expanded(
                child: Text(
                  status.category.labelKey.tr(),
                  style: context.appTexts.bodyMdBold,
                ),
              ),
              Text(
                status.spent.formatted,
                key: Key('budget_spent_label_${status.category.name}'),
                style: context.appTexts.bodyMdBold,
              ),
            ],
          ),
          kGapH8,
          if (status.hasBudget)
            _BudgetProgress(status: status)
          else
            Text(
              LocaleKeys.expense_budget_no_budget.tr(),
              key: Key('budget_no_budget_label_${status.category.name}'),
              style: context.appTexts.bodySmRegular.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  const _BudgetProgress({required this.status});

  final CategoryBudgetStatus status;

  @override
  Widget build(BuildContext context) {
    final budget = status.budget!;
    final isOver = status.isOverBudget;
    final statusColor = isOver
        ? context.appColors.error
        : context.appColors.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(kRadiusFull),
          child: LinearProgressIndicator(
            // utilization may exceed 1.0 (over budget) or be null (zero
            // limit) — clamping for DISPLAY happens here, never in domain.
            value: (status.utilization ?? (isOver ? 1 : 0)).clamp(0.0, 1.0),
            minHeight: Sizes.kP8,
            color: statusColor,
            backgroundColor: context.appColors.background,
          ),
        ),
        kGapH4,
        Row(
          children: [
            Expanded(
              child: Text(
                LocaleKeys.expense_budget_limit.tr(
                  args: [budget.limit.formatted],
                ),
                style: context.appTexts.bodySmRegular.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
            ),
            if (isOver)
              Text(
                LocaleKeys.expense_budget_over_by.tr(
                  args: [(status.spent - budget.limit).formatted],
                ),
                key: Key('budget_over_label_${status.category.name}'),
                style: context.appTexts.bodySmRegular.copyWith(
                  color: context.appColors.error,
                ),
              )
            else
              Text(
                LocaleKeys.expense_budget_remaining.tr(
                  args: [status.remaining!.formatted],
                ),
                key: Key('budget_remaining_label_${status.category.name}'),
                style: context.appTexts.bodySmRegular.copyWith(
                  color: context.appColors.success,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
