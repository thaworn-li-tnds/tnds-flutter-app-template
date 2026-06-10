// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_expense_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetExpenseResponse _$GetExpenseResponseFromJson(Map<String, dynamic> json) =>
    GetExpenseResponse(
      item: json['item'] == null
          ? null
          : ExpenseItemResponse.fromJson(json['item'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetExpenseResponseToJson(GetExpenseResponse instance) =>
    <String, dynamic>{'item': instance.item?.toJson()};
