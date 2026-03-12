import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/mca/domain/models/company.dart';
import 'package:ca_app/features/mca/domain/models/director_detail.dart';
import 'package:ca_app/features/mca/domain/models/mgt7_return.dart';
import 'package:ca_app/features/mca/domain/services/mgt7_preparation_service.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

Company _makeCompany({List<Director>? directors}) {
  return Company(
    id: 'c1',
    cin: 'U74999MH2018PTC123456',
    companyName: 'Test Private Ltd',
    incorporationDate: DateTime(2018, 1, 1),
    category: CompanyCategory.privateLimited,
    paidUpCapital: 100000,
    authorisedCapital: 1000000,
    registeredAddress: '123 MG Road, Mumbai',
    rocJurisdiction: 'ROC Mumbai',
    directors: directors ?? _defaultDirectors(),
  );
}

List<Director> _defaultDirectors() => [
  Director(
    din: '12345678',
    name: 'Rajesh Kumar',
    designation: 'Director',
    appointmentDate: DateTime(2018, 1, 1),
    isActive: true,
  ),
  Director(
    din: '87654321',
    name: 'Priya Sharma',
    designation: 'Managing Director',
    appointmentDate: DateTime(2019, 3, 15),
    isActive: true,
  ),
];

void main() {
  // -------------------------------------------------------------------------
  // prepareMgt7
  // -------------------------------------------------------------------------
  group('Mgt7PreparationService.prepareMgt7', () {
    test('returns Mgt7Return with correct CIN and company name', () {
      final company = _makeCompany();
      final result = Mgt7PreparationService.instance.prepareMgt7(
        company,
        2024,
      );

      expect(result.cin, 'U74999MH2018PTC123456');
      expect(result.companyName, 'Test Private Ltd');
    });

    test('financial year is set correctly', () {
      final company = _makeCompany();
      final result = Mgt7PreparationService.instance.prepareMgt7(
        company,
        2024,
      );

      expect(result.financialYear, 2024);
    });

    test('directors are populated from company directors', () {
      final company = _makeCompany();
      final result = Mgt7PreparationService.instance.prepareMgt7(
        company,
        2024,
      );

      expect(result.directors, hasLength(2));
      expect(result.directors.first.din, '12345678');
    });

    test('returns Mgt7Return with empty shareholding by default', () {
      final company = _makeCompany();
      final result = Mgt7PreparationService.instance.prepareMgt7(
        company,
        2024,
      );

      expect(result.shareholdingPattern, isEmpty);
    });

    test('returns Mgt7Return with registered office from company', () {
      final company = _makeCompany();
      final result = Mgt7PreparationService.instance.prepareMgt7(
        company,
        2024,
      );

      expect(result.registeredOffice, '123 MG Road, Mumbai');
    });
  });

  // -------------------------------------------------------------------------
  // validateMgt7
  // -------------------------------------------------------------------------
  group('Mgt7PreparationService.validateMgt7', () {
    test('returns no errors for a fully valid MGT-7', () {
      final company = _makeCompany();
      final form = Mgt7PreparationService.instance.prepareMgt7(company, 2024);
      // Set AGM date within 6 months of FY end (March 31 + 6m = Sep 30)
      final validForm = form.copyWith(
        agmDate: DateTime(2024, 9, 15),
        meetings: [
          MeetingRecord(
            meetingType: MeetingType.boardMeeting,
            date: DateTime(2024, 5, 10),
            attendees: ['12345678', '87654321'],
          ),
        ],
      );
      final errors = Mgt7PreparationService.instance.validateMgt7(validForm);
      expect(errors, isEmpty);
    });

    test('error when AGM is after September 30 for March FY company', () {
      final company = _makeCompany();
      final form = Mgt7PreparationService.instance
          .prepareMgt7(company, 2024)
          .copyWith(agmDate: DateTime(2024, 10, 5));

      final errors = Mgt7PreparationService.instance.validateMgt7(form);
      expect(errors.any((e) => e.field == 'agmDate'), isTrue);
    });

    test('error when no directors present', () {
      final company = _makeCompany(directors: []);
      final form = Mgt7PreparationService.instance.prepareMgt7(company, 2024);
      final errors = Mgt7PreparationService.instance.validateMgt7(form);
      expect(errors.any((e) => e.field == 'directors'), isTrue);
    });

    test('error when a director has empty DIN', () {
      final badDirector = DirectorDetail(
        din: '',
        name: 'Ghost Director',
        designation: 'Director',
        dateOfAppointment: DateTime(2022, 1, 1),
        shareholding: 0,
      );
      final company = _makeCompany();
      final form = Mgt7PreparationService.instance
          .prepareMgt7(company, 2024)
          .copyWith(
            directors: [badDirector],
          );

      final errors = Mgt7PreparationService.instance.validateMgt7(form);
      expect(errors.any((e) => e.field == 'directors'), isTrue);
    });

    test('error when CIN is empty', () {
      final company = _makeCompany();
      final form = Mgt7PreparationService.instance
          .prepareMgt7(company, 2024)
          .copyWith(cin: '');
      final errors = Mgt7PreparationService.instance.validateMgt7(form);
      expect(errors.any((e) => e.field == 'cin'), isTrue);
    });

    test('multiple errors returned for multiple violations', () {
      final company = _makeCompany(directors: []);
      final form = Mgt7PreparationService.instance
          .prepareMgt7(company, 2024)
          .copyWith(
            cin: '',
            agmDate: DateTime(2024, 11, 1),
          );
      final errors = Mgt7PreparationService.instance.validateMgt7(form);
      expect(errors.length, greaterThan(1));
    });
  });
}
