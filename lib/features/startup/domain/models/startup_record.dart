/// Immutable data-layer model for a Startup India / DPIIT registration record.
class StartupRecord {
  const StartupRecord({
    required this.id,
    required this.clientId,
    required this.dpiitNumber,
    required this.incorporationDate,
    required this.sectorCategory,
    required this.recognitionStatus,
    this.section80IacEligible = false,
    this.section56ExemptEligible = false,
    this.notes,
  });

  final String id;
  final String clientId;

  /// DPIIT recognition number (e.g. "DIPP12345").
  final String dpiitNumber;

  final DateTime incorporationDate;

  /// Sector / industry category (e.g. "fintech", "agritech", "healthtech").
  final String sectorCategory;

  /// Recognition status (e.g. 'recognised', 'pending', 'rejected', 'expired').
  final String recognitionStatus;

  /// Whether the startup qualifies for Section 80-IAC tax holiday.
  final bool section80IacEligible;

  /// Whether the startup qualifies for Section 56(2)(viib) angel-tax exemption.
  final bool section56ExemptEligible;

  final String? notes;

  StartupRecord copyWith({
    String? id,
    String? clientId,
    String? dpiitNumber,
    DateTime? incorporationDate,
    String? sectorCategory,
    String? recognitionStatus,
    bool? section80IacEligible,
    bool? section56ExemptEligible,
    String? notes,
  }) {
    return StartupRecord(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      dpiitNumber: dpiitNumber ?? this.dpiitNumber,
      incorporationDate: incorporationDate ?? this.incorporationDate,
      sectorCategory: sectorCategory ?? this.sectorCategory,
      recognitionStatus: recognitionStatus ?? this.recognitionStatus,
      section80IacEligible: section80IacEligible ?? this.section80IacEligible,
      section56ExemptEligible:
          section56ExemptEligible ?? this.section56ExemptEligible,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartupRecord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'StartupRecord(id: $id, clientId: $clientId, '
      'dpiitNumber: $dpiitNumber, recognitionStatus: $recognitionStatus)';
}
