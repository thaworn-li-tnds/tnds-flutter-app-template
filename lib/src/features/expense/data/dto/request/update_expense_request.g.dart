// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_expense_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateExpenseRequest _$UpdateExpenseRequestFromJson(
  Map<String, dynamic> json,
) => UpdateExpenseRequest(
  title: json['title'] as String?,
  category: json['category'] as String?,
  amount: json['amount'] as String?,
  currency: json['currency'] as String?,
  date: json['date'] as String?,
);

Map<String, dynamic> _$UpdateExpenseRequestToJson(
  UpdateExpenseRequest instance,
) => <String, dynamic>{
  if (instance.title case final value?) 'title': value,
  if (instance.category case final value?) 'category': value,
  if (instance.amount case final value?) 'amount': value,
  if (instance.currency case final value?) 'currency': value,
  if (instance.date case final value?) 'date': value,
};
