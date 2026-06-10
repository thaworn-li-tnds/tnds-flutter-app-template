import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

/// Mock router injected by `Robot.pumpTestWidget` so screens can call
/// `context.pushNamed(...)` / `context.pop()` without a real GoRouter.
/// Feature robots verify navigation through `robot.goRouter`.
class MockGoRouter extends Mock implements GoRouter {}

/// In-memory translations for tests — keep keys in sync with
/// `assets/translations/` when a test asserts on localized text.
class TestAssetLoader extends AssetLoader {
  const TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      'common': {
        'close': 'Close',
        'error': {
          'title': 'Something went wrong',
          'description': 'Please try again.',
        },
      },
      'home': {'title': 'TNDS Flutter App'},
      'expense': {
        'category': {
          'entertainment': 'Entertainment',
          'food': 'Food',
          'other': 'Other',
          'shopping': 'Shopping',
          'transport': 'Transport',
        },
        'create': {
          'amount_invalid': 'Enter a valid amount',
          'amount_label': 'Amount (THB)',
          'category_label': 'Category',
          'save_button': 'Save expense',
          'title': 'New expense',
          'title_label': 'Title',
          'title_required': 'Enter a title',
        },
        'detail': {
          'amount': 'Amount',
          'category': 'Category',
          'date': 'Date',
          'title': 'Expense detail',
        },
        'error': {
          'not_found_description':
              'The expense may have been deleted. Refresh and try again.',
          'not_found_title': 'Expense not found',
        },
        'filter_all': 'All',
        'home_entry_button': 'Expense tracker sample',
        'list': {
          'add_button': 'Add expense',
          'empty': 'No expenses yet',
          'title': 'Expenses',
          'total': 'Total spent',
        },
      },
    };
  }
}
