import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/mca_api/data/mock_mca_repository.dart';
import 'package:ca_app/features/mca_api/data/repositories/mca_api_repository_impl.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_company_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_director_lookup.dart';
import 'package:ca_app/features/mca_api/domain/models/mca_eform_status.dart';

void main() {
  group('MockMcaRepository', () {
    late MockMcaRepository repo;

    setUp(() {
      repo = const MockMcaRepository();
    });

    const validCin = 'L17110MH1973PLC019786';
    const validDin = '00001001';

    group('lookupByCin', () {
      test('returns company for valid CIN', () async {
        final result = await repo.lookupByCin(validCin);
        expect(result.cin, validCin);
        expect(result.status, McaCompanyStatus.active);
      });

      test('throws ArgumentError for invalid CIN', () async {
        expect(() => repo.lookupByCin('INVALID'), throwsArgumentError);
      });
    });

    group('searchByName', () {
      test('returns result for non-empty name', () async {
        final result = await repo.searchByName('Reliance');
        expect(result.companyName, isNotEmpty);
      });

      test('throws ArgumentError for empty name', () async {
        expect(() => repo.searchByName(''), throwsArgumentError);
      });
    });

    group('lookupDirector', () {
      test('returns director for valid DIN', () async {
        final result = await repo.lookupDirector(validDin);
        expect(result.din, validDin);
        expect(result.status, McaDirectorStatus.approved);
      });

      test('throws ArgumentError for invalid DIN', () async {
        expect(() => repo.lookupDirector('BADDIN'), throwsArgumentError);
      });
    });

    group('getFormStatus', () {
      test('returns approved status for valid SRN', () async {
        final result = await repo.getFormStatus('A12345678');
        expect(result.status, McaEFormStatusValue.approved);
      });
    });

    group('getFilingHistory', () {
      test('returns history with filings for valid CIN', () async {
        final result = await repo.getFilingHistory(validCin);
        expect(result.cin, validCin);
        expect(result.filings, isNotEmpty);
      });

      test('throws ArgumentError for invalid CIN', () async {
        expect(() => repo.getFilingHistory('INVALID'), throwsArgumentError);
      });
    });

    group('prefillAndSubmitForm', () {
      test('returns pending status with generated SRN', () async {
        final result = await repo.prefillAndSubmitForm(validCin, 'MGT-7', {
          'key': 'value',
        });
        expect(result.status, McaEFormStatusValue.pending);
        expect(result.srn, isNotEmpty);
        expect(result.cin, validCin);
        expect(result.formType, 'MGT-7');
      });

      test('throws ArgumentError for invalid CIN', () async {
        expect(
          () => repo.prefillAndSubmitForm('INVALID', 'MGT-7', {}),
          throwsArgumentError,
        );
      });
    });
  });

  group('McaApiRepositoryImpl', () {
    late McaApiRepositoryImpl repo;

    setUp(() {
      repo = const McaApiRepositoryImpl();
    });

    const validCin = 'L17110MH1973PLC019786';

    group('lookupByCin', () {
      test('throws ArgumentError for invalid CIN', () async {
        expect(() => repo.lookupByCin('INVALID'), throwsArgumentError);
      });

      test(
        'throws UnimplementedError for valid CIN (portal pending)',
        () async {
          expect(() => repo.lookupByCin(validCin), throwsUnimplementedError);
        },
      );
    });

    group('searchByName', () {
      test('throws ArgumentError for empty name', () async {
        expect(() => repo.searchByName(''), throwsArgumentError);
      });
    });

    group('getFilingHistory', () {
      test('returns empty history for valid CIN', () async {
        final result = await repo.getFilingHistory(validCin);
        expect(result.filings, isEmpty);
      });

      test('throws ArgumentError for invalid CIN', () async {
        expect(() => repo.getFilingHistory('BAD'), throwsArgumentError);
      });
    });
  });
}
