import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/nri_tax/domain/models/dtaa_benefit.dart';
import 'package:ca_app/features/nri_tax/domain/services/dtaa_computation_service.dart';

void main() {
  group('DtaaComputationService', () {
    late DtaaComputationService service;

    setUp(() {
      service = DtaaComputationService.instance;
    });

    test('singleton returns same instance', () {
      expect(
        DtaaComputationService.instance,
        same(DtaaComputationService.instance),
      );
    });

    // ─── getWithholdingRate ────────────────────────────────────────────────

    group('getWithholdingRate', () {
      test('US interest rate is 10%', () {
        expect(service.getWithholdingRate('US', IncomeType.interest), 0.10);
      });

      test('US royalty rate is 15%', () {
        expect(service.getWithholdingRate('US', IncomeType.royalty), 0.15);
      });

      test('US dividend rate is 25% (non-qualified default)', () {
        // US DTAA Article 10: 15% if beneficial owner holds ≥10%; else 25%
        // Default (non-qualifying): 25%
        expect(service.getWithholdingRate('US', IncomeType.dividend), 0.25);
      });

      test('GB interest rate is 10%', () {
        expect(service.getWithholdingRate('GB', IncomeType.interest), 0.10);
      });

      test('GB dividend rate is 15%', () {
        expect(service.getWithholdingRate('GB', IncomeType.dividend), 0.15);
      });

      test('GB royalty rate is 10%', () {
        expect(service.getWithholdingRate('GB', IncomeType.royalty), 0.10);
      });

      test('SG dividend rate is 10%', () {
        expect(service.getWithholdingRate('SG', IncomeType.dividend), 0.10);
      });

      test('SG interest rate is 10%', () {
        expect(service.getWithholdingRate('SG', IncomeType.interest), 0.10);
      });

      test('SG royalty rate is 10%', () {
        expect(service.getWithholdingRate('SG', IncomeType.royalty), 0.10);
      });

      test('DE dividend rate is 10%', () {
        expect(service.getWithholdingRate('DE', IncomeType.dividend), 0.10);
      });

      test('DE interest rate is 10%', () {
        expect(service.getWithholdingRate('DE', IncomeType.interest), 0.10);
      });

      test('DE royalty rate is 10%', () {
        expect(service.getWithholdingRate('DE', IncomeType.royalty), 0.10);
      });

      test('AE (UAE) returns 0 (no DTAA, no income tax)', () {
        expect(service.getWithholdingRate('AE', IncomeType.interest), 0.0);
      });

      test('unknown country falls back to domestic rate (30%)', () {
        expect(service.getWithholdingRate('ZZ', IncomeType.interest), 0.30);
      });
    });

    // ─── isTrcRequired ────────────────────────────────────────────────────

    group('isTrcRequired', () {
      test('TRC is always required for DTAA benefits', () {
        expect(service.isTrcRequired('US'), true);
        expect(service.isTrcRequired('GB'), true);
        expect(service.isTrcRequired('AE'), true);
        expect(service.isTrcRequired('SG'), true);
      });
    });

    // ─── computeDoubleTaxRelief ───────────────────────────────────────────

    group('computeDoubleTaxRelief', () {
      test('relief is min of foreign and Indian tax on same income', () {
        // Indian tax ₹30k, foreign tax ₹20k → relief is ₹20k
        final relief = service.computeDoubleTaxRelief(
          3000000, // ₹30,000 Indian tax in paise
          2000000, // ₹20,000 foreign tax
          10000000, // ₹1,00,000 gross income
        );
        expect(relief, 2000000);
      });

      test('when Indian tax < foreign tax, relief is Indian tax', () {
        final relief = service.computeDoubleTaxRelief(
          1500000, // ₹15,000 Indian tax
          2500000, // ₹25,000 foreign tax
          10000000,
        );
        expect(relief, 1500000);
      });

      test('zero gross income → zero relief', () {
        final relief = service.computeDoubleTaxRelief(0, 0, 0);
        expect(relief, 0);
      });

      test('Indian and foreign tax equal → relief equals either', () {
        final relief = service.computeDoubleTaxRelief(
          1000000,
          1000000,
          5000000,
        );
        expect(relief, 1000000);
      });
    });

    // ─── computeRelief ────────────────────────────────────────────────────

    group('computeRelief', () {
      test('relief when TRC and Form 10F submitted for US interest', () {
        const benefit = DtaaBenefit(
          pan: 'ABCDE1234F',
          countryCode: 'US',
          incomeType: IncomeType.interest,
          grossIncome: 10000000, // ₹1,00,000 in paise
          withholdingTaxRate: 0.10,
          trcSubmitted: true,
          form10fSubmitted: true,
          dtaaTaxPaid: 1000000, // ₹10,000 paid abroad
          reliefClaimed: 0,
          article: 'Article 11 — Interest',
        );
        // dtaaTaxPaid = grossIncome × dtaaRate = 1,00,000 × 10% = ₹10,000
        // Indian tax assumed 30% = ₹30,000
        // Relief = min(₹10,000, ₹30,000) = ₹10,000
        final relief = service.computeRelief(benefit);
        expect(relief, 1000000); // ₹10,000 in paise
      });

      test('no relief when TRC not submitted', () {
        const benefit = DtaaBenefit(
          pan: 'ABCDE1234F',
          countryCode: 'US',
          incomeType: IncomeType.interest,
          grossIncome: 10000000,
          withholdingTaxRate: 0.10,
          trcSubmitted: false,
          form10fSubmitted: false,
          dtaaTaxPaid: 1000000,
          reliefClaimed: 0,
          article: 'Article 11 — Interest',
        );
        final relief = service.computeRelief(benefit);
        expect(relief, 0);
      });

      test('zero gross income → zero relief', () {
        const benefit = DtaaBenefit(
          pan: 'ABCDE1234F',
          countryCode: 'US',
          incomeType: IncomeType.interest,
          grossIncome: 0,
          withholdingTaxRate: 0.10,
          trcSubmitted: true,
          form10fSubmitted: true,
          dtaaTaxPaid: 0,
          reliefClaimed: 0,
          article: 'Article 11 — Interest',
        );
        expect(service.computeRelief(benefit), 0);
      });

      test('relief for UAE income is 0 (no DTAA)', () {
        const benefit = DtaaBenefit(
          pan: 'ABCDE1234F',
          countryCode: 'AE',
          incomeType: IncomeType.interest,
          grossIncome: 10000000,
          withholdingTaxRate: 0.0,
          trcSubmitted: true,
          form10fSubmitted: true,
          dtaaTaxPaid: 0,
          reliefClaimed: 0,
          article: 'N/A',
        );
        // dtaaTaxPaid = 0 → relief = 0
        expect(service.computeRelief(benefit), 0);
      });
    });

    // ─── DtaaBenefit model ────────────────────────────────────────────────

    group('DtaaBenefit model', () {
      test('equality and hashCode', () {
        const a = DtaaBenefit(
          pan: 'ABCDE1234F',
          countryCode: 'US',
          incomeType: IncomeType.interest,
          grossIncome: 10000000,
          withholdingTaxRate: 0.10,
          trcSubmitted: true,
          form10fSubmitted: true,
          dtaaTaxPaid: 1000000,
          reliefClaimed: 0,
          article: 'Article 11',
        );
        const b = DtaaBenefit(
          pan: 'ABCDE1234F',
          countryCode: 'US',
          incomeType: IncomeType.interest,
          grossIncome: 10000000,
          withholdingTaxRate: 0.10,
          trcSubmitted: true,
          form10fSubmitted: true,
          dtaaTaxPaid: 1000000,
          reliefClaimed: 0,
          article: 'Article 11',
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('copyWith updates fields immutably', () {
        const original = DtaaBenefit(
          pan: 'ABCDE1234F',
          countryCode: 'US',
          incomeType: IncomeType.interest,
          grossIncome: 10000000,
          withholdingTaxRate: 0.10,
          trcSubmitted: false,
          form10fSubmitted: false,
          dtaaTaxPaid: 0,
          reliefClaimed: 0,
          article: 'Article 11',
        );
        final updated = original.copyWith(
          trcSubmitted: true,
          dtaaTaxPaid: 1000000,
        );
        expect(updated.trcSubmitted, true);
        expect(updated.dtaaTaxPaid, 1000000);
        expect(original.trcSubmitted, false);
        expect(original.dtaaTaxPaid, 0);
      });

      test('different countryCode → not equal', () {
        const a = DtaaBenefit(
          pan: 'ABCDE1234F',
          countryCode: 'US',
          incomeType: IncomeType.interest,
          grossIncome: 10000000,
          withholdingTaxRate: 0.10,
          trcSubmitted: true,
          form10fSubmitted: true,
          dtaaTaxPaid: 1000000,
          reliefClaimed: 0,
          article: 'Article 11',
        );
        const b = DtaaBenefit(
          pan: 'ABCDE1234F',
          countryCode: 'GB',
          incomeType: IncomeType.interest,
          grossIncome: 10000000,
          withholdingTaxRate: 0.10,
          trcSubmitted: true,
          form10fSubmitted: true,
          dtaaTaxPaid: 1000000,
          reliefClaimed: 0,
          article: 'Article 11',
        );
        expect(a, isNot(equals(b)));
      });
    });
  });
}
