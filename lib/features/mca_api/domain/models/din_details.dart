import 'package:ca_app/features/mca_api/domain/models/mca_director_lookup.dart';

/// Immutable DIN (Director Identification Number) details.
class DinDetails {
  const DinDetails({
    required this.din,
    required this.name,
    required this.nationality,
    required this.status,
    this.dob,
  });

  /// 8-digit Director Identification Number.
  final String din;

  final String name;

  final String nationality;

  final McaDirectorStatus status;

  /// Date of birth — may be absent when not disclosed by the MCA API.
  final DateTime? dob;

  DinDetails copyWith({
    String? din,
    String? name,
    String? nationality,
    McaDirectorStatus? status,
    DateTime? dob,
  }) {
    return DinDetails(
      din: din ?? this.din,
      name: name ?? this.name,
      nationality: nationality ?? this.nationality,
      status: status ?? this.status,
      dob: dob ?? this.dob,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DinDetails &&
          runtimeType == other.runtimeType &&
          din == other.din &&
          name == other.name &&
          nationality == other.nationality &&
          status == other.status &&
          dob == other.dob;

  @override
  int get hashCode => Object.hash(din, name, nationality, status, dob);
}
