// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_expenses_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetExpensesResponse _$GetExpensesResponseFromJson(Map<String, dynamic> json) =>
    GetExpensesResponse(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ExpenseItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetExpensesResponseToJson(
  GetExpensesResponse instance,
) => <String, dynamic>{
  'items': instance.items?.map((e) => e.toJson()).toList(),
};

ExpenseItemResponse _$ExpenseItemResponseFromJson(Map<String, dynamic> json) =>
    ExpenseItemResponse(
      id: json['id'] as String?,
      title: json['title'] as String?,
      category: json['category'] as String?,
      amount: json['amount'] as String?,
      currency: json['currency'] as String?,
      date: json['date'] as String?,
    );

Map<String, dynamic> _$ExpenseItemResponseToJson(
  ExpenseItemResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'category': instance.category,
  'amount': instance.amount,
  'currency': instance.currency,
  'date': instance.date,
};
