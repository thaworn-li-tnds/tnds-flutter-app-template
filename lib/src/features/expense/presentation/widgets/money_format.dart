import 'package:easy_localization/easy_localization.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';

/// Display formatting for the pure-Dart [Money] value object. `NumberFormat`
/// comes from intl (re-exported by easy_localization) — a presentation
/// dependency, so the formatting lives here: the deliberate counterpart of
/// `ExpenseCategoryPresentation.icon`.
extension MoneyFormat on Money {
  /// `Money(amount: 1250.5)` → `'THB 1,250.50'`.
  String get formatted =>
      '$currency ${NumberFormat('#,##0.00').format(amount)}';
}
