import 'package:ca_app/features/mca/domain/models/company.dart';
import 'package:ca_app/features/mca/domain/models/director_detail.dart';
import 'package:ca_app/features/mca/domain/models/mgt7_return.dart';
import 'package:ca_app/features/mca/domain/models/validation_error.dart';

/// Stateless service for preparing and validating MGT-7 Annual Returns
/// under Section 92 of the Companies Act 2013.
///
/// Usage:
/// ```dart
/// final svc = Mgt7PreparationService.instance;
/// final form = svc.prepareMgt7(company, 2024);
/// final errors = svc.validateMgt7(form);
/// ```
class Mgt7PreparationService {
  Mgt7PreparationService._();

  static final Mgt7PreparationService instance = Mgt7PreparationService._();

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Build an [Mgt7Return] skeleton from the given [company] data.
  ///
  /// Converts existing [Director] entries to [DirectorDetail] records.
  /// Shareholding pattern, KMP, meetings, and penalties start empty
  /// and must be populated by the caller before filing.
  Mgt7Return prepareMgt7(Company company, int financialYear) {
    final directorDetails = company.directors
        .map(
          (d) => DirectorDetail(
            din: d.din,
            name: d.name,
            designation: d.designation,
            dateOfAppointment: d.appointmentDate,
            shareholding: 0.0,
          ),
        )
        .toList();

    return Mgt7Return(
      cin: company.cin,
      companyName: company.companyName,
      registeredOffice: company.registeredAddress,
      financialYear: financialYear,
      shareholdingPattern: const [],
      directors: directorDetails,
      keyManagerialPersonnel: const [],
      meetings: const [],
      penalties: const [],
    );
  }

  /// Validate an [Mgt7Return] and return a list of [ValidationError]s.
  ///
  /// Returns an empty list when the form is valid.
  ///
  /// Checks performed:
  /// - CIN must be non-empty
  /// - At least one director must be present with a non-empty DIN
  /// - AGM must be on or before September 30 for March FY-end companies
  List<ValidationError> validateMgt7(Mgt7Return form) {
    final errors = <ValidationError>[];

    if (form.cin.trim().isEmpty) {
      errors.add(
        const ValidationError(field: 'cin', message: 'CIN is required'),
      );
    }

    if (form.directors.isEmpty) {
      errors.add(
        const ValidationError(
          field: 'directors',
          message: 'At least one director is required',
        ),
      );
    } else {
      final hasBadDin = form.directors.any((d) => d.din.trim().isEmpty);
      if (hasBadDin) {
        errors.add(
          const ValidationError(
            field: 'directors',
            message: 'All directors must have a valid DIN',
          ),
        );
      }
    }

    if (form.agmDate != null) {
      final agm = form.agmDate!;
      // For March FY-end: AGM must be on or before September 30
      final agmDeadline = DateTime(agm.year, 9, 30);
      if (agm.isAfter(agmDeadline)) {
        errors.add(
          ValidationError(
            field: 'agmDate',
            message:
                'AGM must be held on or before September 30 for March '
                'financial year-end companies. AGM date: '
                '${agm.toIso8601String()}',
          ),
        );
      }
    }

    return errors;
  }
}
