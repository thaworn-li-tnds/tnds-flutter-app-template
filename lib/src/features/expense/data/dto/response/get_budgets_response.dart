import 'package:json_annotation/json_annotation.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/budget.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';

part 'get_budgets_response.g.dart';

/// The wire is NORMALIZED: `month` appears once at the response root, and
/// each item references its category by a code string. The domain does not
/// mirror that layout — [toBudgets] flattens the root month into every
/// [Budget] and resolves the code to the enum. Resist the urge to create a
/// `Budgets {month, items}` domain class: that would just be the response
/// wearing a domain name.
@JsonSerializable(explicitToJson: true)
class GetBudgetsResponse {
  const GetBudgetsResponse({this.month, this.items});

  final String? month;
  final List<BudgetItemResponse>? items;

  factory GetBudgetsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetBudgetsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetBudgetsResponseToJson(this);

  List<Budget> get toBudgets =>
      items?.map((item) => item.toBudget(month ?? '')).toList() ?? const [];
}

@JsonSerializable()
class BudgetItemResponse {
  const BudgetItemResponse({this.category, this.limit, this.currency});

  final String? category;

  /// Amounts travel as String on the wire, same as `ExpenseItemResponse`.
  final String? limit;
  final String? currency;

  factory BudgetItemResponse.fromJson(Map<String, dynamic> json) =>
      _$BudgetItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetItemResponseToJson(this);

  /// [month] comes from the response root — the item itself never carried it.
  Budget toBudget(String month) => Budget(
    category: ExpenseCategory.from(category),
    limit: Money(
      amount: double.tryParse(limit ?? '') ?? 0,
      currency: currency ?? Money.defaultCurrency,
    ),
    month: month,
  );
}
