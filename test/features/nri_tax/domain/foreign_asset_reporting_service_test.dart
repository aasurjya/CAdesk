import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/nri_tax/domain/models/foreign_asset_declaration.dart';
import 'package:ca_app/features/nri_tax/domain/models/foreign_asset_item.dart';
import 'package:ca_app/features/nri_tax/domain/models/trc_document.dart';
import 'package:ca_app/features/nri_tax/domain/services/foreign_asset_reporting_service.dart';

void main() {
  group('ForeignAssetReportingService', () {
    late ForeignAssetReportingService service;

    setUp(() {
      service = ForeignAssetReportingService.instance;
    });

    test('singleton returns same instance', () {
      expect(
        ForeignAssetReportingService.instance,
        same(ForeignAssetReportingService.instance),
      );
    });

    // ─── computeReportingThreshold ────────────────────────────────────────

    group('computeReportingThreshold', () {
      test('single asset > ₹5 lakh (5,00,00,000 paise) → must report', () {
        const asset = ForeignAssetItem(
          assetType: ForeignAssetCategory.bankAccount,
          country: 'US',
          institution: 'Bank of America',
          accountNumber: '****1234',
          peakValue: 60000000, // ₹6 lakh in paise
          closingValue: 55000000,
          incomeAccrued: 100000,
        );
        expect(service.computeReportingThreshold(asset), true);
      });

      test('asset exactly ₹5 lakh → must report (boundary)', () {
        const asset = ForeignAssetItem(
          assetType: ForeignAssetCategory.bankAccount,
          country: 'US',
          institution: 'Chase',
          accountNumber: '****5678',
          peakValue: 50000000, // ₹5 lakh = 50,000,000 paise
          closingValue: 50000000,
          incomeAccrued: 0,
        );
        expect(service.computeReportingThreshold(asset), true);
      });

      test('asset < ₹5 lakh → not required individually', () {
        const asset = ForeignAssetItem(
          assetType: ForeignAssetCategory.bankAccount,
          country: 'US',
          institution: 'Chase',
          accountNumber: '****9999',
          peakValue: 40000000, // ₹4 lakh
          closingValue: 35000000,
          incomeAccrued: 0,
        );
        expect(service.computeReportingThreshold(asset), false);
      });
    });

    // ─── buildScheduleFA ─────────────────────────────────────────────────

    group('buildScheduleFA', () {
      test('returns declaration with all assets', () {
        final assets = [
          const ForeignAssetItem(
            assetType: ForeignAssetCategory.bankAccount,
            country: 'US',
            institution: 'Bank of America',
            accountNumber: '****1234',
            peakValue: 60000000,
            closingValue: 55000000,
            incomeAccrued: 100000,
          ),
          const ForeignAssetItem(
            assetType: ForeignAssetCategory.equity,
            country: 'GB',
            institution: 'HSBC',
            accountNumber: '****5678',
            peakValue: 80000000,
            closingValue: 75000000,
            incomeAccrued: 500000,
          ),
        ];
        final declaration = service.buildScheduleFA(assets, 2024);
        expect(declaration.assets.length, 2);
        expect(declaration.financialYear, 2024);
        expect(declaration.totalForeignAssetValue, 130000000); // sum of closing
      });

      test('requiresScheduleFA true when total closing > ₹5 lakh', () {
        final assets = [
          const ForeignAssetItem(
            assetType: ForeignAssetCategory.bankAccount,
            country: 'US',
            institution: 'Bank of America',
            accountNumber: '****1234',
            peakValue: 60000000,
            closingValue: 55000000,
            incomeAccrued: 0,
          ),
        ];
        final declaration = service.buildScheduleFA(assets, 2024);
        expect(declaration.requiresScheduleFA, true);
      });

      test('requiresScheduleFA false when total closing < ₹5 lakh', () {
        final assets = [
          const ForeignAssetItem(
            assetType: ForeignAssetCategory.bankAccount,
            country: 'US',
            institution: 'Chase',
            accountNumber: '****0001',
            peakValue: 30000000,
            closingValue: 25000000,
            incomeAccrued: 0,
          ),
        ];
        final declaration = service.buildScheduleFA(assets, 2024);
        expect(declaration.requiresScheduleFA, false);
      });

      test('requiresFbar is always false (Indian context)', () {
        final declaration = service.buildScheduleFA([], 2024);
        expect(declaration.requiresFbar, false);
      });

      test('empty assets → zero total value', () {
        final declaration = service.buildScheduleFA([], 2024);
        expect(declaration.totalForeignAssetValue, 0);
        expect(declaration.assets, isEmpty);
      });
    });

    // ─── computePenaltyForNonDisclosure ───────────────────────────────────

    group('computePenaltyForNonDisclosure', () {
      test('penalty is ₹10 lakh flat when 300% of tax is lower', () {
        // 300% of tax on ₹1 lakh at 30% = 300% × ₹30k = ₹90k < ₹10 lakh
        // So penalty = ₹10 lakh = 100,000,000 paise
        final penalty = service.computePenaltyForNonDisclosure(
          10000000,
        ); // ₹1 lakh
        expect(penalty, 100000000); // ₹10 lakh in paise
      });

      test('penalty is 300% of tax when that exceeds ₹10 lakh', () {
        // Asset value ₹1 crore = 10,000,000,000 paise
        // Tax at 30% = ₹30 lakh; 300% = ₹90 lakh (> ₹10 lakh)
        // So penalty = 300% × ₹30 lakh = ₹90 lakh = 9,000,000,000 paise
        final penalty = service.computePenaltyForNonDisclosure(
          1000000000,
        ); // ₹1 cr
        // 300% of 30% of ₹1cr = 0.9 × 1,000,000,000 = 900,000,000 paise = ₹90 lakh
        expect(penalty, 900000000);
      });

      test('zero asset value → flat ₹10 lakh penalty (minimum)', () {
        final penalty = service.computePenaltyForNonDisclosure(0);
        expect(penalty, 100000000); // ₹10 lakh minimum
      });
    });

    // ─── ForeignAssetDeclaration model ────────────────────────────────────

    group('ForeignAssetDeclaration model', () {
      test('equality and hashCode', () {
        const a = ForeignAssetDeclaration(
          pan: 'ABCDE1234F',
          financialYear: 2024,
          assets: [],
          totalForeignAssetValue: 0,
          requiresScheduleFA: false,
          requiresFbar: false,
        );
        const b = ForeignAssetDeclaration(
          pan: 'ABCDE1234F',
          financialYear: 2024,
          assets: [],
          totalForeignAssetValue: 0,
          requiresScheduleFA: false,
          requiresFbar: false,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('copyWith updates specific fields immutably', () {
        const original = ForeignAssetDeclaration(
          pan: 'ABCDE1234F',
          financialYear: 2024,
          assets: [],
          totalForeignAssetValue: 0,
          requiresScheduleFA: false,
          requiresFbar: false,
        );
        final updated = original.copyWith(
          financialYear: 2025,
          requiresScheduleFA: true,
        );
        expect(updated.financialYear, 2025);
        expect(updated.requiresScheduleFA, true);
        expect(original.financialYear, 2024);
        expect(original.requiresScheduleFA, false);
      });
    });

    // ─── ForeignAssetItem model ───────────────────────────────────────────

    group('ForeignAssetItem model', () {
      test('equality and hashCode', () {
        const a = ForeignAssetItem(
          assetType: ForeignAssetCategory.equity,
          country: 'US',
          institution: 'Fidelity',
          accountNumber: '****1111',
          peakValue: 100000000,
          closingValue: 90000000,
          incomeAccrued: 500000,
        );
        const b = ForeignAssetItem(
          assetType: ForeignAssetCategory.equity,
          country: 'US',
          institution: 'Fidelity',
          accountNumber: '****1111',
          peakValue: 100000000,
          closingValue: 90000000,
          incomeAccrued: 500000,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('copyWith updates fields immutably', () {
        const original = ForeignAssetItem(
          assetType: ForeignAssetCategory.equity,
          country: 'US',
          institution: 'Fidelity',
          accountNumber: '****1111',
          peakValue: 100000000,
          closingValue: 90000000,
          incomeAccrued: 500000,
        );
        final updated = original.copyWith(
          country: 'SG',
          closingValue: 85000000,
        );
        expect(updated.country, 'SG');
        expect(updated.closingValue, 85000000);
        expect(original.country, 'US');
        expect(original.closingValue, 90000000);
      });
    });

    // ─── TrcDocument model ────────────────────────────────────────────────

    group('TrcDocument model', () {
      test('isValid true when today is within validity range', () {
        final trc = TrcDocument(
          pan: 'ABCDE1234F',
          countryCode: 'US',
          trcNumber: 'TRC-US-2024-001',
          issuingAuthority: 'IRS',
          validFrom: DateTime(2024, 1, 1),
          validTo: DateTime(2026, 12, 31),
        );
        // Today is 2026-03-12 — within range
        expect(trc.isValid, true);
      });

      test('isValid false when validTo is in the past', () {
        final trc = TrcDocument(
          pan: 'ABCDE1234F',
          countryCode: 'US',
          trcNumber: 'TRC-US-2023-001',
          issuingAuthority: 'IRS',
          validFrom: DateTime(2023, 1, 1),
          validTo: DateTime(2023, 12, 31),
        );
        expect(trc.isValid, false);
      });

      test('isValid false when validFrom is in the future', () {
        final trc = TrcDocument(
          pan: 'ABCDE1234F',
          countryCode: 'US',
          trcNumber: 'TRC-US-2030-001',
          issuingAuthority: 'IRS',
          validFrom: DateTime(2030, 1, 1),
          validTo: DateTime(2030, 12, 31),
        );
        expect(trc.isValid, false);
      });

      test('equality and hashCode', () {
        final a = TrcDocument(
          pan: 'ABCDE1234F',
          countryCode: 'US',
          trcNumber: 'TRC-001',
          issuingAuthority: 'IRS',
          validFrom: DateTime(2024, 1, 1),
          validTo: DateTime(2025, 12, 31),
        );
        final b = TrcDocument(
          pan: 'ABCDE1234F',
          countryCode: 'US',
          trcNumber: 'TRC-001',
          issuingAuthority: 'IRS',
          validFrom: DateTime(2024, 1, 1),
          validTo: DateTime(2025, 12, 31),
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('copyWith updates fields immutably', () {
        final original = TrcDocument(
          pan: 'ABCDE1234F',
          countryCode: 'US',
          trcNumber: 'TRC-001',
          issuingAuthority: 'IRS',
          validFrom: DateTime(2024, 1, 1),
          validTo: DateTime(2025, 12, 31),
        );
        final updated = original.copyWith(
          countryCode: 'GB',
          trcNumber: 'TRC-002',
        );
        expect(updated.countryCode, 'GB');
        expect(updated.trcNumber, 'TRC-002');
        expect(original.countryCode, 'US');
        expect(original.trcNumber, 'TRC-001');
      });
    });
  });
}
