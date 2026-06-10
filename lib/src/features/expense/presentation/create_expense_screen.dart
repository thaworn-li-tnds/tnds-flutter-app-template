import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tnds_flutter_app/generated/locale_keys.g.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_app_bar.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_button_widget.dart';
import 'package:tnds_flutter_app/src/constants/app_sizes.dart';
import 'package:tnds_flutter_app/src/exceptions/app_exception.dart';
import 'package:tnds_flutter_app/src/extensions/context_extension.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/create_expense_controller.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/expense_list_controller.dart';

/// Create form. `ConsumerStatefulWidget` is correct here because the State
/// holds LOCAL form inputs only (text controllers, picked category) — server
/// state never lives in a StatefulWidget; the submit round-trip belongs to
/// [CreateExpenseController].
class CreateExpenseScreen extends ConsumerStatefulWidget {
  const CreateExpenseScreen({super.key});

  @override
  ConsumerState<CreateExpenseScreen> createState() =>
      _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends ConsumerState<CreateExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.food;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // ref.read in a callback — never ref.watch.
    ref
        .read(createExpenseControllerProvider.notifier)
        .submit(
          title: _titleController.text.trim(),
          category: _category,
          amount: _amountController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen = side effects (navigation) — never inside .when(data:).
    ref.listen(createExpenseControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (expense) {
          if (expense == null) return; // idle state, not a result
          // One invalidate re-runs the list load; every watcher of the list
          // (and of the derived filtered provider) updates by itself.
          ref.invalidate(expenseListControllerProvider);
          context.pop();
        },
      );
    });

    final submitState = ref.watch(createExpenseControllerProvider);

    return Scaffold(
      appBar: CommonAppBar(titleText: LocaleKeys.expense_create_title.tr()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.kP16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('expense_title_field'),
                  controller: _titleController,
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
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
                  selected: _category,
                  onSelected: (category) =>
                      setState(() => _category = category),
                ),
                const Spacer(),
                if (submitState.hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Sizes.kP12),
                    child: Text(
                      AppException.parse(error: submitState.error).description,
                      key: const Key('create_expense_error'),
                      style: context.appTexts.bodyMdRegular.copyWith(
                        color: context.appColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                CommonButtonWidget(
                  buttonKey: const Key('save_expense_button'),
                  buttonText: LocaleKeys.expense_create_save_button.tr(),
                  onButtonPressed: submitState.isLoading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
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
