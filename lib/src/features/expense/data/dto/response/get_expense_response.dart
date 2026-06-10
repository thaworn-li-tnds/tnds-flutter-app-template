import 'package:json_annotation/json_annotation.dart';
import 'package:tnds_flutter_app/src/features/expense/data/dto/response/get_expenses_response.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';

part 'get_expense_response.g.dart';

@JsonSerializable(explicitToJson: true)
class GetExpenseResponse {
  const GetExpenseResponse({this.item});

  final ExpenseItemResponse? item;

  factory GetExpenseResponse.fromJson(Map<String, dynamic> json) =>
      _$GetExpenseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetExpenseResponseToJson(this);

  Expense get toExpense => item?.toExpense ?? const Expense();
}
