/// Detailed director information for MGT-7 annual return filing.
class DirectorDetail {
  const DirectorDetail({
    required this.din,
    required this.name,
    required this.designation,
    required this.dateOfAppointment,
    this.dateOfCessation,
    this.shareholding = 0.0,
  });

  /// Director Identification Number — 8-digit unique identifier.
  final String din;
  final String name;
  final String designation;
  final DateTime dateOfAppointment;

  /// Null if the director is still on the board.
  final DateTime? dateOfCessation;

  /// Percentage of shareholding held by this director (0–100).
  final double shareholding;

  bool get isActive => dateOfCessation == null;

  DirectorDetail copyWith({
    String? din,
    String? name,
    String? designation,
    DateTime? dateOfAppointment,
    DateTime? dateOfCessation,
    double? shareholding,
  }) {
    return DirectorDetail(
      din: din ?? this.din,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      dateOfAppointment: dateOfAppointment ?? this.dateOfAppointment,
      dateOfCessation: dateOfCessation ?? this.dateOfCessation,
      shareholding: shareholding ?? this.shareholding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DirectorDetail &&
        other.din == din &&
        other.name == name &&
        other.designation == designation &&
        other.dateOfAppointment == dateOfAppointment &&
        other.dateOfCessation == dateOfCessation &&
        other.shareholding == shareholding;
  }

  @override
  int get hashCode => Object.hash(
    din,
    name,
    designation,
    dateOfAppointment,
    dateOfCessation,
    shareholding,
  );
}
