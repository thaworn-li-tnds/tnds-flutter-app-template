import 'package:json_annotation/json_annotation.dart';
import 'package:tnds_flutter_app/src/features/expense/data/dto/response/get_expenses_response.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';

part 'create_expense_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateExpenseResponse {
  const CreateExpenseResponse({this.item});

  final ExpenseItemResponse? item;

  factory CreateExpenseResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateExpenseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateExpenseResponseToJson(this);

  Expense get toExpense => item?.toExpense ?? const Expense();
}
