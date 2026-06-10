import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/generated/locale_keys.g.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';

void main() {
  group('from', () {
    test('parses known wire values', () {
      expect(ExpenseCategory.from('FOOD'), ExpenseCategory.food);
      expect(ExpenseCategory.from('TRANSPORT'), ExpenseCategory.transport);
      expect(ExpenseCategory.from('SHOPPING'), ExpenseCategory.shopping);
      expect(
        ExpenseCategory.from('ENTERTAINMENT'),
        ExpenseCategory.entertainment,
      );
    });

    test('unknown or missing wire values degrade to other', () {
      expect(ExpenseCategory.from('CRYPTO'), ExpenseCategory.other);
      expect(ExpenseCategory.from(null), ExpenseCategory.other);
      expect(ExpenseCategory.from(''), ExpenseCategory.other);
    });
  });

  test('labelKey maps onto the generated locale keys', () {
    expect(ExpenseCategory.food.labelKey, LocaleKeys.expense_category_food);
    expect(ExpenseCategory.other.labelKey, LocaleKeys.expense_category_other);
  });
}
