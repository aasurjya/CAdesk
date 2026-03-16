import 'package:ca_app/features/fema/domain/models/fc_gpr.dart';
import 'package:ca_app/features/fema/domain/services/fema_compliance_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final engine = FemaComplianceEngine.instance;

  FcGpr makeValidFcGpr({
    String entityName = 'TechCorp India Pvt Ltd',
    String cin = 'U72200MH2020PTC123456',
    bool fipbRouteApproval = false,
    DateTime? dateOfReceipt,
    int sharesAllotted = 1000,
    int faceValuePaise = 1000, // Rs 10 face value
    int issuePricePaise = 10000, // Rs 100 issue price
    int premiumAmountPaise = 9000, // Rs 90 premium
    int totalInflowPaise = 10000000,
    String foreignInvestorCountry = 'USA',
  }) {
    return FcGpr(
      entityName: entityName,
      cin: cin,
      fipbRouteApproval: fipbRouteApproval,
      dateOfReceipt: dateOfReceipt ?? DateTime(2025, 6, 1),
      sharesAllotted: sharesAllotted,
      faceValuePaise: faceValuePaise,
      issuePricePaise: issuePricePaise,
      premiumAmountPaise: premiumAmountPaise,
      totalInflowPaise: totalInflowPaise,
      foreignInvestorCountry: foreignInvestorCountry,
    );
  }

  group('FemaComplianceEngine.instance', () {
    test('singleton returns same instance', () {
      expect(identical(FemaComplianceEngine.instance, engine), isTrue);
    });
  });

  group('FemaComplianceEngine.computeFcGprDeadline', () {
    test('deadline is 30 days after allotment date', () {
      final allotmentDate = DateTime(2025, 6, 1);
      final deadline = engine.computeFcGprDeadline(allotmentDate);

      expect(deadline, DateTime(2025, 7, 1));
    });

    test('handles month rollover correctly', () {
      final allotmentDate = DateTime(2025, 12, 15);
      final deadline = engine.computeFcGprDeadline(allotmentDate);

      expect(deadline, DateTime(2026, 1, 14));
    });

    test('deadline is exactly 30 days later', () {
      final allotmentDate = DateTime(2025, 3, 1);
      final deadline = engine.computeFcGprDeadline(allotmentDate);

      final diff = deadline.difference(allotmentDate).inDays;
      expect(diff, 30);
    });

    test('handles leap year February correctly', () {
      final allotmentDate = DateTime(2024, 2, 10);
      final deadline = engine.computeFcGprDeadline(allotmentDate);

      final diff = deadline.difference(allotmentDate).inDays;
      expect(diff, 30);
    });
  });

  group('FemaComplianceEngine.computeFlaDeadline', () {
    test('FLA deadline is July 15 of the given year', () {
      final deadline = engine.computeFlaDeadline(2025);
      expect(deadline, DateTime(2025, 7, 15));
    });

    test('FLA deadline for 2026 is July 15, 2026', () {
      final deadline = engine.computeFlaDeadline(2026);
      expect(deadline, DateTime(2026, 7, 15));
    });

    test('month is always July (month 7)', () {
      final deadline = engine.computeFlaDeadline(2024);
      expect(deadline.month, 7);
    });

    test('day is always 15', () {
      final deadline = engine.computeFlaDeadline(2025);
      expect(deadline.day, 15);
    });
  });

  group('FemaComplianceEngine.checkPricingGuidelines', () {
    test('returns true when issue price equals FMV', () {
      final form = makeValidFcGpr(issuePricePaise: 10000); // Rs 100
      // FMV Rs 100 → FMV paise in the method = 100 * 100 = 10000 paise
      final result = engine.checkPricingGuidelines(form, 100.0);
      expect(result, isTrue);
    });

    test('returns true when issue price exceeds FMV', () {
      final form = makeValidFcGpr(issuePricePaise: 12000); // Rs 120
      // FMV Rs 100 → 100 * 100 = 10000 paise
      final result = engine.checkPricingGuidelines(form, 100.0);
      expect(result, isTrue);
    });

    test('returns false when issue price is below FMV', () {
      final form = makeValidFcGpr(issuePricePaise: 8000); // Rs 80
      // FMV Rs 100 → 100 * 100 = 10000 paise
      final result = engine.checkPricingGuidelines(form, 100.0);
      expect(result, isFalse);
    });

    test(
      'returns false for zero FMV but non-zero issue price is okay (always compliant)',
      () {
        final form = makeValidFcGpr(issuePricePaise: 1000);
        // FMV = 0 → fmvPaise = 0 → issuePrice (1000) >= 0 → true
        final result = engine.checkPricingGuidelines(form, 0.0);
        expect(result, isTrue);
      },
    );
  });

  group('FemaComplianceEngine.validateFcGpr', () {
    test('returns no errors for a valid form', () {
      final form = makeValidFcGpr();
      final errors = engine.validateFcGpr(form);
      expect(errors, isEmpty);
    });

    test('returns error when entityName is empty', () {
      final form = makeValidFcGpr(entityName: '');
      final errors = engine.validateFcGpr(form);

      final nameErrors = errors.where((e) => e.field == 'entityName');
      expect(nameErrors, isNotEmpty);
    });

    test('returns error when entityName is whitespace only', () {
      final form = makeValidFcGpr(entityName: '   ');
      final errors = engine.validateFcGpr(form);

      final nameErrors = errors.where((e) => e.field == 'entityName');
      expect(nameErrors, isNotEmpty);
    });

    test('returns error when CIN is empty', () {
      final form = makeValidFcGpr(cin: '');
      final errors = engine.validateFcGpr(form);

      final cinErrors = errors.where((e) => e.field == 'cin');
      expect(cinErrors, isNotEmpty);
    });

    test('returns error when sharesAllotted is zero', () {
      final form = makeValidFcGpr(sharesAllotted: 0);
      final errors = engine.validateFcGpr(form);

      final shareErrors = errors.where((e) => e.field == 'sharesAllotted');
      expect(shareErrors, isNotEmpty);
    });

    test('returns error when sharesAllotted is negative', () {
      final form = makeValidFcGpr(sharesAllotted: -100);
      final errors = engine.validateFcGpr(form);

      final shareErrors = errors.where((e) => e.field == 'sharesAllotted');
      expect(shareErrors, isNotEmpty);
    });

    test('returns error when foreignInvestorCountry is empty', () {
      final form = makeValidFcGpr(foreignInvestorCountry: '');
      final errors = engine.validateFcGpr(form);

      final countryErrors = errors.where(
        (e) => e.field == 'foreignInvestorCountry',
      );
      expect(countryErrors, isNotEmpty);
    });

    test('returns error when issue price is below face value', () {
      final form = makeValidFcGpr(
        faceValuePaise: 1000, // Rs 10
        issuePricePaise: 500, // Rs 5 — below face value
      );
      final errors = engine.validateFcGpr(form);

      final priceErrors = errors.where((e) => e.field == 'issuePricePaise');
      expect(priceErrors, isNotEmpty);
    });

    test('no error when issue price equals face value', () {
      final form = makeValidFcGpr(
        faceValuePaise: 1000,
        issuePricePaise: 1000, // equal to face value — acceptable
      );
      final errors = engine.validateFcGpr(form);

      final priceErrors = errors.where((e) => e.field == 'issuePricePaise');
      expect(priceErrors, isEmpty);
    });

    test('accumulates multiple errors for multiple invalid fields', () {
      final form = makeValidFcGpr(entityName: '', cin: '', sharesAllotted: 0);
      final errors = engine.validateFcGpr(form);
      expect(errors.length, greaterThanOrEqualTo(3));
    });

    test('ValidationError equality — same fields are equal', () {
      const a = ValidationError(
        field: 'cin',
        message: 'CIN must not be empty.',
      );
      const b = ValidationError(
        field: 'cin',
        message: 'CIN must not be empty.',
      );
      expect(a, equals(b));
    });

    test('ValidationError inequality — different message', () {
      const a = ValidationError(
        field: 'cin',
        message: 'CIN must not be empty.',
      );
      const b = ValidationError(field: 'cin', message: 'Different message');
      expect(a, isNot(equals(b)));
    });
  });
}
