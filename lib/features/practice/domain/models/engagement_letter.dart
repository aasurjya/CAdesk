import 'package:ca_app/features/practice/domain/models/fee_structure.dart';

/// Immutable ICAI-compliant engagement letter record.
class EngagementLetter {
  const EngagementLetter({
    required this.letterId,
    required this.clientName,
    required this.clientPan,
    required this.scope,
    required this.feeStructure,
    required this.startDate,
    required this.endDate,
    required this.signatoryName,
    required this.membershipNumber,
    required this.firmName,
    required this.firmRegistrationNumber,
  });

  /// Unique letter identifier.
  final String letterId;

  /// Client's full legal name.
  final String clientName;

  /// Client's Permanent Account Number (PAN).
  final String clientPan;

  /// Scope of services to be provided.
  final List<String> scope;

  /// Fee arrangement for this engagement.
  final FeeStructure feeStructure;

  /// Date from which services commence.
  final DateTime startDate;

  /// Date on which the engagement period ends.
  final DateTime endDate;

  /// Name of the CA signing this letter.
  final String signatoryName;

  /// ICAI membership number of the signing CA.
  final String membershipNumber;

  /// Name of the CA firm.
  final String firmName;

  /// ICAI firm registration number (required for ICAI compliance).
  final String firmRegistrationNumber;

  EngagementLetter copyWith({
    String? letterId,
    String? clientName,
    String? clientPan,
    List<String>? scope,
    FeeStructure? feeStructure,
    DateTime? startDate,
    DateTime? endDate,
    String? signatoryName,
    String? membershipNumber,
    String? firmName,
    String? firmRegistrationNumber,
  }) {
    return EngagementLetter(
      letterId: letterId ?? this.letterId,
      clientName: clientName ?? this.clientName,
      clientPan: clientPan ?? this.clientPan,
      scope: scope ?? this.scope,
      feeStructure: feeStructure ?? this.feeStructure,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      signatoryName: signatoryName ?? this.signatoryName,
      membershipNumber: membershipNumber ?? this.membershipNumber,
      firmName: firmName ?? this.firmName,
      firmRegistrationNumber:
          firmRegistrationNumber ?? this.firmRegistrationNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EngagementLetter &&
        other.letterId == letterId &&
        other.clientName == clientName &&
        other.clientPan == clientPan &&
        other.signatoryName == signatoryName &&
        other.membershipNumber == membershipNumber &&
        other.firmName == firmName &&
        other.firmRegistrationNumber == firmRegistrationNumber &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(
    letterId,
    clientName,
    clientPan,
    signatoryName,
    membershipNumber,
    firmName,
    firmRegistrationNumber,
    startDate,
    endDate,
  );
}
