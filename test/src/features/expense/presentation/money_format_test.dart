import 'package:flutter_test/flutter_test.dart';
import 'package:tnds_flutter_app/src/features/expense/domain/money.dart';
import 'package:tnds_flutter_app/src/features/expense/presentation/widgets/money_format.dart';

void main() {
  group('formatted', () {
    test('zero', () {
      expect(const Money().formatted, 'THB 0.00');
    });

    test('two decimals', () {
      expect(const Money(amount: 99.5).formatted, 'THB 99.50');
    });

    test('thousands grouping', () {
      expect(const Money(amount: 1250.5).formatted, 'THB 1,250.50');
      expect(const Money(amount: 1000000).formatted, 'THB 1,000,000.00');
    });

    test('carries its currency', () {
      expect(const Money(amount: 5, currency: 'USD').formatted, 'USD 5.00');
    });
  });
}
