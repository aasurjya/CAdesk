import 'package:ca_app/features/mca_api/domain/models/mca_company_lookup.dart';

/// Immutable summary of a director attached to a company.
class Director {
  const Director({
    required this.din,
    required this.name,
    required this.designation,
    this.appointmentDate,
  });

  /// 8-digit Director Identification Number.
  final String din;

  final String name;

  /// e.g. "Managing Director", "Independent Director".
  final String designation;

  final DateTime? appointmentDate;

  Director copyWith({
    String? din,
    String? name,
    String? designation,
    DateTime? appointmentDate,
  }) {
    return Director(
      din: din ?? this.din,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      appointmentDate: appointmentDate ?? this.appointmentDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Director &&
          runtimeType == other.runtimeType &&
          din == other.din &&
          name == other.name &&
          designation == other.designation &&
          appointmentDate == other.appointmentDate;

  @override
  int get hashCode => Object.hash(din, name, designation, appointmentDate);
}

/// Full company details fetched from the MCA portal.
class CompanyDetails {
  const CompanyDetails({
    required this.cin,
    required this.name,
    required this.registeredAddress,
    required this.authorizedCapital,
    required this.paidUpCapital,
    required this.directors,
    required this.status,
    required this.incorporationDate,
    required this.roc,
  });

  /// 21-character Corporate Identification Number.
  final String cin;

  final String name;

  final String registeredAddress;

  /// Authorized share capital in paise.
  final int authorizedCapital;

  /// Paid-up share capital in paise.
  final int paidUpCapital;

  final List<Director> directors;

  final McaCompanyStatus status;

  final DateTime incorporationDate;

  final String roc;

  CompanyDetails copyWith({
    String? cin,
    String? name,
    String? registeredAddress,
    int? authorizedCapital,
    int? paidUpCapital,
    List<Director>? directors,
    McaCompanyStatus? status,
    DateTime? incorporationDate,
    String? roc,
  }) {
    return CompanyDetails(
      cin: cin ?? this.cin,
      name: name ?? this.name,
      registeredAddress: registeredAddress ?? this.registeredAddress,
      authorizedCapital: authorizedCapital ?? this.authorizedCapital,
      paidUpCapital: paidUpCapital ?? this.paidUpCapital,
      directors: directors ?? this.directors,
      status: status ?? this.status,
      incorporationDate: incorporationDate ?? this.incorporationDate,
      roc: roc ?? this.roc,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyDetails &&
          runtimeType == other.runtimeType &&
          cin == other.cin &&
          name == other.name &&
          registeredAddress == other.registeredAddress &&
          authorizedCapital == other.authorizedCapital &&
          paidUpCapital == other.paidUpCapital &&
          status == other.status &&
          incorporationDate == other.incorporationDate &&
          roc == other.roc;

  @override
  int get hashCode => Object.hash(
    cin,
    name,
    registeredAddress,
    authorizedCapital,
    paidUpCapital,
    status,
    incorporationDate,
    roc,
  );
}
