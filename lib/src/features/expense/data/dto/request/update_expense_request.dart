import 'package:json_annotation/json_annotation.dart';

part 'update_expense_request.g.dart';

/// Request DTO for editing an expense. The [id] is NOT here — it is the
/// resource being addressed (a path/op argument on the repository call), not a
/// body field. Same shape as `CreateExpenseRequest` today, kept as its own
/// operation DTO so the two can diverge (e.g. partial-update semantics) without
/// entangling create. Built by `ExpenseService`, never by presentation.
@JsonSerializable(includeIfNull: false)
class UpdateExpenseRequest {
  const UpdateExpenseRequest({
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

  factory UpdateExpenseRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateExpenseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateExpenseRequestToJson(this);
}
