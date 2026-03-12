import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/cma/domain/models/cma_data.dart';
import 'package:ca_app/features/cma/domain/models/cma_operating_statement.dart';
import 'package:ca_app/features/cma/domain/models/cma_balance_sheet.dart';
import 'package:ca_app/features/cma/domain/models/fund_flow_statement.dart';
import 'package:ca_app/features/cma/domain/services/cma_preparation_service.dart';

void main() {
  group('CmaPreparationService — projectOperatingStatement', () {
    test('projects gross sales with given growth rate', () {
      final base = CmaOperatingStatement.empty().copyWith(
        year: 2023,
        grossSales: 10000000, // ₹1L in paise
      );
      final projected = CmaPreparationService.instance
          .projectOperatingStatement(
            base,
            0.20, // 20% growth
            2024,
          );
      expect(projected.year, 2024);
      expect(projected.grossSales, 12000000); // 1L × 1.20
    });

    test('projects all cost line items with same growth rate', () {
      final base = CmaOperatingStatement.empty().copyWith(
        year: 2023,
        grossSales: 10000000,
        rawMaterials: 4000000,
        wages: 1000000,
        power: 500000,
        sellingExpenses: 200000,
        adminExpenses: 300000,
      );
      final projected = CmaPreparationService.instance
          .projectOperatingStatement(base, 0.10, 2024);
      expect(projected.rawMaterials, 4400000); // 4L × 1.10
      expect(projected.wages, 1100000);
      expect(projected.power, 550000);
      expect(projected.sellingExpenses, 220000);
      expect(projected.adminExpenses, 330000);
    });

    test('projected year is set correctly', () {
      final base = CmaOperatingStatement.empty().copyWith(year: 2023);
      final projected = CmaPreparationService.instance
          .projectOperatingStatement(base, 0.15, 2025);
      expect(projected.year, 2025);
    });

    test('zero growth rate returns same values with new year', () {
      final base = CmaOperatingStatement.empty().copyWith(
        year: 2023,
        grossSales: 5000000,
        rawMaterials: 2000000,
      );
      final projected = CmaPreparationService.instance
          .projectOperatingStatement(base, 0.0, 2024);
      expect(projected.grossSales, 5000000);
      expect(projected.rawMaterials, 2000000);
      expect(projected.year, 2024);
    });
  });

  group('CmaPreparationService — validateCmaData', () {
    test('valid data returns empty error list', () {
      final data = _buildValidCmaData();
      final errors = CmaPreparationService.instance.validateCmaData(data);
      expect(errors, isEmpty);
    });

    test('empty entity name returns validation error', () {
      final data = _buildValidCmaData().copyWith(entityName: '');
      final errors = CmaPreparationService.instance.validateCmaData(data);
      expect(errors.any((e) => e.field == 'entityName'), isTrue);
    });

    test('invalid PAN format returns validation error', () {
      final data = _buildValidCmaData().copyWith(pan: 'INVALID');
      final errors = CmaPreparationService.instance.validateCmaData(data);
      expect(errors.any((e) => e.field == 'pan'), isTrue);
    });

    test('valid PAN format passes validation', () {
      final data = _buildValidCmaData().copyWith(pan: 'ABCDE1234F');
      final errors = CmaPreparationService.instance.validateCmaData(data);
      expect(errors.where((e) => e.field == 'pan'), isEmpty);
    });

    test('no operating statements returns validation error', () {
      final data = _buildValidCmaData().copyWith(operatingStatements: {});
      final errors = CmaPreparationService.instance.validateCmaData(data);
      expect(errors.any((e) => e.field == 'operatingStatements'), isTrue);
    });

    test('no balance sheets returns validation error', () {
      final data = _buildValidCmaData().copyWith(balanceSheets: {});
      final errors = CmaPreparationService.instance.validateCmaData(data);
      expect(errors.any((e) => e.field == 'balanceSheets'), isTrue);
    });

    test('empty historialYears list returns validation error', () {
      final data = _buildValidCmaData().copyWith(historicalYears: []);
      final errors = CmaPreparationService.instance.validateCmaData(data);
      expect(errors.any((e) => e.field == 'historicalYears'), isTrue);
    });

    test('empty projectionYears list returns validation error', () {
      final data = _buildValidCmaData().copyWith(projectionYears: []);
      final errors = CmaPreparationService.instance.validateCmaData(data);
      expect(errors.any((e) => e.field == 'projectionYears'), isTrue);
    });
  });

  group('CmaPreparationService — singleton', () {
    test('instance returns same object each time', () {
      expect(
        identical(
          CmaPreparationService.instance,
          CmaPreparationService.instance,
        ),
        isTrue,
      );
    });
  });

  group('CmaData — model', () {
    test('copyWith returns updated instance without mutating original', () {
      final original = _buildValidCmaData();
      final updated = original.copyWith(entityName: 'Updated Corp');
      expect(updated.entityName, 'Updated Corp');
      expect(original.entityName, 'Test Corp');
    });

    test('equality based on all fields', () {
      final a = _buildValidCmaData();
      final b = _buildValidCmaData();
      expect(a, equals(b));
    });

    test('hashCode consistency', () {
      final a = _buildValidCmaData();
      final b = _buildValidCmaData();
      expect(a.hashCode, b.hashCode);
    });

    test('purpose enum has correct values', () {
      expect(CmaLoanPurpose.values.length, 3);
      expect(CmaLoanPurpose.values, contains(CmaLoanPurpose.workingCapital));
      expect(CmaLoanPurpose.values, contains(CmaLoanPurpose.termLoan));
      expect(CmaLoanPurpose.values, contains(CmaLoanPurpose.both));
    });
  });

  group('CmaOperatingStatement — model', () {
    test('netSales = grossSales - returnsAndDiscounts', () {
      final stmt = CmaOperatingStatement.empty().copyWith(
        grossSales: 10000000,
        returnsAndDiscounts: 500000,
      );
      expect(stmt.netSales, 9500000);
    });

    test('costOfProduction = all manufacturing costs', () {
      final stmt = CmaOperatingStatement.empty().copyWith(
        rawMaterials: 4000000,
        wages: 1000000,
        power: 500000,
        storeItems: 200000,
        repairsAndMaintenance: 100000,
        otherManufacturing: 200000,
      );
      expect(stmt.costOfProduction, 6000000);
    });

    test(
      'costOfGoodsSold = costOfProduction + openingStock - closingStock',
      () {
        final stmt = CmaOperatingStatement.empty().copyWith(
          rawMaterials: 4000000,
          wages: 1000000,
          power: 500000,
          openingStock: 800000,
          closingStock: 600000,
        );
        // COP = 5,500,000, COGS = 5,500,000 + 800,000 - 600,000 = 5,700,000
        expect(stmt.costOfGoodsSold, 5700000);
      },
    );

    test(
      'profitBeforeTax = netSales - COGS - opex - fin charges - depreciation',
      () {
        final stmt = CmaOperatingStatement.empty().copyWith(
          grossSales: 10000000,
          returnsAndDiscounts: 0,
          rawMaterials: 4000000,
          openingStock: 0,
          closingStock: 0,
          sellingExpenses: 500000,
          adminExpenses: 500000,
          financialCharges: 200000,
          depreciation: 300000,
        );
        // NetSales = 10M, COGS = 4M, opex = 1M, fin = 0.2M, dep = 0.3M
        // PBT = 10M - 4M - 1M - 0.2M - 0.3M = 4.5M
        expect(stmt.profitBeforeTax, 4500000);
      },
    );

    test('profitAfterTax = profitBeforeTax - tax', () {
      final stmt = CmaOperatingStatement.empty().copyWith(
        grossSales: 10000000,
        rawMaterials: 4000000,
        sellingExpenses: 500000,
        adminExpenses: 500000,
        financialCharges: 200000,
        depreciation: 300000,
        tax: 1200000,
      );
      // PBT = 4.5M, PAT = 4.5M - 1.2M = 3.3M
      expect(stmt.profitAfterTax, 3300000);
    });

    test('copyWith does not mutate original', () {
      final original = CmaOperatingStatement.empty().copyWith(
        year: 2023,
        grossSales: 5000000,
      );
      final updated = original.copyWith(grossSales: 6000000);
      expect(original.grossSales, 5000000);
      expect(updated.grossSales, 6000000);
    });

    test('equality and hashCode', () {
      final a = CmaOperatingStatement.empty().copyWith(
        year: 2023,
        grossSales: 5000000,
      );
      final b = CmaOperatingStatement.empty().copyWith(
        year: 2023,
        grossSales: 5000000,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('CmaBalanceSheet — model', () {
    test(
      'workingCapital = totalCurrentAssets - currentLiabilitiesExclBank',
      () {
        final bs = CmaBalanceSheet.empty().copyWith(
          totalCurrentAssets: 5000000,
          currentLiabilitiesExclBank: 2000000,
        );
        expect(bs.workingCapital, 3000000);
      },
    );

    test('copyWith does not mutate original', () {
      final original = CmaBalanceSheet.empty().copyWith(year: 2023);
      final updated = original.copyWith(year: 2024);
      expect(original.year, 2023);
      expect(updated.year, 2024);
    });

    test('equality and hashCode', () {
      final a = CmaBalanceSheet.empty().copyWith(
        year: 2023,
        totalCurrentAssets: 1000000,
      );
      final b = CmaBalanceSheet.empty().copyWith(
        year: 2023,
        totalCurrentAssets: 1000000,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('ValidationError — model', () {
    test('holds field and message', () {
      const error = ValidationError(field: 'pan', message: 'Invalid PAN');
      expect(error.field, 'pan');
      expect(error.message, 'Invalid PAN');
    });

    test('equality', () {
      const a = ValidationError(field: 'pan', message: 'Invalid PAN');
      const b = ValidationError(field: 'pan', message: 'Invalid PAN');
      expect(a, equals(b));
    });
  });
}

// Helper to build a valid CmaData for testing
CmaData _buildValidCmaData() {
  final opStmt = CmaOperatingStatement.empty().copyWith(
    year: 2023,
    grossSales: 10000000,
  );
  final bs = CmaBalanceSheet.empty().copyWith(year: 2023);
  final ff = FundFlowStatement(
    year: 2023,
    sourcesOfFunds: const [],
    usesOfFunds: const [],
    netChange: 0,
    openingWorkingCapital: 0,
    closingWorkingCapital: 0,
  );
  return CmaData(
    entityName: 'Test Corp',
    pan: 'ABCDE1234F',
    purpose: CmaLoanPurpose.workingCapital,
    historicalYears: const [2022, 2023],
    projectionYears: const [2024, 2025],
    operatingStatements: {2023: opStmt},
    balanceSheets: {2023: bs},
    cashFlows: {2023: ff},
  );
}
