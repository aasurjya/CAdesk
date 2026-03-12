import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/fema/domain/models/fc_gpr.dart';
import 'package:ca_app/features/fema/domain/models/fla_return.dart';
import 'package:ca_app/features/fema/domain/services/fema_compliance_engine.dart';

void main() {
  group('FemaComplianceEngine', () {
    late FemaComplianceEngine engine;

    setUp(() {
      engine = FemaComplianceEngine.instance;
    });

    test('singleton returns same instance', () {
      expect(
        FemaComplianceEngine.instance,
        same(FemaComplianceEngine.instance),
      );
    });

    group('computeFcGprDeadline', () {
      test('deadline is 30 days from date of allotment', () {
        final allotment = DateTime(2024, 3, 1);
        final deadline = engine.computeFcGprDeadline(allotment);
        expect(deadline, DateTime(2024, 3, 31));
      });

      test('deadline for allotment on Jan 15 is Feb 14', () {
        final allotment = DateTime(2024, 1, 15);
        final deadline = engine.computeFcGprDeadline(allotment);
        expect(deadline, DateTime(2024, 2, 14));
      });
    });

    group('computeFlaDeadline', () {
      test('FLA deadline is July 15 of reporting year', () {
        final deadline = engine.computeFlaDeadline(2024);
        expect(deadline, DateTime(2024, 7, 15));
      });
    });

    group('checkPricingGuidelines', () {
      test('valid when issue price equals FMV', () {
        final form = FcGpr(
          entityName: 'Test Startup Pvt Ltd',
          cin: 'U72900MH2020PTC345678',
          fipbRouteApproval: false,
          dateOfReceipt: DateTime(2024, 3, 15),
          sharesAllotted: 1000,
          faceValuePaise: 1000, // Rs 10 face value
          issuePricePaise: 100000, // Rs 1000 per share
          premiumAmountPaise: 99000, // Rs 990 premium
          totalInflowPaise: 100000000, // Rs 10L
          foreignInvestorCountry: 'USA',
        );
        expect(engine.checkPricingGuidelines(form, 1000.0), true);
      });

      test('valid when issue price exceeds FMV', () {
        final form = FcGpr(
          entityName: 'Test Startup Pvt Ltd',
          cin: 'U72900MH2020PTC345678',
          fipbRouteApproval: false,
          dateOfReceipt: DateTime(2024, 3, 15),
          sharesAllotted: 1000,
          faceValuePaise: 1000,
          issuePricePaise: 120000, // Rs 1200 > FMV Rs 1000
          premiumAmountPaise: 119000,
          totalInflowPaise: 120000000,
          foreignInvestorCountry: 'USA',
        );
        expect(engine.checkPricingGuidelines(form, 1000.0), true);
      });

      test('invalid when issue price is below FMV', () {
        final form = FcGpr(
          entityName: 'Test Startup Pvt Ltd',
          cin: 'U72900MH2020PTC345678',
          fipbRouteApproval: false,
          dateOfReceipt: DateTime(2024, 3, 15),
          sharesAllotted: 1000,
          faceValuePaise: 1000,
          issuePricePaise: 80000, // Rs 800 < FMV Rs 1000
          premiumAmountPaise: 79000,
          totalInflowPaise: 80000000,
          foreignInvestorCountry: 'USA',
        );
        expect(engine.checkPricingGuidelines(form, 1000.0), false);
      });
    });

    group('validateFcGpr', () {
      test('no errors for valid FcGpr', () {
        final form = FcGpr(
          entityName: 'Test Startup Pvt Ltd',
          cin: 'U72900MH2020PTC345678',
          fipbRouteApproval: false,
          dateOfReceipt: DateTime(2024, 3, 15),
          sharesAllotted: 1000,
          faceValuePaise: 1000,
          issuePricePaise: 100000,
          premiumAmountPaise: 99000,
          totalInflowPaise: 100000000,
          foreignInvestorCountry: 'USA',
        );
        final errors = engine.validateFcGpr(form);
        expect(errors, isEmpty);
      });

      test('error when entity name is empty', () {
        final form = FcGpr(
          entityName: '',
          cin: 'U72900MH2020PTC345678',
          fipbRouteApproval: false,
          dateOfReceipt: DateTime(2024, 3, 15),
          sharesAllotted: 1000,
          faceValuePaise: 1000,
          issuePricePaise: 100000,
          premiumAmountPaise: 99000,
          totalInflowPaise: 100000000,
          foreignInvestorCountry: 'USA',
        );
        final errors = engine.validateFcGpr(form);
        expect(errors.isNotEmpty, true);
      });

      test('error when shares allotted is zero', () {
        final form = FcGpr(
          entityName: 'Test Co',
          cin: 'U72900MH2020PTC345678',
          fipbRouteApproval: false,
          dateOfReceipt: DateTime(2024, 3, 15),
          sharesAllotted: 0,
          faceValuePaise: 1000,
          issuePricePaise: 100000,
          premiumAmountPaise: 99000,
          totalInflowPaise: 0,
          foreignInvestorCountry: 'USA',
        );
        final errors = engine.validateFcGpr(form);
        expect(errors.isNotEmpty, true);
      });
    });
  });

  group('FcGpr model', () {
    test('equality and copyWith', () {
      final a = FcGpr(
        entityName: 'Test Co',
        cin: 'U72900MH2020PTC345678',
        fipbRouteApproval: false,
        dateOfReceipt: DateTime(2024, 3, 15),
        sharesAllotted: 1000,
        faceValuePaise: 1000,
        issuePricePaise: 100000,
        premiumAmountPaise: 99000,
        totalInflowPaise: 100000000,
        foreignInvestorCountry: 'USA',
      );
      final b = FcGpr(
        entityName: 'Test Co',
        cin: 'U72900MH2020PTC345678',
        fipbRouteApproval: false,
        dateOfReceipt: DateTime(2024, 3, 15),
        sharesAllotted: 1000,
        faceValuePaise: 1000,
        issuePricePaise: 100000,
        premiumAmountPaise: 99000,
        totalInflowPaise: 100000000,
        foreignInvestorCountry: 'USA',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      final updated = a.copyWith(foreignInvestorCountry: 'UK');
      expect(updated.foreignInvestorCountry, 'UK');
      expect(a.foreignInvestorCountry, 'USA');
    });
  });

  group('FlaReturn model', () {
    test('equality', () {
      const a = FlaReturn(
        entityName: 'Test Corp',
        pan: 'AAAAA0001A',
        reportingYear: 2024,
        totalForeignEquityLiabilitiesPaise: 100000000,
        totalForeignDebtLiabilitiesPaise: 50000000,
        totalForeignAssetsPaise: 30000000,
      );
      const b = FlaReturn(
        entityName: 'Test Corp',
        pan: 'AAAAA0001A',
        reportingYear: 2024,
        totalForeignEquityLiabilitiesPaise: 100000000,
        totalForeignDebtLiabilitiesPaise: 50000000,
        totalForeignAssetsPaise: 30000000,
      );
      expect(a, equals(b));
    });
  });
}
