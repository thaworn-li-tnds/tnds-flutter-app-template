// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_budgets_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetBudgetsResponse _$GetBudgetsResponseFromJson(Map<String, dynamic> json) =>
    GetBudgetsResponse(
      month: json['month'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => BudgetItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetBudgetsResponseToJson(GetBudgetsResponse instance) =>
    <String, dynamic>{
      'month': instance.month,
      'items': instance.items?.map((e) => e.toJson()).toList(),
    };

BudgetItemResponse _$BudgetItemResponseFromJson(Map<String, dynamic> json) =>
    BudgetItemResponse(
      category: json['category'] as String?,
      limit: json['limit'] as String?,
      currency: json['currency'] as String?,
    );

Map<String, dynamic> _$BudgetItemResponseToJson(BudgetItemResponse instance) =>
    <String, dynamic>{
      'category': instance.category,
      'limit': instance.limit,
      'currency': instance.currency,
    };
