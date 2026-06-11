import 'package:json_annotation/json_annotation.dart';
import 'package:tnds_flutter_app/src/features/expense/data/dto/response/get_expenses_response.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/expense.dart';

part 'update_expense_response.g.dart';

/// Response DTO for an edit — reuses the shared [ExpenseItemResponse] item
/// shape, like the create/get responses. The `toExpense` getter is the one
/// place nulls die before the domain noun leaves the data layer.
@JsonSerializable(explicitToJson: true)
class UpdateExpenseResponse {
  const UpdateExpenseResponse({this.item});

  final ExpenseItemResponse? item;

  factory UpdateExpenseResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateExpenseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateExpenseResponseToJson(this);

  Expense get toExpense => item?.toExpense ?? const Expense();
}
