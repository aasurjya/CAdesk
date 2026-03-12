import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/llp/domain/models/llp_form11.dart';
import 'package:ca_app/features/llp/domain/models/llp_form8.dart';
import 'package:ca_app/features/llp/domain/models/llp_penalty_computation.dart';
import 'package:ca_app/features/llp/domain/services/llp_form11_service.dart';
import 'package:ca_app/features/llp/domain/services/llp_form8_service.dart';

void main() {
  group('LlpForm11Service', () {
    late LlpForm11Service service;

    setUp(() {
      service = LlpForm11Service.instance;
    });

    test('singleton returns same instance', () {
      expect(LlpForm11Service.instance, same(LlpForm11Service.instance));
    });

    group('computeDeadline', () {
      test('returns May 30 of the year following the financial year', () {
        // FY 2023-24 → deadline May 30, 2024
        final deadline = service.computeDeadline(2024);
        expect(deadline, DateTime(2024, 5, 30));
      });

      test('FY 2022-23 deadline is May 30 2023', () {
        final deadline = service.computeDeadline(2023);
        expect(deadline, DateTime(2023, 5, 30));
      });
    });

    group('computePenalty', () {
      test('no penalty when filed on due date', () {
        final due = DateTime(2024, 5, 30);
        final filed = DateTime(2024, 5, 30);
        expect(service.computePenalty(due, filed), 0);
      });

      test('no penalty when filed before due date', () {
        final due = DateTime(2024, 5, 30);
        final filed = DateTime(2024, 5, 15);
        expect(service.computePenalty(due, filed), 0);
      });

      test('penalty of Rs 100 per day beyond due date', () {
        final due = DateTime(2024, 5, 30);
        final filed = DateTime(2024, 6, 9); // 10 days late
        // 10 days * Rs 100 = Rs 1000 = 100000 paise
        expect(service.computePenalty(due, filed), 100000);
      });

      test('1 day late = Rs 100 = 10000 paise', () {
        final due = DateTime(2024, 5, 30);
        final filed = DateTime(2024, 5, 31);
        expect(service.computePenalty(due, filed), 10000);
      });
    });

    group('prepareForm11', () {
      test('creates LlpForm11 with correct financial year', () {
        const llp = LlpData(
          llpin: 'AAA-1234',
          name: 'Test LLP',
          registeredOffice: '123 Main Street, Mumbai',
          numberOfPartners: 2,
          totalContributionPaise: 1000000,
        );
        final form = service.prepareForm11(llp, 2024);
        expect(form.llpin, 'AAA-1234');
        expect(form.name, 'Test LLP');
        expect(form.numberOfPartners, 2);
        expect(form.financialYear, 2024);
      });
    });
  });

  group('LlpForm8Service', () {
    late LlpForm8Service service;

    setUp(() {
      service = LlpForm8Service.instance;
    });

    test('singleton returns same instance', () {
      expect(LlpForm8Service.instance, same(LlpForm8Service.instance));
    });

    group('computeDeadline', () {
      test('returns October 30 of the year following the financial year end', () {
        // FY 2023-24 → deadline Oct 30, 2024
        final deadline = service.computeDeadline(2024);
        expect(deadline, DateTime(2024, 10, 30));
      });

      test('FY 2022-23 deadline is Oct 30 2023', () {
        final deadline = service.computeDeadline(2023);
        expect(deadline, DateTime(2023, 10, 30));
      });
    });

    group('prepareForm8', () {
      test('creates LlpForm8 with correct data', () {
        const llp = LlpData(
          llpin: 'BBB-5678',
          name: 'Sample LLP',
          registeredOffice: '456 Park Avenue, Delhi',
          numberOfPartners: 3,
          totalContributionPaise: 5000000,
        );
        const fs = FinancialStatements(
          totalAssetsPaise: 10000000,
          totalLiabilitiesPaise: 4000000,
          turnoverPaise: 20000000,
          profitAfterTaxPaise: 2000000,
        );
        final form = service.prepareForm8(llp, fs, 2024);
        expect(form.financialYear, 2024);
        expect(form.totalAssetsPaise, 10000000);
        expect(form.totalLiabilitiesPaise, 4000000);
        expect(form.solvencyDeclaration, true);
      });

      test('solvency declaration false when liabilities exceed assets', () {
        const llp = LlpData(
          llpin: 'CCC-9999',
          name: 'Insolvent LLP',
          registeredOffice: '789 Street',
          numberOfPartners: 2,
          totalContributionPaise: 100000,
        );
        const fs = FinancialStatements(
          totalAssetsPaise: 1000000,
          totalLiabilitiesPaise: 5000000,
          turnoverPaise: 500000,
          profitAfterTaxPaise: -2000000,
        );
        final form = service.prepareForm8(llp, fs, 2024);
        expect(form.solvencyDeclaration, false);
      });
    });
  });

  group('LlpForm11 model', () {
    test('immutable equality', () {
      const a = LlpForm11(
        llpin: 'AAA-1234',
        name: 'Test LLP',
        registeredOffice: '123 Main',
        numberOfPartners: 2,
        totalContributionPaise: 1000000,
        financialYear: 2024,
        partners: [],
        meetings: [],
      );
      const b = LlpForm11(
        llpin: 'AAA-1234',
        name: 'Test LLP',
        registeredOffice: '123 Main',
        numberOfPartners: 2,
        totalContributionPaise: 1000000,
        financialYear: 2024,
        partners: [],
        meetings: [],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith creates new instance with updated field', () {
      const original = LlpForm11(
        llpin: 'AAA-1234',
        name: 'Old Name',
        registeredOffice: '123 Main',
        numberOfPartners: 2,
        totalContributionPaise: 1000000,
        financialYear: 2024,
        partners: [],
        meetings: [],
      );
      final updated = original.copyWith(name: 'New Name');
      expect(updated.name, 'New Name');
      expect(updated.llpin, 'AAA-1234');
      expect(original.name, 'Old Name'); // original unchanged
    });
  });

  group('LlpForm8 model', () {
    test('immutable equality', () {
      const a = LlpForm8(
        llpin: 'BBB-5678',
        financialYear: 2024,
        totalAssetsPaise: 10000000,
        totalLiabilitiesPaise: 4000000,
        turnoverPaise: 20000000,
        profitAfterTaxPaise: 2000000,
        solvencyDeclaration: true,
      );
      const b = LlpForm8(
        llpin: 'BBB-5678',
        financialYear: 2024,
        totalAssetsPaise: 10000000,
        totalLiabilitiesPaise: 4000000,
        turnoverPaise: 20000000,
        profitAfterTaxPaise: 2000000,
        solvencyDeclaration: true,
      );
      expect(a, equals(b));
    });
  });

  group('LlpPenaltyComputation model', () {
    test('immutable equality', () {
      final due = DateTime(2024, 5, 30);
      final filed = DateTime(2024, 6, 9);
      final a = LlpPenaltyComputation(
        formType: 'Form-11',
        dueDate: due,
        filedDate: filed,
        daysBeyondDue: 10,
        penaltyPaise: 100000,
      );
      final b = LlpPenaltyComputation(
        formType: 'Form-11',
        dueDate: due,
        filedDate: filed,
        daysBeyondDue: 10,
        penaltyPaise: 100000,
      );
      expect(a, equals(b));
    });
  });

  group('LlpPartnerDetail model', () {
    test('equality and copyWith', () {
      const a = LlpPartnerDetail(
        dpin: '00123456',
        name: 'Amit Kumar',
        contributionPaise: 500000,
        isDesignatedPartner: true,
      );
      const b = LlpPartnerDetail(
        dpin: '00123456',
        name: 'Amit Kumar',
        contributionPaise: 500000,
        isDesignatedPartner: true,
      );
      expect(a, equals(b));
      final updated = a.copyWith(name: 'Rahul');
      expect(updated.name, 'Rahul');
      expect(a.name, 'Amit Kumar');
    });
  });

  group('MeetingRecord model', () {
    test('equality and copyWith', () {
      final date = DateTime(2024, 3, 15);
      final a = MeetingRecord(date: date, purpose: 'Annual Review', venue: 'Office');
      final b = MeetingRecord(date: date, purpose: 'Annual Review', venue: 'Office');
      expect(a, equals(b));
      final updated = a.copyWith(venue: 'Virtual');
      expect(updated.venue, 'Virtual');
    });
  });
}
