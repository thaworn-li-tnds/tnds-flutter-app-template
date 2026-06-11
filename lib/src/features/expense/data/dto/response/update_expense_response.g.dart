// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_expense_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateExpenseResponse _$UpdateExpenseResponseFromJson(
  Map<String, dynamic> json,
) => UpdateExpenseResponse(
  item: json['item'] == null
      ? null
      : ExpenseItemResponse.fromJson(json['item'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UpdateExpenseResponseToJson(
  UpdateExpenseResponse instance,
) => <String, dynamic>{'item': instance.item?.toJson()};
