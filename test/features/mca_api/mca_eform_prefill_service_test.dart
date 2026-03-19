import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/mca/domain/models/mgt7_return.dart';
import 'package:ca_app/features/mca/domain/models/aoc4_financial_statement.dart';
import 'package:ca_app/features/mca/domain/models/director_detail.dart';
import 'package:ca_app/features/mca_api/domain/services/mca_eform_prefill_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Mgt7Return _makeMgt7({DateTime? agmDate}) => Mgt7Return(
  cin: 'L17110MH1973PLC019786',
  companyName: 'RELIANCE INDUSTRIES LIMITED',
  registeredOffice: 'Maker Chambers IV, Nariman Point, Mumbai 400021',
  financialYear: 2024,
  agmDate: agmDate ?? DateTime(2024, 9, 25),
  shareholdingPattern: const [],
  directors: const [],
  keyManagerialPersonnel: const [],
  meetings: const [],
  penalties: const [],
);

Aoc4FinancialStatement _makeAoc4() => Aoc4FinancialStatement(
  cin: 'L17110MH1973PLC019786',
  financialYear: 2024,
  auditReportDate: DateTime(2024, 8, 20),
  agmDate: DateTime(2024, 9, 25),
  balanceSheetTotal: 5000000000,
  profitAfterTax: 200000000,
  dividendPaid: 50000000,
  auditQualifications: const [],
);

DirectorDetail _makeDirector() => DirectorDetail(
  din: '00001008',
  name: 'Mukesh Dhirubhai Ambani',
  designation: 'Chairman and Managing Director',
  dateOfAppointment: DateTime(1977, 6, 24),
);

void main() {
  const service = McaEFormPrefillService();

  // -------------------------------------------------------------------------
  // buildMgt7Prefill
  // -------------------------------------------------------------------------
  group('McaEFormPrefillService.buildMgt7Prefill', () {
    test('returns a non-empty map', () {
      final form = _makeMgt7();
      final result = service.buildMgt7Prefill(form);
      expect(result, isNotEmpty);
    });

    test('includes cin field', () {
      final form = _makeMgt7();
      final result = service.buildMgt7Prefill(form);
      expect(result.containsKey('cin'), isTrue);
      expect(result['cin'], 'L17110MH1973PLC019786');
    });

    test('includes company_name field', () {
      final form = _makeMgt7();
      final result = service.buildMgt7Prefill(form);
      expect(result.containsKey('company_name'), isTrue);
      expect(result['company_name'], 'RELIANCE INDUSTRIES LIMITED');
    });

    test('includes financial_year field', () {
      final form = _makeMgt7();
      final result = service.buildMgt7Prefill(form);
      expect(result.containsKey('financial_year'), isTrue);
      expect(result['financial_year'], '2024');
    });

    test('includes agm_date field when AGM date is set', () {
      final form = _makeMgt7(agmDate: DateTime(2024, 9, 25));
      final result = service.buildMgt7Prefill(form);
      expect(result.containsKey('agm_date'), isTrue);
    });

    test('agm_date is formatted as DD/MM/YYYY', () {
      final form = _makeMgt7(agmDate: DateTime(2024, 9, 25));
      final result = service.buildMgt7Prefill(form);
      expect(result['agm_date'], '25/09/2024');
    });

    test('includes total_shareholders field', () {
      final form = _makeMgt7();
      final result = service.buildMgt7Prefill(form);
      expect(result.containsKey('total_shareholders'), isTrue);
    });

    test('total_shareholders reflects shareholding entries count', () {
      final form = _makeMgt7();
      final result = service.buildMgt7Prefill(form);
      expect(result['total_shareholders'], '0');
    });

    test('all values are strings', () {
      final form = _makeMgt7();
      final result = service.buildMgt7Prefill(form);
      for (final entry in result.entries) {
        expect(
          entry.value,
          isA<String>(),
          reason: 'Key ${entry.key} is not a String',
        );
      }
    });

    test('agm_date is empty string when agmDate is null', () {
      const form = Mgt7Return(
        cin: 'L17110MH1973PLC019786',
        companyName: 'Test Co',
        registeredOffice: '123 Test',
        financialYear: 2024,
        agmDate: null,
        shareholdingPattern: [],
        directors: [],
        keyManagerialPersonnel: [],
        meetings: [],
        penalties: [],
      );
      final result = service.buildMgt7Prefill(form);
      expect(result['agm_date'], '');
    });
  });

  // -------------------------------------------------------------------------
  // buildAoc4Prefill
  // -------------------------------------------------------------------------
  group('McaEFormPrefillService.buildAoc4Prefill', () {
    test('returns a non-empty map', () {
      final form = _makeAoc4();
      final result = service.buildAoc4Prefill(form);
      expect(result, isNotEmpty);
    });

    test('includes cin field', () {
      final form = _makeAoc4();
      final result = service.buildAoc4Prefill(form);
      expect(result.containsKey('cin'), isTrue);
      expect(result['cin'], 'L17110MH1973PLC019786');
    });

    test('includes financial_year field', () {
      final form = _makeAoc4();
      final result = service.buildAoc4Prefill(form);
      expect(result.containsKey('financial_year'), isTrue);
      expect(result['financial_year'], '2024');
    });

    test('includes total_assets field', () {
      final form = _makeAoc4();
      final result = service.buildAoc4Prefill(form);
      expect(result.containsKey('total_assets'), isTrue);
    });

    test('total_assets matches balance sheet total', () {
      final form = _makeAoc4();
      final result = service.buildAoc4Prefill(form);
      expect(result['total_assets'], '5000000000.0');
    });

    test('includes profit_loss field', () {
      final form = _makeAoc4();
      final result = service.buildAoc4Prefill(form);
      expect(result.containsKey('profit_loss'), isTrue);
    });

    test('profit_loss matches profit after tax', () {
      final form = _makeAoc4();
      final result = service.buildAoc4Prefill(form);
      expect(result['profit_loss'], '200000000.0');
    });

    test('includes agm_date field', () {
      final form = _makeAoc4();
      final result = service.buildAoc4Prefill(form);
      expect(result.containsKey('agm_date'), isTrue);
    });

    test('agm_date is formatted as DD/MM/YYYY', () {
      final form = _makeAoc4();
      final result = service.buildAoc4Prefill(form);
      expect(result['agm_date'], '25/09/2024');
    });

    test('all values are strings', () {
      final form = _makeAoc4();
      final result = service.buildAoc4Prefill(form);
      for (final entry in result.entries) {
        expect(
          entry.value,
          isA<String>(),
          reason: 'Key ${entry.key} is not a String',
        );
      }
    });
  });

  // -------------------------------------------------------------------------
  // buildDir3KycPrefill
  // -------------------------------------------------------------------------
  group('McaEFormPrefillService.buildDir3KycPrefill', () {
    test('returns a non-empty map', () {
      final director = _makeDirector();
      final result = service.buildDir3KycPrefill(director);
      expect(result, isNotEmpty);
    });

    test('includes din field', () {
      final director = _makeDirector();
      final result = service.buildDir3KycPrefill(director);
      expect(result.containsKey('din'), isTrue);
      expect(result['din'], '00001008');
    });

    test('includes name field', () {
      final director = _makeDirector();
      final result = service.buildDir3KycPrefill(director);
      expect(result.containsKey('name'), isTrue);
      expect(result['name'], 'Mukesh Dhirubhai Ambani');
    });

    test('includes dob field', () {
      final director = _makeDirector();
      final result = service.buildDir3KycPrefill(director);
      expect(result.containsKey('dob'), isTrue);
    });

    test('dob is formatted as DD/MM/YYYY from dateOfAppointment', () {
      final director = _makeDirector();
      final result = service.buildDir3KycPrefill(director);
      expect(result['dob'], '24/06/1977');
    });

    test('includes mobile field as empty string placeholder', () {
      final director = _makeDirector();
      final result = service.buildDir3KycPrefill(director);
      expect(result.containsKey('mobile'), isTrue);
    });

    test('includes email field as empty string placeholder', () {
      final director = _makeDirector();
      final result = service.buildDir3KycPrefill(director);
      expect(result.containsKey('email'), isTrue);
    });

    test('includes aadhaar field as empty string placeholder', () {
      final director = _makeDirector();
      final result = service.buildDir3KycPrefill(director);
      expect(result.containsKey('aadhaar'), isTrue);
    });

    test('all values are strings', () {
      final director = _makeDirector();
      final result = service.buildDir3KycPrefill(director);
      for (final entry in result.entries) {
        expect(
          entry.value,
          isA<String>(),
          reason: 'Key ${entry.key} is not a String',
        );
      }
    });

    test('map is immutable (returns unmodifiable view)', () {
      final director = _makeDirector();
      final result = service.buildDir3KycPrefill(director);
      // Verify it is a Map<String, String> — adding to it should throw
      expect(() => result['extra'] = 'value', throwsA(anything));
    });
  });
}
