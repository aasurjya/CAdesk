/// Status of a PAN as returned by the TRACES PAN verification API.
///
/// - [valid]    — PAN exists and is active (TRACES status code "E")
/// - [invalid]  — PAN does not exist or format is wrong (code "I")
/// - [inactive] — PAN exists but is inactive, e.g. Aadhaar not linked (code "A")
/// - [deleted]  — PAN has been deleted from ITD records (code "X")
enum PanStatus { valid, invalid, inactive, deleted }

/// Immutable result of a TRACES PAN verification call.
///
/// All fields are populated from the ITD/TRACES API response.
/// [dateOfBirth] is optional — the API may omit it for privacy reasons.
class TracesPanVerification {
  const TracesPanVerification({
    required this.pan,
    required this.name,
    required this.status,
    required this.aadhaarLinked,
    required this.verifiedAt,
    this.dateOfBirth,
  });

  /// The PAN that was verified (upper-case, 10 characters).
  final String pan;

  /// Name of the PAN holder as recorded in ITD.
  final String name;

  /// Verification status from the TRACES API.
  final PanStatus status;

  /// Whether Aadhaar is seeded/linked to this PAN in ITD records.
  final bool aadhaarLinked;

  /// Date-of-birth string in the format returned by TRACES (dd/MM/yyyy),
  /// or `null` when the API does not include it.
  final String? dateOfBirth;

  /// UTC timestamp at which this verification was performed.
  final DateTime verifiedAt;

  /// Returns a new [TracesPanVerification] with selected fields replaced.
  TracesPanVerification copyWith({
    String? pan,
    String? name,
    PanStatus? status,
    bool? aadhaarLinked,
    String? dateOfBirth,
    DateTime? verifiedAt,
  }) {
    return TracesPanVerification(
      pan: pan ?? this.pan,
      name: name ?? this.name,
      status: status ?? this.status,
      aadhaarLinked: aadhaarLinked ?? this.aadhaarLinked,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TracesPanVerification &&
        other.pan == pan &&
        other.name == name &&
        other.status == status &&
        other.aadhaarLinked == aadhaarLinked &&
        other.dateOfBirth == dateOfBirth &&
        other.verifiedAt == verifiedAt;
  }

  @override
  int get hashCode => Object.hash(
        pan,
        name,
        status,
        aadhaarLinked,
        dateOfBirth,
        verifiedAt,
      );
}
