import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';

void main() {
  group('operator +', () {
    test('adds same-currency amounts', () {
      const sum = Money(amount: 320.50);
      expect(sum + const Money(amount: 62), const Money(amount: 382.50));
    });

    test('throws on mixed currencies', () {
      expect(
        () => const Money() + const Money(currency: 'USD'),
        throwsArgumentError,
      );
    });
  });

  group('operator -', () {
    test('subtracts same-currency amounts', () {
      expect(
        const Money(amount: 1500) - const Money(amount: 320.50),
        const Money(amount: 1179.50),
      );
    });

    test('a negative result is allowed — it signals over-budget', () {
      expect(
        const Money(amount: 50) - const Money(amount: 62),
        const Money(amount: -12),
      );
    });

    test('throws on mixed currencies', () {
      expect(
        () => const Money() - const Money(currency: 'USD'),
        throwsArgumentError,
      );
    });
  });

  test('value equality — same value means equal, regardless of instance', () {
    expect(const Money(amount: 10), Money(amount: 10));
    expect(const Money(amount: 10), isNot(const Money(amount: 11)));
    expect(
      const Money(amount: 10),
      isNot(const Money(amount: 10, currency: 'USD')),
    );
  });

  test('defaults to the app base currency', () {
    expect(const Money().currency, Money.defaultCurrency);
  });
}
