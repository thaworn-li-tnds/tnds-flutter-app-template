import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tnds_flutter_app/generated/locale_keys.g.dart';
import 'package:tnds_flutter_app/src/constants/app_sizes.dart';
import 'package:tnds_flutter_app/src/extensions/context_extension.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';

/// The title / amount / category inputs shared by the create AND edit screens.
/// Extracted so the two screens stay in sync (same keys, same validators) and
/// neither duplicates the form — each screen owns only its own [Form] key,
/// controllers, submit target and button. The widget is stateless: the caller
/// holds the [TextEditingController]s and the selected category.
class ExpenseFormFields extends StatelessWidget {
  const ExpenseFormFields({
    super.key,
    required this.titleController,
    required this.amountController,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final TextEditingController titleController;
  final TextEditingController amountController;
  final ExpenseCategory selectedCategory;
  final ValueChanged<ExpenseCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: const Key('expense_title_field'),
          controller: titleController,
          decoration: InputDecoration(
            labelText: LocaleKeys.expense_create_title_label.tr(),
          ),
          validator: (value) => (value == null || value.trim().isEmpty)
              ? LocaleKeys.expense_create_title_required.tr()
              : null,
        ),
        kGapH16,
        TextFormField(
          key: const Key('expense_amount_field'),
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: LocaleKeys.expense_create_amount_label.tr(),
          ),
          validator: (value) {
            final amount = double.tryParse(value ?? '');
            return (amount == null || amount <= 0)
                ? LocaleKeys.expense_create_amount_invalid.tr()
                : null;
          },
        ),
        kGapH24,
        Text(
          LocaleKeys.expense_create_category_label.tr(),
          style: context.appTexts.bodySmRegular.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        kGapH8,
        _CategoryPicker(
          selected: selectedCategory,
          onSelected: onCategorySelected,
        ),
      ],
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({required this.selected, required this.onSelected});

  final ExpenseCategory selected;
  final ValueChanged<ExpenseCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Sizes.kP8,
      runSpacing: Sizes.kP8,
      children: [
        for (final category in ExpenseCategory.values)
          ChoiceChip(
            key: Key('expense_category_chip_${category.name}'),
            label: Text(category.labelKey.tr()),
            selected: selected == category,
            onSelected: (_) => onSelected(category),
          ),
      ],
    );
  }
}
