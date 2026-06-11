/// Value object — identity is its value, so it overrides `==`/`hashCode`
/// and carries same-currency addition instead of leaking raw doubles around
/// the app. Pure Dart: no flutter/riverpod/dio imports — display formatting
/// (an intl concern) lives in `presentation/widgets/money_format.dart`.
class Money {
  const Money({this.amount = 0, this.currency = defaultCurrency});

  /// The app's base currency — defined once, never retyped at call sites.
  static const defaultCurrency = 'THB';

  final double amount;
  final String currency;

  /// Same-currency addition; mixing currencies is a programming error.
  Money operator +(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot add $currency to ${other.currency}');
    }
    return Money(amount: amount + other.amount, currency: currency);
  }

  /// Same-currency subtraction. The result MAY be negative — a negative
  /// remaining budget is the over-budget signal; clamping for display is a
  /// presentation concern.
  Money operator -(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot subtract ${other.currency} from $currency');
    }
    return Money(amount: amount - other.amount, currency: currency);
  }

  @override
  bool operator ==(Object other) =>
      other is Money && other.amount == amount && other.currency == currency;

  @override
  int get hashCode => Object.hash(amount, currency);
}
