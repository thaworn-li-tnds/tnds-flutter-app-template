// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_expense_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateExpenseResponse _$CreateExpenseResponseFromJson(
  Map<String, dynamic> json,
) => CreateExpenseResponse(
  item: json['item'] == null
      ? null
      : ExpenseItemResponse.fromJson(json['item'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CreateExpenseResponseToJson(
  CreateExpenseResponse instance,
) => <String, dynamic>{'item': instance.item?.toJson()};
