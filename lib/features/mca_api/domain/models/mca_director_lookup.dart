/// Approval status of a director on the MCA portal.
enum McaDirectorStatus {
  approved,
  disqualified,
  deactivated,
}

/// Immutable result of a DIN lookup on the MCA portal.
class McaDirectorLookup {
  const McaDirectorLookup({
    required this.din,
    required this.directorName,
    required this.nationality,
    required this.status,
    required this.associatedCompanies,
    this.dateOfBirth,
    this.fatherName,
  });

  /// 8-digit Director Identification Number.
  final String din;

  final String directorName;

  /// Nullable — may not be returned by all MCA responses.
  final DateTime? dateOfBirth;

  /// Nullable — may not be disclosed.
  final String? fatherName;

  final String nationality;
  final McaDirectorStatus status;

  /// List of CINs of companies the director is associated with.
  final List<String> associatedCompanies;

  /// Derived: true when [status] is [McaDirectorStatus.disqualified].
  bool get isDisqualified => status == McaDirectorStatus.disqualified;

  McaDirectorLookup copyWith({
    String? din,
    String? directorName,
    DateTime? dateOfBirth,
    String? fatherName,
    String? nationality,
    McaDirectorStatus? status,
    List<String>? associatedCompanies,
  }) {
    return McaDirectorLookup(
      din: din ?? this.din,
      directorName: directorName ?? this.directorName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      fatherName: fatherName ?? this.fatherName,
      nationality: nationality ?? this.nationality,
      status: status ?? this.status,
      associatedCompanies: associatedCompanies ?? this.associatedCompanies,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is McaDirectorLookup &&
        other.din == din &&
        other.directorName == directorName &&
        other.dateOfBirth == dateOfBirth &&
        other.fatherName == fatherName &&
        other.nationality == nationality &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(
        din,
        directorName,
        dateOfBirth,
        fatherName,
        nationality,
        status,
      );
}
