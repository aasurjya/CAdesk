import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/filing/domain/models/itr2/foreign_asset_schedule.dart';

void main() {
  group('ForeignAsset', () {
    test('→ valueInINR converts foreign currency to INR', () {
      const asset = ForeignAsset(
        countryCode: 'US',
        countryName: 'United States',
        assetType: ForeignAssetType.bankAccount,
        description: 'Savings account at Chase Bank',
        valueInForeignCurrency: 10000.0,
        exchangeRate: 83.5,
        acquisitionDate: '2022-06-01',
        incomeDerived: 0,
        incomeOffered: 0,
      );
      expect(asset.valueInINR, 835000.0);
    });

    test('→ equality and hashCode', () {
      const a = ForeignAsset(
        countryCode: 'GB',
        countryName: 'United Kingdom',
        assetType: ForeignAssetType.equityShares,
        description: 'Barclays shares',
        valueInForeignCurrency: 5000,
        exchangeRate: 105.0,
        acquisitionDate: '2020-01-01',
        incomeDerived: 500,
        incomeOffered: 500,
      );
      const b = ForeignAsset(
        countryCode: 'GB',
        countryName: 'United Kingdom',
        assetType: ForeignAssetType.equityShares,
        description: 'Barclays shares',
        valueInForeignCurrency: 5000,
        exchangeRate: 105.0,
        acquisitionDate: '2020-01-01',
        incomeDerived: 500,
        incomeOffered: 500,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('→ copyWith changes specified field', () {
      const asset = ForeignAsset(
        countryCode: 'US',
        countryName: 'United States',
        assetType: ForeignAssetType.bankAccount,
        description: 'Chase account',
        valueInForeignCurrency: 5000,
        exchangeRate: 83.0,
        acquisitionDate: '2021-01-01',
        incomeDerived: 200,
        incomeOffered: 200,
      );
      final updated = asset.copyWith(valueInForeignCurrency: 8000);
      expect(updated.valueInForeignCurrency, 8000);
      expect(updated.countryCode, 'US');
    });
  });

  group('ForeignAssetSchedule', () {
    test('→ totalValueInINR sums all asset values', () {
      const a1 = ForeignAsset(
        countryCode: 'US',
        countryName: 'United States',
        assetType: ForeignAssetType.bankAccount,
        description: 'Account 1',
        valueInForeignCurrency: 10000,
        exchangeRate: 83.0,
        acquisitionDate: '2020-01-01',
        incomeDerived: 0,
        incomeOffered: 0,
      );
      const a2 = ForeignAsset(
        countryCode: 'SG',
        countryName: 'Singapore',
        assetType: ForeignAssetType.immovableProperty,
        description: 'Condo',
        valueInForeignCurrency: 500000,
        exchangeRate: 62.0,
        acquisitionDate: '2019-05-01',
        incomeDerived: 0,
        incomeOffered: 0,
      );
      const schedule = ForeignAssetSchedule(assets: [a1, a2]);
      // 10000*83 + 500000*62 = 830000 + 31000000 = 31830000
      expect(schedule.totalValueInINR, 31830000.0);
    });

    test('→ empty schedule has zero totalValueInINR', () {
      const schedule = ForeignAssetSchedule(assets: []);
      expect(schedule.totalValueInINR, 0.0);
    });

    test('→ equality and hashCode', () {
      const s1 = ForeignAssetSchedule(assets: []);
      const s2 = ForeignAssetSchedule(assets: []);
      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
    });
  });
}
