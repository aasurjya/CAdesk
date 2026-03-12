import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/itr_u/updated_return.dart';

void main() {
  final base = UpdatedReturn(
    originalAckNumber: 'ACK123',
    originalFilingDate: DateTime(2025, 7, 31),
    reasonForUpdate: UpdateReason.incomeNotReported,
    additionalTaxPercentage: 25,
    additionalIncome: 200000,
    additionalTax: 60000,
  );

  group('UpdatedReturn', () {
    test('additionalTaxAmount is 25% of additionalTax within 12 months', () {
      expect(base.additionalTaxAmount, 15000.0); // 60000 * 25 / 100
    });

    test('additionalTaxAmount is 50% of additionalTax after 12 months', () {
      final lateReturn = base.copyWith(additionalTaxPercentage: 50);
      expect(lateReturn.additionalTaxAmount, 30000.0); // 60000 * 50 / 100
    });

    test('totalTaxPayable = additionalTax + additionalTaxAmount', () {
      expect(base.totalTaxPayable, 75000.0); // 60000 + 15000
    });

    test('copyWith returns a new instance without mutating original', () {
      final modified = base.copyWith(additionalIncome: 300000);
      expect(modified.additionalIncome, 300000);
      expect(base.additionalIncome, 200000); // original unchanged
      expect(identical(base, modified), isFalse);
    });

    test('equality: same values are equal', () {
      final copy = base.copyWith();
      expect(copy, equals(base));
      expect(copy.hashCode, equals(base.hashCode));
    });

    test('equality: different values are not equal', () {
      final different = base.copyWith(additionalTax: 99999);
      expect(different, isNot(equals(base)));
    });
  });
}
