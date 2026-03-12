import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_exempt_supplies.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gstr3bExemptSupplies', () {
    Gstr3bExemptSupplies createExempt({
      double interStateExempt = 0.0,
      double intraStateExempt = 50000.0,
      double interStateNilRated = 0.0,
      double intraStateNilRated = 20000.0,
      double interStateNonGst = 0.0,
      double intraStateNonGst = 10000.0,
    }) {
      return Gstr3bExemptSupplies(
        interStateExempt: interStateExempt,
        intraStateExempt: intraStateExempt,
        interStateNilRated: interStateNilRated,
        intraStateNilRated: intraStateNilRated,
        interStateNonGst: interStateNonGst,
        intraStateNonGst: intraStateNonGst,
      );
    }

    test('creates with correct field values', () {
      final exempt = createExempt();
      expect(exempt.interStateExempt, 0.0);
      expect(exempt.intraStateExempt, 50000.0);
      expect(exempt.interStateNilRated, 0.0);
      expect(exempt.intraStateNilRated, 20000.0);
      expect(exempt.interStateNonGst, 0.0);
      expect(exempt.intraStateNonGst, 10000.0);
    });

    test('totalExempt → interStateExempt + intraStateExempt', () {
      final exempt = createExempt(
        interStateExempt: 30000,
        intraStateExempt: 50000,
      );
      expect(exempt.totalExempt, 80000.0);
    });

    test('totalNilRated → inter + intra nil rated', () {
      final exempt = createExempt(
        interStateNilRated: 10000,
        intraStateNilRated: 20000,
      );
      expect(exempt.totalNilRated, 30000.0);
    });

    test('totalNonGst → inter + intra non-GST', () {
      final exempt = createExempt(
        interStateNonGst: 5000,
        intraStateNonGst: 10000,
      );
      expect(exempt.totalNonGst, 15000.0);
    });

    test('grandTotal → sum of exempt + nilRated + nonGst', () {
      final exempt = createExempt(
        intraStateExempt: 50000,
        intraStateNilRated: 20000,
        intraStateNonGst: 10000,
      );
      expect(exempt.grandTotal, 80000.0);
    });

    test('copyWith → returns new instance with updated fields', () {
      final original = createExempt();
      final updated = original.copyWith(
        intraStateExempt: 100000.0,
        interStateExempt: 25000.0,
      );
      expect(updated.intraStateExempt, 100000.0);
      expect(updated.interStateExempt, 25000.0);
      expect(updated.intraStateNilRated, original.intraStateNilRated);
    });

    test('copyWith → preserves all fields when called with no args', () {
      final original = createExempt();
      final copy = original.copyWith();
      expect(copy, equals(original));
      expect(copy.hashCode, original.hashCode);
    });

    test('equality → equal when all fields match', () {
      final a = createExempt();
      final b = createExempt();
      expect(a, equals(b));
    });

    test('equality → not equal when intraStateExempt differs', () {
      final a = createExempt(intraStateExempt: 50000);
      final b = createExempt(intraStateExempt: 60000);
      expect(a, isNot(equals(b)));
    });
  });
}
