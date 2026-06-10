import 'package:json_annotation/json_annotation.dart';

part 'create_expense_request.g.dart';

/// Request DTO: nullable fields + `includeIfNull: false` so optional fields
/// are simply omitted from the payload. Built by `ExpenseService`, never by
/// presentation code.
@JsonSerializable(includeIfNull: false)
class CreateExpenseRequest {
  const CreateExpenseRequest({
    this.title,
    this.category,
    this.amount,
    this.currency,
    this.date,
  });

  final String? title;
  final String? category;
  final String? amount;
  final String? currency;
  final String? date;

  factory CreateExpenseRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateExpenseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateExpenseRequestToJson(this);
}
