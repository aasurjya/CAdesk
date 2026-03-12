import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_al.dart';

void main() {
  group('ScheduleAl', () {
    group('totalAssets', () {
      test('→ sums immovable + movable + financial assets', () {
        const al = ScheduleAl(
          immovablePropertyValue: 5000000,
          movablePropertyValue: 800000,
          financialAssetValue: 2000000,
          totalLiabilities: 1500000,
        );
        expect(al.totalAssets, 7800000.0);
      });

      test('→ netWorth = totalAssets - totalLiabilities', () {
        const al = ScheduleAl(
          immovablePropertyValue: 5000000,
          movablePropertyValue: 800000,
          financialAssetValue: 2000000,
          totalLiabilities: 1500000,
        );
        expect(al.netWorth, 6300000.0);
      });

      test('→ netWorth can be negative if liabilities > assets', () {
        const al = ScheduleAl(
          immovablePropertyValue: 1000000,
          movablePropertyValue: 0,
          financialAssetValue: 0,
          totalLiabilities: 2000000,
        );
        expect(al.netWorth, -1000000.0);
      });
    });

    group('copyWith and equality', () {
      test('→ copyWith returns new instance', () {
        const al = ScheduleAl(
          immovablePropertyValue: 1000000,
          movablePropertyValue: 200000,
          financialAssetValue: 500000,
          totalLiabilities: 300000,
        );
        final updated = al.copyWith(immovablePropertyValue: 2000000);
        expect(updated.immovablePropertyValue, 2000000);
        expect(updated.movablePropertyValue, 200000);
      });

      test('→ equal instances satisfy == and hashCode', () {
        const a = ScheduleAl(
          immovablePropertyValue: 1000000,
          movablePropertyValue: 200000,
          financialAssetValue: 500000,
          totalLiabilities: 300000,
        );
        const b = ScheduleAl(
          immovablePropertyValue: 1000000,
          movablePropertyValue: 200000,
          financialAssetValue: 500000,
          totalLiabilities: 300000,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('→ different instances are not equal', () {
        const a = ScheduleAl(
          immovablePropertyValue: 1000000,
          movablePropertyValue: 200000,
          financialAssetValue: 500000,
          totalLiabilities: 300000,
        );
        const b = ScheduleAl(
          immovablePropertyValue: 2000000,
          movablePropertyValue: 200000,
          financialAssetValue: 500000,
          totalLiabilities: 300000,
        );
        expect(a, isNot(equals(b)));
      });
    });

    test('→ ScheduleAl.empty() creates zero-value instance', () {
      final al = ScheduleAl.empty();
      expect(al.totalAssets, 0.0);
      expect(al.totalLiabilities, 0.0);
      expect(al.netWorth, 0.0);
    });
  });
}
