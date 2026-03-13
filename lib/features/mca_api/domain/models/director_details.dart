import 'package:ca_app/features/mca_api/domain/models/mca_director_lookup.dart';

/// Full director profile returned by an MCA director search.
class DirectorDetails {
  const DirectorDetails({
    required this.din,
    required this.name,
    required this.nationality,
    required this.status,
    required this.associatedCompanies,
    this.dob,
    this.fatherName,
    this.address,
  });

  /// 8-digit Director Identification Number.
  final String din;

  final String name;

  final String nationality;

  final McaDirectorStatus status;

  /// List of CINs the director is currently associated with.
  final List<String> associatedCompanies;

  final DateTime? dob;
  final String? fatherName;
  final String? address;

  DirectorDetails copyWith({
    String? din,
    String? name,
    String? nationality,
    McaDirectorStatus? status,
    List<String>? associatedCompanies,
    DateTime? dob,
    String? fatherName,
    String? address,
  }) {
    return DirectorDetails(
      din: din ?? this.din,
      name: name ?? this.name,
      nationality: nationality ?? this.nationality,
      status: status ?? this.status,
      associatedCompanies: associatedCompanies ?? this.associatedCompanies,
      dob: dob ?? this.dob,
      fatherName: fatherName ?? this.fatherName,
      address: address ?? this.address,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DirectorDetails &&
          runtimeType == other.runtimeType &&
          din == other.din &&
          name == other.name &&
          nationality == other.nationality &&
          status == other.status &&
          dob == other.dob &&
          fatherName == other.fatherName &&
          address == other.address;

  @override
  int get hashCode =>
      Object.hash(din, name, nationality, status, dob, fatherName, address);
}
