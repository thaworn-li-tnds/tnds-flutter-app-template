// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_expense_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateExpenseRequest _$CreateExpenseRequestFromJson(
  Map<String, dynamic> json,
) => CreateExpenseRequest(
  title: json['title'] as String?,
  category: json['category'] as String?,
  amount: json['amount'] as String?,
  currency: json['currency'] as String?,
  date: json['date'] as String?,
);

Map<String, dynamic> _$CreateExpenseRequestToJson(
  CreateExpenseRequest instance,
) => <String, dynamic>{
  if (instance.title case final value?) 'title': value,
  if (instance.category case final value?) 'category': value,
  if (instance.amount case final value?) 'amount': value,
  if (instance.currency case final value?) 'currency': value,
  if (instance.date case final value?) 'date': value,
};
