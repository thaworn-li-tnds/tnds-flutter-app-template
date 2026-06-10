import 'package:json_annotation/json_annotation.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense_category.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';

part 'get_expenses_response.g.dart';

/// Response DTO: every field nullable (the wire is never trusted), nested DTOs
/// need `explicitToJson: true`, and the `to<Domain>` getter is where nulls die
/// — domain models receive non-null defaults and DTOs never leak past `data/`.
@JsonSerializable(explicitToJson: true)
class GetExpensesResponse {
  const GetExpensesResponse({this.items});

  final List<ExpenseItemResponse>? items;

  factory GetExpensesResponse.fromJson(Map<String, dynamic> json) =>
      _$GetExpensesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetExpensesResponseToJson(this);

  List<Expense> get toExpenses =>
      items?.map((item) => item.toExpense).toList() ?? const [];
}

/// Shared by every expense response DTO (list/detail/create all carry the
/// same item shape).
@JsonSerializable()
class ExpenseItemResponse {
  const ExpenseItemResponse({
    this.id,
    this.title,
    this.category,
    this.amount,
    this.currency,
    this.date,
  });

  final String? id;
  final String? title;
  final String? category;

  /// Amounts travel as String on the wire; parsing to double happens once,
  /// here in the domain mapping.
  final String? amount;
  final String? currency;
  final String? date;

  factory ExpenseItemResponse.fromJson(Map<String, dynamic> json) =>
      _$ExpenseItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseItemResponseToJson(this);

  Expense get toExpense => Expense(
    id: id ?? '',
    title: title ?? '',
    category: ExpenseCategory.from(category),
    money: Money(
      amount: double.tryParse(amount ?? '') ?? 0,
      currency: currency ?? Money.defaultCurrency,
    ),
    date: date ?? '',
  );
}
