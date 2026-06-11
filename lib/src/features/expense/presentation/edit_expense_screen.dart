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
import 'package:tnds_flutter_app/src/features/expense/presentation/edit_expense_controller.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/expense_detail_controller.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/expense_list_controller.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/widgets/expense_form_fields.dart';

/// Edit form. Two responsibilities split by widget: the screen GATES on the
/// current expense load ([SystemAsyncValueWidget]) so an unknown id degrades to
/// the not-found error like the detail screen; the inner [_EditExpenseForm]
/// owns the prefilled inputs. The current value arrives via the route's
/// [expenseId] (queryParameters) — fetched through the same detail provider, so
/// editing reuses the read path instead of passing an entity through `extra`.
class EditExpenseScreen extends ConsumerWidget {
  const EditExpenseScreen({super.key, required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Side effect on success: refresh the list AND the detail this edit came
    // from, then leave. Both watchers reload themselves — no data is threaded
    // back through navigation.
    ref.listen(editExpenseControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (expense) {
          if (expense == null) return; // idle state, not a result
          ref.invalidate(expenseListControllerProvider);
          ref.invalidate(expenseDetailControllerProvider(expenseId));
          context.pop();
        },
      );
    });

    final expenseAsync = ref.watch(expenseDetailControllerProvider(expenseId));

    return Scaffold(
      appBar: CommonAppBar(titleText: LocaleKeys.expense_edit_title.tr()),
      body: SafeArea(
        child: SystemAsyncValueWidget<Expense>(
          value: expenseAsync,
          data: (expense) => _EditExpenseForm(expense: expense),
        ),
      ),
    );
  }
}

/// Local form inputs are UI state, so `ConsumerStatefulWidget` is correct —
/// the controllers are seeded ONCE from [expense] in the field initializers.
/// The submit round-trip stays in [EditExpenseController].
class _EditExpenseForm extends ConsumerStatefulWidget {
  const _EditExpenseForm({required this.expense});

  final Expense expense;

  @override
  ConsumerState<_EditExpenseForm> createState() => _EditExpenseFormState();
}

class _EditExpenseFormState extends ConsumerState<_EditExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.expense.title,
  );
  late final _amountController = TextEditingController(
    text: widget.expense.money.amount.toString(),
  );
  late var _category = widget.expense.category;

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
        .read(editExpenseControllerProvider.notifier)
        .submit(
          id: widget.expense.id,
          title: _titleController.text.trim(),
          category: _category,
          amount: _amountController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(editExpenseControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(Sizes.kP16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExpenseFormFields(
              titleController: _titleController,
              amountController: _amountController,
              selectedCategory: _category,
              onCategorySelected: (category) =>
                  setState(() => _category = category),
            ),
            const Spacer(),
            if (submitState.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: Sizes.kP12),
                child: Text(
                  AppException.parse(error: submitState.error).description,
                  key: const Key('edit_expense_error'),
                  style: context.appTexts.bodyMdRegular.copyWith(
                    color: context.appColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            CommonButtonWidget(
              buttonKey: const Key('update_expense_button'),
              buttonText: LocaleKeys.expense_edit_save_button.tr(),
              onButtonPressed: submitState.isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
