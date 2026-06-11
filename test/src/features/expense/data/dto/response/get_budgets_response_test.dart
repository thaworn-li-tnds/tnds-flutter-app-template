import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/src/features/expense/data/dto/response/get_budgets_response.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';

void main() {
  test('flattens the root-level month into every Budget', () {
    final response = GetBudgetsResponse.fromJson(const {
      'month': '2026-06',
      'items': [
        {'category': 'FOOD', 'limit': '1500.00', 'currency': 'THB'},
        {'category': 'SHOPPING', 'limit': '2000.00', 'currency': 'THB'},
      ],
    });

    final budgets = response.toBudgets;
    expect(budgets, hasLength(2));
    expect(budgets.every((b) => b.month == '2026-06'), isTrue);
    expect(budgets.first.category, ExpenseCategory.food);
    expect(budgets.first.limit, const Money(amount: 1500.00));
  });

  test('the wire is never trusted — missing fields die in the mapping', () {
    expect(GetBudgetsResponse.fromJson(const {}).toBudgets, isEmpty);

    final sparse = GetBudgetsResponse.fromJson(const {
      'items': [
        {'category': 'CRYPTO'},
      ],
    }).toBudgets.single;
    expect(sparse.month, '');
    expect(sparse.category, ExpenseCategory.other);
    expect(sparse.limit, const Money());
  });
}
